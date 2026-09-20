---
--- STG 波次生成器
--- 按 enemyWaveTemplates 的 formation / entryPath 计算编队成员的出生点与入场延时
--- 本类是纯逻辑：只产出 SpawnRequest，不创建 GameObject
--- 表现层（UIPlaneBattleView）收到 OnSpawnRequests 后自行实例化 PlaneUnit
---
--- 用法：
---   spawner:Reset(cfg)                              -- 绑定关卡配置
---   spawner:SpawnWave(templateId, offsetX)          -- 时间轴事件调用
---   spawner:Update(dt)                              -- 每帧推进，产出到期的 SpawnRequest
---
---@class StgWaveSpawner
local StgWaveSpawner = {}
StgWaveSpawner.__index = StgWaveSpawner

--- 阵型类型（对齐编辑器 StgWaveTemplate.formationType）
local Formation = {
    Single  = "single",
    Row     = "row",       -- 横排
    Column  = "column",    -- 竖排
    VShape  = "v_shape",   -- V 字
}

--- 入场路径类型（对齐编辑器 StgWaveTemplate.entryPathType）
local EntryPath = {
    FromTopStraight = "from_top_straight",
    FromTopSine     = "from_top_sine",
}

--- 参考分辨率宽 750 的一半（与 UIPlaneBattleView.SCREEN_HALF_W 保持一致）
local SCREEN_HALF_W = 375
local SPAWN_TOP_Y   = 900

function StgWaveSpawner.New()
    local self = setmetatable({}, StgWaveSpawner)
    self.cfg = nil
    self.pending = {}   -- { {delay, request}, ... } 延时待发队列
    self.time = 0
    self.spawnEnabled = true
    return self
end

--- @param cfg table StgLevelConfig
function StgWaveSpawner:Reset(cfg)
    self.cfg = cfg
    self.pending = {}
    self.time = 0
    self.spawnEnabled = true
end

function StgWaveSpawner:SetSpawnEnabled(enabled)
    self.spawnEnabled = enabled == true
end

--- 每帧推进，把到点的 SpawnRequest 通过回调吐出去（含暂停自动恢复）
--- @param dt number
--- @param onSpawn fun(requests:table[]) 到点的生成请求列表（可一次多个）
function StgWaveSpawner:Update(dt, onSpawn)
    self.time = self.time + dt

    -- 自动恢复
    if not self.spawnEnabled and self.resumeTime ~= nil and self.time >= self.resumeTime then
        self:ResumeSpawn()
    end

    if not self.spawnEnabled then
        return
    end

    local due = {}
    local i = 1
    while i <= #self.pending do
        local item = self.pending[i]
        if item.fireTime <= self.time then
            table.insert(due, item.request)
            table.remove(self.pending, i)
        else
            i = i + 1
        end
    end

    if #due > 0 and onSpawn ~= nil then
        onSpawn(due)
    end
end

