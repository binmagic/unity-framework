# Network/
> L2 | 父级: ../../../CLAUDE.md

本目录是 C# 侧网络消息定义层。所有对外通信抽象为「消息」：具体 `*Message` 继承 `BaseMessage` 复用组包与错误处理，经 `MessageFactory` 统一注册与分发。底层传输走 SmartFox2X（socket，iOS/Android/PC 与 WebGL WebSocket 两条入口）与 BestHTTP/UnityWebRequest（HTTP）。多数业务协议已下沉 Lua，此处仅保留登录握手等少量高频/底层协议。

## 成员清单
- `BaseMessage.cs`: 消息根抽象，定义 Send/Handle 收发模板与 CSSetData/CSHandleResponse 扩展点及统一错误码处理，是所有具体消息的契约基座。
- `MessageFactory.cs`: 消息调度中枢（单例），手工注册消息表并按 cmd 路由响应，命中走 C# Handle、未命中转 Lua，桥接底层传输与上层消息体系。
- `LoginMessage.cs`: 登录握手入口（login），聚合设备/版本/渠道/安全码组装最重的登录请求，响应处理已下沉 Lua。
- `ChangePFdisplayName.cs`: 第三方登录昵称落地（user.modify.nickName.google），将平台昵称同步服务端并回写本地 Player。
- `AccountBindMessage.cs`: 广告标识绑定（UserBindGaidMessage / bind.gaid），上报 gaid 完成账号绑定，标记 [Hotfix] 支持热修。
- `FcmTokenMessage.cs`: 推送寻址上报（change.user.parseid），上报 Firebase 推送 token 与 appId。
- `PushRecordMessage.cs`: 推送效果回收（push.record），上报推送到达/点击埋点并在回执后清缓存。
- `FutureManager.cs`: 请求追踪中枢，为每条请求分配自增 futureId、登记发送时刻、结算应用层 RTT 与超时监测，是延迟统计唯一来源。
- `UnityPing.cs`: 底层链路测速组件（MonoBehaviour），协程对 IP 发起 ICMP 探测回调耗时，服务选服/网络质量检测，独立于消息体系。
- `BypassCertificate.cs`: HTTP 传输辅助，放行 HTTPS 证书校验供 UnityWebRequest 挂载，解决自签名/测试环境证书问题。
- `protobuf/`: 预留空目录，规划承接 Protobuf 序列化协议，当前为空。

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
