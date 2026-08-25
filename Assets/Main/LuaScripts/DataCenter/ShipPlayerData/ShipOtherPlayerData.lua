---
--- 飞船游戏 — 其他玩家基础数据对象
--- 对标旧项目 BasePlayerInfo，只保留查看其他玩家时需要展示的字段
--- 带 15 秒本地缓存，超时后需重新从服务器拉取
---
---@class ShipOtherPlayerData
local ShipOtherPlayerData = BaseClass("ShipOtherPlayerData")

--- 缓存有效期（秒），对标旧项目 BasePlayerInfo 的 15 秒过期逻辑
local CACHE_EXPIRE_SECONDS = 15

function ShipOtherPlayerData:__init()
    self:Reset()
end

function ShipOtherPlayerData:__delete()
    self:Reset()
end

--- ---------------------------------------------------------------
--- 字段定义
--- ---------------------------------------------------------------

function ShipOtherPlayerData:Reset()
    --- ---- 账号标识（对标 BasePlayerInfo）----
    self.uid        = ""    -- 玩家唯一 ID（对标 BasePlayerInfo.uid）
    self.serverId   = 0     -- 所在服务器 ID（对标 BasePlayerInfo.serverId）

    --- ---- 基础信息（对标 BasePlayerInfo）----
    self.name       = ""    -- 玩家名称（对标 BasePlayerInfo.name）
    self.level      = 0     -- 玩家等级（对标 BasePlayerInfo.level）
    self.exp        = 0     -- 经验值（对标 BasePlayerInfo.exp）
    self.sex        = 0     -- 性别（对标 BasePlayerInfo.sex）
    self.pic        = ""    -- 头像（对标 BasePlayerInfo.pic）
    self.picVer     = 0     -- 头像版本（对标 BasePlayerInfo.picVer）

    --- ---- 战力（对标 BasePlayerInfo）----
    self.power          = 0     -- 总战力（对标 BasePlayerInfo.playerPower）
    self.buildingPower  = 0     -- 建筑战力（对标 BasePlayerInfo.buildingPower）
    self.sciencePower   = 0     -- 科技战力（对标 BasePlayerInfo.sciencePower）
    self.armyPower      = 0     -- 军队战力（对标 BasePlayerInfo.armyPower）
    self.heroPower      = 0     -- 英雄战力（对标 BasePlayerInfo.heroPower）

    --- ---- 联盟（对标 BasePlayerInfo）----
    self.allianceId     = 0     -- 联盟 ID（对标 BasePlayerInfo.allianceId）
    self.allianceName   = ""    -- 联盟名称（对标 BasePlayerInfo.allianceName）
    self.alAbbr         = ""    -- 联盟缩写（对标 BasePlayerInfo.alAbbr）

    --- ---- 战绩（对标 BasePlayerInfo）----
    self.battleWin  = 0     -- 胜利场次（对标 BasePlayerInfo.battleWin）
    self.battleLose = 0     -- 失败场次（对标 BasePlayerInfo.battleLose）
    self.armyKill   = 0     -- 击杀兵力（对标 BasePlayerInfo.armyKill）
    self.armyDead   = 0     -- 阵亡兵力（对标 BasePlayerInfo.armyDead）

    --- ---- 飞船游戏新增字段（旧项目无对应）----
    self.shipName   = ""    -- 飞船/空间站名称
    self.shipLevel  = 0     -- 飞船主建筑等级

    --- ---- 缓存控制（对标 BasePlayerInfo.updateTime）----
    --- 本地缓存时间戳（毫秒），0 表示从未拉取过
    self.updateTime = 0
end

--- ---------------------------------------------------------------
--- 缓存判断
--- ---------------------------------------------------------------

--- 缓存是否有效（15 秒内）
function ShipOtherPlayerData:IsCacheValid()
    if self.updateTime <= 0 then return false end
    local elapsedMs = os.clock() * 1000 - self.updateTime
    return elapsedMs < CACHE_EXPIRE_SECONDS * 1000
end

--- 标记缓存刷新时间
function ShipOtherPlayerData:MarkCacheRefresh()
    self.updateTime = os.clock() * 1000
end

--- ---------------------------------------------------------------
--- 查询方法
--- ---------------------------------------------------------------

--- 获取显示名称
function ShipOtherPlayerData:GetDisplayName()
    if self.shipName ~= "" then
        return self.shipName
    end
    return self.name ~= "" and self.name or "未知指挥官"
end

--- 是否在联盟中
function ShipOtherPlayerData:IsInAlliance()
    return self.allianceId ~= 0
end

--- ---------------------------------------------------------------
--- 服务器同步接口（留好接口，暂不实现）
--- ---------------------------------------------------------------

--- 从服务器数据包解析（对标 BasePlayerInfo:ParseData）
function ShipOtherPlayerData:InitFromServer(message)
    -- TODO: 服务器同步
    -- self.uid            = tostring(message["uid"]           or "")
    -- self.serverId       = message["serverId"]               or 0
    -- self.name           = message["name"]                   or ""
    -- self.level          = message["level"]                  or 0
    -- self.exp            = message["exp"]                    or 0
    -- self.sex            = message["sex"]                    or 0
    -- self.pic            = message["pic"]                    or ""
    -- self.picVer         = message["picVer"]                 or 0
    -- self.power          = message["playerPower"]            or 0
    -- self.buildingPower  = message["buildingPower"]          or 0
    -- self.sciencePower   = message["sciencePower"]           or 0
    -- self.armyPower      = message["armyPower"]              or 0
    -- self.heroPower      = message["heroPower"]              or 0
    -- self.allianceId     = message["allianceId"]             or 0
    -- self.allianceName   = message["allianceName"]           or ""
    -- self.alAbbr         = message["alAbbr"]                 or ""
    -- self.battleWin      = message["battleWin"]              or 0
    -- self.battleLose     = message["battleLose"]             or 0
    -- self.armyKill       = message["armyKill"]               or 0
    -- self.armyDead       = message["armyDead"]               or 0
    -- self:MarkCacheRefresh()
end

return ShipOtherPlayerData
