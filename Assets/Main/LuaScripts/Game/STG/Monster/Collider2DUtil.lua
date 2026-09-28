---
--- STG 怪物子系统 — 2D 碰撞检测封装
--- 把 Physics2D 的三种 OverlapXxxNonAlloc 调用统一成一个入口，调用方只需要传形状参数，
--- 不用关心具体是哪个 C# 重载。数组复用同一个静态缓冲区，避免每次检测都新分配。
---
--- 用法：
---   local hits, count = Collider2DUtil.OverlapBox(center, size, angle, layerMask)
---   for i = 1, count do local col = hits[i] end
---
---@class Collider2DUtil
local Collider2DUtil = {}

local Physics2D  = CS.UnityEngine.Physics2D
local Vector2    = CS.UnityEngine.Vector2
local CS_Array   = CS.System.Array
local CS_Collider2D = CS.UnityEngine.Collider2D

local MAX_RESULT = 10
--- 静态复用缓冲区：同一帧内多次检测会互相覆盖结果，调用方需要在拿到 count 后立刻读完 hits，
--- 不能跨帧持有引用（这一点和原 3D ColliderComponent 的 colliderArray 用法一致）。
local s_resultBuffer = CS_Array.CreateInstance(typeof(CS_Collider2D), MAX_RESULT)

--- 把 C# 数组包装成 1 基索引的 Lua 访问方式，返回 (buffer, count)
--- @param center table {x, y}
--- @param size table {x, y} 矩形宽高
--- @param angle number 旋转角度（度），默认 0
--- @param layerMask number 默认命中全部层
--- @return userdata, number
function Collider2DUtil.OverlapBox(center, size, angle, layerMask)
    local cnt = Physics2D.OverlapBoxNonAlloc(
        Vector2(center.x, center.y),
        Vector2(size.x, size.y),
        angle or 0,
        s_resultBuffer,
        layerMask or Physics2D.AllLayers
    )
    return s_resultBuffer, cnt
end

--- @param center table {x, y}
--- @param radius number
--- @param layerMask number
--- @return userdata, number
function Collider2DUtil.OverlapCircle(center, radius, layerMask)
    local cnt = Physics2D.OverlapCircleNonAlloc(
        Vector2(center.x, center.y),
        radius,
        s_resultBuffer,
        layerMask or Physics2D.AllLayers
    )
    return s_resultBuffer, cnt
end

--- 胶囊体检测，direction 对齐 CapsuleDirection2D（0=横向 Horizontal，1=纵向 Vertical）
--- @param center table {x, y}
--- @param size table {x, y} 胶囊体尺寸
--- @param direction number 0=Horizontal 1=Vertical
--- @param angle number 旋转角度（度）
--- @param layerMask number
--- @return userdata, number
function Collider2DUtil.OverlapCapsule(center, size, direction, angle, layerMask)
    local cnt = Physics2D.OverlapCapsuleNonAlloc(
        Vector2(center.x, center.y),
        Vector2(size.x, size.y),
        direction or 0,
        angle or 0,
        s_resultBuffer,
        layerMask or Physics2D.AllLayers
    )
    return s_resultBuffer, cnt
end

return Collider2DUtil
