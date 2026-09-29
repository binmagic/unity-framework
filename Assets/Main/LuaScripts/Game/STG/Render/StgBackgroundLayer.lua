---
--- [INPUT]: 依赖 Game.STG.Const 的资源路径约定，依赖全局 Mathf 的 GetRandomByWeight/RandomFloat，
---          依赖 CS.UnityEngine 的 GameObject/RectTransform/Image
--- [OUTPUT]: 对外提供 StgBackgroundLayer.New / :Update / :Destroy
--- [POS]: Game/STG/Render 的单层背景渲染器，被 StgBackgroundRenderer 批量持有；
---        与 Spawner/ 的区别是这里只管背景表现，不产出战斗实体
--- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
---
--- STG 背景层运行时渲染（单层）
--- 消费 StgLevelConfig.Load() 解析出的 cfg.backgroundLayers[i]，做两件事：
---   ① 循环贴图带（useTileLoop）：多张图首尾相接铺成无限带，随卷轴下移，滚出屏底的挪到带顶
---   ② 散布装饰物（enableScatterSpawn）：按随机间隔 + 加权规则在屏幕上方撒装饰物，出屏回收
---
--- 算法与编辑器预览 Assets/Editor/STG/Preview/StgPreviewTileStrip.cs 保持一致，
--- 保证"编辑器里预览到的滚动效果"和"真机跑出来的"是同一套接带规则。两处关键约定必须对齐：
---   - tile 高度取贴图原生高度（编辑器不导出 tileWorldHeight 字段，见下方 _ResolveTileHeight 说明）
---   - 铺带时盖过屏顶后仍强制再铺一张预备图（否则单张图高于屏幕时会出现整屏黑块，
---     即 commit 462ae91 "修复无缝滚动黑屏" 修的那个 bug）
---
--- 坐标系：本模块工作在 UGUI 参考分辨率像素空间（750x1625，锚点在父节点底部中心），
--- 与编辑器预览的世界单位空间（ScreenTopY=6）不同，故所有画幅常量在此重新定义。
---
--- 用法：
---   local layer = StgBackgroundLayer.New(parentTf, layerConfig, function() return 300 end)
---   layer:Update(dt)
---   layer:Destroy()
---
---@class StgBackgroundLayer
local StgBackgroundLayer = {}
StgBackgroundLayer.__index = StgBackgroundLayer

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

--- 画幅常量（对齐 UIPlaneBattleView 的参考分辨率 750x1625，锚点在底部中心）
local SCREEN_HALF_W  = 375
local SCREEN_TOP_Y   = 1625   -- 屏幕顶边（锚点在底部，所以顶边就是全高）
local SCREEN_BOTTOM_Y= 0      -- 屏幕底边
local SCREEN_HEIGHT  = SCREEN_TOP_Y - SCREEN_BOTTOM_Y

--- 铺带时的防御上限，防止贴图高度异常（接近 0）导致 while 死循环。
--- 对齐 StgPreviewTileStrip.cs 的 guard < 64。
local FILL_GUARD_MAX = 64

--- 贴图高度异常阈值：低于此值视为导入设置有问题，退化为按屏幕高度兜底
local MIN_VALID_TILE_HEIGHT = 1

--- 散布装饰物出屏回收的下边界（略低于屏底，留出完全移出视野的余量）
local SCATTER_RECYCLE_Y = -300

--- 贴图原生尺寸缓存：path -> { w = number, h = number }
--- 模块级缓存，跨层/跨关卡复用，避免重复读 sprite.rect
local SpriteSizeCache = {}

--- ---------------------------------------------------------------
--- 构造
--- ---------------------------------------------------------------

