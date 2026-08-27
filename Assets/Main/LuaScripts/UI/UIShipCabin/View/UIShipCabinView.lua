---
--- 隆隆冒险号 船舱主界面 — View
--- 船体剖面布局：
---   顶部：资源栏
---   中部：船体剖面 + 房间(舱室)列表，点击房间打开详情面板
---   左侧：挑战/建造队列悬浮按钮
---   右侧：背包/邮件/商店/一键领取悬浮按钮
---   底部上方：当前培养进度条
---   最底部：Tab 导航栏
--- 节点不存在时静默跳过，Prefab 补充节点后自动生效
---@class UIShipCabinView : UIBaseView
local UIShipCabinView = BaseClass("UIShipCabinView", UIBaseView)
local base = UIBaseView

local function SafeAddComponent(self, componentType, nodeName)
    if self.transform:Find(nodeName) == nil then return nil end
    return self:AddComponent(componentType, nodeName)
end

--- 在运行时实例化的 GameObject 上绑组件（走 AddComponent 的 gameObject 重载）
--- subPath 为 nil 时绑在 go 自身，否则绑在其子节点上
--- 节点不存在时返回 nil，不报错
local function SafeAddComponentByGo(self, componentType, go, subPath)
    if go == nil then return nil end
    local target = go
    if subPath ~= nil then
        local tf = go.transform:Find(subPath)
        if tf == nil then return nil end
        target = tf.gameObject
    end
    return self:AddComponent(componentType, target)
end

local function FormatTime(seconds)
    if seconds <= 0 then return "" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%02d:%02d:%02d", h, m, s)
    else
        return string.format("%02d:%02d", m, s)
    end
end

local function FormatNumber(num)
    if num >= 100000000 then
        return string.format("%.1f亿", num / 100000000)
    elseif num >= 10000 then
        return string.format("%.1f万", num / 10000)
    else
        return tostring(num)
    end
end

--- 顶部资源栏项数（参考原版 6 项两行排布，须与 prefab 的 ResItem_1..N 一致）
local TOP_RES_COUNT = 6

--- 左侧悬浮按钮列（参考原版 7 项，须与 prefab 的 LeftFloat 子节点一致）
--- key 用于点击分发，node 是 prefab 节点名
local LEFT_FLOAT_ENTRIES = {
    { key = "level",     node = "BtnLevel"     },
    { key = "list",      node = "BtnList"      },
    { key = "challenge", node = "BtnChallenge" },
    { key = "queue",     node = "BtnQueue"     },
    { key = "tip",       node = "BtnTip"       },
    { key = "notice",    node = "BtnNotice"    },
    { key = "more",      node = "BtnMore"      },
}

--- 底部聊天流行数（参考原版两行，须与 prefab 的 TxtLine_1..N 一致）
local CHAT_LINE_COUNT = 2

--- 导航栏选中项的凸起效果（参考原版：选中项橙色向上凸起并放大）
local TAB_SELECTED_SCALE = 1.12   -- 放大倍数
local TAB_SELECTED_RISE  = 10     -- 向上位移（逻辑px）

--- 右侧悬浮按钮列（参考原版 10 项，须与 prefab 的 RightFloat 子节点一致）
--- 前 4 项是带时效的活动入口，中间 5 项功能圆钮，最后一项一键领取胶囊
local RIGHT_FLOAT_ENTRIES = {
    { key = "activity",   node = "BtnActivity"   },
    { key = "giftPack",   node = "BtnGiftPack"   },
    { key = "treasure",   node = "BtnTreasure"   },
    { key = "event",      node = "BtnEvent"      },
    { key = "reset",      node = "BtnReset"      },
    { key = "speedUp",    node = "BtnSpeedUp"    },
    { key = "arena",      node = "BtnArena"      },
    { key = "recruit",    node = "BtnRecruit"    },
    { key = "shop",       node = "BtnShop"       },
    { key = "collectAll", node = "BtnCollectAll" },
}

--- 资源图标所在目录（Ctrl 只给 sprite 名，这里拼完整路径加载）
local RES_ICON_DIR = "Assets/Main/Sprites/ItemIcons/"

--- 顶部资源栏配色：满仓转红提示玩家去升仓库，正常态用 prefab 原本的白字/淡蓝
local RES_COLOR_NORMAL = Color(1, 1, 1, 1)
local RES_COLOR_FULL   = Color(1, 0.35, 0.32, 1)      -- 红 #FF5A52
local RES_COLOR_RATE   = Color(0.62, 0.78, 0.95, 1)   -- 淡蓝，与速率副标签原色一致

--- 格子 prefab（运行时按 GetRoomList 条数动态实例化到 Rooms/Viewport/Content 下）
local ROOM_CELL_PREFAB = "Assets/Main/Prefabs/UI/UIShipCabin/ShipRoomCell.prefab"

--- 滚动容器内容节点路径
local CONTENT_PATH = "ShipBody/Rooms/Viewport/Content"

--- buildId → 内景 prefab 的映射（唯一真相源，详情面板也走这份）
local RoomSceneMap = require "UI.UIShipCabin.RoomSceneMap"

--- ---------------------------------------------------------------
--- 生命周期
--- ---------------------------------------------------------------

function UIShipCabinView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

