# 飞船游戏 — 玩家数据结构文档

> 文件位置：`Assets/Main/LuaScripts/DataCenter/ShipPlayerData/`
> 统一入口：`DataCenter.ShipPlayerDataManager`

---

## 目录

1. [整体架构](#整体架构)
2. [玩家基本信息](#玩家基本信息)
   - [ShipSelfPlayerData — 自身玩家](#shipSelfPlayerData--自身玩家)
   - [ShipOtherPlayerData — 其他玩家](#shipOtherPlayerData--其他玩家)
3. [建筑数据](#建筑数据)
   - [ShipBuildingData — 单个建筑](#shipBuildingData--单个建筑)
   - [ShipBuildingState — 建筑状态枚举](#shipBuildingState--建筑状态枚举)
4. [资源与道具数据](#资源与道具数据)
   - [ShipResourceData — 资源道具](#shipResourceData--资源道具)
   - [资源 ID 对照表](#资源-id-对照表)
5. [ShipPlayerDataManager — 统一管理器](#shipPlayerDataManager--统一管理器)
6. [EventId 事件列表](#eventid-事件列表)
7. [服务器联调说明](#服务器联调说明)

---

## 整体架构

```
ShipPlayerDataManager
├── selfPlayer      : ShipSelfPlayerData        自身玩家数据
├── otherPlayers    : table<uid, ShipOtherPlayerData>  其他玩家缓存
├── buildingMap     : table<uuid, ShipBuildingData>    建筑数据（按 uuid 索引）
├── buildIdIndex    : table<itemId, uuid[]>            建筑类型索引
├── resourceData    : ShipResourceData                 资源与道具数据
├── upgradingSet    : table<uuid, bool>                升级中的建筑集合
└── unlockingSet    : table<uuid, bool>                解锁中的建筑集合
```

所有数据只存本地内存，不直接发网络请求。
网络请求由 Controller 层负责，服务器回包后调用 `ApplyServerXxx` 接口更新本地数据。

---

## 玩家基本信息

### ShipSelfPlayerData — 自身玩家

**文件：** `ShipSelfPlayerData.lua`
**对标旧项目：** `PlayerInfo.lua`

#### 字段

| 字段 | 类型 | 默认值 | 说明 | 对标旧字段 |
|------|------|--------|------|-----------|
| **账号标识** |
| `uid` | string | `""` | 玩家唯一 ID | `PlayerInfo.uid` |
| `serverId` | number | `0` | 所在服务器 ID | `PlayerInfo.serverId` |
| `deviceId` | string | `""` | 设备 ID | `PlayerInfo.deviceId` |
| **基础信息** |
| `name` | string | `""` | 玩家名称 | `PlayerInfo.name` |
| `level` | number | `1` | 玩家等级 | `PlayerInfo.level` |
| `exp` | number | `0` | 当前经验值 | `PlayerInfo.exp` |
| `sex` | number | `0` | 性别：0=未设置 1=男 2=女 | `PlayerInfo.sex` |
| `pic` | string | `""` | 头像资源路径 | `PlayerInfo.pic` |
| `picVer` | number | `0` | 头像版本号 | `PlayerInfo.picVer` |
| **战力** |
| `power` | number | `0` | 总战力 | `PlayerInfo.power` |
| `buildingPower` | number | `0` | 建筑战力 | `PlayerInfo.buildingPower` |
| `sciencePower` | number | `0` | 科技战力 | `PlayerInfo.sciencePower` |
| `armyPower` | number | `0` | 军队战力 | `PlayerInfo.armyPower` |
| `heroPower` | number | `0` | 英雄战力 | `PlayerInfo.heroPower` |
| **货币** |
| `gold` | number | `0` | 钻石/硬货币 | `PlayerInfo.gold` |
| `payTotal` | number | `0` | 累计充值金额 | `PlayerInfo.payTotal` |
| **联盟** |
| `allianceId` | number | `0` | 联盟 ID，0=未加入 | `PlayerInfo.allianceId` |
| `allianceName` | string | `""` | 联盟名称 | — |
| `alAbbr` | string | `""` | 联盟缩写 | `PlayerInfo.alAbbr` |
| **战绩** |
| `battleWin` | number | `0` | 胜利场次 | `PlayerInfo.battleWin` |
| `battleLose` | number | `0` | 失败场次 | `PlayerInfo.battleLose` |
| `armyKill` | number | `0` | 击杀兵力 | `PlayerInfo.armyKill` |
| `armyDead` | number | `0` | 阵亡兵力 | `PlayerInfo.armyDead` |
| **体力** |
| `stamina` | number | `0` | 当前体力值 | `PlayerInfo.stamina` |
| `lastStaminaTime` | number | `0` | 上次体力恢复时间戳（秒） | `PlayerInfo.lastStaminaTime` |
| **保护盾** |
| `protectTimeStamp` | number | `0` | 保护盾到期时间戳（秒） | `PlayerInfo.ProtectTimeStamp` |
| **时间** |
| `regTime` | number | `0` | 注册时间戳（秒） | `PlayerInfo.regTime` |
| `lastOffLineTime` | number | `0` | 上次下线时间戳（秒） | `PlayerInfo.lastOffLineTime` |
| `openServerTime` | number | `0` | 开服时间戳（秒） | `PlayerInfo.openServerTime` |
| **飞船新增** |
| `shipName` | string | `""` | 飞船/空间站名称 | — |
| `shipLevel` | number | `0` | 飞船主建筑等级 | — |
| `totalPower` | number | `0` | 全站总战力（本地计算缓存） | — |
| `lastLoginTime` | number | `0` | 上次登录时间戳（秒） | — |

#### 方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetDisplayName()` | string | 优先返回 `shipName`，其次 `name`，兜底"未命名指挥官" |
| `IsInAlliance()` | boolean | `allianceId ~= 0` |
| `IsProtected()` | boolean | 保护盾是否有效 |
| `GetProtectRemainSeconds()` | number | 保护盾剩余秒数 |
| `GetCurrentStamina(interval, max)` | number | 根据时间差计算当前实际体力 |
| `InitFromServer(message)` | — | 服务器初始化接口（TODO） |
| `ApplyServerDelta(message)` | — | 服务器增量更新接口（TODO） |

---

### ShipOtherPlayerData — 其他玩家

**文件：** `ShipOtherPlayerData.lua`
**对标旧项目：** `BasePlayerInfo.lua`
**缓存有效期：** 15 秒，超时需重新从服务器拉取

#### 字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `uid` | string | `""` | 玩家唯一 ID |
| `serverId` | number | `0` | 所在服务器 ID |
| `name` | string | `""` | 玩家名称 |
| `level` | number | `0` | 玩家等级 |
| `exp` | number | `0` | 经验值 |
| `sex` | number | `0` | 性别 |
| `pic` | string | `""` | 头像 |
| `picVer` | number | `0` | 头像版本 |
| `power` | number | `0` | 总战力 |
| `buildingPower` | number | `0` | 建筑战力 |
| `sciencePower` | number | `0` | 科技战力 |
| `armyPower` | number | `0` | 军队战力 |
| `heroPower` | number | `0` | 英雄战力 |
| `allianceId` | number | `0` | 联盟 ID |
| `allianceName` | string | `""` | 联盟名称 |
| `alAbbr` | string | `""` | 联盟缩写 |
| `battleWin` | number | `0` | 胜利场次 |
| `battleLose` | number | `0` | 失败场次 |
| `armyKill` | number | `0` | 击杀兵力 |
| `armyDead` | number | `0` | 阵亡兵力 |
| `shipName` | string | `""` | 飞船/空间站名称（新增） |
| `shipLevel` | number | `0` | 飞船主建筑等级（新增） |
| `updateTime` | number | `0` | 本地缓存时间戳（毫秒） |

> **与 ShipSelfPlayerData 的区别：**
> 去掉了货币（`gold`）、体力（`stamina`）、保护盾（`protectTimeStamp`）等私密字段，只保留可公开展示的信息。

#### 方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `IsCacheValid()` | boolean | 缓存是否在 15 秒有效期内 |
| `MarkCacheRefresh()` | — | 刷新缓存时间戳 |
| `GetDisplayName()` | string | 优先 `shipName`，其次 `name`，兜底"未知指挥官" |
| `IsInAlliance()` | boolean | `allianceId ~= 0` |
| `InitFromServer(message)` | — | 服务器数据解析接口（TODO） |

---

## 建筑数据

### ShipBuildingData — 单个建筑

**文件：** `ShipBuildingData.lua`
**对标旧项目：** `BuildingDate.lua`

#### 字段

| 字段 | 类型 | 默认值 | 说明 | 对标旧字段 |
|------|------|--------|------|-----------|
| **基础标识** |
| `uuid` | number | `0` | 建筑唯一 ID（本地自增负数，联调后替换为服务器 uuid） | `BuildingDate.uuid` |
| `itemId` | number | `0` | 建筑类型 ID，对应 `Building_Config.id` | `BuildingDate.itemId` |
| `level` | number | `0` | 当前等级，0 = 未解锁 | `BuildingDate.level` |
| `unlock` | number | `0` | 解锁状态：0=未解锁，1=已解锁 | `BuildingDate.unlock` |
| **状态** |
| `state` | ShipBuildingState | `Locked` | 建筑当前状态（见枚举表） | `BuildingDate.state` |
| **时间** |
| `startTime` | number | `0` | 升级/解锁开始时间戳（秒） | `BuildingDate.startTime` |
| `updateTime` | number | `0` | 升级/解锁完成时间戳（秒），0=未在进行 | `BuildingDate.updateTime` |
| `upgradeTargetLevel` | number | `0` | 升级目标等级（新增） | — |
| **资源产出** |
| `lastCollectTime` | number | `0` | 上次收取资源时间戳（秒） | `BuildingDate.lastCollectTime` |
| `produceEndTime` | number | `0` | 资源产出结束时间，0=无限产出 | `BuildingDate.produceEndTime` |
| **战力** |
| `power` | number | `0` | 当前等级战力缓存（从 CfgBuildingLevel 读取，新增） | — |
| **其他** |
| `isHelped` | number | `0` | 是否有人帮助 | `BuildingDate.isHelped` |
| `destroyEndTime` | number | `0` | 废墟修复完成时间戳（秒） | `BuildingDate.destroyEndTime` |
| `destroyStartTime` | number | `0` | 废墟修复开始时间戳（秒） | `BuildingDate.destroyStartTime` |
| `peopleStation` | number | `0` | 驻扎人口数 | `BuildingDate.peopleStation` |
| `mainExp` | number | `0` | 建造总进度值 | `BuildingDate.mainExp` |
| `subExp` | number | `0` | 建造当前进度值 | `BuildingDate.subExp` |

#### 方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `IsUpgrading()` | boolean | 是否正在升级 |
| `IsUpgradeFinished()` | boolean | 升级倒计时是否已到期 |
| `IsUnlocking()` | boolean | 是否正在解锁 |
| `IsUnlockFinished()` | boolean | 解锁倒计时是否已到期 |
| `IsActive()` | boolean | 已解锁且空闲（unlock==1 且 state==Idle） |
| `IsInFix()` | boolean | 是否处于废墟修复中 |
| `IsFixFinish()` | boolean | 废墟修复是否完成 |
| `GetRemainSeconds()` | number | 升级/解锁剩余秒数 |
| `GetBuildProgress()` | number | 建造进度 0~1（subExp/mainExp） |
| `InitNew(buildId, uuid)` | — | 本地首次创建建筑 |
| `InitFromServer(message)` | — | 服务器数据解析接口（TODO） |
| `ToServerMessage()` | table | 序列化为服务器协议格式（TODO） |

---

### ShipBuildingState — 建筑状态枚举

**定义位置：** `Global/EnumType.lua`

| 枚举值 | 数值 | 说明 |
|--------|------|------|
| `ShipBuildingState.Locked` | `0` | 未解锁，不可操作 |
| `ShipBuildingState.Idle` | `1` | 已解锁，空闲中 |
| `ShipBuildingState.Unlocking` | `2` | 解锁倒计时进行中 |
| `ShipBuildingState.Upgrading` | `3` | 升级倒计时进行中 |

---

## 资源与道具数据

### ShipResourceData — 资源道具

**文件：** `ShipResourceData.lua`
**对标旧项目：** `ResourceInfo.lua` + `ResourceItemData.lua`

#### 字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `resources` | table\<number, number\> | `{}` | 基础资源，key=itemId，value=当前数量 |
| `resourceMax` | table\<number, number\> | `{}` | 基础资源上限，key=itemId，0=不限制 |
| `items` | table\<number, number\> | `{}` | 道具背包，key=itemId，value=数量 |
| `itemMax` | number | `-1` | 道具背包上限，-1=无上限 |
| `diamond` | number | `0` | 钻石（硬货币） |
| `gold` | number | `0` | 金币（软货币） |

#### 资源 ID 对照表

| itemId | 资源名称 | 说明 |
|--------|----------|------|
| `102001` | 食材 | 建筑升级主要消耗 |
| `102002` | 金属 | 建筑升级主要消耗 |
| `102003` | 电力 | 建筑升级主要消耗 |
| `102004` | 有机质 | 建筑升级辅助消耗 |
| `102005` | 科技点 | 建筑升级辅助消耗 |

> 资源 ID 来源于 `CfgBuildingLevel` 表的 `lvup_cost` 字段，格式为 `"102001,200000;102002,100000"`

#### 基础资源方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetResource(itemId)` | number | 获取某类资源当前数量 |
| `GetResourceMax(itemId)` | number | 获取某类资源上限 |
| `SetResource(itemId, amount)` | — | 直接设置资源数量（服务器同步回写用） |
| `SetResourceMax(itemId, max)` | — | 设置资源上限 |
| `ChangeResource(itemId, delta)` | boolean | 增减资源，不足时返回 false，不超过上限 |
| `ConsumeCostList(costList)` | boolean, itemId | 原子批量扣费，全部满足才扣，返回是否成功及第一个不足的 itemId |

#### 道具方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetItemCount(itemId)` | number | 获取某道具数量 |
| `SetItemCount(itemId, count)` | — | 直接设置道具数量（服务器同步回写用） |
| `ChangeItem(itemId, delta)` | boolean | 增减道具数量 |

#### 货币方法

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `ConsumeDiamond(amount)` | boolean | 消耗钻石，不足返回 false |
| `ConsumeGold(amount)` | boolean | 消耗金币，不足返回 false |

#### 服务器同步方法

| 方法 | 说明 |
|------|------|
| `InitFromServer(message)` | 登录时从服务器数据包初始化（TODO） |
| `ToServerMessage()` | 序列化为服务器协议格式（TODO） |
| `ApplyServerDelta(message)` | 服务器资源增量推送处理（TODO） |

---

## ShipPlayerDataManager — 统一管理器

**文件：** `ShipPlayerDataManager.lua`
**注册：** `DataCenter.lua` 第 5 行
**启动：** `LuaEntry.lua` 第 146 行 `DataCenter.ShipPlayerDataManager:Startup()`

### 玩家数据接口

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetSelfPlayer()` | ShipSelfPlayerData | 获取自身玩家数据对象 |
| `GetSelfLevel()` | number | 获取自身玩家等级 |
| `GetSelfDisplayName()` | string | 获取自身显示名称 |
| `CalcTotalPower()` | number | 实时计算全站总战力并写入 selfPlayer.totalPower |
| `GetOtherPlayer(uid)` | ShipOtherPlayerData\|nil | 获取其他玩家缓存，过期返回 nil |
| `CacheOtherPlayer(uid, data)` | — | 写入其他玩家缓存 |
| `ClearOtherPlayerCache(uid)` | — | 清除指定玩家缓存 |

### 建筑查询接口

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetBuildingByUuid(uuid)` | ShipBuildingData\|nil | 通过 uuid 获取建筑 |
| `GetBuildingsByBuildId(buildId)` | ShipBuildingData[] | 获取某类型所有建筑 |
| `GetMaxLevelBuilding(buildId)` | ShipBuildingData\|nil | 获取某类型等级最高的建筑 |
| `GetMaxBuildingLevel(buildId)` | number | 获取某类型最高等级，未拥有返回 0 |
| `IsBuildingUnlocked(buildId)` | boolean | 是否已解锁（unlock==1 且 level>0） |
| `GetUnlockedBuildIdList()` | number[] | 所有已解锁建筑 buildId 列表 |
| `GetAllBuildIdList()` | number[] | 所有建筑 buildId 列表（含未解锁） |

### 资源查询接口

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `GetResourceCount(itemId)` | number | 获取某类资源数量 |
| `GetItemCount(itemId)` | number | 获取某道具数量 |
| `CheckCostEnough(costList)` | boolean, itemId | 检查费用列表是否全部满足 |

### 建筑操作接口

| 方法 | 返回值 | 说明 |
|------|--------|------|
| `StartUnlockBuilding(buildId, costList, seconds)` | boolean, errMsg | 开始解锁：扣资源 + 更新状态 |
| `FinishUnlockBuilding(uuid)` | — | 完成解锁（Tick 到期或服务器回包后调用） |
| `StartUpgradeBuilding(buildId, costList, seconds, nextLevel)` | boolean, errMsg | 开始升级：扣资源 + 更新状态 |
| `FinishUpgradeBuilding(uuid)` | — | 完成升级（Tick 到期或服务器回包后调用） |
| `Tick()` | — | 每秒检查升级/解锁是否自然完成（由 TimerManager 驱动） |

### 服务器同步接口（TODO）

| 方法 | 说明 |
|------|------|
| `InitFromServer(message)` | 登录/重连时服务器全量数据初始化 |
| `ApplyServerPlayerDelta(message)` | 玩家信息增量推送（改名/升级/战力变化） |
| `ApplyServerOtherPlayerData(message)` | 其他玩家数据回包缓存 |
| `ApplyServerUnlockResult(message)` | 解锁结果回包 |
| `ApplyServerUpgradeResult(message)` | 升级结果回包 |
| `ApplyServerResourceDelta(message)` | 资源增量推送 |

---

## EventId 事件列表

**定义位置：** `Framework/UI/Message/EventId.lua`

| EventId | 数值 | 触发时机 |
|---------|------|----------|
| `ShipBuildingUnlockStart` | 250001 | 建筑开始解锁 |
| `ShipBuildingUnlockFinish` | 250002 | 建筑解锁完成 |
| `ShipBuildingUpgradeStart` | 250003 | 建筑开始升级 |
| `ShipBuildingUpgradeFinish` | 250004 | 建筑升级完成 |
| `ShipResourceUpdated` | 250005 | 飞船资源数据变更 |
| `ShipPlayerInfoUpdated` | 250006 | 自身玩家信息变更（改名/升级/战力等） |
| `ShipOtherPlayerDataUpdated` | 250007 | 其他玩家数据缓存刷新 |

---

## 服务器联调说明

当前阶段所有数据均为本地内存默认值，联调时按以下步骤接入：

### 第一步：填写 InitFromServer 解析逻辑

| 文件 | 方法 | 说明 |
|------|------|------|
| `ShipSelfPlayerData.lua` | `InitFromServer(message)` | 解析登录包中的玩家基础信息 |
| `ShipBuildingData.lua` | `InitFromServer(message)` | 解析单个建筑数据，字段对标 `BuildingDate.UpdateInfo` |
| `ShipResourceData.lua` | `InitFromServer(message)` | 解析资源包，字段参考文件内注释 |
| `ShipPlayerDataManager.lua` | `InitFromServer(message)` | 取消注释，驱动上述三个解析方法 |

### 第二步：接入服务器回包

| 回包场景 | 调用方法 |
|----------|----------|
| 解锁建筑成功 | `DataCenter.ShipPlayerDataManager:ApplyServerUnlockResult(message)` |
| 升级建筑成功 | `DataCenter.ShipPlayerDataManager:ApplyServerUpgradeResult(message)` |
| 资源变化推送 | `DataCenter.ShipPlayerDataManager:ApplyServerResourceDelta(message)` |
| 玩家信息变化 | `DataCenter.ShipPlayerDataManager:ApplyServerPlayerDelta(message)` |
| 查看他人信息 | `DataCenter.ShipPlayerDataManager:ApplyServerOtherPlayerData(message)` |

### 第三步：取消 Controller 中的网络请求注释

`UIShipBackgroundCtrl.lua` 中 `UnlockBuilding` 和 `UpgradeBuilding` 函数末尾各有一段注释掉的 `SFSNetwork.SendMessage`，取消注释即可发送请求。

### 第四步：删除本地测试默认值

联调完成后删除 `ShipPlayerDataManager.lua` 中的三个初始化函数：
- `_InitDefaultResources()` — 资源默认值（999999999）
- `_InitDefaultSelfPlayer()` — 玩家默认值（指挥官/我的空间站）