--- @param parentTransform userdata 父节点（BackgroundRoot 下的层节点）
--- @param layerConfig table cfg.backgroundLayers[i]，字段见 StgLevelConfig.ParseBackgroundLayers
--- @param scrollSpeedProvider fun():number 返回当前基础滚动速度（像素/秒）
function StgBackgroundLayer.New(parentTransform, layerConfig, scrollSpeedProvider)
    local self = setmetatable({}, StgBackgroundLayer)
    self.cfg = layerConfig or {}
    self.scrollSpeedProvider = scrollSpeedProvider

    -- 每层自己一个根节点，销毁时整棵子树一起清掉，不残留节点
    local root = GameObject("BgLayer_" .. tostring(self.cfg.layerId or "?"), RectTransform)
    root.transform:SetParent(parentTransform, false)
    local rootRt = root:GetComponent(RectTransform)
    rootRt.anchorMin = Vector2(0.5, 0)
    rootRt.anchorMax = Vector2(0.5, 0)
    rootRt.pivot     = Vector2(0.5, 0)
    rootRt.anchoredPosition = Vector2(0, 0)
    rootRt.sizeDelta = Vector2(SCREEN_HALF_W * 2, SCREEN_HEIGHT)

    self.rootGo = root
    self.rootTf = root.transform

    -- 贴图带状态
    self.tiles = {}          -- { { go, rt, height, pathIndex } }，顺序不保证（回收会打乱）
    self.nextPathIndex = 1   -- 下一次接到带尾时取 tileSpritePaths 的第几个（顺序循环，1-based）

    -- 散布装饰物状态（手写池，对齐 BulletPool 的 freeList/active 写法）
    self.scatterActive = {}  -- { { go, rt } }
    self.scatterFree   = {}  -- GameObject[]
    self.scatterTimer  = 0   -- 倒计时，<=0 时生成一个

    if self.cfg.useTileLoop then
        self:_BuildTileStrip()
    end

    return self
end

--- ---------------------------------------------------------------
--- 贴图带：铺带 / 滚动 / 回收接续
--- ---------------------------------------------------------------

--- 初始铺满画幅：从屏底往上铺，且必须在屏顶之上多留出一整张"预备图"的高度。
---
--- 为什么是"屏顶 + 一张图高"而不是"盖过屏顶就停"：
--- tile 的回收条件是"整张都滚到屏底之下"（不能更早，否则会把还看得见的图抽走）。
--- 也就是说带底那张图在被回收接到带顶之前，最多会先往下走一整张图的高度，
--- 这段时间带顶是在往下掉的——如果初始只铺到刚好盖过屏顶，带顶就会掉到屏顶之下，
--- 屏幕顶部露出一条没有任何 tile 覆盖的空带（单张图高度小于屏高时必然发生）。
--- 所以要满足 (n-1) * 图高 >= 屏高，即多铺一张预备图，让带顶永远不低于屏顶。
--- 这也是编辑器预览 StgPreviewTileStrip.BuildStrips 里"强制至少再铺一张"的同一个道理
--- （commit 462ae91 "修复无缝滚动黑屏"），那边贴图高度远大于画幅所以只需 2 张兜底，
--- 这里是像素空间、单张图往往小于屏高，必须按高度算够。
function StgBackgroundLayer:_BuildTileStrip()
    local paths = self.cfg.tileSpritePaths
    if paths == nil or #paths == 0 then
        Logger.LogError('#STG# 背景层开启了 useTileLoop 但 tileSpritePaths 为空 layerId='
            .. tostring(self.cfg.layerId))
        return
    end

    local cursorY = SCREEN_BOTTOM_Y
    local maxTileHeight = 0
    local guard = 0
    while guard < FILL_GUARD_MAX do
        guard = guard + 1
        local tile = self:_CreateTile(cursorY)
        if tile == nil then
            break
        end
        cursorY = cursorY + tile.height
        if tile.height > maxTileHeight then
            maxTileHeight = tile.height
        end
        -- 预备高度按"见过的最高一张"算：各张图高度可以不一样，用最高的才安全
        if cursorY >= SCREEN_TOP_Y + maxTileHeight and #self.tiles >= 2 then
            break
        end
    end
end

