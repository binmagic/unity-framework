---
--- STG 怪物子系统 — 区间匹配小工具
--- 从 ParkourBattle/Monster/MonsterImpl/UpgradeableGate2.lua 和 UpgradeableDuetGate.lua 里
--- 抽出的共享算法：两者的核心判定都是"按累计值在一张 {min, max, effectId} 区间表里找当前
--- 应该生效的档位"，原版各自实现了一份几乎一样的查找逻辑（`__reCalcIndexAndEvent`），这里
--- 抽成一个不依赖任何具体门类型的纯函数，供 CounterGate2D / DuetGate2D 共用，避免重复代码。
---
--- 用法：
---   local effectId = RangeMatchUtil.Match(ranges, value)
---
---@class RangeMatchUtil
local RangeMatchUtil = {}

--- 按当前值在区间表里找最后一个 min <= value 的档位，返回其 effectId。
--- 要求 ranges 按 min 升序排列（原版数据约定，这里不做排序，调用方负责传入有序表）。
--- @param ranges table[] { {min:number, max:number, effectId:any}, ... }
--- @param value number
--- @return any effectId，如果 value 小于所有档位的 min 则返回 nil
function RangeMatchUtil.Match(ranges, value)
    local matched = nil
    for _, range in ipairs(ranges) do
        if value >= range.min then
            matched = range.effectId
        else
            break
        end
    end
    return matched
end

return RangeMatchUtil
