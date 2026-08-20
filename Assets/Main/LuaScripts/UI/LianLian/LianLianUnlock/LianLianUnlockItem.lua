--[[
-- 解锁界面单个元素 cell widget
-- 结构：Face(元素图) + SelectFrame(选中框，默认隐藏)
-- 已解锁=正常色，未解锁=灰显
--]]

local LianLianUnlockItem = BaseClass("LianLianUnlockItem", UIBaseContainer)
local base = UIBaseContainer

local COLOR_NORMAL = { r = 1, g = 1, b = 1, a = 1 }
local COLOR_LOCKED = { r = 0.4, g = 0.4, b = 0.4, a = 1 }

function LianLianUnlockItem:OnCreate()
    base.OnCreate(self)
    self.face = self:AddComponent(UIImage, "Face")
    self.selectFrame = self:AddComponent(UIBaseComponent, "SelectFrame")
    self.button = self:AddComponent(UIButton, "")
    if self.selectFrame then self.selectFrame:SetActive(false) end
end

--- 设置 cell 数据
--- @param themeId number
--- @param elementId number
--- @param spritePath string 元素图路径
--- @param unlocked boolean 是否已解锁
--- @param onClick function 点击回调(themeId, elementId)
function LianLianUnlockItem:SetData(themeId, elementId, spritePath, unlocked, onClick)
    self.themeId = themeId
    self.elementId = elementId
    if self.face then
        self.face:LoadSprite(spritePath)
    end
    self:SetLockState(unlocked)
    if self.button then
        self.button:SetOnClick(function()
            if onClick then onClick(self.themeId, self.elementId) end
        end)
    end
end

--- 设置解锁态（高亮/灰显）
function LianLianUnlockItem:SetLockState(unlocked)
    self.unlocked = unlocked
    if self.face then
        local c = unlocked and COLOR_NORMAL or COLOR_LOCKED
        self.face:SetColorRGBA(c.r, c.g, c.b, c.a)
    end
end

--- 设置选中框
function LianLianUnlockItem:SetSelected(bSelected)
    if self.selectFrame then self.selectFrame:SetActive(bSelected) end
end

--- 位置 / 尺寸
function LianLianUnlockItem:SetPosition(x, y)
    if self.rectTransform then
        self.rectTransform:Set_anchoredPosition(x, y)
    end
end

function LianLianUnlockItem:SetSize(w, h)
    if self.rectTransform then
        self.rectTransform:Set_anchorMin(0.5, 0.5)
        self.rectTransform:Set_anchorMax(0.5, 0.5)
        self.rectTransform:Set_pivot(0.5, 0.5)
        self.rectTransform:Set_sizeDelta(w, h)
    end
end

return LianLianUnlockItem
