---
--- STG 关卡配置加载器
--- 单向适配编辑器导出 JSON（Assets/Editor/STG/Data/StgLevelJsonIO.cs）
--- 字段契约见 Docs/STG/STG导出格式_运行时字段对照表.md
---
--- 用法：
---   local StgLevelConfig = require "Game.STG.DataCenter.StgLevelConfig"
---   local cfg = StgLevelConfig.Load("1001")
---   if cfg == nil then return end
---   local waves = cfg.waveTemplates          -- 按 templateId 索引
---   local timeline = cfg.timeline            -- { duration, events[] 按 time 升序 }
---
--- 资源路径：Resources/STG/Levels/{levelId}.json（TextAsset）
---@class StgLevelConfig
local StgLevelConfig = {}

local Const = require "Game.STG.Const"
local StgGateParaUtil = require "Game.STG.DataCenter.StgGateParaUtil"

--- levelId -> cfg 缓存
local cache = {}

--- 安全取字段（编辑器导出的数字可能是 int/float，字符串可能缺省）
local function Str(j, key, def)
    if type(j) ~= "table" then return def end
    local v = j[key]
    if v == nil then return def end
    return tostring(v)
end

local function Num(j, key, def)
    if type(j) ~= "table" then return def end
    local v = j[key]
    if v == nil then return def end
    local n = tonumber(v)
    if n == nil then return def end
    return n
end

local function Bool(j, key, def)
    if type(j) ~= "table" then return def end
    local v = j[key]
    if v == nil then return def end
    return v == true
end

local function Vec2(j, key, defX, defY)
    if type(j) ~= "table" then return defX, defY end
    local v = j[key]
    if type(v) ~= "table" then return defX, defY end
    return Num(v, "x", defX), Num(v, "y", defY)
end

local function Arr(j, key)
    if type(j) ~= "table" then return {} end
    local v = j[key]
    if type(v) ~= "table" then return {} end
    return v
end

--- ---------- 解析各段 ----------

local function ParseBasicScroll(j)
    return {
        baseSpeed          = Num(j, "baseSpeed", 300),
        speedMultiplier    = Num(j, "speedMultiplier", 1),
        rampUpTime         = Num(j, "rampUpTime", 0),
        rampUpTargetSpeed  = Num(j, "rampUpTargetSpeed", 300),
    }
end

local function ParseScatterRules(arr)
    local list = {}
    for _, r in ipairs(arr or {}) do
        local sizeMin, sizeMax = 1, 1
        if type(r.sizeRange) == "table" then
            sizeMin = tonumber(r.sizeRange[1]) or 1
            sizeMax = tonumber(r.sizeRange[2]) or 1
        end
        table.insert(list, {
            ruleName             = Str(r, "ruleName", ""),
            prefabPath           = Str(r, "prefabPath", ""),
            weight               = Num(r, "weight", 1),
            sizeRangeMin         = sizeMin,
            sizeRangeMax         = sizeMax,
            allowPartialOffscreen= Bool(r, "allowPartialOffscreen", true),
        })
    end
    return list
end

local function ParseBackgroundLayers(arr)
    local list = {}
    for _, l in ipairs(arr or {}) do
        local layer = {
            layerId           = Str(l, "layerId", ""),
            layerName         = Str(l, "layerName", ""),
            layerType         = Str(l, "layerType", "parallax"),
            orderInLayer      = Num(l, "orderInLayer", 0),
            speedCoefficient  = Num(l, "speedCoefficient", 1),
            useTileLoop       = Bool(l, "useTileLoop", false),
            tileSpritePaths   = {},
            tileWorldHeight   = Num(l, "tileWorldHeight", 0),
            enableScatterSpawn= Bool(l, "enableScatterSpawn", false),
            scatterIntervalMin= 1,
            scatterIntervalMax= 2,
            scatterMaxActive  = Num(l, "scatterMaxActive", 6),
            scatterOverlapCheckRadius = Num(l, "scatterOverlapCheckRadius", 150),
            scatterSpawnYOffset = Num(l, "scatterSpawnYOffset", 100),
            scatterRules      = {},
        }
        for _, p in ipairs(Arr(l, "tileSpritePaths")) do
            table.insert(layer.tileSpritePaths, tostring(p))
        end
        if type(l.scatterInterval) == "table" then
            layer.scatterIntervalMin = tonumber(l.scatterInterval[1]) or 1
            layer.scatterIntervalMax = tonumber(l.scatterInterval[2]) or 2
        end
        layer.scatterRules = ParseScatterRules(Arr(l, "scatterRules"))
        table.insert(list, layer)
    end
    return list
