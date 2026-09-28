---
--- STG 怪物子系统 — 待救援 NPC
--- 提炼自 ParkourBattle/Monster/MonsterImpl/NeedRescueGirl.lua 的核心语义：非战斗单位，
--- 朝一个固定目标坐标移动，每帧检查是否到达（原版用 Z 轴距离差 < 1 判定），到达后只触发
--- 一次：标记完成、停止移动、播放音效回调、从场上移除。去掉了原实现里的 RVO 寻路
--- （LWBattleRVOAgent + rvoMgr）、旧队伍系统的 DynamicAddHero、图层/挂点相关的表现代码，
--- 移动改成 Monster2DBase 的直线插值。
---
--- 用法：
---   local npc = RescueNpc2D.New(parentTransform, x, y, {
---       targetY = 300, reachThreshold = 4, speed = 40,
---       onReach = function(npc) --[[ 播放获救音效、加入队伍等 ]] end,
---   })
---   npc:Update(dt)
---
---@class RescueNpc2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local RescueNpc2D = BaseClass("RescueNpc2D", Monster2DBase)

--- @param cfg table
---   targetY          number  目标 Y 坐标（对齐原版 targetPosZ，判定到达用的是这一维距离，不是二维欧氏距离）
---   reachThreshold   number  到达判定阈值，默认 1（原版 math.abs(pos.z - targetPosZ) < 1）
---   speed            number  移动速度（像素/秒）
---   spritePath       string  可选
---   onReach          fun(npc:RescueNpc2D)  到达时触发一次
function RescueNpc2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    Monster2DBase.__init(self, parentTransform, x, y, 1, self.cfg.sizeVec2)

    self.targetY = self.cfg.targetY or y
    self.reachThreshold = self.cfg.reachThreshold or 1
    self.moveSpeed = self.cfg.speed or 40
    self.onReach = self.cfg.onReach
    self.isReach = false
end

function RescueNpc2D:GetGoName()
    return "RescueNpc2D"
end

function RescueNpc2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 每帧朝 targetY 方向直线移动，到达阈值内触发一次 onReach（对齐原版只用一个维度判定到达，
--- 不是二维欧氏距离，因为原版场景里 NPC 只在纵深方向上有意义的移动）
function RescueNpc2D:Update(dt)
    if self.isDead or self.isReach then
        return
    end

    local x, y = self:GetLocalPos()
    if math.abs(y - self.targetY) < self.reachThreshold then
        self:_OnReach()
        return
    end

    local dirY = (self.targetY > y) and 1 or -1
    self:SetLocalPos(x, y + dirY * self.moveSpeed * dt)
end

function RescueNpc2D:_OnReach()
    self.isReach = true
    if self.onReach ~= nil then
        self.onReach(self)
    end
end

function RescueNpc2D:IsReach()
    return self.isReach
end

return RescueNpc2D
