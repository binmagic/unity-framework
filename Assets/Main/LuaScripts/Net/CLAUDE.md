# Net/
> L2 | 父级: ../../../CLAUDE.md

网络协议层，基于 SmartFox2X。三张配置/骨架构成消息系统：MsgDefines 定义"有哪些协议"、MsgMap 定义"谁来处理"、SFSBaseMessage 定义"怎么处理"的双向骨架；SFSNetwork 是收发门面，NetworkManager/CrossNetworkManager 分管主服与跨服连接。

## 成员清单
Config/MsgDefines.lua: 协议命令常量表，ConstClass 只读，命令名→SFS2X 命令字符串；全局 require，全项目发消息/路由/C# 分发的唯一命令字典
Config/MsgMap.lua: 消息路由注册表，命令ID→Net.Msgs 消息类 require 路径；唯一消费者 SFSNetwork，收发时查表懒加载，连连看当前为空表待接入
SFSNetwork.lua: 消息收发入口，SendMessage/SendCrossMessage 发送、HandleMessage 收包分发；经 MsgMap 懒加载消息类做序列化/反序列化，收包 xpcall 隔离单条崩溃
SFSBaseMessage.lua: 消息基类，约定每条协议双向骨架——OnCreate 写发送包、HandleMessage 解收包；Net/Msgs 下消息类继承它
NetworkManager.lua: 主服连接入口，多线路并发择优、pingpong 掉线检测与重连弹窗，按平台切 WebSocket/原生代理，登录结果转交 AppStartupLoading
CrossNetworkManager.lua: 跨服连接管理器，因 C# NetProxy 未区分跨服回调而在 Lua 侧独立直连一套 SmartFox，跨服推送透传回原消息工厂，与主服并列

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