--- 渲染排序：船舱作为主视图背景层，与 UIShipBackground 保持一致
--- ScreenSpaceOverlay + sortingOrder=-1，让主界面 HUD 浮在船舱之上
function UIShipCabinView:ResortOrder(baseLayerOrder)
    if self.canvas then
        self.canvas.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceOverlay
        self.canvas.sortingOrder = -1
        self.lastSortingOrder = -1
    end
end

function UIShipCabinView:OnEnable()
    base.OnEnable(self)
    self:RefreshAll()
    self:RefreshTabBar(self.curTabIndex or 1)
    self:_StartCountdownTimer()
end

function UIShipCabinView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.ShipBuildingUpgradeStart,  self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipBuildingUpgradeFinish, self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipBuildingUpgradeDone,   self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockStart,   self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockFinish,  self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipBuildingUnlockDone,    self.OnShipDataChanged)
    self:AddUIListener(EventId.ShipResourceUpdated,       self.OnResourceChanged)
    self:AddUIListener(EventId.ShipPlayerInfoUpdated,     self.OnShipDataChanged)
end

function UIShipCabinView:OnRemoveListener()
    self:RemoveUIListener(EventId.ShipBuildingUpgradeStart,  self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeFinish, self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipBuildingUpgradeDone,   self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockStart,   self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockFinish,  self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipBuildingUnlockDone,    self.OnShipDataChanged)
    self:RemoveUIListener(EventId.ShipResourceUpdated,       self.OnResourceChanged)
    self:RemoveUIListener(EventId.ShipPlayerInfoUpdated,     self.OnShipDataChanged)
    base.OnRemoveListener(self)
end

function UIShipCabinView:OnDestroy()
    self:_StopCountdownTimer()
    self:DataDestroy()
    base.OnDestroy(self)
end

--- ---------------------------------------------------------------
--- 组件绑定
--- ---------------------------------------------------------------

