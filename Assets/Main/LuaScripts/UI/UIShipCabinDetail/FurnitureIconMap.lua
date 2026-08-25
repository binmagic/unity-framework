---
--- 家具图标映射：buildId + 序号 → 道具 sprite 名
---
--- 唯一真相源。详情面板的家具列表（UIShipCabinDetailView:_RefreshFurnitureItem）走这里。
---
--- 背景：Furniture_Config 有 368 条家具，但项目只有 21 张道具图
--- （Sprites/UIShipCabinClean/Props_NoText/）。原版参考图里每件家具都有具体图标，
--- 这里按「建筑类型选一组风格相符的图 + 组内按序号轮转」来铺满，
--- 保证同一建筑内相邻家具图标不同、且永远不会缺图。
---
--- 家具 id 在表里是按 buildId 连续分段的（build1:1-18, build2:19-35, ...），
--- 但**不要依赖这个规律去反推 buildId** —— 直接用 View 传进来的 buildId。
---
local FurnitureIconMap = {}

--- 道具图目录（Props_NoText 下实际存在的 21 张）
FurnitureIconMap.DIR = "Assets/Main/Sprites/UIShipCabinClean/Props_NoText/"

--- 按建筑功能分组的图标候选。组内按家具序号轮转。
--- 建筑功能参考 RoomSceneMap 的分类（能源/指挥/仓库/船坞/实验/医疗/通讯/宿舍）
local GROUPS = {
    power    = { "generator", "pipe_valve", "cable", "oil_barrel", "warning_sign" },
    command  = { "console", "large_screen", "computer_terminal", "server_rack", "safe" },
    warehouse= { "container", "shelf", "storage_cabinet", "cart", "toolbox" },
    shipyard = { "workbench", "toolbox", "ladder", "cart", "fire_extinguisher" },
    lab      = { "lab_bench", "computer_terminal", "server_rack", "console", "container" },
    medical  = { "medical_bed", "lab_bench", "storage_cabinet", "container", "shelf" },
    comms    = { "server_rack", "large_screen", "console", "cable", "computer_terminal" },
    dorm     = { "shelf", "storage_cabinet", "medical_bed", "container", "vent_duct" },
}

--- buildId → 分组。与 RoomSceneMap 的建筑分类保持一致。
local BY_BUILD = {
    [1]  = "power",     [2]  = "command",   [3]  = "command",   [4]  = "warehouse",
    [5]  = "warehouse", [6]  = "power",     [7]  = "shipyard",  [8]  = "shipyard",
    [9]  = "shipyard",  [10] = "shipyard",  [11] = "lab",       [12] = "power",
    [13] = "lab",       [14] = "lab",       [15] = "lab",       [16] = "command",
    [17] = "comms",     [18] = "comms",     [19] = "medical",   [20] = "medical",
    [21] = "dorm",      [22] = "dorm",      [23] = "warehouse", [24] = "shipyard",
    [25] = "lab",       [26] = "command",   [27] = "comms",     [28] = "power",
    [29] = "warehouse", [30] = "dorm",      [31] = "medical",   [32] = "shipyard",
    [33] = "lab",       [34] = "command",   [35] = "power",     [36] = "comms",
    [37] = "warehouse",
}

local DEFAULT_GROUP = "warehouse"

