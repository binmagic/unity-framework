--[[
-- [INPUT]: 依赖 LianLianSpecialRegistry / LianLianModifierRegistry 查钩子；DOTween 做动画；
--          UIImage/UIButton 等 UI 组件；prefab PrePlayItem 的 Bg/Face/Vine/Line* 节点
-- [OUTPUT]: 对外提供 LianLianTileItem —— SetData/SetFace/SetSpecial/SetModifiers、
--           入场 PlayPopIn、位移 MoveTo、消除爆点 PlayClearBurst、修饰器过场 PlayModifierEnter/PlayModifierShatter
-- [POS]: 连连看棋盘的单格视图 widget，被 LianLianPlayView 创建与刷新；
--        修饰器的「静态显示 vs 生死过场」在此落地（onShow 幂等显示 / onEnter/onRemove 播动画）
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--
-- 连连看单张牌 widget
-- 双层结构：Bg(底图 bg/select/tip) + Face(图案 1..27)，Vine 为修饰器覆盖层
--]]

local LianLianSpecial = require "Game.LianLian.Special.LianLianSpecialRegistry"
local LianLianModifier = require "Game.LianLian.Special.LianLianModifierRegistry"

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
    -- 藤蔓覆盖层（Face 之上，prefab 里的 Vine 节点；缺节点则为 nil，SetVined 里兜底）
    self.vine = self:AddComponent(UIImage, "Vine")

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
    local prevId = self.id   -- 捕获旧牌 id：用于判断本次是「换了张牌」还是「同牌刷新」
    self.pos = pos
    self.id = id

    -- 加载底图和图案
    if self.bg then self.bg:LoadSprite(GetSpritePath("bg")) end
    -- 普通图案(id 在普通段)才走 item_%d 路径；特殊 id(如火箭 1001)无对应图，
    -- 交给随后的 SetSpecial→onShow 换成专属图（否则会去加载不存在的 item_1/1001）。
    if self.face and id > 0 and not LianLianSpecial.isSpecialId(id) then
        self.face:LoadSprite(GetSpritePath(tostring(id)))
    end

    if self.button then
        self.button:SetOnClick(function()
            if onClick then onClick(self.pos) end
        end)
    end

    self._checked = false
    self._tip = false
    self._specialType = nil
    self._modBlocked = false
    -- 覆盖层生命周期交给 SetModifiers（紧随 SetData 调用）做 diff：
    -- 仅当「换了张牌」才硬复位覆盖层与 mods 记录，避免同牌刷新打断进行中的震碎/入场。
    if prevId ~= id then
        self:KillModifierFx()
        self:KillClearBurst()   -- 复用旧 tile 装新牌：清残留爆点 tween,复位 scale/alpha
        if self.vine then self.vine:SetActive(false) end
        self._mods = nil
    end
    self:HideLines()
    self:SetVisible(id ~= 0)
end

--- 设置/清除特殊元素显示：调用注册表 onShow 钩子装扮本 tile（角标/变色/特效挂载）
--- @param specialType string|nil nil=普通牌（还原默认外观）
function LianLianTileItem:SetSpecial(specialType)
    self._specialType = specialType
    local def = LianLianSpecial.get(specialType)
    if def and def.onShow then
        def.onShow(self, { pos = self.pos, id = self.id, specialType = specialType })
    end
    -- 注：普通牌(def=nil)不做额外处理；各特殊元素的 onShow 负责自身外观，
    -- 若需要"还原"逻辑由具体 def 自行处理（框架不假设默认外观结构）。
end

--- 播放特殊元素消除特效（调用注册表 playClearFx 钩子）
function LianLianTileItem:PlaySpecialClearFx()
    local def = LianLianSpecial.get(self._specialType)
    if def and def.playClearFx then
        def.playClearFx(self)
    end
end

--- 供特殊元素 onShow 用：把 Face 换成任意完整路径的图（不走皮肤 item_%d 路径）
function LianLianTileItem:SetFaceSprite(fullPath)
    if self.face and fullPath then
        self.face:LoadSprite(fullPath)
    end
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

