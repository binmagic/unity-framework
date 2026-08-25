---
--- 飞船游戏 — 自身玩家基础数据对象
--- 对标旧项目 PlayerInfo，只保留飞船游戏实际需要的字段
--- 不依赖服务器，所有字段均在本地内存中维护
---
---@class ShipSelfPlayerData
local ShipSelfPlayerData = BaseClass("ShipSelfPlayerData")

function ShipSelfPlayerData:__init()
    self:Reset()
end

function ShipSelfPlayerData:__delete()
    self:Reset()
end

--- ---------------------------------------------------------------
--- 字段定义
--- ---------------------------------------------------------------

function ShipSelfPlayerData:Reset()
    --- ---- 账号标识（对标 PlayerInfo）----
    self.uid        = ""    -- 玩家唯一 ID（对标 PlayerInfo.uid）
    self.serverId   = 0     -- 所在服务器 ID（对标 PlayerInfo.serverId）
    self.deviceId   = ""    -- 设备 ID（对标 PlayerInfo.deviceId）

    --- ---- 基础信息（对标 PlayerInfo）----
    self.name       = ""    -- 玩家名称（对标 PlayerInfo.name）
    self.level      = 1     -- 玩家等级（对标 PlayerInfo.level）
    self.exp        = 0     -- 当前经验值（对标 PlayerInfo.exp）
    self.sex        = 0     -- 性别：0=未设置 1=男 2=女（对标 PlayerInfo.sex）
    self.pic        = ""    -- 头像资源路径（对标 PlayerInfo.pic）
    self.picVer     = 0     -- 头像版本号（对标 PlayerInfo.picVer）

    --- ---- 战力（对标 PlayerInfo）----
    self.power          = 0     -- 总战力（对标 PlayerInfo.power）
    self.buildingPower  = 0     -- 建筑战力（对标 PlayerInfo.buildingPower）
    self.sciencePower   = 0     -- 科技战力（对标 PlayerInfo.sciencePower）
    self.armyPower      = 0     -- 军队战力（对标 PlayerInfo.armyPower）
    self.heroPower      = 0     -- 英雄战力（对标 PlayerInfo.heroPower）

    --- ---- 货币（对标 PlayerInfo）----
    self.gold       = 0     -- 钻石/硬货币（对标 PlayerInfo.gold）
    self.payTotal   = 0     -- 累计充值金额（对标 PlayerInfo.payTotal）

    --- ---- 联盟（对标 PlayerInfo）----
    self.allianceId     = 0     -- 联盟 ID（对标 PlayerInfo.allianceId）
    self.allianceName   = ""    -- 联盟名称
    self.alAbbr         = ""    -- 联盟缩写

    --- ---- 战绩（对标 PlayerInfo）----
    self.battleWin  = 0     -- 胜利场次（对标 PlayerInfo.battleWin）
    self.battleLose = 0     -- 失败场次（对标 PlayerInfo.battleLose）
    self.armyKill   = 0     -- 击杀兵力（对标 PlayerInfo.armyKill）
    self.armyDead   = 0     -- 阵亡兵力（对标 PlayerInfo.armyDead）

    --- ---- 体力（对标 PlayerInfo）----
    self.stamina            = 0     -- 当前体力（对标 PlayerInfo.stamina）
    self.lastStaminaTime    = 0     -- 上次体力恢复时间戳（对标 PlayerInfo.lastStaminaTime）

    --- ---- 保护盾（对标 PlayerInfo）----
    self.protectTimeStamp   = 0     -- 基地保护盾到期时间戳（对标 PlayerInfo.ProtectTimeStamp）

    --- ---- 注册/时间（对标 PlayerInfo）----
    self.regTime            = 0     -- 注册时间戳（对标 PlayerInfo.regTime）
    self.lastOffLineTime    = 0     -- 上次下线时间戳（对标 PlayerInfo.lastOffLineTime）
    self.openServerTime     = 0     -- 开服时间戳（对标 PlayerInfo.openServerTime）

    --- ---- 飞船游戏新增字段（旧项目无对应）----
    self.shipName       = ""    -- 飞船/空间站名称
    self.shipLevel      = 0     -- 飞船主建筑等级（枢纽指挥中心等级）
    self.totalPower     = 0     -- 全站总战力（所有建筑战力之和，本地计算）
    self.lastLoginTime  = 0     -- 上次登录时间戳
