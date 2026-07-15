--[[
-- 解锁主题/元素 Debug 界面
-- 下拉选主题 → 网格列出元素图（已解锁高亮/未解锁灰显）→ 选中后可解锁
--]]

local LianLianUnlockView = BaseClass("LianLianUnlockView", UIBaseView)
local base = UIBaseView

local CELL_PREFAB = "Assets/Main/Prefabs/UI/LianLian/PreUnlockItem.prefab"

-- 网格布局参数
local COLS = 5          -- 每行元素数
local CELL = 90         -- cell 尺寸
local GAP = 16          -- 间距
local START_X = -220    -- 第一列 x（相对 Content 中心）
local START_Y = 210     -- 第一行 y（相对 Content 中心）

function LianLianUnlockView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
end

function LianLianUnlockView:ComponentDefine()
    self.panel = self:AddComponent(UIBaseComponent, "Panel")
    self.themeDropdown = self:AddComponent(UITMPDropdown, "Panel/ThemeDropdown")
    self.elementContent = self:AddComponent(UIBaseContainer, "Panel/ElementScroll/Viewport/Content")
    self.unlockBtn = self:AddComponent(UIButton, "Panel/UnlockBtn")
    self.closeBtn = self:AddComponent(UIButton, "Panel/CloseBtn")

    self.cells = {}          -- elementId -> LianLianUnlockItem
    self.themeList = {}
    self.curThemeId = nil
    self.selectedId = nil

    if self.themeDropdown then
        self.themeDropdown:SetOnValueChanged(BindCallback(self, self.OnThemeChanged))
    end
    if self.unlockBtn then
        self.unlockBtn:SetOnClick(BindCallback(self, self.OnUnlockClick))
    end
    if self.closeBtn then
        self.closeBtn:SetOnClick(BindCallback(self, self.OnCloseClick))
    end
end

function LianLianUnlockView:OnEnable()
    base.OnEnable(self)
    self:InitThemeDropdown()
end

--- 填充主题下拉
function LianLianUnlockView:InitThemeDropdown()
    if not self.ctrl then return end
    self.themeList = self.ctrl:GetThemeList() or {}
    if self.themeDropdown then
        self.themeDropdown:Clear()
        for _, theme in ipairs(self.themeList) do
            self.themeDropdown:AddWithText(theme.name)
        end
        self.themeDropdown:SetValueWithoutNotify(0)
    end
    -- 默认展示第一个主题
    local first = self.themeList[1]
    if first then
        self.curThemeId = first.id
        self:RefreshElements()
    end
end

--- 下拉切换主题
function LianLianUnlockView:OnThemeChanged(index)
    local theme = self.themeList[(index or 0) + 1]
    if not theme then return end
    self.curThemeId = theme.id
    self.selectedId = nil
    self:RefreshElements()
end

--- 重建元素网格
function LianLianUnlockView:RefreshElements()
    if not self.elementContent or not self.curThemeId then return end
    self:ClearCells()

    local count = self.ctrl:GetElementCount(self.curThemeId)
    for i = 1, count do
        self:CreateCell(self.curThemeId, i)
    end
    self:UpdateUnlockBtn()
end

--- 清空已有 cell
function LianLianUnlockView:ClearCells()
    if self.cells then
        for _, cell in pairs(self.cells) do
            if cell and cell.gameObject then
                CS.UnityEngine.GameObject.Destroy(cell.gameObject)
            end
        end
    end
    self.cells = {}
end

--- 创建单个元素 cell（异步实例化）
function LianLianUnlockView:CreateCell(themeId, elementId)
    local col = (elementId - 1) % COLS
    local row = math.floor((elementId - 1) / COLS)
    local x = START_X + col * (CELL + GAP)
    local y = START_Y - row * (CELL + GAP)
    local path = self.ctrl:GetElementSpritePath(themeId, elementId)
    local unlocked = self.ctrl:IsUnlocked(themeId, elementId)

    self.elementContent:GameObjectInstantiateAsync(CELL_PREFAB, function(request)
        if request == nil or request.isError or request.gameObject == nil then return end
        if not self.cells then return end
        local cell = self.elementContent:AddComponent(LianLianUnlockItem, request.gameObject)
        cell:SetSize(CELL, CELL)
        cell:SetPosition(x, y)
        cell:SetData(themeId, elementId, path, unlocked, function(t, e)
            self:OnCellClick(t, e)
        end)
        self.cells[elementId] = cell
        -- 若正好是当前选中项，恢复选中框
        if self.selectedId == elementId then cell:SetSelected(true) end
    end, self.elementContent.transform)
end

--- 点击某个元素 cell
function LianLianUnlockView:OnCellClick(themeId, elementId)
    -- 取消旧选中
    if self.selectedId and self.cells[self.selectedId] then
        self.cells[self.selectedId]:SetSelected(false)
    end
    self.selectedId = elementId
    if self.cells[elementId] then
        self.cells[elementId]:SetSelected(true)
    end
    self:UpdateUnlockBtn()
end

--- 刷新解锁按钮可用态（选中已解锁 → 不可用）
function LianLianUnlockView:UpdateUnlockBtn()
    if not self.unlockBtn then return end
    local canUnlock = false
    if self.selectedId and self.curThemeId then
        canUnlock = not self.ctrl:IsUnlocked(self.curThemeId, self.selectedId)
    end
    self.unlockBtn:SetInteractable(canUnlock)
end

--- 点击解锁
function LianLianUnlockView:OnUnlockClick()
    if not self.selectedId or not self.curThemeId then return end
    if self.ctrl:IsUnlocked(self.curThemeId, self.selectedId) then return end
    self.ctrl:Unlock(self.curThemeId, self.selectedId)
end

function LianLianUnlockView:OnCloseClick()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.LianLianUnlock)
end

function LianLianUnlockView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener("LianLian_UnlockUpdate", self.OnUnlockUpdate)
end

--- 解锁数据变化：刷新对应 cell + 按钮
function LianLianUnlockView:OnUnlockUpdate(data)
    if not data then return end
    if data.themeId ~= self.curThemeId then return end
    local cell = self.cells[data.elementId]
    if cell then cell:SetLockState(true) end
    self:UpdateUnlockBtn()
end

function LianLianUnlockView:OnRemoveListener()
    base.OnRemoveListener(self)
end

function LianLianUnlockView:OnDisable()
    base.OnDisable(self)
end

function LianLianUnlockView:OnDestroy()
    self:ClearCells()
    base.OnDestroy(self)
end

return LianLianUnlockView
