---
--- [INPUT]: 依赖 Game.STG.Render.StgBackgroundLayer 的单层渲染能力，
---          消费 Game.STG.DataCenter.StgLevelConfig 解析出的 cfg.backgroundLayers
--- [OUTPUT]: 对外提供 StgBackgroundRenderer.New / :Setup / :Update / :Destroy
--- [POS]: Game/STG/Render 的背景层总管，被 UI.UIPlaneBattle.View.UIPlaneBattleView 持有；
---        对上承接关卡配置，对下批量驱动 StgBackgroundLayer
--- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
---
--- STG 背景层运行时渲染（多层总管）
--- 职责：读 cfg.backgroundLayers，按 orderInLayer 从后往前创建各层，统一驱动 Update/Destroy。
--- 自身不碰贴图/装饰物的具体逻辑，那些在 StgBackgroundLayer 里。
---
--- 层级：UGUI 的渲染顺序由 sibling index 决定（越靠前越先绘制、越在下层），
--- 所以把各层按 orderInLayer 升序创建，天然形成"远景在下、近景在上"的叠放。
---
--- 用法（见 UIPlaneBattleView:_BuildStgCallbacks 的 OnLevelLoaded）：
---   local renderer = StgBackgroundRenderer.New(backgroundRootTf)
---   renderer:Setup(cfg, function() return cfg.basicScroll.baseSpeed end)
---   renderer:Update(dt)   -- 每帧
---   renderer:Destroy()
---
---@class StgBackgroundRenderer
local StgBackgroundRenderer = {}
StgBackgroundRenderer.__index = StgBackgroundRenderer

local StgBackgroundLayer = require "Game.STG.Render.StgBackgroundLayer"

--- @param parentTransform userdata 背景根节点（UIPlaneBattleView 的 BackgroundRoot）
function StgBackgroundRenderer.New(parentTransform)
    local self = setmetatable({}, StgBackgroundRenderer)
    self.parentTf = parentTransform
    self.layers = {}
    return self
end

--- 按关卡配置重建所有背景层（重进关卡时会再调一次，内部先清旧层）
--- @param cfg table StgLevelConfig.Load 的返回值
--- @param scrollSpeedProvider fun():number 当前基础滚动速度（像素/秒）
function StgBackgroundRenderer:Setup(cfg, scrollSpeedProvider)
    self:ClearLayers()

    if cfg == nil or cfg.backgroundLayers == nil or #cfg.backgroundLayers == 0 then
        -- 没配背景层是合法情况（比如纯黑底关卡），不报错，只记一行便于排查"为什么没背景"
        Logger.Log('#STG# 关卡未配置背景层 levelId=' .. tostring(cfg and cfg.levelId))
        return
    end

    -- 按 orderInLayer 升序：小的先建（sibling index 靠前）= 画在下层 = 远景
    -- 复制一份再排序，不改动 StgLevelConfig 的缓存表（cfg 是跨关卡复用的缓存对象）
    local sorted = {}
    for _, layer in ipairs(cfg.backgroundLayers) do
        table.insert(sorted, layer)
    end
    table.sort(sorted, function(a, b)
        return (tonumber(a.orderInLayer) or 0) < (tonumber(b.orderInLayer) or 0)
    end)

    for _, layerCfg in ipairs(sorted) do
        -- TODO: layerType == "player" 的层（编辑器里指"跟随主机移动的层"）目前与 parallax 同样处理，
        -- 等策划确认跟随规则（跟随幅度/是否只跟 X）后再在 StgBackgroundLayer 里分流
        local layer = StgBackgroundLayer.New(self.parentTf, layerCfg, scrollSpeedProvider)
        table.insert(self.layers, layer)
    end

    Logger.Log('#STG# 背景层就绪 levelId=' .. tostring(cfg.levelId) .. ' layers=' .. #self.layers)
end

function StgBackgroundRenderer:Update(dt)
    for _, layer in ipairs(self.layers) do
        layer:Update(dt)
    end
end

--- 清空所有层但保留 renderer 自身（可继续 Setup 重建）。
--- 供 View 在切换关卡/退回选关时复位背景表现，语义上区别于 Destroy 的"整个不要了"。
function StgBackgroundRenderer:ClearLayers()
    for _, layer in ipairs(self.layers) do
        layer:Destroy()
    end
    self.layers = {}
end

function StgBackgroundRenderer:Destroy()
    self:ClearLayers()
    self.parentTf = nil
end

return StgBackgroundRenderer