end

--- ---------------------------------------------------------------
--- 查询方法
--- ---------------------------------------------------------------

--- 获取玩家显示名称（有飞船名则优先显示）
function ShipSelfPlayerData:GetDisplayName()
    if self.shipName ~= "" then
        return self.shipName
    end
    return self.name ~= "" and self.name or "未命名指挥官"
end

--- 是否在联盟中
function ShipSelfPlayerData:IsInAlliance()
    return self.allianceId ~= 0
end

--- 保护盾是否有效
function ShipSelfPlayerData:IsProtected()
    return self.protectTimeStamp > os.time()
end

--- 保护盾剩余秒数
function ShipSelfPlayerData:GetProtectRemainSeconds()
    local remain = self.protectTimeStamp - os.time()
    return remain > 0 and remain or 0
end

--- 体力恢复计算（每 N 秒恢复 1 点，上限由外部配置决定）
--- recoverInterval: 每次恢复间隔秒数
--- maxStamina: 体力上限
function ShipSelfPlayerData:GetCurrentStamina(recoverInterval, maxStamina)
    if self.stamina >= maxStamina then
        return maxStamina
    end
    local elapsed   = os.time() - self.lastStaminaTime
    local recovered = math.floor(elapsed / recoverInterval)
    return math.min(self.stamina + recovered, maxStamina)
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

--- 从服务器初始化数据包解析（登录时调用）
--- 字段命名对标旧项目 PlayerInfo:UpdateUser / UpdatePlayerInfo 中的 message 字段
function ShipSelfPlayerData:InitFromServer(message)
    -- TODO: 服务器同步
    -- local user = message["user"]
    -- if user then
    --     self.uid              = tostring(user["uid"]    or "")
    --     self.serverId         = user["serverId"]        or 0
    --     self.name             = user["name"]            or ""
    --     self.level            = user["level"]           or 1
    --     self.exp              = user["exp"]             or 0
    --     self.sex              = user["sex"]             or 0
    --     self.pic              = user["pic"]             or ""
    --     self.picVer           = user["picVer"]          or 0
    --     self.gold             = user["gold"]            or 0
    --     self.payTotal         = user["payTotal"]        or 0
    --     self.allianceId       = user["allianceId"]      or 0
    --     self.allianceName     = user["allianceName"]    or ""
    --     self.alAbbr           = user["alAbbr"]          or ""
    --     self.battleWin        = user["battleWin"]       or 0
    --     self.battleLose       = user["battleLose"]      or 0
    --     self.armyKill         = user["armyKill"]        or 0
    --     self.armyDead         = user["armyDead"]        or 0
    --     self.stamina          = user["stamina"]         or 0
    --     self.lastStaminaTime  = user["lastStaminaTime"] or 0
    --     self.protectTimeStamp = user["protectTs"]       or 0
    --     self.regTime          = user["regTime"]         or 0
    --     self.lastOffLineTime  = user["lastOffLineTime"] or 0
    --     self.openServerTime   = user["openServerTime"]  or 0
    --     self.power            = user["power"]           or 0
    --     self.buildingPower    = user["buildingPower"]   or 0
    --     self.sciencePower     = user["sciencePower"]    or 0
    --     self.armyPower        = user["armyPower"]       or 0
    --     self.heroPower        = user["heroPower"]       or 0
    -- end
end

--- 增量更新（服务器推送部分字段变化时调用）
function ShipSelfPlayerData:ApplyServerDelta(message)
    -- TODO: 服务器同步
    -- if message["gold"]  ~= nil then self.gold  = message["gold"]  end
    -- if message["level"] ~= nil then self.level = message["level"] end
    -- if message["exp"]   ~= nil then self.exp   = message["exp"]   end
    -- if message["power"] ~= nil then self.power = message["power"] end
    -- if message["allianceId"] ~= nil then self.allianceId = message["allianceId"] end
end

--- 序列化为发给服务器的数据包
function ShipSelfPlayerData:ToServerMessage()
    -- TODO: 服务器同步
    return {}
end

return ShipSelfPlayerData
