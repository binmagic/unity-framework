# UI/
> L2 | 父级: ../../../CLAUDE.md

本目录是 C# 侧 UI 层：一批继承自 UGUI/TMP 的定制控件与网格特效，加上阿拉伯语 RTL 适配、新手引导箭头两套子系统。业务 UI 窗口逻辑在 Lua（`LuaScripts/UI/`），本层只提供这些窗口所挂载的原子组件与底层能力。

## 成员清单

### 定制控件（替代原生，统一全项目表现）
- `NewText.cs`: 定制 legacy 文本，扩展 UGUI Text，做省略号截断/BestFit 缩放/阿语整形/按语言换字体
- `NewTMPText.cs`: 定制 TMP 文本（UGUI 版），阿语检测整形/自动右对齐/字号补偿 + 点击回调 + 打字机，TMP 富文本主力控件
- `NewTMP3DText.cs`: NewTMPText 的世界空间 3D 变体，继承 TextMeshPro，用于场景 3D 物体上的文字
- `NewButton.cs`: 定制按钮，扩展 UGUI Button，灰度禁用材质 + DOTween 曲线驱动的按压/回弹手感，含全局默认曲线 DefaultNewButtonCurve
- `UIButtonCommonAnim.cs`: 非按钮节点复用 NewButton 同款点击动画的手动触发件，共享 DefaultNewButtonCurve
- `TMPTeletypeComponent.cs`: 打字机效果共享执行体，兼容两套 TMP 控件，由 NewTMPText/NewTMP3DText 委托

### 网格特效（在顶点生成阶段改写文本）
- `CircleText.cs`: 将字符沿弧线/环形重排的 BaseMeshEffect
- `TextSpacing.cs`: 按对齐方式逐行逐字调整字间距的 BaseMeshEffect

### 布局与屏幕适配
- `ClampedContentSizeFitter.cs`: 扩展 ContentSizeFitter，追加最大宽/高上限，防自适应无限撑大
- `ScreenSafeArea.cs`: 刘海/安全区适配，按平台计算并把面板锚点收进安全区
- `AutoChangeFont.cs`: 按当前语言自动替换原生 Text 字体（NewText 换字体能力的轻量独立版）

### 输入与数据附加
- `KeyCodeListener.cs`: 监听 Esc/安卓返回键并收敛为全局事件供 Lua UI 响应
- `UIExtraData.cs`: 挂在 UI 节点上的纯数据标记（声音 ID + 扩展字段）
- `LoginErrorCode.cs`: 登录/网络/热更各阶段错误码常量表，全流程共享的单一来源

### 渲染
- `BlurPanel.cs`: 背景高斯模糊，BlurPanel 挂需模糊底衬的界面，内建 BlurMgr 单例用引用计数统筹共享的模糊相机与 URP 后处理特性开关

### Arabic/ 子目录 — 阿拉伯语 RTL 适配
镜像布局/图片/文本，两条路线并存：`ArabicHorizonLayout` 逐节点手工精调，`ArabicMirror` 整树自动镜像。
- `ArabicMirror.cs`: 镜像中枢，递归遍历整棵 UI 树统一处理位置/对齐/布局/Slider/Image 翻转，含 MirrorVersionConfig 全局开关
- `ArabicHorizonLayout.cs`: 逐节点手工适配器，反转单个水平容器的子节点顺序、镜像图片、纠正文本对齐
- `ArabicImageMirror.cs`: 图片镜像执行末端，在顶点层面水平翻转 Image（Simple/Sliced/Tiled），由 ArabicMirror 自动挂载
- `BidirectionalHorizontalLayoutGroup.cs`: 双向水平布局基础设施，替代原生 HorizontalLayoutGroup，IsReverse 控制从左起/右起排布
- `AutoReverseImageNameList.cs`: 镜像白/黑名单查询表，为 ArabicMirror 判定图片是否翻转提供依据
- `ArabicMirrorAutoReverseImageListData.cs`: 上述名单的 ScriptableObject 磁盘配置载体
- `ForceArabicImage.cs`: 单张图片是否镜像的强制覆盖标记，供 ArabicMirror 读取
- `ForceArabicBiHorizontalLayout.cs`: 单个双向布局容器是否随 RTL 反向的强制覆盖标记
- `ForceArabicText.cs`: 单个文本强制对齐/字体覆盖的意图标记（逻辑主体已注释，以数据配置形态存在）

### Guide/ + UIGuideArrow/ — 新手引导
- `Guide/GuideTimelineMarker.cs`: Timeline 与引导逻辑的桥接，把演出时间轴信号点转成引导事件，控制过场暂停/回放
- `Guide/GuideGM.cs`: 引导调试入口（C# 薄壳，真正逻辑在 Lua DataCenter.GuideManager），Inspector 一键触发引导/事件
- `UIGuideArrow/AutoDoMovePos.cs`: 引导手势箭头的门面与数据中心，持有路径点与速度/时长，逐帧驱动委托给状态机
- `UIGuideArrow/AutoDoMovePosMachine.cs`: 有限状态机核心，管理按下→移动→抬起循环
- `UIGuideArrow/BaseAutoDoMovePosState.cs`: 状态抽象基类，定义 OnEnter/OnUpdate/OnLeave 契约
- `UIGuideArrow/AutoDoMovePosDownAnimState.cs`: "按下"态，归位起点并触发按下手指表现
- `UIGuideArrow/AutoDoMovePosMoveState.cs`: "移动"态，按速度在相邻路径点间线性插值移动
- `UIGuideArrow/AutoDoMovePosUpAnimState.cs`: "抬起"态，停终点触发抬起表现后重启循环
- `UIGuideArrow/UIImageLightAnim.cs`: 辅助高亮特效，给引导目标图片加节律性流光（独立于箭头状态机）

## 备注
本工程当前仅内置 English，Arabic/ 目录代码为母工程遗留，接入多语言时可复用（见父级 CLAUDE.md 国际化章节）。

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
