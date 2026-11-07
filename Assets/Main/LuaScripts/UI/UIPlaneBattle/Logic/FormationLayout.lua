---
--- 探险玩法 战斗 — 编队站位纯函数
--- 参考 barrel（D:\UnityProject\barrel）ParkourTeamFormation 的设计思路：按数量分排布点，
--- 数量越多弧线越大；这里换算成 2D UI 坐标下的前方护航弧线，
--- 不是 barrel 原版的纵深矩阵站位。
---
--- 不依赖任何 Unity/Lua框架 API，可用 D:\lua 桩环境直接跑单元测试。
---
local FormationLayout = {}

--- 每弧最多容纳的僚机数（超过则开新弧，半径叠加）
local RING_CAPACITY = 6
--- 第一环半径（像素，UI坐标系）
local BASE_RADIUS = 82
--- 每多一环增加的半径
local RADIUS_STEP = 48

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
    local ringIndex = 0

    while remaining > 0 do
        local ringCount = math.min(remaining, RING_CAPACITY)
        local radius = BASE_RADIUS + ringIndex * RADIUS_STEP

        for i = 1, ringCount do
            -- 护航弧放在主机上方；下方空间留给拖动手势和主机。
            local angle = ringCount == 1 and math.pi / 2
                or math.pi * 0.18 + (math.pi * 0.64 * (i - 1)) / (ringCount - 1)
            local x = radius * math.cos(angle)
            local y = radius * math.sin(angle)
            table.insert(offsets, { x = x, y = y })
        end

        remaining = remaining - ringCount
        ringIndex = ringIndex + 1
    end

    return offsets
end

return FormationLayout
