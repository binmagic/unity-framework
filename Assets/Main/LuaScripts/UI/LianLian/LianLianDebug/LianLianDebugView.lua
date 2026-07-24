--[[
-- Debug 面板视图
-- 左上角开关按钮 + 模态空面板
--]]

local LianLianTheme = require "Game.LianLian.DataCenter.LianLianTheme"
local LianLianThemeElement = require "UI.LianLian.LianLianUnlock.LianLianThemeElement"

-- 取玩家数据（解锁态存 PlayerInfo.themeUnlock）
local function GetPlayer()
    return LuaEntry and LuaEntry.Player
end

-- 元素展示区网格布局参数
local PRE_THEME_ELEMENT = "Assets/Main/Prefabs/UI/LianLian/PreThemeElement.prefab"
local EL_COLS = 6       -- 每行元素数
local EL_CELL = 90      -- cell 尺寸
local EL_GAP = 12       -- 间距
local EL_START_X = -300 -- 第一列 x（相对 ElementArea 中心）
local EL_START_Y = 200  -- 第一行 y（相对 ElementArea 中心）

local LianLianDebugView = BaseClass("LianLianDebugView", UIBaseView)
local base = UIBaseView

-- 移动类型下拉项（显示名 → 传给逻辑的方向字符串；随机=nil）
local MOVE_TYPE_OPTIONS = {
    { label = "随机",     value = nil },
    { label = "无移动",   value = "" },
    { label = "上移",     value = "up" },
    { label = "下移",     value = "down" },
    { label = "左移",     value = "left" },
    { label = "右移",     value = "right" },
    { label = "左右分散", value = "divide_left_right" },
    { label = "上下分散", value = "divide_up_down" },
    { label = "左右聚拢", value = "flock_left_right" },
    { label = "上下聚拢", value = "flock_up_down" },
}

-- direction 字符串 → 下拉 index(0基)；随机/未知 → 0
local function DirectionToIndex(direction)
    if direction == nil then return 0 end
    for i, opt in ipairs(MOVE_TYPE_OPTIONS) do
        if opt.value == direction then
            return i - 1
        end
    end
    return 0
end

function LianLianDebugView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
end

function LianLianDebugView:ComponentDefine()
    self.toggleBtn = self:AddComponent(UIButton, "ToggleBtn")
    self.panel = self:AddComponent(UIBaseComponent, "Panel")
    self.closeBtn = self:AddComponent(UIButton, "Panel/Content/CloseBtn")

    -- 棋盘参数输入框 + Gen 按钮
    self.rowInput = self:AddComponent(UITMPInput, "Panel/Content/RowInput")
    self.colInput = self:AddComponent(UITMPInput, "Panel/Content/ColInput")
    self.layerInput = self:AddComponent(UITMPInput, "Panel/Content/LayerInput")
    self.moveTypeDropdown = self:AddComponent(UITMPDropdown, "Panel/Content/MoveTypeDropdown")
    self.themeDropdown = self:AddComponent(UITMPDropdown, "Panel/Content/ThemeDropdown")
    self.elementArea = self:AddComponent(UIBaseContainer, "Panel/Content/ElementArea")
    self.genBtn = self:AddComponent(UIButton, "Panel/Content/GenBtn")
    -- 玩法调试按钮：提示 / 重排 / 类型-1
    self.tipBtn = self:AddComponent(UIButton, "Panel/Content/TipBtn")
    self.shuffleBtn = self:AddComponent(UIButton, "Panel/Content/ShuffleBtn")
    self.typeMinusBtn = self:AddComponent(UIButton, "Panel/Content/TypeMinusBtn")
    -- 打开「解锁主题/元素」界面
    self.unlockBtn = self:AddComponent(UIButton, "Panel/Content/UnlockBtn")

    -- 初始化移动类型下拉项
    if self.moveTypeDropdown then
        self.moveTypeDropdown:Clear()
        for _, opt in ipairs(MOVE_TYPE_OPTIONS) do
            self.moveTypeDropdown:AddWithText(opt.label)
        end
        self.moveTypeDropdown:SetValueWithoutNotify(0)
    end

    -- 初始化主题下拉项（从 Theme_Config 读，显示 name，传参用 id）
    self.themeList = LianLianTheme.GetThemeList() or {}
    if self.themeDropdown then
        self.themeDropdown:Clear()
        for _, theme in ipairs(self.themeList) do
            self.themeDropdown:AddWithText(theme.name)
        end
        self.themeDropdown:SetValueWithoutNotify(0)
        -- 切主题时刷新元素展示区
        self.themeDropdown:SetOnValueChanged(BindCallback(self, self.OnThemeChanged))
    end

    -- 初始化元素展示区（按当前主题铺 PreThemeElement 网格）
    self.elementCells = {}
    self.selectedElementIndex = nil
    self:RefreshElementArea()

    self._open = false
    if self.panel then self.panel:SetActive(false) end

    self.toggleBtn:SetOnClick(BindCallback(self, self.OnToggleClick))
    if self.closeBtn then
        self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
    end
    if self.genBtn then
        self.genBtn:SetOnClick(BindCallback(self, self.OnGenClick))
    end
    if self.tipBtn then
        self.tipBtn:SetOnClick(BindCallback(self, self.OnTipClick))
    end
    if self.shuffleBtn then
        self.shuffleBtn:SetOnClick(BindCallback(self, self.OnShuffleClick))
    end
    if self.typeMinusBtn then
        self.typeMinusBtn:SetOnClick(BindCallback(self, self.OnTypeMinusClick))
    end
    if self.unlockBtn then
        self.unlockBtn:SetOnClick(BindCallback(self, self.OnUnlockClick))
    end
