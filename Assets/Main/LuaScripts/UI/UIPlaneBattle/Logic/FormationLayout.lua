---
--- 探险玩法 战斗 — 编队站位纯函数
--- 参考 barrel（D:\UnityProject\barrel）ParkourTeamFormation 的设计思路：按数量分排布点，
--- 数量越多环越大；这里换算成 2D UI 坐标下的环绕布局（贴合截图里"僚机围一圈"的效果），
--- 不是 barrel 原版的纵深矩阵站位。
---
--- 不依赖任何 Unity/Lua框架 API，可用 D:\lua 桩环境直接跑单元测试。
---
local FormationLayout = {}

--- 每环最多容纳的僚机数（超过则开新环，半径叠加）
local RING_CAPACITY = 8
--- 第一环半径（像素，UI坐标系）
local BASE_RADIUS = 110
--- 每多一环增加的半径
local RADIUS_STEP = 55

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
            -- 从正上方(90度)开始，均匀分布一圈，避免第一颗正好挡在主机前方正中
            local angle = math.pi / 2 + (2 * math.pi * (i - 1)) / ringCount
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