--- 取下一个非空贴图路径（顺序循环）。
--- 空字符串槽位（编辑器里刚加的行、还没拖贴图）直接跳过，当它在数组里不存在一样——
--- 不能让"未配置"生成一个整屏高度的占位块插进无缝带里。
--- @return number|nil pathIndex, string|nil path
function StgBackgroundLayer:_TakeNextPath()
    local paths = self.cfg.tileSpritePaths
    local count = #paths
    for _ = 1, count do
        local candidate = self.nextPathIndex
        self.nextPathIndex = (self.nextPathIndex % count) + 1
        local p = paths[candidate]
        if p ~= nil and p ~= "" then
            return candidate, p
        end
    end
    return nil, nil
end

--- 解析 tile 高度。
--- 优先用贴图原生高度：编辑器侧的接带定位就是按原生高度算的（StgPreviewTileStrip.CreateTile），
--- 而 tileWorldHeight 这个字段虽然 StgLevelConfig 会解析，但编辑器 StgLevelJsonIO 从不导出它，
--- 恒为默认值 0 —— 所以它只能当兜底，不能当主来源，否则高度全是 0，整条带会叠在一起。
--- @return number height
function StgBackgroundLayer:_ResolveTileHeight(img, path)
    local cached = SpriteSizeCache[path]
    if cached ~= nil and cached.h > MIN_VALID_TILE_HEIGHT then
        return cached.h
    end

    local h = 0
    local sprite = img.sprite
    if sprite ~= nil and not IsNull(sprite) then
        local rect = sprite.rect
        h = rect.height
        SpriteSizeCache[path] = { w = rect.width, h = h }
    end

    if h > MIN_VALID_TILE_HEIGHT then
        return h
    end

    -- 贴图还没加载完（LoadSprite 内部可能走异步）或导入设置异常：先用配置值，再退到屏幕高度。
    -- 这里不能返回 0，否则 _BuildTileStrip 的 cursorY 不前进，会一直铺到 guard 上限。
    local cfgH = tonumber(self.cfg.tileWorldHeight) or 0
    if cfgH > MIN_VALID_TILE_HEIGHT then
        return cfgH
    end
    return SCREEN_HEIGHT
end

--- 创建一个 tile，bottomY 是它的底边位置
--- @return table|nil tile
function StgBackgroundLayer:_CreateTile(bottomY)
    local pathIndex, path = self:_TakeNextPath()
    if pathIndex == nil then
        Logger.LogError('#STG# 背景层 tileSpritePaths 全是空槽位，该层不会显示任何内容 layerId='
            .. tostring(self.cfg.layerId))
        return nil
    end

    local go = GameObject("Tile_" .. tostring(pathIndex), RectTransform)
    go.transform:SetParent(self.rootTf, false)

    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)

    local img = go:AddComponent(Image)
    img.raycastTarget = false   -- 背景不吃点击，否则会挡住主机拖动
    img:LoadSprite(path)

    local height = self:_ResolveTileHeight(img, path)
    -- 横向铺满屏宽（纵向保持原生高度，保证接带严密无缝）
    rt.sizeDelta = Vector2(SCREEN_HALF_W * 2, height)
    rt.anchoredPosition = Vector2(0, bottomY + height * 0.5)

    local tile = { go = go, rt = rt, height = height, pathIndex = pathIndex }
    table.insert(self.tiles, tile)
    return tile
end

--- 当前带里最高的 tile 顶边
--- @return number|nil
function StgBackgroundLayer:_GetHighestTopY()
    local highest = nil
    for _, t in ipairs(self.tiles) do
        if not IsNull(t.rt) then
            local top = t.rt.anchoredPosition.y + t.height * 0.5
            if highest == nil or top > highest then
                highest = top
            end
        end
    end
    return highest
end