end

-- 打开「解锁主题/元素」界面
-- 解锁：解锁 ElementArea 当前选中的元素（写入 PlayerInfo）；未选中则无效果
function LianLianDebugView:OnUnlockClick()
    if not self.selectedElementIndex then return end
    local themeId = self:GetSelectedThemeId()
    if not themeId then return end
    local player = GetPlayer()
    if not player then return end
    -- 已解锁则不重复
    if player:IsThemeTypeUnlocked(themeId, self.selectedElementIndex) then return end
    player:UnlockThemeType(themeId, self.selectedElementIndex)
    -- 刷新对应格子为激活（亮）
    local cell = self.elementCells and self.elementCells[self.selectedElementIndex]
    if cell then cell:SetActivated(true) end
end

-- 提示：高亮一对可消除的牌
function LianLianDebugView:OnTipClick()
    if self.ctrl then self.ctrl:UseTip() end
end

-- 重排：洗牌当前盘面
function LianLianDebugView:OnShuffleClick()
    if self.ctrl then self.ctrl:UseShuffle() end
end

-- 类型-1：图案种类数减 1 并重新生成
function LianLianDebugView:OnTypeMinusClick()
    if self.ctrl then self.ctrl:DecreaseKind() end
end

-- 点击 Gen：读取输入，委托 Ctrl 重新生成盘面（校验/生成在 Manager 内）
function LianLianDebugView:OnGenClick()
    if not self.ctrl then return end
    local rows = self.rowInput and tonumber(self.rowInput:GetText()) or 14
    local cols = self.colInput and tonumber(self.colInput:GetText()) or 8
    -- Layer 输入框 = 每格叠加层数
    local layer = self.layerInput and tonumber(self.layerInput:GetText()) or 1
    -- 下拉选中的移动类型（GetValue 为 0 基索引）；「随机」项 value=nil
    local moveType = nil
    if self.moveTypeDropdown then
        local idx = self.moveTypeDropdown:GetValue() or 0
        local opt = MOVE_TYPE_OPTIONS[idx + 1]
        if opt then moveType = opt.value end
    end

    -- 选「随机」(moveType==nil)：从具体方向里随机抽一个；否则用选中的方向
    if moveType == nil then
        -- 具体方向项 = MOVE_TYPE_OPTIONS[2..#]（跳过第1项“随机”）
        local pick = math.random(2, #MOVE_TYPE_OPTIONS)
        moveType = MOVE_TYPE_OPTIONS[pick].value
    end
    -- 统一走直传版：行/列/方向/叠加层数 直接生成（叠加层数 = LayerInput）
    self.ctrl:Regen(rows, cols, moveType, layer)
end

-- 取当前主题下拉选中的主题 id（传参用 id，非 index）
function LianLianDebugView:GetSelectedThemeId()
    if not self.themeDropdown or not self.themeList then return nil end
    local idx = self.themeDropdown:GetValue() or 0
    local theme = self.themeList[idx + 1]
    return theme and theme.id
end

-- 切主题：重建元素展示区
function LianLianDebugView:OnThemeChanged(index)
    self:RefreshElementArea()
end

-- 重建元素展示区：按当前主题铺 PreThemeElement 网格
function LianLianDebugView:RefreshElementArea()
    if not self.elementArea then return end
    self:ClearElementCells()
    self.selectedElementIndex = nil

    local themeId = self:GetSelectedThemeId()
    if not themeId then return end
    local count = LianLianTheme.GetElementCount(themeId)
    for i = 1, count do
        self:CreateElementCell(themeId, i)
    end
end

-- 清空元素区已有 cell
function LianLianDebugView:ClearElementCells()
    if self.elementCells then
        for _, cell in pairs(self.elementCells) do
            if cell and cell.gameObject then
                CS.UnityEngine.GameObject.Destroy(cell.gameObject)
            end
        end
    end
    self.elementCells = {}
end

-- 创建单个元素 cell（异步实例化 PreThemeElement）
function LianLianDebugView:CreateElementCell(themeId, index)
    local col = (index - 1) % EL_COLS
    local row = math.floor((index - 1) / EL_COLS)
    local x = EL_START_X + col * (EL_CELL + EL_GAP)
    local y = EL_START_Y - row * (EL_CELL + EL_GAP)
    local path = LianLianTheme.GetElementSpritePath(themeId, index)
    -- 激活态 = PlayerInfo 是否已解锁该元素
    local player = GetPlayer()
    local activated = player and player:IsThemeTypeUnlocked(themeId, index) or false

    self.elementArea:GameObjectInstantiateAsync(PRE_THEME_ELEMENT, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self.elementCells then return end
        local cell = self.elementArea:AddComponent(LianLianThemeElement, request.gameObject)
        cell:SetSize(EL_CELL, EL_CELL)
        cell:SetPosition(x, y)
        -- 已解锁=亮，未解锁=灰；点击出选中框
        cell:SetData(index, path, activated, function(i) self:OnElementCellClick(i) end)
        self.elementCells[index] = cell
        if self.selectedElementIndex == index then cell:SetSelected(true) end
    end, self.elementArea.transform)
end

-- 点击元素 cell：更新选中框
function LianLianDebugView:OnElementCellClick(index)
    if self.selectedElementIndex and self.elementCells[self.selectedElementIndex] then
        self.elementCells[self.selectedElementIndex]:SetSelected(false)
    end
    self.selectedElementIndex = index
    if self.elementCells[index] then
        self.elementCells[index]:SetSelected(true)
    end
end

function LianLianDebugView:OnToggleClick()
    self._open = not self._open
    if self.panel then self.panel:SetActive(self._open) end
    if self._open then
        self:FillDefaults()
    end
end

-- 填充输入框/下拉默认值（当前盘面的 row/col/layer/direction，经 Ctrl 从 Manager 取）
function LianLianDebugView:FillDefaults()
    if not self.ctrl then return end
    local rows, cols, part, direction = self.ctrl:GetBoardInfo()
    if self.rowInput then self.rowInput:SetText(tostring(rows or 14)) end
    if self.colInput then self.colInput:SetText(tostring(cols or 8)) end
    if self.layerInput then self.layerInput:SetText(tostring(part or 1)) end
    if self.moveTypeDropdown then
        self.moveTypeDropdown:SetValueWithoutNotify(DirectionToIndex(direction))
    end
    -- 打开面板时按 PlayerInfo 最新解锁态重建元素区
    self:RefreshElementArea()
end

function LianLianDebugView:OnCloseClick()
    self._open = false
    if self.panel then self.panel:SetActive(false) end
end

function LianLianDebugView:OnEnable()
    base.OnEnable(self)
end

function LianLianDebugView:OnDisable()
    base.OnDisable(self)
end

function LianLianDebugView:OnDestroy()
    self:ClearElementCells()
    base.OnDestroy(self)
end

function LianLianDebugView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianDebugView:OnRemoveListener()
    base.OnRemoveListener(self)
end

return LianLianDebugView