function UIShipCabinView:ComponentDefine()
    -- 顶部资源栏：参考原版 6 项两行排布
    -- 结构 TopBar/ResArea/Row_1..2/ResItem_1..6，每项 = Icon + TxtCount + TxtRate
    self.resItems = {}
    for i = 1, TOP_RES_COUNT do
        local row  = (i <= 3) and 1 or 2
        local path = string.format("TopBar/ResArea/Row_%d/ResItem_%d", row, i)
        if self.transform:Find(path) then
            self.resItems[i] = {
                icon  = SafeAddComponent(self, UIImage,             path .. "/Icon"),
                count = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtCount"),
                rate  = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtRate"),
                root  = self.transform:Find(path),
            }
        end
    end

    -- 玩家头像框（等级角标）+ 尊享金库入口
    self.txtPlayerLevel = SafeAddComponent(self, UITextMeshProUGUIEx, "TopBar/PlayerAvatar/LevelBadge/TxtLevel")
    self.btnAvatar      = SafeAddComponent(self, UIButton, "TopBar/PlayerAvatar")
    self.btnVault       = SafeAddComponent(self, UIButton, "TopBar/BtnVault")
    if self.btnAvatar then self.btnAvatar:SetOnClick(function() self:OnClickAvatar() end) end
    if self.btnVault  then self.btnVault:SetOnClick(function()  self:OnClickVault()  end) end

    -- 船体剖面房间格子：不再依赖预置节点，运行时按数据条数动态生成
    -- 每个 cell 的组件引用缓存在 self.roomCells[i] 里，见 EnsureRoomCells
    self.contentNode = self.transform:Find(CONTENT_PATH)
    if self.contentNode == nil then
        Logger.LogWarning("UIShipCabinView ComponentDefine 找不到滚动容器 path=" .. CONTENT_PATH)
    end
    self.roomCells    = {}   -- [i] = { go, btn, txtName, txtLevel, txtCountdown, imgLock, unlockHint, imgCollect, fill, sceneRoot, buildId, sceneName }
    self.roomCellCount = 0   -- 已实例化的格子数
    self.pendingCells  = {}  -- 正在异步加载中的格子索引，防重复实例化

    -- 左侧悬浮按钮列（参考原版 7 项入口，带倒计时/红点角标）
    -- 每项结构：Btn* / TxtLabel + TxtCountdown + RedDot(TxtNum)
    self.leftFloatBtns = {}
    for _, cfg in ipairs(LEFT_FLOAT_ENTRIES) do
        local path = "LeftFloat/" .. cfg.node
        if self.transform:Find(path) then
            local entry = {
                key       = cfg.key,
                btn       = SafeAddComponent(self, UIButton,            path),
                countdown = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtCountdown"),
                redDot    = self.transform:Find(path .. "/RedDot"),
                redDotNum = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/RedDot/TxtNum"),
            }
            if entry.btn then
                local k = cfg.key
                entry.btn:SetOnClick(function() self:OnClickLeftFloat(k) end)
            end
            self.leftFloatBtns[cfg.key] = entry
        end
    end

    -- 右侧悬浮按钮列（参考原版 10 项：4 活动入口 + 5 功能圆钮 + 一键领取胶囊）
    -- 结构同左侧：Btn* / TxtLabel + TxtCountdown + RedDot(TxtNum)
    self.rightFloatBtns = {}
    for _, cfg in ipairs(RIGHT_FLOAT_ENTRIES) do
        local path = "RightFloat/" .. cfg.node
        if self.transform:Find(path) then
            local entry = {
                key       = cfg.key,
                btn       = SafeAddComponent(self, UIButton,            path),
                countdown = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtCountdown"),
                redDot    = self.transform:Find(path .. "/RedDot"),
                redDotNum = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/RedDot/TxtNum"),
            }
            if entry.btn then
                local k = cfg.key
                entry.btn:SetOnClick(function() self:OnClickRightFloat(k) end)
            end
            self.rightFloatBtns[cfg.key] = entry
        end
    end
    -- 一键领取走已有的真实业务流程，不用统一提示
    local collectEntry = self.rightFloatBtns["collectAll"]
    if collectEntry and collectEntry.btn then
        collectEntry.btn:SetOnClick(function() self:OnClickCollectAll() end)
    end

    -- 底部聊天流（参考原版：两行半透明黑底 + 右侧礼物图标，位于导航栏上方）
    self.chatFeed  = self.transform:Find("ChatFeed")
    self.chatLines = {}
    for i = 1, CHAT_LINE_COUNT do
        self.chatLines[i] = SafeAddComponent(self, UITextMeshProUGUIEx,
            string.format("ChatFeed/TxtLine_%d", i))
    end
    self.btnChatFeed = SafeAddComponent(self, UIButton, "ChatFeed")
    self.btnGift     = SafeAddComponent(self, UIButton, "ChatFeed/BtnGift")
    if self.btnChatFeed then self.btnChatFeed:SetOnClick(function() self:OnClickChatFeed() end) end
    if self.btnGift then self.btnGift:SetOnClick(function() self:OnClickGift() end) end

    -- 底部进度条
    self.txtProgressDesc = SafeAddComponent(self, UITextMeshProUGUIEx, "ProgressBar/TxtDesc")
    self.txtProgressNum  = SafeAddComponent(self, UITextMeshProUGUIEx, "ProgressBar/TxtNum")
    self.imgProgressFill = SafeAddComponent(self, UIImage, "ProgressBar/Fill")

    -- 底部 Tab 导航栏
    -- 参考原版：选中项橙底 + 向上凸起放大，未选中蓝底；图标在上文字在下
    self.tabBtns     = {}
    self.tabIcons    = {}   -- ImgIcon（选中/未选中变色）
    self.tabLabels   = {}   -- TxtLabel（选中/未选中变色）
    self.tabSelLines = {}   -- ImgSelected（顶部高光条，仅选中显示）
    self.tabPills    = {}   -- BgPill（底板胶囊，选中橙/未选中蓝）
    self.tabRects    = {}   -- 按钮 RectTransform
    self.tabParts    = {}   -- [i] = { {rt, baseX, baseY}, ... } 按钮内子节点及其原始位置（凸起位移用）
    local tabNames = { "BtnShip", "BtnGrow", "BtnExplore", "BtnGuild", "BtnWorld" }
    for i, tabName in ipairs(tabNames) do
        local path = "TabBar/" .. tabName
        self.tabBtns[i]     = SafeAddComponent(self, UIButton,            path)
        self.tabIcons[i]    = SafeAddComponent(self, UIImage,             path .. "/ImgIcon")
        self.tabLabels[i]   = SafeAddComponent(self, UITextMeshProUGUIEx, path .. "/TxtLabel")
        self.tabSelLines[i] = SafeAddComponent(self, UIImage,             path .. "/ImgSelected")
        self.tabPills[i]    = SafeAddComponent(self, UIImage,             path .. "/BgPill")
        local node = self.transform:Find(path)
        if node then
            self.tabRects[i] = node:GetComponent(typeof(CS.UnityEngine.RectTransform))

            -- 记录按钮内各子节点的原始位置，供 RefreshTabBar 做凸起位移用。
            -- 必须移动子节点：TabBar 的 HorizontalLayoutGroup 会覆写按钮自身的位置。
            -- 含 ImgSelected：它锚在按钮顶边，必须和 BgPill 一起上移，
            -- 否则胶囊凸起后高光条留在原处，会陷进橙色胶囊内部
            -- 变成"按钮上叠一截淡黄(255,216,114)"。
            -- prefab 里它的 pos.y 已改为 0（贴齐按钮顶边、不外溢），
            -- 上移 TAB_SELECTED_RISE 后正好贴着凸起后的胶囊顶边。
            local parts = {}
            for _, sub in ipairs({ "BgPill", "ImgIcon", "TxtLabel", "ImgSelected" }) do
                local t = node:Find(sub)
                if t then
                    local prt = t:GetComponent(typeof(CS.UnityEngine.RectTransform))
                    if prt then
                        parts[#parts + 1] = {
                            rt    = prt,
                            baseX = prt.anchoredPosition.x,
                            baseY = prt.anchoredPosition.y,
                        }
                    end
                end
            end
            self.tabParts[i] = parts
        end
        if self.tabBtns[i] then
            local idx = i
            self.tabBtns[i]:SetOnClick(function() self:OnClickTab(idx) end)
        end
    end
    self.curTabIndex = 1
end