--- 把滚出屏底的 tile 挪到带顶，并换成顺序里的下一张图。
--- 复用节点本身（改 sprite + 改位置），不销毁重建，避免每次接带都产生 GC。
function StgBackgroundLayer:_RecycleAndAppend()
    for i = #self.tiles, 1, -1 do
        local tile = self.tiles[i]
        if IsNull(tile.rt) then
            table.remove(self.tiles, i)
        else
            local topY = tile.rt.anchoredPosition.y + tile.height * 0.5
            if topY < SCREEN_BOTTOM_Y then
                -- 先算接续位置（此时本 tile 还在列表里，但它已经在屏底外，不会是最高的那个）
                local highestTopY = self:_GetHighestTopY()
                local pathIndex, path = self:_TakeNextPath()
                if pathIndex == nil or highestTopY == nil then
                    -- 没有可用贴图，或者带里已经没有有效 tile：保持现状，交给下一帧
                    break
                end

                tile.pathIndex = pathIndex
                tile.go.name = "Tile_" .. tostring(pathIndex)
                local img = tile.go:GetComponent(Image)
                if img ~= nil and not IsNull(img) then
                    img:LoadSprite(path)
                    tile.height = self:_ResolveTileHeight(img, path)
                end
                tile.rt.sizeDelta = Vector2(SCREEN_HALF_W * 2, tile.height)
                tile.rt.anchoredPosition = Vector2(0, highestTopY + tile.height * 0.5)
            end
        end
    end
end

--- ---------------------------------------------------------------
--- 散布装饰物：定时生成 / 推进 / 出屏回收
--- ---------------------------------------------------------------

--- 按权重选一条散布规则
--- @return table|nil rule
function StgBackgroundLayer:_PickWeightedRule()
    local rules = self.cfg.scatterRules
    if rules == nil or #rules == 0 then
        return nil
    end

    local weights = {}
    local total = 0
    for i, r in ipairs(rules) do
        local w = math.max(0, tonumber(r.weight) or 0)
        weights[i] = w
        total = total + w
    end
    -- 全 0 权重时 GetRandomByWeight 会返回 1，这里显式对齐编辑器的"退化取第一条"
    if total <= 0 then
        return rules[1]
    end
    return rules[Mathf.GetRandomByWeight(weights)]
end

--- 与已有装饰物做一次距离检测，太近就这轮不生成（避免视觉重叠堆在一起）
function StgBackgroundLayer:_IsOverlapping(x, y)
    local radius = tonumber(self.cfg.scatterOverlapCheckRadius) or 0
    if radius <= 0 then
        return false
    end
    local rSqr = radius * radius
    for _, item in ipairs(self.scatterActive) do
        if not IsNull(item.rt) then
            local pos = item.rt.anchoredPosition
            local dx, dy = pos.x - x, pos.y - y
            if (dx * dx + dy * dy) < rSqr then
                return true
            end
        end
    end
    return false
end

--- 从池里取一个装饰物节点（没有就新建）
function StgBackgroundLayer:_AcquireScatterGo()
    local go = table.remove(self.scatterFree)
    if go ~= nil and not IsNull(go) then
        go:SetActive(true)
        return go
    end

    go = GameObject("Scatter", RectTransform)
    go.transform:SetParent(self.rootTf, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0)
    rt.anchorMax = Vector2(0.5, 0)
    rt.pivot     = Vector2(0.5, 0.5)
    local img = go:AddComponent(Image)
    img.raycastTarget = false
    return go
end

--- 生成一个散布装饰物
function StgBackgroundLayer:_SpawnScatter()
    local rule = self:_PickWeightedRule()
    if rule == nil then
        return
    end
    local path = rule.prefabPath
    if path == nil or path == "" then
        return
    end

    local scale = math.max(0.2, Mathf.RandomFloat(
        tonumber(rule.sizeRangeMin) or 1,
        tonumber(rule.sizeRangeMax) or 1))

    local go = self:_AcquireScatterGo()
    local rt = go:GetComponent(RectTransform)
    local img = go:GetComponent(Image)
    if img ~= nil and not IsNull(img) then
        img:LoadSprite(path)
    end

    -- 尺寸：贴图原生尺寸 × 随机缩放。没缓存到原生尺寸时退化为固定基准，
    -- 避免 sizeDelta 是 0 导致装饰物完全看不见
    local cached = SpriteSizeCache[path]
    local baseW, baseH = 120, 120
    if cached == nil then
        local sprite = img ~= nil and not IsNull(img) and img.sprite or nil
        if sprite ~= nil and not IsNull(sprite) then
            local rect = sprite.rect
            SpriteSizeCache[path] = { w = rect.width, h = rect.height }
            baseW, baseH = rect.width, rect.height
        end
    else
        baseW, baseH = cached.w, cached.h
    end
    local w, h = baseW * scale, baseH * scale
    rt.sizeDelta = Vector2(w, h)

    -- X 位置：allowPartialOffscreen=false 时收缩范围，保证整张贴图不越界
    local halfRange = SCREEN_HALF_W
    if rule.allowPartialOffscreen == false then
        halfRange = math.max(0, SCREEN_HALF_W - w * 0.5)
    end
    local x = Mathf.RandomFloat(-halfRange, halfRange)
    local y = SCREEN_TOP_Y + (tonumber(self.cfg.scatterSpawnYOffset) or 0)

    if self:_IsOverlapping(x, y) then
        -- 这轮放弃，节点回池（不强行挪位，下一轮重新 roll 更自然）
        go:SetActive(false)
        table.insert(self.scatterFree, go)
        return
    end

    rt.anchoredPosition = Vector2(x, y)
    table.insert(self.scatterActive, { go = go, rt = rt })
