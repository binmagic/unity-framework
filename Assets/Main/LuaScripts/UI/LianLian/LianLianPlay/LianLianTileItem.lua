--[[
-- 连连看单张牌 widget
-- 包装 PrePlayItem 实例：设置图案(占位色块)、点击、选中/提示高亮、连线、显隐
--]]

local LianLianTileItem = BaseClass("LianLianTileItem", UIBaseContainer)
local base = UIBaseContainer

local KIND_MAX = 27

-- 依据 id 生成一个稳定的占位颜色 (HSV 均匀取色)
local function IdToColor(id)
    local h = ((id - 1) % KIND_MAX) / KIND_MAX
    -- 简单 HSV(h,0.65,0.95) -> RGB
    local s, v = 0.65, 0.95
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    local r, g, b
    local m = i % 6
    if m == 0 then r, g, b = v, t, p
    elseif m == 1 then r, g, b = q, v, p
    elseif m == 2 then r, g, b = p, v, t
    elseif m == 3 then r, g, b = p, q, v
    elseif m == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return r, g, b
end

function LianLianTileItem:OnCreate()
    base.OnCreate(self)

    -- 根节点 Image (占位色块) 与 Button
    self.icon = self:AddComponent(UIImage, "")
    self.button = self:AddComponent(UIButton, "")

    -- 高亮/提示
    self.highlight = self:AddComponent(UIBaseComponent, "Highlight")
    self.tipHighlight = self:AddComponent(UIBaseComponent, "TipHighlight")

    -- 连线四方向
    self.lineTop = self:AddComponent(UIBaseComponent, "LineTop")
    self.lineRight = self:AddComponent(UIBaseComponent, "LineRight")
    self.lineBottom = self:AddComponent(UIBaseComponent, "LineBottom")
    self.lineLeft = self:AddComponent(UIBaseComponent, "LineLeft")

    self:HideLines()
    if self.highlight then self.highlight:SetActive(false) end
    if self.tipHighlight then self.tipHighlight:SetActive(false) end
end

--- 设置牌数据
--- @param pos table {r, c}
--- @param id number 图案 id (1..27)
--- @param onClick function 点击回调, 接收 pos
function LianLianTileItem:SetData(pos, id, onClick)
    self.pos = pos
    self.id = id

    -- 占位：按 id 上色 (真实贴图后续 LoadSprite 替换)
    if self.icon and self.icon.unity_image then
        local r, g, b = IdToColor(id)
        self.icon.unity_image.color = CS.UnityEngine.Color(r, g, b, 1)
    end

    if self.button then
        self.button:SetOnClick(function()
            if onClick then onClick(self.pos) end
        end)
    end

    self:SetChecked(false)
    self:SetTip(false)
    self:HideLines()
    self:SetVisible(id ~= 0)
end

--- 设置牌在棋盘容器内的锚点坐标
function LianLianTileItem:SetPosition(x, y)
    if self.rectTransform then
        self.rectTransform.anchoredPosition = CS.UnityEngine.Vector2(x, y)
    end
end

--- 设置牌尺寸
function LianLianTileItem:SetSize(w, h)
    if self.rectTransform then
        self.rectTransform.sizeDelta = CS.UnityEngine.Vector2(w, h)
    end
end

--- 选中高亮
function LianLianTileItem:SetChecked(bChecked)
    if self.highlight then self.highlight:SetActive(bChecked and true or false) end
end

--- 提示高亮
function LianLianTileItem:SetTip(bTip)
    if self.tipHighlight then self.tipHighlight:SetActive(bTip and true or false) end
end

--- 显隐整张牌
function LianLianTileItem:SetVisible(bVisible)
    self:SetActive(bVisible and true or false)
end

--- 隐藏所有连线段
function LianLianTileItem:HideLines()
    if self.lineTop then self.lineTop:SetActive(false) end
    if self.lineRight then self.lineRight:SetActive(false) end
    if self.lineBottom then self.lineBottom:SetActive(false) end
    if self.lineLeft then self.lineLeft:SetActive(false) end
end

--- 依据连线节点 (getPathLine 生成) 显示方向线段
--- node: { top,right,bottom,left, lt,rt,lb,rb }
function LianLianTileItem:SetLines(node)
    if not node then return end
    local top = (node.top == 1) or (node.lt == 1) or (node.rt == 1)
    local right = (node.right == 1) or (node.rt == 1) or (node.rb == 1)
    local bottom = (node.bottom == 1) or (node.lb == 1) or (node.rb == 1)
    local left = (node.left == 1) or (node.lt == 1) or (node.lb == 1)
    if self.lineTop then self.lineTop:SetActive(top) end
    if self.lineRight then self.lineRight:SetActive(right) end
    if self.lineBottom then self.lineBottom:SetActive(bottom) end
    if self.lineLeft then self.lineLeft:SetActive(left) end
end

return LianLianTileItem
