## 2D 游戏下 GameFramework3D.prefab 的改造计划

### 当前结构回顾

```
GameFramework
├── JustForShake
│   └── Main Camera (透视, MobileTouchCamera, CameraMove, Tag=MainCamera)
│       └── HudCamera
└── UI
    ├── UICamera (正交, Depth=90, 渲染 Layer=UI)
    ├── UIContainer (Canvas, 所有UI窗口)
    ├── BlurCamera
    └── WorldUIContainer
```

### 纯 2D 场景下需要变什么

| 组件 | 当前 | 2D 下 |
|------|------|-------|
| Main Camera 投影 | Perspective（透视） | **Orthographic（正交）** |
| Main Camera cullingMask | 大量 3D Layer | 只需渲染 2D 场景 Layer（如 Default + 自定义 2D 层） |
| MobileTouchCamera | 3D 场景缩放/平移（改 FOV + Position.xz） | **不用了**，2D 缩放是改 orthographicSize + Position.xy |
| CameraMove | 3D 位移动画 | 可保留思路，但平移轴从 XZ 变 XY |
| JustForShake | 震屏中间层 | **保留**，2D 震屏同样需要 |
| UICamera | 不变 | **不变**，UI 层独立渲染完全不受影响 |
| UIContainer / UIManager | 不变 | **不变**，整个 UI 系统完全不用改 |

### 核心问题：2D 相机的缩放/平移/边界限制用什么

`MobileTouchCamera`（BitBenderGames 插件）是为 3D 设计的，2D 下不适用。替代方案：

---

### 推荐插件方案（按优先级排序）

#### 方案 1：Cinemachine 2D（推荐，项目已有）

项目 `Library/PackageCache` 里已有 `com.unity.cinemachine@2.8.9`。

- 用 `CinemachineVirtualCamera` + `Confiner2D` 做 2D 相机
- 正交模式下天然支持：跟随目标、边界限制（Confiner）、缩放（改 orthographicSize）、震屏（Impulse）
- 触摸缩放/平移需要自己写一个轻量脚本去改 Virtual Camera 的 `m_Lens.OrthographicSize` 和 `Follow` offset

优点：Unity 官方、项目已安装、2D 支持成熟、震屏/跟随/边界全内置
缺点：触摸手势（双指缩放/拖拽平移）需自写一个小脚本驱动 Cinemachine 参数

#### 方案 2：自写轻量 2D Camera Controller

一个 MonoBehaviour 就够：

- 双指捏合 → 改 `Camera.orthographicSize`（带 min/max 限制）
- 单指拖拽 → 改 `Camera.transform.position.xy`（带边界 clamp）
- 惯性减速（可选）
- 震屏 → 晃 `JustForShake` 节点（复用现有架构）

优点：零依赖、完全可控、最轻量
缺点：需要自己处理多点触摸、惯性、弹性边界等细节

#### 方案 3：第三方 2D 相机插件

| 插件 | 特点 |
|------|------|
| **ProCamera2D**（Asset Store） | 最完整的 2D 相机方案：跟随/边界/缩放/震屏/视差/前瞻全有，触摸支持好 |
| **Camera2DFollow**（简易版） | 轻量跟随+边界 |

优点：开箱即用、功能全
缺点：引入新插件、可能与 Cinemachine 冲突

---

### 我的建议：方案 1（Cinemachine）+ 一个触摸驱动脚本

理由：
1. **项目已有 Cinemachine**，不需要额外导入包
2. 2D Confiner 天然做边界限制（用 PolygonCollider2D 画一个可移动区域）
3. 震屏用 Cinemachine Impulse（替代 JustForShake 手动晃动，更专业）
4. 只需写一个 `TouchZoomPan2D.cs`（~80 行）把触摸手势翻译为 Cinemachine 参数变化

---

### 改造后的 Prefab 结构（计划）

```
GameFramework (根, DontDestroyOnLoad)
├── JustForShake                           ← 保留（震屏中间层，Cinemachine 也可控制它）
│   └── Main Camera (改为 Orthographic)    ← 改投影模式、改 cullingMask 只渲 2D 层
│       ├── CinemachineBrain               ← 新增（替代 MobileTouchCamera）
│       └── TouchZoomPan2D                 ← 新增（触摸缩放平移 → 驱动 VCam）
├── CM vcam1 (CinemachineVirtualCamera)    ← 新增（2D 模式、Confiner2D、Follow 目标）
└── UI                                     ← 完全不动
    ├── UICamera
    ├── UIContainer
    ├── BlurCamera
    └── WorldUIContainer
```

移除的组件：
- ~~MobileTouchCamera~~（3D 专用，2D 不需要）
- ~~CameraMove~~（用 Cinemachine 的 Transposer/Follow 替代）
- ~~HudCamera~~（2D 游戏一般不需要单独 Hud 相机，用 UI Layer 就够）

保留的：
- JustForShake 节点（震屏结构不变，或交给 Cinemachine Impulse）
- UICamera + UIContainer + 整个 UI 系统（完全不动）
- Main Camera 的 Tag=MainCamera（Lua 代码通过 `Camera.main` 获取）

### 不改代码的前提下需要注意

| 现有代码 | 影响 | 处理方式 |
|----------|------|----------|
| `UIManager.lua:46` `GameObject.Find("GameFramework/JustForShake/Main Camera")` | 路径不变就不影响 | ✅ 保持节点名和层级不变 |
| `SceneManager.ToggleMainCamera` | 通过 `Camera.main` 操作 cullingMask | ✅ 只要 Tag=MainCamera 就行 |
| `UIBaseView:TryHideMainCamera` | 关 cullingMask 节省渲染 | ✅ 正交相机一样可以关 mask |
| `LayoutHelper.SetUICamera` | 调整 UICamera 的 orthographicSize | ✅ UICamera 不动 |
| `CSUtils.WorldToScreenPoint` 坐标转换 | `Camera.main.WorldToScreenPoint` | ⚠️ 正交下结果不同，但不改代码的话只要 2D 坐标系一致就行 |
| `MobileTouchCamera` 相关的 Lua 引用 | 可能有少量 Lua 代码调它 | 需要检查，但去掉该组件后不调就不报错 |

### 总结

| 做什么 | 怎么做 |
|--------|--------|
| Main Camera 改正交 | Inspector 切 Orthographic，设 orthographicSize |
| 去掉 MobileTouchCamera | 移除组件 |
| 2D 缩放/平移 | Cinemachine 2D + 自写触摸脚本（~80行） |
| 边界限制 | Cinemachine Confiner2D + PolygonCollider2D |
| 震屏 | Cinemachine Impulse 或继续用 JustForShake DOTween 晃动 |
| UI 系统 | 完全不动 |
| Lua 代码 | 不需要改（路径/Tag/Camera.main 引用都不变） |