--- 按家具名关键词选图（优先级高于分组轮转）
---
--- 为什么加这一层：只按 buildId 分组 + 序号轮转的话，图标和家具名基本对不上
--- （"挂墙式机械工具箱"可能配到 medical_bed）。而 Furniture_Config 的
--- furniture_name 描述性很强，能覆盖绝大多数条目。
---
--- **顺序即优先级**，从具体到宽泛匹配，第一个命中就返回。
--- 所以像"柜"这种会被"配电柜/服务器柜"抢先命中的宽泛词必须排在后面。
local BY_KEYWORD = {
    -- 灭火 / 警示
    { "灭火",   "fire_extinguisher" },
    { "警示",   "warning_sign" },
    { "警报",   "warning_sign" },
    -- 屏幕 / 投影 / 监控（先于"台/席位"，"监视台"应出屏而不是操作台）
    { "监视",   "large_screen" },
    { "监控",   "large_screen" },
    { "监测",   "large_screen" },
    { "显示",   "large_screen" },
    { "投影",   "large_screen" },
    { "全息",   "large_screen" },
    { "幕",     "large_screen" },
    { "屏",     "large_screen" },
    -- 服务器 / 数据 / 机柜
    { "服务器", "server_rack" },
    { "机柜",   "server_rack" },
    { "机房",   "server_rack" },
    { "母机",   "server_rack" },
    { "数据",   "server_rack" },
    { "链路",   "server_rack" },
    -- 电力
    { "配电",   "generator" },
    { "电容",   "generator" },
    { "储能",   "generator" },
    { "电解",   "generator" },
    { "转换器", "generator" },
    { "变压",   "generator" },
    { "聚变",   "generator" },
    { "反应",   "generator" },
    { "电力",   "cable" },
    { "汇流",   "cable" },
    { "电缆",   "cable" },
    { "导热",   "cable" },
    -- 管路 / 罐体
    { "软管",   "pipe_valve" },
    { "管",     "pipe_valve" },
    { "阀",     "pipe_valve" },
    { "泵",     "pipe_valve" },
    { "循环",   "pipe_valve" },
    { "冷却",   "pipe_valve" },
    { "压力罐", "oil_barrel" },
    { "油",     "oil_barrel" },
    { "罐",     "oil_barrel" },
    { "腔",     "oil_barrel" },
    -- 搬运
    { "叉车",   "cart" },
    { "推车",   "cart" },
    { "搬运",   "cart" },
    { "起重",   "cart" },
    { "吊",     "cart" },
    { "轨道",   "cart" },
    -- 工具 / 维修
    { "工具",   "toolbox" },
    { "维修",   "toolbox" },
    { "工作台", "workbench" },
    { "工作舱", "workbench" },
    { "梯",     "ladder" },
    -- 仓储
    { "货架",   "shelf" },
    { "铁架",   "shelf" },
    { "格架",   "shelf" },
    { "格阵",   "shelf" },
    { "货物",   "shelf" },
    { "集装箱", "container" },
    { "运输箱", "container" },
    { "料斗",   "container" },
    { "箱",     "container" },
    { "保险",   "safe" },
    { "金库",   "safe" },
    -- 实验 / 分析
    { "分析",   "lab_bench" },
    { "实验",   "lab_bench" },
    { "扫描",   "lab_bench" },
    { "沙盘",   "lab_bench" },
    { "星图",   "lab_bench" },
    { "观测",   "lab_bench" },
    { "晶核",   "lab_bench" },
    -- 医疗 / 居住
    { "医",     "medical_bed" },
    { "治疗",   "medical_bed" },
    { "床",     "medical_bed" },
    { "睡",     "medical_bed" },
    -- 通风
    { "通风",   "vent_duct" },
    { "风道",   "vent_duct" },
    { "空气",   "vent_duct" },
    -- 席位 / 操作台（放最后：很多名字里都带"台/椅"，但更具体的词应先命中）
    { "王座",   "console" },
    { "指挥",   "console" },
    { "席位",   "console" },
    { "椅",     "console" },
    { "操作",   "console" },
    { "控制",   "console" },
    { "终端",   "computer_terminal" },
    { "计算",   "computer_terminal" },
    { "中枢",   "computer_terminal" },
    { "台",     "console" },
    -- 柜（宽泛，必须在配电柜/服务器柜之后）
    { "柜",     "storage_cabinet" },
    { "门",     "storage_cabinet" },
    { "闸",     "storage_cabinet" },

    -- ---- 第二批：覆盖上面漏掉的 127 条 ----
    -- 显示面（墙/板/图谱都归到屏）
    { "墙",     "large_screen" },
    { "面板",   "large_screen" },
    { "看板",   "large_screen" },
    { "图谱",   "large_screen" },
    { "相框",   "large_screen" },
    { "海报",   "large_screen" },
    { "记事板", "large_screen" },
    { "摄像",   "large_screen" },
    -- 熔炼 / 炉体（先于"机"，"熔炼炉"不该落到 workbench）
    { "熔炼",   "generator" },
    { "精炼",   "generator" },
    { "熔融",   "generator" },
    { "炉",     "generator" },
    { "光电",   "generator" },
    { "集光",   "generator" },
    { "充能",   "generator" },
    -- 线缆 / 导能
    { "导能",   "cable" },
    { "母线",   "cable" },
    { "电极",   "cable" },
    -- 通风 / 散热
    { "散热",   "vent_duct" },
    { "风扇",   "vent_duct" },
    { "风洞",   "vent_duct" },
    -- 通讯
    { "通讯",   "computer_terminal" },
    { "天线",   "server_rack" },
    { "耳机",   "computer_terminal" },
    { "手柄",   "computer_terminal" },
    -- 架类（先于"药剂/试剂"，"药剂架"是架子）
    { "架",     "shelf" },
    { "展示",   "shelf" },
    -- 实验器械
    { "药剂",   "lab_bench" },
    { "试剂",   "lab_bench" },
    { "光谱",   "lab_bench" },
    { "仪",     "lab_bench" },
    { "筛",     "lab_bench" },
    { "分选",   "lab_bench" },
    { "尺",     "lab_bench" },
    { "圆规",   "lab_bench" },
    { "生态",   "lab_bench" },
    { "环境",   "lab_bench" },
    -- 罐体 / 发酵
    { "发酵",   "oil_barrel" },
    { "釜",     "oil_barrel" },
    { "球",     "oil_barrel" },
    -- 搬运 / 输送（先于"机"）
    { "传送带", "cart" },
    { "输送",   "cart" },
    { "分拣",   "cart" },
    { "抓斗",   "cart" },
    { "抓取",   "cart" },
    { "吸盘",   "cart" },
    { "牵引",   "cart" },
    { "车",     "cart" },
    { "轨",     "cart" },
    -- 加工 / 装配（"机"很宽泛，排在具体词之后）
    { "焊",     "workbench" },
    { "装配",   "workbench" },
    { "拼装",   "workbench" },
    { "打印",   "workbench" },
    { "成型",   "workbench" },
    { "粉碎",   "workbench" },
    { "撕碎",   "workbench" },
    { "剪切",   "workbench" },
    { "打包",   "workbench" },
    { "建造",   "workbench" },
    { "烹饪",   "workbench" },
    { "对接",   "workbench" },
    { "廊",     "workbench" },
    { "机",     "workbench" },
    -- 夹具 / 锁扣 / 机械臂
    { "夹",     "toolbox" },
    { "锁",     "toolbox" },
    { "臂",     "toolbox" },
    { "触手",   "toolbox" },
    { "修复",   "toolbox" },
    -- 安全 / 靶标
    { "束缚",   "warning_sign" },
    { "靶",     "warning_sign" },
    { "信号",   "warning_sign" },
    { "灯",     "warning_sign" },
    -- 休息 / 舱茧
    { "沙发",   "medical_bed" },
    { "休息",   "medical_bed" },
    { "茧",     "medical_bed" },
    -- 容器（"舱/仓"很宽泛，放最后）
    { "存储",   "container" },
    { "胶囊",   "container" },
    { "舱",     "container" },
    { "仓",     "container" },
    -- 席位 / 桌面（补充）
    { "工作站", "console" },
    { "底座",   "console" },
    { "桌",     "console" },
    -- 管路（补充）
    { "流道",   "pipe_valve" },
    { "分配器", "pipe_valve" },
    { "槽",     "pipe_valve" },
}

