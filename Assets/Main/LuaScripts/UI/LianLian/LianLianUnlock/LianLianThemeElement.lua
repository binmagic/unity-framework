--[[
-- 主题元素格子 widget（承载 Theme_Config 某风格下的单个元素）
-- 结构：Face(元素图) + SelectFrame(选中框，默认隐藏)
-- 记录 index；灰=未激活，亮=激活；激活态由外部设置（不查存档）
--]]

local LianLianThemeElement = BaseClass("LianLianThemeElement", UIBaseContainer)
local base = UIBaseContainer

local COLOR_ACTIVE = { r = 1, g = 1, b = 1, a = 1 }        -- 亮（激活）
local COLOR_INACTIVE = { r = 0.4, g = 0.4, b = 0.4, a = 1 } -- 灰（未激活）

function LianLianThemeElement:OnCreate()
    base.OnCreate(self)
    self.face = self:AddComponent(UIImage, "Face")
    self.selectFrame = self:AddComponent(UIBaseComponent, "SelectFrame")
    self.button = self:AddComponent(UIButton, "")
    self.index = 0
    self.activated = false
    if self.selectFrame then self.selectFrame:SetActive(false) end
end

--- 设置格子数据
--- @param index number 元素序号（记录用）
--- @param spritePath string 元素图路径
--- @param activated boolean 是否激活（亮/灰）
--- @param onClick function 点击回调(index)
function LianLianThemeElement:SetData(index, spritePath, activated, onClick)
    self.index = index
    if self.face and spritePath and spritePath ~= "" then
        self.face:LoadSprite(spritePath)
    end
    self:SetActivated(activated)
    self._onClick = onClick
    if self.button then
        self.button:SetOnClick(function()
            if self._onClick then self._onClick(self.index) end
        end)
    end
end

--- 取/设 index
function LianLianThemeElement:GetIndex()
    return self.index
end

function LianLianThemeElement:SetIndex(i)
    self.index = i
end

--- 激活态（外部设置）：亮/灰
function LianLianThemeElement:SetActivated(activated)
    self.activated = activated and true or false
    if self.face then
        local c = self.activated and COLOR_ACTIVE or COLOR_INACTIVE
        self.face:SetColorRGBA(c.r, c.g, c.b, c.a)
    end
end

function LianLianThemeElement:IsActivated()
    return self.activated
end

--- 选中框
function LianLianThemeElement:SetSelected(bSelected)
    if self.selectFrame then
        self.selectFrame:SetActive(bSelected and true or false)
    end
end

--- 位置 / 尺寸（供网格布局）
function LianLianThemeElement:SetPosition(x, y)
    if self.rectTransform then
        self.rectTransform:Set_anchoredPosition(x, y)
    end
end

function LianLianThemeElement:SetSize(w, h)
    if self.rectTransform then
        self.rectTransform:Set_anchorMin(0.5, 0.5)
        self.rectTransform:Set_anchorMax(0.5, 0.5)
        self.rectTransform:Set_pivot(0.5, 0.5)
        self.rectTransform:Set_sizeDelta(w, h)
    end
end

return LianLianThemeElement