--- 触发一波编队生成
--- @param templateId string enemyWaveTemplates 里的 id
--- @param offsetX number 归一化横坐标偏移（-1~1，对齐时间轴事件 offsetX）
--- @return boolean 是否找到模板
function StgWaveSpawner:SpawnWave(templateId, offsetX)
    if self.cfg == nil then
        Logger.LogError('#StgWaveSpawner# 未 Reset 就 SpawnWave')
        return false
    end

    local template = self.cfg.waveById[templateId]
    if template == nil then
        Logger.LogError('#StgWaveSpawner# 波次模板不存在 templateId=' .. tostring(templateId))
        return false
    end

    offsetX = tonumber(offsetX) or 0
    local positions = self:ComputeFormationPositions(template, offsetX)

    for idx, pos in ipairs(positions) do
        local delay = self:ComputeEntryDelay(template, idx)
        table.insert(self.pending, {
            fireTime = self.time + delay,
            request  = self:BuildRequest(template, pos, idx),
        })
    end

    Logger.Log('#StgWaveSpawner# 生成波次 templateId=' .. templateId
        .. ' count=' .. #positions .. ' formation=' .. template.formation.type)
    return true
end

--- 计算编队各成员的归一化出生坐标
--- @param template table
--- @param offsetX number
--- @return table[] { {x=number, y=number}, ... } x 归一化 -1~1，y 屏幕坐标
function StgWaveSpawner:ComputeFormationPositions(template, offsetX)
    local count = math.max(1, tonumber(template.count) or 1)
    local ftype = template.formation.type or Formation.Single
    local spacing = tonumber(template.formation.spacing) or 0
    -- spacing 配置为像素，换算成归一化（相对半屏宽）
    local spacingNorm = spacing / SCREEN_HALF_W

    local positions = {}

    if ftype == Formation.Single or count == 1 then
        table.insert(positions, { x = offsetX, y = SPAWN_TOP_Y })

    elseif ftype == Formation.Row then
        -- 横排：以 offsetX 为中心，左右对称展开
        local totalWidth = spacingNorm * (count - 1)
        local startX = offsetX - totalWidth * 0.5
        for i = 1, count do
            table.insert(positions, {
                x = startX + (i - 1) * spacingNorm,
                y = SPAWN_TOP_Y,
            })
        end

    elseif ftype == Formation.Column then
        -- 竖排：同一 x，y 递减（入场更靠后的先在更上方）
        local rowDelay = tonumber(template.formation.rowDelay) or 0
        local speed = tonumber(template.entryPath.speed) or 200
        local yOffset = rowDelay * speed
        for i = 1, count do
            table.insert(positions, {
                x = offsetX,
                y = SPAWN_TOP_Y + (i - 1) * yOffset,
            })
        end

    elseif ftype == Formation.VShape then
        -- V 字：中间靠上，两侧靠下
        local half = math.floor(count / 2)
        for i = 1, count do
            local offsetFromCenter = i - 1 - half
            table.insert(positions, {
                x = offsetX + offsetFromCenter * spacingNorm,
                y = SPAWN_TOP_Y + math.abs(offsetFromCenter) * (spacing * 0.3),
            })
        end

    else
        Logger.LogError('#StgWaveSpawner# 未知阵型 type=' .. tostring(ftype) .. ' 按 single 处理')
        table.insert(positions, { x = offsetX, y = SPAWN_TOP_Y })
    end

    return positions
end

--- 计算第 idx 个成员的入场延时（秒）
function StgWaveSpawner:ComputeEntryDelay(template, idx)
    local ftype = template.formation.type or Formation.Single
    local rowDelay = tonumber(template.formation.rowDelay) or 0
    if ftype == Formation.Column then
        -- 竖排用 rowDelay 做逐个延时
        return (idx - 1) * rowDelay
    end
    -- row / v_shape / single：整波同屏出现
    return 0
end

--- 构造单个生成请求（表现层消费）
--- @return table
---   kind          "enemy" | "boss"
---   metaId        number  PlaneUnit 的 metaId（enemyType 数字化）
---   x             number  归一化横坐标 -1~1
---   y             number  屏幕 y
---   hp            number  模板血量（可覆盖 PlaneUnit 默认）
---   speed         number  入场速度
---   entryPathType string
---   amplitude     number  正弦振幅
---   behaviorType  string
---   fireInterval  number
---   bulletType    string
---   dropTableId   string
---   score         number
---   templateId    string
function StgWaveSpawner:BuildRequest(template, pos, index)
    return {
        kind          = "enemy",
        metaId        = tonumber(template.enemyType) or 8001,
        x             = pos.x,
        y             = pos.y,
        hp            = tonumber(template.hp) or 100,
        speed         = tonumber(template.entryPath.speed) or 200,
        entryPathType = template.entryPath.type or EntryPath.FromTopStraight,
        amplitude     = tonumber(template.entryPath.amplitude) or 0,
        behaviorType  = template.behavior.type or "straight_down",
        fireInterval  = tonumber(template.behavior.fireInterval) or 2,
        bulletType    = template.behavior.bulletType or "",
        dropTableId   = template.dropTableId or "",
        score         = tonumber(template.score) or 100,
        templateId    = template.templateId,
        memberIndex   = index,
    }
end

--- 暂停/恢复刷怪（对齐时间轴 pause_enemy_spawn / resume_enemy_spawn）
function StgWaveSpawner:PauseSpawn(duration)
    self.spawnEnabled = false
    if duration ~= nil and duration > 0 then
        self.resumeTime = self.time + duration
    end
end

function StgWaveSpawner:ResumeSpawn()
    self.spawnEnabled = true
    self.resumeTime = nil
end

--- 清空待发队列
function StgWaveSpawner:ClearPending()
    self.pending = {}
end

function StgWaveSpawner:GetPendingCount()
    return #self.pending
end

StgWaveSpawner.Formation = Formation
StgWaveSpawner.EntryPath = EntryPath

return StgWaveSpawner