end

local function ParseObjectPool(j)
    return {
        backgroundLayerPoolSize = Num(j, "backgroundLayerPoolSize", 20),
        enemyPoolSize           = Num(j, "enemyPoolSize", 30),
        bossPoolSize            = Num(j, "bossPoolSize", 2),
        bulletPoolSize          = Num(j, "bulletPoolSize", 100),
        itemPoolSize            = Num(j, "itemPoolSize", 50),
        trapPoolSize            = Num(j, "trapPoolSize", 15),
        preloadOnStart          = Bool(j, "preloadOnStart", true),
    }
end

local function ParseItemConfigs(arr)
    local list, byId = {}, {}
    for _, i in ipairs(arr or {}) do
        local item = {
            itemId           = Str(i, "itemId", ""),
            itemName         = Str(i, "itemName", ""),
            prefabPath       = Str(i, "prefabPath", ""),
            type             = Str(i, "type", "currency"),
            value            = Num(i, "value", 0),
            moveMode         = Str(i, "moveMode", "fall_down"),
            attractToPlayer  = Bool(i, "attractToPlayer", true),
            attractRadius    = Num(i, "attractRadius", 100),
            lifetime         = Num(i, "lifetime", 10),
        }
        table.insert(list, item)
        if item.itemId ~= "" then
            byId[item.itemId] = item
        end
    end
    return list, byId
end

local function ParseDropTables(arr)
    local byId = {}
    for _, d in ipairs(arr or {}) do
        local entries = {}
        for _, e in ipairs(Arr(d, "entries")) do
            local cMin, cMax = 1, 1
            if type(e.countRange) == "table" then
                cMin = tonumber(e.countRange[1]) or 1
                cMax = tonumber(e.countRange[2]) or 1
            end
            table.insert(entries, {
                itemId      = Str(e, "itemId", ""),
                probability = Num(e, "probability", 0),
                countMin    = cMin,
                countMax    = cMax,
            })
        end
        local id = Str(d, "dropTableId", "")
        if id ~= "" then
            byId[id] = { dropTableId = id, entries = entries }
        end
    end
    return byId
end

local function ParseSpawnAreas(arr)
    local list, byId = {}, {}
    for _, s in ipairs(arr or {}) do
        local cx, cy = Vec2(s, "centerCoord", 0, 0)
        local area = {
            spawnAreaId   = Str(s, "spawnAreaId", ""),
            type          = Str(s, "type", "fix_point"),
            centerX       = cx,
            centerY       = cy,
            monsterWeights= Str(s, "monsterWeights", ""),
            limit         = Num(s, "limit", 10),
            intervalMin   = Num(s, "intervalMin", 1),
            intervalMax   = Num(s, "intervalMax", 2),
            interval      = Num(s, "interval", 1),
            radiusOuter   = Num(s, "radiusOuter", 200),
            radiusInner   = Num(s, "radiusInner", 0),
            centerOffsetY = Num(s, "centerOffsetY", 0),
        }
        table.insert(list, area)
        if area.spawnAreaId ~= "" then
            byId[area.spawnAreaId] = area
        end
    end
    return list, byId
end

local function ParseWaveTemplates(arr)
    local list, byId = {}, {}
    for _, t in ipairs(arr or {}) do
        local wave = {
            templateId   = Str(t, "templateId", ""),
            templateName = Str(t, "templateName", ""),
            enemyType    = Str(t, "enemyType", ""),
            count        = Num(t, "count", 1),
            formation = {
                type    = Str(t.formation, "type", "single"),
                spacing = Num(t.formation, "spacing", 0),
                rowDelay= Num(t.formation, "rowDelay", 0),
            },
            entryPath = {
                type     = Str(t.entryPath, "type", "from_top_straight"),
                speed    = Num(t.entryPath, "speed", 200),
                amplitude= Num(t.entryPath, "amplitude", 0),
            },
            behavior = {
                type         = Str(t.behavior, "type", "straight_down"),
                fireInterval = Num(t.behavior, "fireInterval", 2),
                bulletType   = Str(t.behavior, "bulletType", ""),
            },
            hp          = Num(t, "hp", 100),
            score       = Num(t, "score", 100),
            dropTableId = Str(t, "dropTableId", ""),
        }
        table.insert(list, wave)
        if wave.templateId ~= "" then
            byId[wave.templateId] = wave
        end
    end
    return list, byId
end