end

--- 推进散布装饰物：计时生成 + 跟随滚动 + 出屏回收
function StgBackgroundLayer:_UpdateScatter(dt, delta)
    -- 已有装饰物跟着背景一起下移
    for i = #self.scatterActive, 1, -1 do
        local item = self.scatterActive[i]
        if IsNull(item.rt) then
            table.remove(self.scatterActive, i)
        else
            local pos = item.rt.anchoredPosition
            local newY = pos.y - delta
            if newY < SCATTER_RECYCLE_Y then
                item.go:SetActive(false)
                table.insert(self.scatterFree, item.go)
                table.remove(self.scatterActive, i)
            else
                item.rt.anchoredPosition = Vector2(pos.x, newY)
            end
        end
    end

    -- 到点生成（同屏数量达上限时只是不生成，计时照走，对齐编辑器预览行为）
    local maxActive = tonumber(self.cfg.scatterMaxActive) or 0
    if #self.scatterActive >= maxActive then
        return
    end

    self.scatterTimer = self.scatterTimer - dt
    if self.scatterTimer > 0 then
        return
    end
    self.scatterTimer = Mathf.RandomFloat(
        tonumber(self.cfg.scatterIntervalMin) or 1,
        tonumber(self.cfg.scatterIntervalMax) or 2)

    self:_SpawnScatter()
end

--- ---------------------------------------------------------------
--- 每帧驱动
--- ---------------------------------------------------------------

function StgBackgroundLayer:Update(dt)
    if IsNull(self.rootGo) then
        return
    end

    local baseSpeed = 0
    if self.scrollSpeedProvider ~= nil then
        baseSpeed = tonumber(self.scrollSpeedProvider()) or 0
    end
    -- 本层位移量 = 基础速度 × 本层视差系数
    local delta = baseSpeed * (tonumber(self.cfg.speedCoefficient) or 1) * dt

    if self.cfg.useTileLoop and #self.tiles > 0 then
        for _, tile in ipairs(self.tiles) do
            if not IsNull(tile.rt) then
                local pos = tile.rt.anchoredPosition
                tile.rt.anchoredPosition = Vector2(pos.x, pos.y - delta)
            end
        end
        self:_RecycleAndAppend()
    end

    if self.cfg.enableScatterSpawn then
        self:_UpdateScatter(dt, delta)
    end
end

--- ---------------------------------------------------------------
--- 清理
--- ---------------------------------------------------------------

--- 整层销毁：所有 tile / 装饰物都挂在 rootGo 下，销毁根节点即可全部带走。
--- 逐个置 nil 是为了让 Lua 侧引用尽快断开，不依赖 GC 时机。
function StgBackgroundLayer:Destroy()
    if self.rootGo ~= nil and not IsNull(self.rootGo) then
        self.rootGo:Destroy()
    end
    self.rootGo = nil
    self.rootTf = nil
    self.tiles = {}
    self.scatterActive = {}
    self.scatterFree = {}
    self.cfg = {}
    self.scrollSpeedProvider = nil
end

return StgBackgroundLayer
