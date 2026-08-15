# Framework/UI/
> L2 | 父级: ../CLAUDE.md

Lua 层的 MVC UI 框架。业务界面全部构建其上：`UIManager` 是打开界面的唯一入口，
`Base/` 提供 MVC 三层基类，`Component/` 是对 Unity 原生 UI 组件的 Lua 封装，
`Message/` 承载事件驱动刷新，`Time/` 提供 UI 计时服务。本层不含任何连连看业务逻辑。

## 窗口管理核心（本目录直属）
- UIManager.lua: UI 框架总控中枢，挂在 UIRoot 上的隐式组件式单例；统管 Model+Ctrl+View 构成的完整窗口概念，业务打开界面的唯一入口
- UILayer.lua: UI 层级顺序标准（Scene→Background→UIResource→Normal→Info→Dialog→Guide→TopMost→TopCanvas），相邻层 OrderInLayer 差 5000 隔离特效排序
- UIWindow.lua: 一个窗口的运行时数据载体，由 UIManager 创建持有，串联该窗口的 View/Ctrl 实例与加载状态；窗口名必须与预设名一致

## Base/ — MVC 三层基类
- UIBaseComponent.lua: 所有 UI 组件的根基类，对应 Unity 原生 Component；缓存 transform/gameObject，管理 Lua 侧名字与实例 id
- UIBaseContainer.lua: 容器基类，以子节点 InstanceID 为键调度所持子组件生命周期，是 Component 与 View 之间的中间层
- UIBaseView.lua: MVC 视图层，每个窗口最外层节点；只读 Model、被动响应消息刷新，写操作与网络交由 Ctrl；UIBaseContainer 的直接特化
- UIBaseModel.lua: MVC 数据模型层，界面数据源与消息定制中枢；对 View 只读不写、不依赖 Ctrl/View，可独立运行
- UIBaseCtrl.lua: MVC 控制层，衔接 Model 与 View、承载网络请求与逻辑控制；本身无状态
- UIBaseRecordModel.lua: 模型层的记忆型特化，由 UIBaseModel 派生，供有多级子窗口需保持现场的界面使用

## Message/ — 事件系统
- EventManager.lua: UI 与全局的事件中枢，Lua 与 CS 双向事件桥；被各层用于消息驱动刷新
- EventId.lua: 事件字典，EventManager 广播/订阅的键来源；业务层与引导层共用号段保证跨模块一致

## Time/ — UI 计时
- UITimeManager.lua: UI 层时间服务中枢，区分服务器无时区时间与本地时区时间；被计时/邮件/聊天/活动倒计时广泛复用，独立于窗口生命周期

## Component/ — Unity UI 组件封装（对 CS 原生组件的 Lua 薄封装）
文本家族: UIText(位图基础) / UINewText(增强位图) / UITextMeshProUGUI(原生 TMP) / UINewTMPText(推荐 TMP，替代已弃用的 UITextMeshProUGUIEx) / UITweenNumberText(数值滚动)
图片家族: UIImage(基础九宫格) / CircleImage(圆形裁剪) / UIRawImage(原始 Texture)
滚动列表家族: UIScrollRect(底层容器) / UIScrollView(对象池循环列表主力) / UIScrollViewEx(数据驱动增强) / UIScrollViewExclusive(嵌套滚动独占) / UILoopListView2(SuperScrollView 高性能) / UIUnlimitedScrollView(GameKit 实现) / GridInfinityScrollView(网格无限) / HorizontalInfinityScrollView(横向无限) / UIScrollPage(整页翻动)
头像家族: UIPlayerHead(基础) / UIPlayerHeadNew(新版容器) / UICommonHead(头像图+框+加载动画)
输入/选择: UIButton(按钮容器) / UIToggle(复选/页签) / UISlider(进度/血条) / UIInput·UITMPInput(输入) / UIDropdown·UITMPDropdown(下拉)
布局: UIHorizontalOrVerticalLayoutGroup / UILayoutElement
动画: UIAnimator(状态机) / UISimpleAnimation(AnimationClip) / UISpine(2D 骨骼)
画布/层级: UICanvas(局部排序，禁业务直改 orderInLayer) / UICanvasGroup(整组淡入淡出) / UILayerComponent(层级节点，view 归属判定顶层)
效果: UIOutline(描边) / UIShadow(投影)
交互/其他: UIEventTrigger(指针/拖拽事件转发) / UIBoxCollider2D(2D 碰撞)

## ComponentExt/ — 组件扩展
- UIButton_LongPress.lua: 支持长按的按钮，相较 UIButton 增加长按语义（加速、连续操作）
- UIEmpty4Raycast.lua: 无绘制开销的射线遮挡图形，用作全屏点击拦截/引导遮罩，避免真实 Image 顶点成本
- GetHDRIntensity.lua: 对 CS 侧 GetHDRIntensity 脚本的薄封装，供需 HDR 泛光强度控制的界面使用

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
