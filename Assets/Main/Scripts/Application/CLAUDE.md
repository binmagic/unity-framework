# Application/
> L2 | 父级: ../../../CLAUDE.md

应用启动层：从 launcher 场景拉起游戏，串起屏幕方向决策、热更资源下载、Lua 虚拟机启动。是 C# 侧的运行起点。

## 成员清单
ApplicationLaunch.cs: 游戏总入口 MonoBehaviour 单例（DontDestroyOnLoad），承接启动检测/热更加载/热重载，最终拉起 GameEntry 与 Lua 层
LayoutHelper.cs: 横竖屏布局决策中枢，按缓存与账号信息判定初始朝向并缓存
GameViewResHelper.cs: 编辑器辅助（仅 UNITY_EDITOR），横竖屏切换时反射设置 GameView 分辨率
CameraSphericalMoveWithEase.cs: 摄像机球面运镜组件，绕中心点在预设方位间做 DOTween 缓动移动
ZipDataTable.cs: 内网配置压缩包的下载/解压/落地处理，供开发测试期覆盖本地表
ManualPreserve.cs: IL2CPP 裁剪保护声明，持有字段防止仅反射/Lua 使用的类型被 link 剥离
LoadingState/: 启动加载状态子目录
  DownloadManifestState.cs: 资源清单版本拉取与校验状态机，热更第一步
  HttpRequest.cs: 带超时与重试的 HTTP 请求原语，被清单/资源下载复用

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
