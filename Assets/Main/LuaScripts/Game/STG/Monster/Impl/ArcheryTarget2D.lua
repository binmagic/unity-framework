---
--- STG 怪物子系统 — 箭塔（多靶块目标）
--- 提炼自 ParkourBattle/Monster/MonsterImpl/ArcheryTarget.lua 的核心语义："由若干独立靶块
--- 组成，每次命中随机打碎一个存活靶块，全部打碎才算真正死亡"。去掉了原实现里的
--- SimpleAnimation 播放、旧战斗框架 monsterMgr 回调等耦合逻辑，靶块用子节点 Image 表现，
--- 打碎即隐藏（不做破碎特效，特效由调用方在 onSubDestroyed 回调里自行处理）。
---
--- 用法：
---   local target = ArcheryTarget2D.New(parentTransform, x, y, {
---       subCount = 3, subHp = 1, hitCdSec = 1,
---       spritePath = "...", subSize = Vector2(20, 20), subSpacing = 24,
---       onSubDestroyed = function(remaining, target) --[[ 打碎特效 ]] end,
---   })
---   target:TakeDamage(1)
---
---@class ArcheryTarget2D : Monster2DBase
local Monster2DBase = require "Game.STG.Monster.Monster2DBase"
local ArcheryTarget2D = BaseClass("ArcheryTarget2D", Monster2DBase)

local GameObject    = CS.UnityEngine.GameObject
local RectTransform = typeof(CS.UnityEngine.RectTransform)
local Image         = typeof(CS.UnityEngine.UI.Image)
local Vector2       = CS.UnityEngine.Vector2

--- @param cfg table
---   subCount    number  靶块数量（对齐原版 bornMeta.para 的第一个字段）
---   subHp       number  单个靶块血量，默认 1
---   hitCdSec    number  受击冷却（秒），默认 1，冷却内的命中忽略
---   spritePath  string  底座贴图（可选）
---   subSpritePath  string  靶块贴图（可选）
---   subSize     userdata  Vector2，靶块尺寸
---   subSpacing  number  靶块横向间距
---   onSubDestroyed  fun(remaining:number, target:ArcheryTarget2D)  每打碎一个靶块回调一次
function ArcheryTarget2D:__init(parentTransform, x, y, cfg)
    self.cfg = cfg or {}
    self.subCount = self.cfg.subCount or 1
    self.subHp = self.cfg.subHp or 1
    self.hitCdSec = self.cfg.hitCdSec or 1
    self.curHitCd = 0
    self.curSubBlood = self.subHp

    -- 整体 hp 只是占位（真正的存活判定看 liveSubIndexes 是否为空），传固定值即可
    Monster2DBase.__init(self, parentTransform, x, y, 1, nil)

    self.subNodes = {}
    self.liveSubIndexes = {}
    self:_CreateSubTargets()
end

function ArcheryTarget2D:GetGoName()
    return "ArcheryTarget2D"
end

function ArcheryTarget2D:GetSpritePath()
    return self.cfg and self.cfg.spritePath or nil
end

--- 按 subCount 横向排列创建若干靶块子节点，替代原版的 target_group/target_i 固定挂点结构
function ArcheryTarget2D:_CreateSubTargets()
    local size = self.cfg.subSize or Vector2(20, 20)
    local spacing = self.cfg.subSpacing or (size.x + 4)
    local totalWidth = spacing * (self.subCount - 1)
    local startX = -totalWidth * 0.5

    for i = 1, self.subCount do
        local go = GameObject("Sub" .. i, RectTransform)
        go.transform:SetParent(self.go.transform, false)
        local rt = go:GetComponent(RectTransform)
        rt.sizeDelta = size
        rt.anchoredPosition = Vector2(startX + (i - 1) * spacing, 0)

        local img = go:AddComponent(Image)
        if self.cfg.subSpritePath ~= nil then
            img:LoadSprite(self.cfg.subSpritePath)
        end

        self.subNodes[i] = rt
        table.insert(self.liveSubIndexes, i)
    end
end

--- 每帧推进受击冷却，不做位移（箭塔是静态目标）
function ArcheryTarget2D:Update(dt)
    self.curHitCd = math.max(0, self.curHitCd - dt)
end

--- 命中：冷却内忽略，否则累计单个靶块血量，耗尽则随机打碎一个存活靶块
--- @param damage number
--- @return boolean isDead 是否所有靶块都已打碎
function ArcheryTarget2D:TakeDamage(damage)
    if self.isDead or self.curHitCd > 0 then
        return self.isDead
    end
    self.curHitCd = self.hitCdSec

    self.curSubBlood = math.max(0, self.curSubBlood - (damage or 0))
    if self.curSubBlood <= 0 then
        self:_DestroyOneSubTarget()
        self.curSubBlood = self.subHp
    end
    return self.isDead
end

--- 随机挑一个存活靶块打碎并隐藏，全部打碎后走 OnDeath 流程
function ArcheryTarget2D:_DestroyOneSubTarget()
    local liveCount = #self.liveSubIndexes
    if liveCount <= 0 then
        return
    end

    local pick = math.random(liveCount)
    local subIndex = self.liveSubIndexes[pick]
    table.remove(self.liveSubIndexes, pick)

    local node = self.subNodes[subIndex]
    if node ~= nil and not IsNull(node) then
        node.gameObject:SetActive(false)
    end

    if self.cfg.onSubDestroyed ~= nil then
        self.cfg.onSubDestroyed(#self.liveSubIndexes, self)
    end

    if #self.liveSubIndexes <= 0 then
        self.isDead = true
        self:OnDeath()
    end
end

function ArcheryTarget2D:GetLiveSubCount()
    return #self.liveSubIndexes
end

function ArcheryTarget2D:Destroy()
    self.subNodes = nil
    self.liveSubIndexes = nil
    Monster2DBase.Destroy(self)
end

return ArcheryTarget2D