local function ParseBossSkills(arr)
    local list = {}
    for _, s in ipairs(arr or {}) do
        table.insert(list, {
            skillId         = Str(s, "skillId", "spread_shot"),
            interval        = Num(s, "interval", 2),
            bulletCount     = Num(s, "bulletCount", 5),
            spreadAngle     = Num(s, "spreadAngle", 60),
            duration        = Num(s, "duration", 0),
            width           = Num(s, "width", 0),
            rings           = Num(s, "rings", 0),
            waveTemplateId  = Str(s, "waveTemplateId", ""),
            count           = Num(s, "count", 0),
            speed           = Num(s, "speed", 0),
            damageReduction = Num(s, "damageReduction", 0),
        })
    end
    return list
end

local function ParseBossConfigs(arr)
    local list, byId = {}, {}
    for _, b in ipairs(arr or {}) do
        local phases = {}
        for _, p in ipairs(Arr(b, "phases")) do
            table.insert(phases, {
                phaseId     = Num(p, "phaseId", 1),
                hpThreshold = Num(p, "hpThreshold", 1),
                movePattern = Str(p, "movePattern", "horizontal_patrol"),
                skills      = ParseBossSkills(Arr(p, "skills")),
            })
        end
        local dropOnDeath = {}
        for _, d in ipairs(Arr(b, "dropOnDeath")) do
            table.insert(dropOnDeath, {
                itemId = Str(d, "itemId", ""),
                count  = Num(d, "count", 1),
            })
        end
        local boss = {
            bossId          = Str(b, "bossId", ""),
            bossName        = Str(b, "bossName", ""),
            prefabPath      = Str(b, "prefabPath", ""),
            entryAnimation  = Str(b, "entryAnimation", "fly_in_from_top"),
            totalHp         = Num(b, "totalHp", 5000),
            score           = Num(b, "score", 5000),
            phases          = phases,
            dropOnDeath     = dropOnDeath,
            onDefeatEvent   = Str(b, "onDefeatEvent", ""),
        }
        table.insert(list, boss)
        if boss.bossId ~= "" then
            byId[boss.bossId] = boss
        end
    end
    return list, byId
end

local function ParseTrapConfigs(arr)
    local list, byId, gateTemplates = {}, {}, {}
    for _, t in ipairs(arr or {}) do
        local px, py = Vec2(t, "position", 0, 0)
        local params = t.params
        if type(params) ~= "table" then params = {} end

        local trap = {
            trapId      = Str(t, "trapId", ""),
            trapName    = Str(t, "trapName", ""),
            type        = Str(t, "type", "static_obstacle"),
            prefabPath  = Str(t, "prefabPath", ""),
            positionX   = px,
            positionY   = py,
            hp          = Num(t, "hp", 9999),
            destroyable = Bool(t, "destroyable", false),
            dropTableId = Str(t, "dropTableId", ""),
            params      = params,
        }

        -- digital_gate：预解析 paraTable，运行时直接用
        if trap.type == Const.TrapType.DigitalGate then
            trap.gateType   = Str(params, "gateType", Const.GateType.Step)
            trap.initialValue = Num(params, "initialValue", 0)
            trap.effectTableRef = Str(params, "effectTableRef", "")
            trap.isReusableGateTemplate = Bool(t, "isReusableGateTemplate", false)

            if trap.gateType == Const.GateType.Step then
                trap.paraEntries = StgGateParaUtil.DecodeStep(Str(params, "paraTable", ""))
            else
                -- counter / duet 左栏
                trap.paraEntries = StgGateParaUtil.DecodeCounter(Str(params, "paraTable", ""))
                if trap.gateType == Const.GateType.Duet then
                    trap.paraEntriesRight = StgGateParaUtil.DecodeCounter(Str(params, "paraTableRight", ""))
                end
            end

            if trap.isReusableGateTemplate then
                gateTemplates[trap.trapId] = trap
            end
        end

        table.insert(list, trap)
        if trap.trapId ~= "" then
            byId[trap.trapId] = trap
        end
    end
    return list, byId, gateTemplates
end

