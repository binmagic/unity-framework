---
--- STG 怪物子系统 — 双生独立计数门（三级门状态机 Tier 3）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/UpgradeableDuetGate.lua：门体左右两侧各自维护一个
--- 计数值和一张区间表，命中哪一侧就累加哪一侧的计数，并按命中比例实时改变左右两半的宽度
--- （几何形变）。去掉了原实现里的 `para;para2` 旧字符串格式和 3D 挂点结构（transform:Find），
--- 改成直接传 Lua table 配置 + 2D sizeDelta/anchoredPosition 驱动左右两个子节点。
---
--- 用法：
---   local gate = DuetGate2D.New(parentTransform, x, y, {
---       totalWidth = 200, height = 60,
---       leftRanges  = { {min=-5, max=0, effectId="eff_zero"}, {min=1, max=5, effectId="eff_plus5"} },
---       rightRanges = { {min=-5, max=0, effectId="eff_zero"}, {min=1, max=5, effectId="eff_plus5"} },
---       onSideChanged = function(isLeft, showValue, effectId, gate) --[[ 更新文案 ]] end,
---   })
---   gate:OnHit(isLeft, damage)   -- isLeft: 命中门体左侧还是右侧
---
---@class DuetGate2D : TriggerGate2D
local TriggerGate2D = require "Game.STG.Monster.Gate.TriggerGate2D"
local RangeMatchUtil = require "Game.STG.Monster.Gate.RangeMatchUtil"
local DuetGate2D = BaseClass("DuetGate2D", TriggerGate2D)

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

local CHANGE_PERCENT = 0.02  -- 每次命中，左右宽度比例变化幅度（对齐原版 ChangePercent）
local MIN_PERCENT    = 0.2   -- 单侧宽度占比下限，避免形变到消失（对齐原版 MinPercent）

--- @param cfg table
---   totalWidth   number  门体总宽度
---   height       number  门体高度
---   leftRanges   table[] { {min, max, effectId}, ... } 左侧区间表，按 min 升序排列
---   rightRanges  table[] 右侧区间表，格式同上
---   onSideChanged  fun(isLeft:boolean, showValue:number, effectId:any, gate:DuetGate2D)
function DuetGate2D:__init(parentTransform, x, y, cfg)
    TriggerGate2D.__init(self, parentTransform, x, y, cfg)

    self.totalWidth = (cfg and cfg.totalWidth) or 200
    self.height = (cfg and cfg.height) or 60
    self.leftRanges = (cfg and cfg.leftRanges) or {}
    self.rightRanges = (cfg and cfg.rightRanges) or {}
    self.onSideChanged = cfg and cfg.onSideChanged

    self.leftValue = 0
    self.rightValue = 0
    self.leftEffectId = self:_MatchRange(self.leftRanges, self.leftValue)
    self.rightEffectId = self:_MatchRange(self.rightRanges, self.rightValue)

    self:_CreateSubNodes()
    self:_UpdateRatio(0.5)
end

function DuetGate2D:GetGoName()
    return "DuetGate2D"
end

--- 创建左右两个子节点用于表现宽度形变，替代原版 3D 预制体里固定挂点的 left/right 结构
function DuetGate2D:_CreateSubNodes()
    self.leftNode = self:_CreateSubImage("Left")
    self.rightNode = self:_CreateSubImage("Right")
end

function DuetGate2D:_CreateSubImage(name)
    local go = GameObject(name, RectTransform)
    go.transform:SetParent(self.go.transform, false)
    local rt = go:GetComponent(RectTransform)
    rt.anchorMin = Vector2(0.5, 0.5)
    rt.anchorMax = Vector2(0.5, 0.5)
    rt.pivot     = Vector2(0.5, 0.5)
    go:AddComponent(Image)
    return rt
end

--- 命中一侧，累加该侧计数、重新按比例形变门体、重新匹配区间效果
--- @param isLeft boolean
--- @param damage number 命中次数权重，通常传 1（对齐原版"每次命中 +1"，不是伤害值）
function DuetGate2D:OnHit(isLeft, damage)
    if self.isDead then
        return
    end

    local newLeftRatio = self.leftRatio + (isLeft and CHANGE_PERCENT or -CHANGE_PERCENT)
    newLeftRatio = math.max(MIN_PERCENT, math.min(1 - MIN_PERCENT, newLeftRatio))
    self:_UpdateRatio(newLeftRatio)

    if isLeft then
        self.leftValue = self.leftValue + (damage or 1)
        self.leftEffectId = RangeMatchUtil.Match(self.leftRanges, self.leftValue)
        if self.onSideChanged ~= nil then
            self.onSideChanged(true, self.leftValue, self.leftEffectId, self)
        end
    else
        self.rightValue = self.rightValue + (damage or 1)
        self.rightEffectId = RangeMatchUtil.Match(self.rightRanges, self.rightValue)
        if self.onSideChanged ~= nil then
            self.onSideChanged(false, self.rightValue, self.rightEffectId, self)
        end
    end
end

--- 按 leftRatio 重新计算左右两侧宽度和位置，驱动子节点做几何形变
--- 原样对齐 UpgradableDuetGate:UpdateRatio/UpdateSubPos/UpdateLayout 的计算方式
--- @param leftRatio number 0~1，左侧占总宽度的比例
function DuetGate2D:_UpdateRatio(leftRatio)
    self.leftRatio = leftRatio
    self.leftWidth = self.totalWidth * leftRatio
    self.rightWidth = self.totalWidth - self.leftWidth

    local leftPosX = -self.totalWidth * 0.5 + self.leftWidth * 0.5
    local rightPosX = self.totalWidth * 0.5 - self.rightWidth * 0.5
    self.separatorX = leftPosX + self.leftWidth * 0.5

    self.leftNode.sizeDelta = Vector2(self.leftWidth, self.height)
    self.leftNode.anchoredPosition = Vector2(leftPosX, 0)
    self.rightNode.sizeDelta = Vector2(self.rightWidth, self.height)
    self.rightNode.anchoredPosition = Vector2(rightPosX, 0)
end

--- 机体飞越门体时结算：按命中点落在分隔线左/右决定用哪一侧的效果
--- @param passX number 飞越点相对门体中心的局部 X 坐标
function DuetGate2D:TriggerBySide(passX)
    local isLeft = passX <= self.separatorX
    local value = isLeft and self.leftValue or self.rightValue
    local effectId = isLeft and self.leftEffectId or self.rightEffectId
    if self.onTrigger ~= nil then
        self.onTrigger(effectId, self)
    end
    return isLeft, value, effectId
end

function DuetGate2D:GetLeftValue()
    return self.leftValue
end

function DuetGate2D:GetRightValue()
    return self.rightValue
end

function DuetGate2D:Destroy()
    self.leftNode = nil
    self.rightNode = nil
    TriggerGate2D.Destroy(self)
end

return DuetGate2D