--- 消除爆点：牌先「胀一下」再缩小淡出（一次性演出，动画内部收尾隐藏）。
--- 复用 PlayPopIn 的 DOTween.Sequence + Kill 幂等模式；不依赖粒子/新美术。
--- @param onDone function|nil 爆点播完回调
function LianLianTileItem:PlayClearBurst(onDone)
    self:KillClearBurst()
    self:KillPopIn()   -- 防入场动画未播完就被消除，两条 scale tween 打架
    self:SetLocalScaleXYZ(1, 1, 1)

    self._burstTween = DOTween.Sequence()
    -- pop：胀一下蓄力
    self._burstTween:Append(self.transform:DOScale(Vector3.New(1.25, 1.25, 1), 0.08):SetEase(Ease.OutQuad))
    -- 飞散淡出：缩到 0 + Face/Bg 透明
    self._burstTween:Append(self.transform:DOScale(Vector3.New(0, 0, 1), 0.18):SetEase(Ease.InBack))
    self._burstTween:Join(DOTween.To(function(t)
        local a = 1 - t
        if self.face then self.face:SetAlpha(a) end
        if self.bg then self.bg:SetAlpha(a) end
    end, 0, 1, 0.18))
    self._burstTween:AppendCallback(function()
        self._burstTween = nil
        self:SetVisible(false)
        -- 复位 scale/alpha，供牌复用（SetData）时正常显示
        self:SetLocalScaleXYZ(1, 1, 1)
        if self.face then self.face:SetAlpha(1) end
        if self.bg then self.bg:SetAlpha(1) end
        if onDone then onDone() end
    end)
end

--- 中断爆点动画并复位 scale/alpha（幂等）
function LianLianTileItem:KillClearBurst()
    if self._burstTween then
        self._burstTween:Kill()
        self._burstTween = nil
    end
    self:SetLocalScaleXYZ(1, 1, 1)
    if self.face then self.face:SetAlpha(1) end
    if self.bg then self.bg:SetAlpha(1) end
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
    -- 禁用/启用点击（遮挡 或 被修饰器禁选 都不可点）
    if self.button then self.button:SetEnabled(not self._occluded and not self._modBlocked) end
end

--- 是否被遮挡（不可选）
function LianLianTileItem:IsOccluded()
    return self._occluded and true or false
end

--- 供修饰器 def.onShow 调用：在覆盖层显示一张图（可选着色）。
--- @param sprite string 图路径
--- @param r,g,b,a number|nil 可选着色（占位用；正式图可不传）
function LianLianTileItem:ShowModifierSprite(sprite, r, g, b, a)
    if not self.vine then return end
    self.vine:LoadSprite(sprite)
    if r then self.vine:SetColorRGBA(r, g, b, a or 1) end
    self.vine:SetActive(true)
end

--- 刷新格子修饰器外观（做 mods diff，驱动「生/死」过场）：
---   · onShow  —— 对所有现存修饰器幂等调用，恢复静态显示（换牌/洗牌刷新后重挂图）
---   · onEnter —— 仅对「本帧新出现」的修饰器调一次，播入场动画（不重播保持态）
---   · onRemove—— 对「上帧有、本帧无」的修饰器调，播消亡过场，播完再隐藏覆盖层
--- @param mods table|nil cell.mods = { [type]=state }
function LianLianTileItem:SetModifiers(mods)
    local prev = self._mods or {}
    local cur = {}
    self._modBlocked = false

    -- 收集本帧有效修饰器（已注册的）并计算禁选态
    if mods and next(mods) then
        for mtype, state in pairs(mods) do
            local def = LianLianModifier.get(mtype)
            if def then
                cur[mtype] = state
                if def.blocksSelect and def.blocksSelect(nil, state) then
                    self._modBlocked = true
                end
            end
        end
    end

    -- 消失的修饰器（上帧有、本帧无）：播消亡过场，onDone 里隐藏覆盖层
    for mtype, state in pairs(prev) do
        if cur[mtype] == nil then
            local def = LianLianModifier.get(mtype)
            if def and def.onRemove then
                def.onRemove(self, state, function()
                    if self.vine then self.vine:SetActive(false) end
                end)
            elseif self.vine then
                self.vine:SetActive(false)   -- 无消亡钩子（如藤蔓）：直接隐藏
            end
        end
    end

    -- 新增/保留的修饰器：onShow 幂等恢复静态显示；仅「新增」额外播入场
    for mtype, state in pairs(cur) do
        local def = LianLianModifier.get(mtype)
        if def then
            if def.onShow then def.onShow(self, state) end
            if prev[mtype] == nil and def.onEnter then def.onEnter(self, state) end
        end
    end

    self._mods = next(cur) and cur or nil

    -- 有"禁选"修饰器时禁用点击；否则恢复（除非仍被遮挡）
    if self.button then
        self.button:SetEnabled(not self._modBlocked and not self._occluded)
    end