local function ParseTimeline(j)
    local events = {}
    for _, e in ipairs(Arr(j, "events")) do
        local ev = {
            time = Num(e, "time", 0),
            type = Str(e, "type", ""),
            -- 通用字段全量保留，按 type 取用（对齐 StgLevelJsonIO.TimelineEventToJson）
            templateId   = Str(e, "templateId", ""),
            offsetX      = Num(e, "offsetX", 0),
            bossId       = Str(e, "bossId", ""),
            trapId       = Str(e, "trapId", ""),
            spawnAreaId  = Str(e, "spawnAreaId", ""),
            startTime    = Num(e, "startTime", 0),
            endTime      = Num(e, "endTime", 0),
            itemId       = Str(e, "itemId", ""),
            pattern      = Str(e, "pattern", "single"),
            count        = Num(e, "count", 1),
            spacing      = Num(e, "spacing", 0),
            speed        = Num(e, "speed", 0),
            text         = Str(e, "text", ""),
            duration     = Num(e, "duration", 0),
            bgmId        = Str(e, "bgmId", ""),
            fadeDuration = Num(e, "fadeDuration", 0),
            cutsceneId   = Str(e, "cutsceneId", ""),
            gateType     = Str(e, "gateType", ""),
            dropIntervalSec = Num(e, "interval", 0.1),
            dropAniDuration = Num(e, "dropAniDuration", 0.5),
        }

        local px, py = Vec2(e, "position", 0, 0)
        ev.positionX, ev.positionY = px, py

        if type(e.offsetRange) == "table" then
            ev.offsetXMin = Num(e.offsetRange, "xMin", 0)
            ev.offsetXMax = Num(e.offsetRange, "xMax", 0)
            ev.offsetYMin = Num(e.offsetRange, "yMin", 0)
            ev.offsetYMax = Num(e.offsetRange, "yMax", 0)
        end

        table.insert(events, ev)
    end
    table.sort(events, function(a, b) return a.time < b.time end)

    return {
        duration = Num(j, "duration", 60),
        events   = events,
    }
end

--- ---------- 对外接口 ----------

--- 加载并解析关卡配置
--- @param levelId string|number
--- @return table|nil cfg
function StgLevelConfig.Load(levelId)
    levelId = tostring(levelId)
    if cache[levelId] ~= nil then
        return cache[levelId]
    end

    local path = Const.LEVEL_JSON_DIR .. levelId
    local asset = CS.UnityEngine.Resources.Load(path, typeof(CS.UnityEngine.TextAsset))
    if asset == nil then
        Logger.LogError('#STG# 关卡JSON不存在 Resources/' .. path .. '.json')
        return nil
    end

    local ok, root = pcall(CommonUtil.JsonDecode, asset.text)
    if not ok or type(root) ~= "table" then
        Logger.LogError('#STG# 关卡JSON解析失败 levelId=' .. levelId .. ' err=' .. tostring(root))
        return nil
    end

    local itemList, itemById = ParseItemConfigs(Arr(root, "itemConfigs"))
    local spawnList, spawnById = ParseSpawnAreas(Arr(root, "spawnAreaConfigs"))
    local waveList, waveById = ParseWaveTemplates(Arr(root, "enemyWaveTemplates"))
    local bossList, bossById = ParseBossConfigs(Arr(root, "bossConfigs"))
    local trapList, trapById, gateTemplates = ParseTrapConfigs(Arr(root, "trapConfigs"))

    local cfg = {
        version        = Str(root, "version", "1.0"),
        levelId        = Str(root, "levelId", levelId),
        levelName      = Str(root, "levelName", ""),
        description    = Str(root, "description", ""),
        seed           = Num(root, "seed", 0),

        basicScroll    = ParseBasicScroll(root.basicScroll),
        backgroundLayers = ParseBackgroundLayers(Arr(root, "backgroundLayers")),
        objectPool     = ParseObjectPool(root.objectPool),

        itemList       = itemList,
        itemById       = itemById,
        dropTables     = ParseDropTables(Arr(root, "globalDropTables")),

        spawnAreas     = spawnList,
        spawnAreaById  = spawnById,
        waveTemplates  = waveList,
        waveById       = waveById,
        bossConfigs    = bossList,
        bossById       = bossById,
        trapConfigs    = trapList,
        trapById       = trapById,
        gateTemplates  = gateTemplates,  -- isReusableGateTemplate=true 的门，供 drop_digital_gate 引用

        timeline       = ParseTimeline(root.timeline),
    }

    cache[levelId] = cfg
    Logger.Log('#STG# 加载关卡 levelId=' .. levelId .. ' name=' .. cfg.levelName
        .. ' waves=' .. #cfg.waveTemplates .. ' traps=' .. #cfg.trapConfigs
        .. ' events=' .. #cfg.timeline.events .. ' duration=' .. cfg.timeline.duration)
    return cfg
end

--- 强制重载（编辑器热更/调试用）
function StgLevelConfig.ClearCache(levelId)
    if levelId == nil then
        cache = {}
    else
        cache[tostring(levelId)] = nil
    end
end

return StgLevelConfig
