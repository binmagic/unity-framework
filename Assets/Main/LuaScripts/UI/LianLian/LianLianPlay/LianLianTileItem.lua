--[[
-- 连连看单张牌 widget
-- 双层结构：Bg(底图 bg/select/tip) + Face(图案 1..27)
--]]

local LianLianTileItem = BaseClass("LianLianTileItem", UIBaseContainer)
local base = UIBaseContainer

local SKIN = 1  -- 当前皮肤（后续接 state.skinId）
local ITEM_PATH = "Assets/_Art_LianLian/ItemSprites/item_%d/%s"

local function GetSpritePath(name)
    return string.format(ITEM_PATH, SKIN, name)
end

function LianLianTileItem:OnCreate()
    base.OnCreate(self)

    -- 底图 + 图案
    self.bg = self:AddComponent(UIImage, "Bg")
    self.face = self:AddComponent(UIImage, "Face")

    -- 按钮（根节点 NewButton）
    self.button = self:AddComponent(UIButton, "")

    -- 连线四方向
    self.lineTop = self:AddComponent(UIBaseComponent, "LineTop")
    self.lineRight = self:AddComponent(UIBaseComponent, "LineRight")
    self.lineBottom = self:AddComponent(UIBaseComponent, "LineBottom")
    self.lineLeft = self:AddComponent(UIBaseComponent, "LineLeft")

    self:HideLines()
    self._checked = false
    self._tip = false
end

--- 设置牌数据
function LianLianTileItem:SetData(pos, id, onClick)
    self.pos = pos
    self.id = id

    -- 加载底图和图案
    if self.bg then self.bg:LoadSprite(GetSpritePath("bg")) end
    if self.face and id > 0 then self.face:LoadSprite(GetSpritePath(tostring(id))) end

    if self.button then
        self.button:SetOnClick(function()
            if onClick then onClick(self.pos) end
        end)
    end

    self._checked = false
    self._tip = false
    self:HideLines()
    self:SetVisible(id ~= 0)
end

--- 换图案为新 id（多层消除后露出下一层用）：刷新 Face + 复位 checked/tip 态并保持可见
function LianLianTileItem:SetFace(id)
    self.id = id
    self._checked = false
    self._tip = false
    if id and id > 0 then
        if self.face then self.face:LoadSprite(GetSpritePath(tostring(id))) end
        self:RefreshBg()
        self:SetVisible(true)
    else
        self:SetVisible(false)
    end
end

--- 刷新底图（依据 checked/tip 状态）
function LianLianTileItem:RefreshBg()
    if not self.bg then return end
    if self._checked then
        self.bg:LoadSprite(GetSpritePath("select"))
    elseif self._tip then
        self.bg:LoadSprite(GetSpritePath("tip"))
    else
        self.bg:LoadSprite(GetSpritePath("bg"))
    end
end

--- 设置牌在棋盘容器内的锚点坐标（相对 Board 中心的偏移）
function LianLianTileItem:SetPosition(x, y)
    if self.rectTransform then
        self.rectTransform:Set_anchoredPosition(x, y)
    end
end

--- 缩放弹出入场动画：延迟 delay 后，localScale 从 0 弹到 1（带回弹）
--- @param delay number 起始延迟（秒）
--- @param duration number 弹出时长（秒）
--- @param onDone function|nil 完成回调
function LianLianTileItem:PlayPopIn(delay, duration, onDone)
    self:KillPopIn()
    self:SetVisible(true)
    self:SetLocalScaleXYZ(0, 0, 1)

    self._popTween = DOTween.Sequence()
    if delay and delay > 0 then
        self._popTween:AppendInterval(delay)
    end
    self._popTween:Append(self.transform:DOScale(Vector3.New(1, 1, 1), duration):SetEase(Ease.OutBack))
    self._popTween:AppendCallback(function()
        self._popTween = nil
        self:SetLocalScaleXYZ(1, 1, 1)
        if onDone then onDone() end
    end)
end

--- 滑动到目标锚点坐标（DOTween 动画）
--- @param x number 目标 x
--- @param y number 目标 y
--- @param duration number 时长（秒）
--- @param onDone function|nil 完成回调
function LianLianTileItem:MoveTo(x, y, duration, onDone)
    self:KillMove()
    if not self.rectTransform then
        if onDone then onDone() end
        return
    end
    local sx, sy = self.rectTransform:Get_anchoredPosition()
    self._moveTween = DOTween.To(function(t)
        local cx = sx + (x - sx) * t
        local cy = sy + (y - sy) * t
        if self.rectTransform then
            self.rectTransform:Set_anchoredPosition(cx, cy)
        end
    end, 0, 1, duration)
    self._moveTween:SetEase(Ease.OutQuad)
    self._moveTween:OnComplete(function()
        self._moveTween = nil
        if self.rectTransform then
            self.rectTransform:Set_anchoredPosition(x, y)
        end
        if onDone then onDone() end
    end)
end

--- 中断入场动画并把 scale 复位为 1（幂等）
function LianLianTileItem:KillPopIn()
    if self._popTween then
        self._popTween:Kill()
        self._popTween = nil
    end
    self:SetLocalScaleXYZ(1, 1, 1)
end

--- 中断滑动动画
function LianLianTileItem:KillMove()
    if self._moveTween then
        self._moveTween:Kill()
        self._moveTween = nil
    end
end

--- 设置牌尺寸（归一到中心锚点固定尺寸模式）
function LianLianTileItem:SetSize(w, h)
    if self.rectTransform then
        self.rectTransform:Set_anchorMin(0.5, 0.5)
        self.rectTransform:Set_anchorMax(0.5, 0.5)
        self.rectTransform:Set_pivot(0.5, 0.5)
        self.rectTransform:Set_sizeDelta(w, h)
    end
end

--- 遮挡态：被上层元素盖住 → 置灰 + 禁用点击；露出 → 恢复
function LianLianTileItem:SetOccluded(bOccluded)
    self._occluded = bOccluded and true or false
    -- 置灰 Face 与 Bg
    local r, g, b = 0.45, 0.45, 0.45
    if not self._occluded then r, g, b = 1, 1, 1 end
    if self.face then self.face:SetColorRGBA(r, g, b, 1) end
    if self.bg then self.bg:SetColorRGBA(r, g, b, 1) end
    -- 禁用/启用点击
    if self.button then self.button:SetEnabled(not self._occluded) end
end

--- 是否被遮挡（不可选）
function LianLianTileItem:IsOccluded()
    return self._occluded and true or false
end

--- 选中高亮（切换底图为 select）
function LianLianTileItem:SetChecked(bChecked)
    self._checked = bChecked and true or false
    self:RefreshBg()
end

--- 提示高亮（切换底图为 tip）
function LianLianTileItem:SetTip(bTip)
    self._tip = bTip and true or false
    self:RefreshBg()
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

--- 依据连线节点显示方向线段
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
