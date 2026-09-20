---
--- 数字门 paraTable 编解码
--- 契约：Assets/Editor/STG/Data/StgGateParaTableUtil.cs
--- 分隔符：';' 分条目，'|' 分字段
---   gate_step:    "阈值|效果id;阈值|效果id;..."
---   gate_counter: "min|max|效果id;min|max|效果id;..."
---   gate_duet:    左栏 paraTable，右栏 paraTableRight，格式同 counter
---@class StgGateParaUtil
local StgGateParaUtil = {}

--- 解析 gate_step 区间表
--- @return table[] { {threshold=number, effectId=string}, ... } 按配置顺序
function StgGateParaUtil.DecodeStep(paraTable)
    local list = {}
    if type(paraTable) ~= "string" or paraTable == "" then
        return list
    end
    for entry in string.gmatch(paraTable, "[^;]+") do
        local threshold, effectId = string.match(entry, "^([^|]+)|(.+)$")
        if threshold ~= nil then
            table.insert(list, {
                threshold = tonumber(threshold) or 0,
                effectId  = effectId,
            })
        end
    end
    return list
end

--- 解析 gate_counter / gate_duet 区间表
--- @return table[] { {min=number, max=number, effectId=string}, ... } 按配置顺序
function StgGateParaUtil.DecodeCounter(paraTable)
    local list = {}
    if type(paraTable) ~= "string" or paraTable == "" then
        return list
    end
    for entry in string.gmatch(paraTable, "[^;]+") do
        local min, max, effectId = string.match(entry, "^([^|]+)|([^|]+)|(.+)$")
        if min ~= nil then
            table.insert(list, {
                min      = tonumber(min) or 0,
                max      = tonumber(max) or 0,
                effectId = effectId,
            })
        end
    end
    return list
end

--- counter 表：按当前数值找命中区间
--- 运行时语义对齐 barrel UpgradeableGate2.__reCalcIndexAndEvent：
---   按配置顺序找最后一个 min <= value 的条目（编辑器已保证区间连续且按 min 升序）
--- @param entries table[] DecodeCounter 结果
--- @param value number 当前计数值
--- @return string|nil effectId
--- @return number|nil index
function StgGateParaUtil.FindCounterEffect(entries, value)
    if entries == nil or #entries == 0 then
        return nil, nil
    end
    local hitEffect, hitIndex = nil, nil
    for i, e in ipairs(entries) do
        if value >= e.min then
            hitEffect = e.effectId
            hitIndex  = i
        else
            break
        end
    end
    return hitEffect, hitIndex
end

--- step 表：按累计伤害找命中档位
--- 语义对齐 barrel UpgradeableGate.TryUpgrade：伤害达到 threshold 切下一档
--- @param entries table[] DecodeStep 结果
--- @param accumulatedDamage number 累计伤害
--- @return string|nil effectId
--- @return number|nil index
function StgGateParaUtil.FindStepEffect(entries, accumulatedDamage)
    if entries == nil or #entries == 0 then
        return nil, nil
    end
    local hitEffect, hitIndex = nil, nil
    for i, e in ipairs(entries) do
        if accumulatedDamage >= e.threshold then
            hitEffect = e.effectId
            hitIndex  = i
        else
            break
        end
    end
    return hitEffect, hitIndex
end

return StgGateParaUtil