--- 按名称关键词取图标名
---@param name string 家具名
---@return string|nil 命中的 sprite 名，未命中返回 nil
function FurnitureIconMap.GetSpriteNameByName(name)
    if name == nil or name == "" then return nil end
    for _, pair in ipairs(BY_KEYWORD) do
        if string.find(name, pair[1], 1, true) ~= nil then
            return pair[2]
        end
    end
    return nil
end

--- 取家具图标的 sprite 名
---
--- 先按家具名关键词匹配（绝大多数能命中且语义相符），
--- 没命中才退回「建筑分组 + 序号轮转」的兜底，保证永不缺图。
---@param buildId number 所属建筑 id
---@param index number 该家具在列表中的序号（1 起）
---@param name string|nil 家具名（可选，传了才走关键词匹配）
---@return string sprite 名（不含扩展名），保证非 nil
function FurnitureIconMap.GetSpriteName(buildId, index, name)
    local byName = FurnitureIconMap.GetSpriteNameByName(name)
    if byName ~= nil then return byName end

    local groupName = BY_BUILD[buildId] or DEFAULT_GROUP
    local group = GROUPS[groupName] or GROUPS[DEFAULT_GROUP]
    local i = ((tonumber(index) or 1) - 1) % #group + 1
    return group[i]
end

--- 取完整 sprite 路径（UIImage:LoadSprite 用）
function FurnitureIconMap.GetSpritePath(buildId, index, name)
    return FurnitureIconMap.DIR .. FurnitureIconMap.GetSpriteName(buildId, index, name) .. ".png"
end

return FurnitureIconMap
