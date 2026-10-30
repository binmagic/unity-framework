---
--- 舱室内景映射：buildId → RoomScene prefab 名称
---
--- 唯一真相源。船舱主界面格子（UIShipCabinView）和详情面板顶部预览
--- （ShipCabinDetailAnimator.cs 经 CSharpCallLuaInterface 查询）都必须走这里，
--- 不要各自维护一份表，否则同一个建筑在两处显示不同内景。
---
--- Building_Config 共 37 条；功能舱 prefab 按用途复用，内景由独立 Sprite 组件组成。
---
local RoomSceneMap = {}

--- 可用功能舱 prefab：engine / forge / warehouse / shipyard / medical / dorm /
--- command / lab / kitchen。

local BY_BUILD = {
    [1]  = "RoomScene_function_engine",    -- 聚变能源核心
    [2]  = "RoomScene_function_command",   -- 枢纽指挥中心
    [3]  = "RoomScene_function_command",   -- 全域最高指挥中枢
    [4]  = "RoomScene_function_warehouse", -- 食材仓库
    [5]  = "RoomScene_function_warehouse", -- 金属仓库
    [6]  = "RoomScene_function_engine",    -- 电力仓库
    [7]  = "RoomScene_function_shipyard",  -- 零重力装配船坞A组
    [8]  = "RoomScene_function_shipyard",  -- 零重力装配船坞B组
    [9]  = "RoomScene_function_shipyard",  -- 零重力装配船坞C组
    [10] = "RoomScene_function_shipyard",  -- 零重力装配船坞D组
    [11] = "RoomScene_function_lab",       -- 矿石精炼阵列
    [12] = "RoomScene_function_lab",       -- 能源采集舱
    [13] = "RoomScene_function_lab",       -- 有机质采集与合成舱
    [14] = "RoomScene_function_shipyard",  -- 精密部件铸造厂
    [15] = "RoomScene_function_shipyard",  -- 无人机组装流水线
    [16] = "RoomScene_function_warehouse", -- 废旧金属回收站
    [17] = "RoomScene_function_lab",       -- 量子实验室
    [18] = "RoomScene_function_lab",       -- 科技研究中心
    [19] = "RoomScene_function_command",   -- 蓝图解析档案馆
    [20] = "RoomScene_function_forge",     -- 实验性武器靶场
    [21] = "RoomScene_function_command",   -- 战术作战中心1组
    [22] = "RoomScene_function_command",   -- 战术作战中心2组
    [23] = "RoomScene_function_command",   -- 战术作战中心3组
    [24] = "RoomScene_function_shipyard",  -- 快速维修停机坪
    [25] = "RoomScene_function_command",   -- 深空雷达导航塔
    [26] = "RoomScene_function_warehouse", -- 泊船港
    [27] = "RoomScene_function_command",   -- 星际贸易交易所
    [28] = "RoomScene_function_dorm",      -- 舰员居住舱1组
    [29] = "RoomScene_function_dorm",      -- 舰员居住舱2组
    [30] = "RoomScene_function_dorm",      -- 舰员居住舱3组
    [31] = "RoomScene_function_dorm",      -- 舰员居住舱4组
    [32] = "RoomScene_function_kitchen",   -- 舰员中央厨房
    [33] = "RoomScene_function_medical",   -- 舰员医疗舱
    [34] = "RoomScene_function_engine",    -- 点防御阵列
    [35] = "RoomScene_function_engine",    -- 结构增强力场发生器
    [36] = "RoomScene_function_warehouse", -- 战利品展览舱
    [37] = "RoomScene_function_command",   -- 情报洗练中心
}

local DEFAULT_SCENE = "RoomScene_function_warehouse"

RoomSceneMap.PREFAB_DIR = "Assets/Main/Prefabs/UI/UIShipCabin/Rooms/"

--- 取 buildId 对应的内景 prefab 名（未配置时返回默认值，不会返回 nil）
---@param buildId number
---@return string
function RoomSceneMap.GetSceneName(buildId)
    return BY_BUILD[tonumber(buildId) or 0] or DEFAULT_SCENE
end

--- 取 buildId 对应的内景 prefab 完整路径
---@param buildId number
---@return string
function RoomSceneMap.GetScenePath(buildId)
    return RoomSceneMap.PREFAB_DIR .. RoomSceneMap.GetSceneName(buildId) .. ".prefab"
end

return RoomSceneMap
