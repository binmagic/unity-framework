--[[
-- Debug 面板视图
-- 左上角开关按钮 + 模态空面板
--]]

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
    self.genBtn = self:AddComponent(UIButton, "Panel/Content/GenBtn")

    -- 初始化移动类型下拉项
    if self.moveTypeDropdown then
        self.moveTypeDropdown:Clear()
        for _, opt in ipairs(MOVE_TYPE_OPTIONS) do
            self.moveTypeDropdown:AddWithText(opt.label)
        end
        self.moveTypeDropdown:SetValueWithoutNotify(0)
    end

    self._open = false
    if self.panel then self.panel:SetActive(false) end

    self.toggleBtn:SetOnClick(BindCallback(self, self.OnToggleClick))
    if self.closeBtn then
        self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
    end
    if self.genBtn then
        self.genBtn:SetOnClick(BindCallback(self, self.OnGenClick))
    end
end

-- 点击 Gen：读取输入，委托 Ctrl 重新生成盘面（校验/生成在 Manager 内）
function LianLianDebugView:OnGenClick()
    if not self.ctrl then return end
    local rows = self.rowInput and tonumber(self.rowInput:GetText()) or 14
    local cols = self.colInput and tonumber(self.colInput:GetText()) or 8
    local layer = self.layerInput and tonumber(self.layerInput:GetText()) or 1
    -- 下拉选中的移动类型（GetValue 为 0 基索引）
    local moveType = nil
    if self.moveTypeDropdown then
        local idx = self.moveTypeDropdown:GetValue() or 0
        local opt = MOVE_TYPE_OPTIONS[idx + 1]
        if opt then moveType = opt.value end
    end
    self.ctrl:Regen(rows, cols, layer, moveType)
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
    base.OnDestroy(self)
end

function LianLianDebugView:OnAddListener()
    base.OnAddListener(self)
end

function LianLianDebugView:OnRemoveListener()
    base.OnRemoveListener(self)
end

return LianLianDebugView