end

--- 中断进行中的修饰器过场动画（入场/震碎），并复位覆盖层缩放。幂等。
function LianLianTileItem:KillModifierFx()
    if self._modEnterTween then
        self._modEnterTween:Kill()
        self._modEnterTween = nil
    end
    if self._modShatterTween then
        self._modShatterTween:Kill()
        self._modShatterTween = nil
    end
    if self.vine then self.vine:SetLocalScaleXYZ(1, 1, 1) end
end

--- 修饰器入场过场：覆盖层 scale 1.15→1 + alpha 0→当前色 alpha，模拟「结冰铺开」。
--- 供 def.onEnter 调用；须在 onShow（已设好贴图/着色）之后调，以读取目标 alpha。
--- @param duration number|nil 时长（缺省 0.2 秒）
function LianLianTileItem:PlayModifierEnter(duration)
    if not self.vine then return end
    self:KillModifierFx()
    local dur = duration or 0.2
    local r, g, b, a = self.vine:GetColorRGBA()   -- 目标态由 onShow 决定（占位=淡蓝 tint，真图=白）
    self.vine:SetActive(true)
    self.vine:SetLocalScaleXYZ(1.15, 1.15, 1)
    self.vine:SetColorRGBA(r, g, b, 0)
    self._modEnterTween = DOTween.Sequence()
    self._modEnterTween:Append(self.vine.transform:DOScale(Vector3.New(1, 1, 1), dur):SetEase(Ease.OutQuad))
    self._modEnterTween:Join(DOTween.To(function(t)
        if self.vine then self.vine:SetColorRGBA(r, g, b, a * t) end
    end, 0, 1, dur))
    self._modEnterTween:AppendCallback(function()
        self._modEnterTween = nil
        if self.vine then
            self.vine:SetLocalScaleXYZ(1, 1, 1)
            self.vine:SetColorRGBA(r, g, b, a)
        end
    end)
end

--- 修饰器震碎过场：按 fps 逐帧切换覆盖层贴图，末帧后隐藏并回调 onDone。
--- 占位阶段 frames 只有 1~2 张也能跑通时序。
--- @param frames table 帧图路径数组 { path, ... }
--- @param fps number|nil 帧率（缺省 20）
--- @param onDone function|nil 播完回调（视图层用于收尾隐藏覆盖层）
function LianLianTileItem:PlayModifierShatter(frames, fps, onDone)
    if not self.vine or not frames or #frames == 0 then
        if self.vine then self.vine:SetActive(false) end
        if onDone then onDone() end
        return
    end
    self:KillModifierFx()
    self.vine:SetActive(true)
    self.vine:SetLocalScaleXYZ(1, 1, 1)
    local interval = 1 / (fps or 20)
    self._modShatterTween = DOTween.Sequence()
    for i = 1, #frames do
        local path = frames[i]
        self._modShatterTween:AppendCallback(function()
            if self.vine then self.vine:LoadSprite(path) end
        end)
        self._modShatterTween:AppendInterval(interval)
    end
    self._modShatterTween:AppendCallback(function()
        self._modShatterTween = nil
        if self.vine then self.vine:SetActive(false) end
        if onDone then onDone() end
    end)
end

--- 是否被修饰器标记为不可选
function LianLianTileItem:IsModBlocked()
    return self._modBlocked and true or false
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