function UIShipCabinView:DataDefine()
    self.roomList = {}
    self.countdownTimer = nil
end

function UIShipCabinView:DataDestroy()
    self.roomList = {}
    -- 格子实例由框架的 RemoveAllAsyncObject 统一销毁（GameObjectInstantiateAsync 创建的都在册），
    -- 这里只清引用表，避免 OnDestroy 后回调里拿到已销毁对象
    self.roomCells     = {}
    self.roomCellCount = 0
    self.pendingCells  = {}
    self.contentNode   = nil
end

--- ---------------------------------------------------------------
--- 格子动态生成 + RoomScene 缩略图加载
--- ---------------------------------------------------------------

--- 确保已实例化 count 个格子（只增不减，多余的隐藏）
--- 异步加载，加载完成后回调 RefreshRoom 填数据
function UIShipCabinView:EnsureRoomCells(count)
    if self.contentNode == nil then return end

    for i = 1, count do
        if self.roomCells[i] == nil and not self.pendingCells[i] then
            self.pendingCells[i] = true
            self:CreateRoomCell(i)
        end
    end

    -- 多出来的格子隐藏（数据变少时）
    for i = count + 1, self.roomCellCount do
        local cell = self.roomCells[i]
        if cell and cell.go then
            cell.go:SetActive(false)
        end
    end
end

--- 实例化单个格子
function UIShipCabinView:CreateRoomCell(index)
    self:GameObjectInstantiateAsync(ROOM_CELL_PREFAB, function(request)
        self.pendingCells[index] = nil

        if not request or request.isError or not request.gameObject then
            Logger.LogWarning("UIShipCabinView CreateRoomCell 格子加载失败 index=" .. tostring(index))
            return
        end

        -- 容器可能已被销毁（界面关闭）
        local content = self.transform and self.transform:Find(CONTENT_PATH)
        if content == nil then return end

        local go = request.gameObject
        go.name = "RoomCell_" .. tostring(index)
        go.transform:SetParent(content, false)
        go.transform.localScale = CS.UnityEngine.Vector3.one

        -- GridLayoutGroup 控制位置和尺寸，这里只需保证顺序正确
        go.transform:SetSiblingIndex(index - 1)

        local cell = {
            go           = go,
            btn          = SafeAddComponentByGo(self, UIButton, go),
            txtName      = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "BottomBar/TxtRoomName"),
            txtBonus     = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "BottomBar/TxtBonus"),
            txtLevel     = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "LevelBadge/TxtLevel"),
            txtCountdown = SafeAddComponentByGo(self, UITextMeshProUGUIEx, go, "TxtCountdown"),
            imgLock      = go.transform:Find("LockMask"),
            unlockHint   = go.transform:Find("UnlockHint"),
            imgCollect   = go.transform:Find("ImgCollect"),
            fill         = SafeAddComponentByGo(self, UIImage, go, "ProgressBar/Fill"),
            sceneRoot    = go.transform:Find("RoomScene"),
            sceneName    = nil,
        }
        self.roomCells[index] = cell
        if index > self.roomCellCount then
            self.roomCellCount = index
        end

        -- 立刻填一次数据（数据可能已就绪）
        local room = self.roomList and self.roomList[index]
        if room then
            self:RefreshRoom(index, room)
        end
    end)
end

--- 把 RoomScene 内景加载进格子（按 buildId 选内景，同内景不重复加载）
function UIShipCabinView:LoadRoomSceneIntoCell(index, buildId)
    local cell = self.roomCells[index]
    if cell == nil or cell.sceneRoot == nil then return end

    local sceneName = RoomSceneMap.GetSceneName(buildId)
    if cell.sceneName == sceneName then return end   -- 已是目标内景，跳过
    cell.sceneName = sceneName

    local sceneRoot = cell.sceneRoot
    -- 清掉旧内景实例（保留 prefab 自带的 ImgRoomBg/ImgProp/ImgCharacter）
    for i = sceneRoot.childCount - 1, 0, -1 do
        local child = sceneRoot:GetChild(i)
        if string.find(child.name, "RoomScene_", 1, true) then
            CS.UnityEngine.Object.Destroy(child.gameObject)
        end
    end

    local prefabPath = RoomSceneMap.PREFAB_DIR .. sceneName .. ".prefab"
    self:GameObjectInstantiateAsync(prefabPath, function(request)
        if not request or request.isError or not request.gameObject then
            Logger.LogWarning("UIShipCabinView RoomScene加载失败 scene=" .. sceneName)
            return
        end

        local curCell = self.roomCells[index]
        if curCell == nil or curCell.sceneRoot == nil then return end

        local inst = request.gameObject
        inst.transform:SetParent(curCell.sceneRoot, false)
        inst.transform:SetSiblingIndex(0)   -- 垫在最底，ImgProp/ImgCharacter 叠上面

        local rt = inst:GetComponent(typeof(CS.UnityEngine.RectTransform))
        if not rt then
            rt = inst:AddComponent(typeof(CS.UnityEngine.RectTransform))
        end
        rt.anchorMin        = CS.UnityEngine.Vector2.zero
        rt.anchorMax        = CS.UnityEngine.Vector2.one
        rt.offsetMin        = CS.UnityEngine.Vector2.zero
        rt.offsetMax        = CS.UnityEngine.Vector2.zero
        rt.localScale       = CS.UnityEngine.Vector3.one
        rt.anchoredPosition = CS.UnityEngine.Vector2.zero

        -- 内景纯展示，不能吃掉格子的点击
        local images = inst:GetComponentsInChildren(typeof(CS.UnityEngine.UI.Image), true)
        for j = 0, images.Length - 1 do
            images[j].raycastTarget = false
        end
        local rawImages = inst:GetComponentsInChildren(typeof(CS.UnityEngine.UI.RawImage), true)
        for j = 0, rawImages.Length - 1 do
            rawImages[j].raycastTarget = false
        end
    end)
