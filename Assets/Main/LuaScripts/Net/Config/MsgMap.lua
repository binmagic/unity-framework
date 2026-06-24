--[[

好的，以下是 `MsgMap.lua` 的完整分析：

## MsgMap.lua 分析

**文件位置**：`Assets/Main/LuaScripts/Net/Config/MsgMap.lua`

### 作用

`MsgMap.lua` 是**网络消息路由表**——一个纯配置文件，把协议命令ID（`MsgDefines.XXX`）映射到对应的消息处理类的 `require` 路径。共 ~1700 行，注册了几百条网络消息。

```lua
-- 结构：命令ID → 消息处理类路径
local config = {
    [MsgDefines.Init] = "Net.Msgs.InitMessage",
    [MsgDefines.ItemUse] = "Net.Msgs.ItemUseMessage",
    ...
}
return config
```

### 使用流程

唯一的消费者是 `SFSNetwork.lua`，整条链路如下：

```
服务器消息到达 (C# NetworkManager)
    ↓
调用 Lua: SFSNetwork.HandleMessage(cmd, t)
    ↓
GetMsgType(cmd) → 查 MsgMap[cmd] 得到路径字符串
    ↓
require(路径) → 加载对应的 Message 类（懒加载 + 缓存到 MsgTypeMap）
    ↓
msgType:NewEmpty() → msg:HandleMessage(t)  -- 解析响应/推送
```

**发送方向**同理：

```
业务逻辑调用 SFSNetwork.SendMessage(cmd, ...)
    ↓
GetMsgType(cmd) → 查 MsgMap 得到 Message 类
    ↓
msgType:NewMessage(...) → 序列化为 SFS 对象
    ↓
C# Network:SendLuaMessageEx(cmd, sfsObj) → 发往服务器
```

### 每条 Message 类的职责

以 `AccountBindMessage.lua` 为例，每个 Message 类都继承 `SFSBaseMessage`，负责两件事：

| 方法 | 职责 |
|------|------|
| `OnCreate(self, param)` | **发送**：把业务参数写入 `self.sfsObj`（SFS2X 数据对象） |
| `HandleMessage(self, t)` | **接收**：解析服务器返回的数据表 `t`，调用对应 Manager 处理 |

### 设计意图

1. **解耦**：业务代码只需知道 `MsgDefines.XXX` 命令常量，不需要知道具体 Message 类在哪
2. **懒加载**：Message 类按需 `require`，首次使用时才加载，避免启动时一次性加载几百个文件
3. **集中注册**：所有协议消息在一处注册，方便查找"某个协议有没有接入"、批量检查遗漏
4. **错误隔离**：`HandleMessage` 包在 `xpcall` 里，单条消息处理崩溃不会影响整体网络循环

### 总结一句话

`MsgMap.lua` = **协议命令 → 消息处理类**的路由注册表，由 `SFSNetwork.lua` 在收发消息时查表、懒加载对应类来执行序列化/反序列化。
]]


local config = {
	--[MsgDefines.ShowStatusItem] = "Net.Msgs.ShowStatusItemMessage",
	
}

return config