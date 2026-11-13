---
--- 探险玩法 战斗 — 编队站位纯函数
--- 参考 barrel（D:\UnityProject\barrel）ParkourTeamFormation 的设计思路：按数量分排布点，
--- 数量越多排数越多；这里换算成 2D UI 坐标下的前方护航队列，
--- 不是 barrel 原版的纵深矩阵站位。
---
--- 不依赖任何 Unity/Lua框架 API，可用 D:\lua 桩环境直接跑单元测试。
---
local FormationLayout = {}

local ROW_CAPACITY = 6
local COLUMN_SPACING = 66
local ROW_SPACING = 82

--- 计算 count 个僚机相对主机的位置偏移
--- @param count number 僚机数量（<=0 返回空表）
--- @return table { {x, y}, {x, y}, ... } 长度为 count，围绕原点(0,0)分布
function FormationLayout.GetOffsets(count)
    count = math.floor(tonumber(count) or 0)
    if count <= 0 then
        return {}
    end

    local offsets = {}
    local remaining = count
    local rowIndex = 0

    while remaining > 0 do
        local rowCount = math.min(remaining, ROW_CAPACITY)

        for i = 1, rowCount do
            -- 各排之间留出机身/尾焰空间，浅 V 轮廓保持前方护航的方向感。
            local x = (i - (rowCount + 1) / 2) * COLUMN_SPACING
            local y = 100 + rowIndex * ROW_SPACING + (1 - math.abs(x) / 198) * 12
            table.insert(offsets, { x = x, y = y })
        end

        remaining = remaining - rowCount
        rowIndex = rowIndex + 1
    end

    return offsets
end

--- 靠近边缘时整队横移，保留队内间距，避免逐机钳制后挤在屏幕边上。
function FormationLayout.GetHorizontalShift(offsets, centerX, halfWidth)
    if #offsets == 0 then return 0 end
    local minX, maxX = math.huge, -math.huge
    for _, off in ipairs(offsets) do
        minX, maxX = math.min(minX, off.x), math.max(maxX, off.x)
    end
    return math.max(-halfWidth - minX - centerX, math.min(0, halfWidth - maxX - centerX))
end

return FormationLayout