end

--- ---------------------------------------------------------------
--- 刷新
--- ---------------------------------------------------------------

function UIShipCabinView:RefreshAll()
    self:RefreshTopResources()
    self:RefreshPlayerInfo()
    self:RefreshRooms()
    self:RefreshProgress()
    self:RefreshQueueBadge()
end

--- 顶部资源栏（6 项：图标 + 数值 + 速率副标签）
function UIShipCabinView:RefreshTopResources()
    local resources = self.ctrl:GetTopResources()
    for i = 1, TOP_RES_COUNT do
        local cell = self.resItems[i]
        local res  = resources[i]
        if cell then
            -- 数据不足时隐藏多余条目，避免显示占位值
            if cell.root then
                cell.root.gameObject:SetActive(res ~= nil)
            end
            if res then
                if cell.count then
                    cell.count:SetText(FormatNumber(res.count))
                    -- 满仓时数值转红，配合下方"已满"副标签
                    cell.count:SetColor(res.isFull and RES_COLOR_FULL or RES_COLOR_NORMAL)
                end
                -- 副标签：满仓时提示"已满"，否则显示速率（参考原版 "N/分钟"）
                if cell.rate then
                    if res.isFull then
                        cell.rate:SetActive(true)
                        cell.rate:SetText("已满")
                        cell.rate:SetColor(RES_COLOR_FULL)
                    elseif res.ratePerMin and res.ratePerMin > 0 then
                        cell.rate:SetActive(true)
                        cell.rate:SetText(FormatNumber(res.ratePerMin) .. "/分钟")
                        cell.rate:SetColor(RES_COLOR_RATE)
                    else
                        cell.rate:SetActive(false)
                    end
                end
                self:_LoadResIcon(i, res.icon)
            end
        end
    end
end

--- 加载资源图标（Ctrl 只给 sprite 名，这里拼路径）
--- UIImage:LoadSprite 内部已按 spritePath 去重，重复调用同一路径不会重复加载
function UIShipCabinView:_LoadResIcon(index, spriteName)
    local cell = self.resItems[index]
    if cell == nil or cell.icon == nil or spriteName == nil then return end
    cell.icon:LoadSprite(RES_ICON_DIR .. spriteName .. ".png")
    cell.icon:SetEnable(true)   -- prefab 里 Icon 默认 enabled=false（无图时不显示灰块）
end

--- 玩家信息（头像等级角标）
function UIShipCabinView:RefreshPlayerInfo()
    if self.ctrl.GetPlayerInfo == nil then return end
    local info = self.ctrl:GetPlayerInfo()
    if info == nil then return end
    if self.txtPlayerLevel then
        self.txtPlayerLevel:SetText(tostring(info.level or 1))
    end
end

--- 船体房间：按数据条数生成格子并逐个刷新
function UIShipCabinView:RefreshRooms()
    self.roomList = self.ctrl:GetRoomList()

    self:EnsureRoomCells(#self.roomList)

    for i = 1, #self.roomList do
        local cell = self.roomCells[i]
        if cell and cell.go then
            cell.go:SetActive(true)
            self:RefreshRoom(i, self.roomList[i])
        end
        -- cell 为 nil 说明还在异步加载中，加载完成的回调里会自己刷一次
    end
end

function UIShipCabinView:RefreshRoom(index, room)
    local cell = self.roomCells[index]
    if cell == nil then return end

    cell.buildId = room.buildId

    -- 内景缩略图（按 buildId 选，内部会跳过重复加载）
    self:LoadRoomSceneIntoCell(index, room.buildId)

    -- 名称
    if cell.txtName then
        cell.txtName:SetText(room.name)
    end

    -- 产出加成文字（prefab 里有 "+50%" 占位，必须显式覆盖）
    -- 未解锁时留空，解锁后显示战力
    if cell.txtBonus then
        if room.unlocked and room.power and room.power > 0 then
            cell.txtBonus:SetActive(true)
            cell.txtBonus:SetText(string.format("战力%d", room.power))
        else
            cell.txtBonus:SetActive(false)
        end
    end

    -- 等级角标
    if cell.txtLevel then
        if room.unlocked then
            cell.txtLevel:SetActive(true)
            cell.txtLevel:SetText(string.format("Lv.%d", room.level))
        else
            cell.txtLevel:SetActive(false)
        end
    end

    -- 锁定遮罩 + 可解锁提示（两者互斥）
    -- 未解锁且条件已满足 → 显示"可解锁"呼吸提示，不显示锁遮罩
    -- 未解锁且条件不满足 → 显示锁遮罩
    -- 解锁中/待领取 → 两者都不显示（此时格子走倒计时/可领取显示），
    --   否则玩家会看到"可解锁"提示而重复点击
    local canUnlockNow = false
    if not room.unlocked and not room.isUpgrading and not room.isDone then
        canUnlockNow = self.ctrl:GetUnlockCondition(room.buildId) and true or false
    end
    if cell.imgLock then
        -- 未解锁就压暗（解锁中也算未解锁），只有"可解锁"时让位给呼吸提示
        cell.imgLock.gameObject:SetActive(not room.unlocked and not canUnlockNow)
    end
    if cell.unlockHint then
        cell.unlockHint.gameObject:SetActive(canUnlockNow)
    end

    -- 倒计时 / 状态文字
    if cell.txtCountdown then
        if room.isUpgrading then
            cell.txtCountdown:SetActive(true)
            cell.txtCountdown:SetText(FormatTime(room.remainSeconds))
        elseif room.isDone then
            cell.txtCountdown:SetActive(true)
            cell.txtCountdown:SetText("可领取")
        else
            cell.txtCountdown:SetActive(false)
        end
    end

    -- 升级进度条：仅升级中显示
    if cell.fill then
        local barRoot = cell.go.transform:Find("ProgressBar")
        if barRoot then
            barRoot.gameObject:SetActive(room.isUpgrading)
        end
        if room.isUpgrading and room.totalSeconds and room.totalSeconds > 0 then
            local passed = room.totalSeconds - room.remainSeconds
            cell.fill.fillAmount = math.max(0, math.min(passed / room.totalSeconds, 1))
        else
            cell.fill.fillAmount = 0
        end
    end

    -- 可领取角标
    if cell.imgCollect then
        cell.imgCollect.gameObject:SetActive(room.isDone)
    end

    -- 点击回调
    if cell.btn then
        local buildId = room.buildId
        cell.btn:SetOnClick(function()
            self:OnClickRoom(buildId)
        end)
    end
end

--- 底部进度条
function UIShipCabinView:RefreshProgress()
    local progress = self.ctrl:GetBottomProgress()

    local progressRoot = self.transform:Find("ProgressBar")
    if progressRoot then
        progressRoot.gameObject:SetActive(progress.hasTask)
    end

    if not progress.hasTask then return end

    if self.txtProgressDesc then
        self.txtProgressDesc:SetText(progress.desc)
    end
    if self.txtProgressNum then
        self.txtProgressNum:SetText(string.format("%d/%d", progress.curLevel, progress.targetLevel))
    end
    if self.imgProgressFill then
        local ratio = 0
        if progress.targetLevel > 0 then
            ratio = math.min(progress.curLevel / progress.targetLevel, 1)
        end
        self.imgProgressFill.fillAmount = ratio
    end
end

--- ---------------------------------------------------------------
--- 按钮回调
--- ---------------------------------------------------------------

--- 点击房间，按状态分发：
---   待领取     → 直接领取成果
---   可解锁     → 直接解锁（不弹确认弹窗）
---   条件不足   → 只提示原因
---   已解锁     → 打开详情面板
function UIShipCabinView:OnClickRoom(buildId)
    local room = self:_FindRoom(buildId)

    -- 待领取优先：解锁完成时 unlocked 仍为 false，若放在解锁分支之后会被拦住
    if room ~= nil and room.isDone then
        local ok, err, doneType = self.ctrl:CollectBuilding(buildId)
        if ok then
            local word = (doneType == "unlock") and "解锁" or "升级"
            UIUtil.ShowTips(string.format("%s %s完成", room.name or "舱室", word))
        else
            UIUtil.ShowTips((err ~= nil and err ~= "") and err or "领取失败")
        end
        return
    end

    if room ~= nil and not room.unlocked then
        local canUnlock, desc = self.ctrl:GetUnlockCondition(buildId)
        if canUnlock then
            -- 条件与资源都满足 → 直接解锁并提示，不弹确认弹窗
            -- （UIBuildingPanel 是为升级设计的，拿来做解锁确认布局会垮）
            local ok, err = self.ctrl:DoUnlock(buildId)
            if ok then
                UIUtil.ShowTips(string.format("%s 解锁中", room.name or "舱室"))
            else
                UIUtil.ShowTips((err ~= nil and err ~= "") and err or "解锁失败")
            end
        else
            -- 条件或资源不满足 → 只提示原因，不给入口
            local tip = (desc ~= nil and desc ~= "") and desc
                or string.format("%s 尚未解锁", room.name or "该舱室")
            UIUtil.ShowTips(tip)
        end
        return
    end
    self.ctrl:OpenRoomDetail(buildId)
end

--- 按 buildId 找 roomList 里的条目
function UIShipCabinView:_FindRoom(buildId)
    if self.roomList == nil then return nil end
    for _, room in ipairs(self.roomList) do
        if room.buildId == buildId then return room end
    end
    return nil
end

function UIShipCabinView:OnClickAvatar()
    UIUtil.ShowTips("玩家信息功能开发中")
end

function UIShipCabinView:OnClickVault()
    UIUtil.ShowTips("尊享金库功能开发中")
end

--- 左侧悬浮按钮点击分发
--- 这些入口对应的业务系统尚未接入，先统一提示；接入时在这里分发到各自流程
--- queue 已接入真实数据，不走这张表
local LEFT_FLOAT_TIPS = {
    level     = "玩家等级功能开发中",
    list      = "任务列表开发中",
    challenge = "挑战功能开发中",
    tip       = "提示功能开发中",
    notice    = "通知功能开发中",
    more      = "更多功能开发中",
}

function UIShipCabinView:OnClickLeftFloat(key)
    if key == "queue" then
        self:OnClickQueue()
        return
    end
    UIUtil.ShowTips(LEFT_FLOAT_TIPS[key] or "功能开发中")
end

--- 点建造队列：列出当前占用情况
---
--- 队列面板需要独立 prefab（+6 处窗口注册），这里先用 Tips 把队列内容如实报出来，
--- 让"有几条队列、谁在占、还剩多久"变成可见信息。prefab 就位后换成 OpenWindow。
function UIShipCabinView:OnClickQueue()
    if self.ctrl.GetQueueInfo == nil then
        UIUtil.ShowTips("建造队列开发中")
        return
    end

    local info = self.ctrl:GetQueueInfo()
    if info.unlocked <= 0 then
        UIUtil.ShowTips("暂无可用的建造队列")
        return
    end

    local lines = { string.format("建造队列 %d/%d", info.running, info.unlocked) }
    for _, slot in ipairs(info.slots) do
        if not slot.isUnlocked then
            table.insert(lines, string.format("队列%d：未解锁", slot.slotIndex))
        elseif slot.isIdle then
            table.insert(lines, string.format("队列%d：空闲", slot.slotIndex))
        elseif slot.isFinished then
            table.insert(lines, string.format("队列%d：%s 已完成，待领取", slot.slotIndex, slot.buildName))
        else
            table.insert(lines, string.format("队列%d：%s %s，剩余 %s",
                slot.slotIndex, slot.buildName, slot.actionDesc, FormatTime(slot.remainSeconds)))
        end
    end
    UIUtil.ShowTips(table.concat(lines, "\n"))
end

--- 刷新左侧建造队列按钮的角标
--- 红点数字 = 正在占用的队列数，倒计时 = 最先完成的那条队列
function UIShipCabinView:RefreshQueueBadge()
    local entry = self.leftFloatBtns and self.leftFloatBtns["queue"]
    if entry == nil or self.ctrl.GetQueueInfo == nil then return end

    local info = self.ctrl:GetQueueInfo()

    if entry.redDot then
        entry.redDot.gameObject:SetActive(info.running > 0)
    end
    if entry.redDotNum then
        entry.redDotNum:SetText(string.format("%d/%d", info.running, info.unlocked))
    end
    if entry.countdown then
        if info.nearestRemain > 0 then
            entry.countdown:SetActive(true)
            entry.countdown:SetText(FormatTime(info.nearestRemain))
        else
            entry.countdown:SetActive(false)
        end
    end
end

--- 右侧悬浮按钮点击分发
--- collectAll 在 ComponentDefine 里单独绑了真实业务流程，不走这里
local RIGHT_FLOAT_TIPS = {
    activity = "超值活动开发中",
    giftPack = "限时礼包开发中",
    treasure = "夺宝奇兵开发中",
    event    = "限时活动开发中",
    reset    = "复位功能开发中",
    speedUp  = "加速采集开发中",
    arena    = "竞技场开发中",
    recruit  = "招募功能开发中",
    shop     = "商店功能开发中",
}

function UIShipCabinView:OnClickRightFloat(key)
    UIUtil.ShowTips(RIGHT_FLOAT_TIPS[key] or "功能开发中")
end

function UIShipCabinView:OnClickChatFeed()
    UIUtil.ShowTips("聊天功能开发中")
end

function UIShipCabinView:OnClickGift()
    UIUtil.ShowTips("礼物功能开发中")
end

function UIShipCabinView:OnClickCollectAll()
    local collected = self.ctrl:CollectAll()
    if collected and collected > 0 then
        UIUtil.ShowTips(string.format("领取了 %d 个舱室的产出", collected))
        self:RefreshRooms()
    else
        UIUtil.ShowTips("暂无可领取产出")
    end
end

--- 刷新 TabBar 选中态
--- 参考原版：选中项橙底 + 向上凸起放大 + 顶部高光条 + 白字，
--- 未选中蓝底 + 灰字 + 原位不放大
function UIShipCabinView:RefreshTabBar(selectedIdx)
    -- 选中：橙底白字；未选中：蓝底灰字
    local pillActive   = Color(0.95, 0.62, 0.16, 1)     -- 橙 #F29E29
    local pillInactive = Color(0.16, 0.27, 0.44, 0.95)  -- 深蓝
    local textActive   = Color(1, 1, 1, 1)
    local textInactive = Color(0.62, 0.68, 0.78, 1)
    local iconActive   = Color(1, 1, 1, 1)
    local iconInactive = Color(0.55, 0.62, 0.72, 1)

    for i = 1, 5 do
        local isSelected = (i == selectedIdx)

        -- 注意：UIImage / UITextMeshProUGUIEx 只有 SetColor 方法，没有 color 属性。
        -- 写 `comp.color = x` 只是给 Lua table 塞字段，不会传到 Unity 组件，且不报错。
        if self.tabPills[i] then
            self.tabPills[i]:SetColor(isSelected and pillActive or pillInactive)
        end
        if self.tabIcons[i] then
            self.tabIcons[i]:SetColor(isSelected and iconActive or iconInactive)
        end
        if self.tabLabels[i] then
            self.tabLabels[i]:SetColor(isSelected and textActive or textInactive)
        end
        -- ImgSelected（顶部淡黄高光条）在本项目**始终不显示**。
        -- 它是 UIShipCabin.prefab 的 TabBar 独有装饰，而那个 TabBar 在 barrel 一直是
        -- 关闭状态（被主界面 ShipBottomBar 盖住），所以它的位置从没被校验过 ——
        -- 一旦显示就会探出 TabBar 顶边，露出一截淡黄(255,216,114)。
        -- barrel 的按钮只有 ImgIcon + Text、没有高光条，靠底板颜色区分选中态，这里照做。
        if self.tabSelLines[i] then
            self.tabSelLines[i].gameObject:SetActive(false)
        end

        -- 选中项向上凸起（参考图的核心视觉特征）
        --
        -- 只做位移、不做 localScale 缩放。原先按钮整体放大 TAB_SELECTED_SCALE，
        -- 会连带放大子节点的锚点偏移，产生两个可见瑕疵：
        --   1. TxtLabel 锚在按钮底边、pos.y=+10，放大后偏移变 11.2，
        --      选中项文字比其他四个低约 5px —— 看起来"没居中"
        --   2. ImgSelected 锚在按钮顶边（pivot 在上），放大+上移后顶到
        --      TabBar(高 116) 之外，淡黄高光条(255,216,114) 露出来成为一截黄色
        --
        -- 凸起：移动按钮的**子节点**，而不是按钮本身。
        --
        -- TabBar 挂着 HorizontalLayoutGroup，它每帧接管直接子级（BtnXxx）的位置，
        -- 所以对按钮写 anchoredPosition / offsetMin / offsetMax 都会被覆写掉
        -- （我试过这三种，全部无效）。孙节点不受布局组管辖，可以自由位移。
        local rt = self.tabRects[i]
        if rt then
            rt.localScale = CS.UnityEngine.Vector3.one
        end
        local rise = isSelected and TAB_SELECTED_RISE or 0
        local parts = self.tabParts and self.tabParts[i]
        if parts then
            for _, p in ipairs(parts) do
                p.rt.anchoredPosition = CS.UnityEngine.Vector2(p.baseX, p.baseY + rise)
            end
        end
    end
end

function UIShipCabinView:OnClickTab(tabIndex)
    -- 1=船舱(当前) 2=养成 3=探险 4=公会 5=世界
    if tabIndex == self.curTabIndex then return end
    self.curTabIndex = tabIndex
    self:RefreshTabBar(tabIndex)
    if tabIndex == 1 then
        return
    end
    UIUtil.ShowTips("该页签开发中")
end

--- ---------------------------------------------------------------
--- 事件监听
--- ---------------------------------------------------------------

function UIShipCabinView:OnShipDataChanged()
    self:RefreshRooms()
    self:RefreshProgress()
end

function UIShipCabinView:OnResourceChanged()
    self:RefreshTopResources()
end

--- ---------------------------------------------------------------
--- 倒计时定时器（刷新房间倒计时显示）
--- ---------------------------------------------------------------

function UIShipCabinView:_StartCountdownTimer()
    if self.countdownTimer then return end
    self.countdownTimer = TimerManager:GetInstance():GetTimer(1, self._OnCountdownTick, self, false, false, false)
    self.countdownTimer:Start()
end

function UIShipCabinView:_StopCountdownTimer()
    if self.countdownTimer then
        self.countdownTimer:Stop()
        self.countdownTimer = nil
    end
end

function UIShipCabinView:_OnCountdownTick()
    -- 队列角标的倒计时也要每秒走（它读的是队列槽位，与房间格子无关）
    self:RefreshQueueBadge()

    -- 只更新升级中房间的倒计时文字和进度条，避免全量刷新
    for i = 1, #self.roomList do
        local room = self.roomList[i]
        local cell = self.roomCells[i]
        if room and room.isUpgrading and cell then
            local mgr = DataCenter.ShipPlayerDataManager
            local buildData = mgr and mgr:GetMaxLevelBuilding(room.buildId)
            if buildData then
                local remain = buildData:GetRemainSeconds()
                if remain > 0 then
                    if cell.txtCountdown then
                        cell.txtCountdown:SetText(FormatTime(remain))
                    end
                    if cell.fill and room.totalSeconds and room.totalSeconds > 0 then
                        local passed = room.totalSeconds - remain
                        cell.fill.fillAmount = math.max(0, math.min(passed / room.totalSeconds, 1))
                    end
                else
                    -- 倒计时结束：状态已变（进入待领取），需全量刷新
                    self:RefreshRooms()
                    self:RefreshProgress()
                    break
                end
            end
        end
    end
end

--- ---------------------------------------------------------------
--- 关闭
--- ---------------------------------------------------------------

function UIShipCabinView:CloseSelf()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIShipCabin)
end

return UIShipCabinView
