

现在所有信息都齐了。以下是完整分析：

## UICamera 完整分析

### 节点层级

```
GameFramework3D.prefab
└── GameFramework 1 (根)
    ├── JustForShake
    │   └── Main Camera (Tag=MainCamera, 3D 场景相机)
    │       └── HudCamera (子相机)
    └── UI (节点)
        ├── UIContainer_Blur
        ├── BlurCamera
        ├── UIContainer (Canvas, 所有 UI 窗口挂载点)
        ├── UICamera (Tag=UICamera, UI 专用相机) ← 本次分析对象
        ├── WorldUIContainer
        └── ...
```

### UICamera 的参数

| 参数 | 值 | 含义 |
|------|-----|------|
| orthographic | true | **正交相机**（UI 不需要透视） |
| orthographicSize | 667 | 正交尺寸 = Screen.height/2（由 LayoutHelper 动态设置） |
| m_Depth | 90 | **渲染深度 90**（比 Main Camera 高很多，最后渲染 = 显示在最上层） |
| m_ClearFlags | 4 | Depth Only（只清深度，不清颜色 → 叠在 3D 场景之上） |
| cullingMask | 32800 | **只渲染 Layer 5 (UI) + Layer 15 (Grab)** |
| m_CameraType (URP) | 1 | Overlay Camera（URP 的叠加相机） |
| renderPostProcessing | false | 不做后处理 |
| position | (375, 667, 0) | 初始位置（由 LayoutHelper 动态调为屏幕中心） |

### Main Camera 与 UICamera 的关系

```
渲染流程（从底到顶）：

Main Camera (Depth 低, Perspective, Tag=MainCamera)
  ├── 渲染 3D 场景：Layer 0(Default),1,2,4,8,10-15,17,19,20,22-24
  ├── 不渲染 Layer 5 (UI)  ← 注意：Main Camera 不管 UI
  └── ClearFlags: Skybox/Solid Color

UICamera (Depth=90, Orthographic, Tag=UICamera)
  ├── 只渲染 Layer 5 (UI) + Layer 15 (Grab)
  ├── ClearFlags: Depth Only (叠在 Main Camera 画面之上)
  └── URP CameraType: Overlay
```

**核心设计**：双相机分层渲染
- **Main Camera**：透视相机，渲染 3D 世界（建筑、地形、行军、特效等）
- **UICamera**：正交相机，渲染 2D UI 界面（所有 Layer=UI 的节点）

两者互不干扰。关 Main Camera 只影响 3D 场景渲染，UI 依然由 UICamera 正常渲染显示。

### 代码中的使用

#### 1. Canvas 绑定 worldCamera（核心用法）

`UIContainer` 的 Canvas 组件的 `worldCamera` 指向 UICamera，这是 **Screen Space - Camera** 模式的标准做法：

```lua
-- UIBaseView.lua:61 — 每个窗口创建时绑定
canvas.worldCamera = UIManager:GetInstance():GetUICamera()

-- UIManager.lua:71 — 层级初始化时绑定
canvas.worldCamera = UIManager:GetInstance():GetUICamera()

-- UIManager.lua:1121 — 获取方法
function UIManager:GetUICamera()
    return self.canvas.worldCamera  -- 就是 UICamera
end
```

#### 2. 屏幕坐标 ↔ UI 坐标转换

3D 世界坐标 → UI 坐标需要经过两个相机：

```csharp
// CSUtils.cs:28-29
var uiPosition = Camera.main.WorldToScreenPoint(worldPosition);    // 3D → 屏幕
uiPosition = GameObject.FindWithTag("UICamera").GetComponent<Camera>().ScreenToWorldPoint(uiPosition);  // 屏幕 → UI 空间
```

Lua 侧同理：
```lua
-- PosConverse.ScreenToUIPos 用 UICamera 做转换
local uiCamera = UIManager:GetInstance():GetUICamera()
```

#### 3. 自适应屏幕尺寸

```csharp
// LayoutHelper.cs:162-181 — 启动时调整 UICamera
private static void SetUICamera()
{
    var uiCameraObj = _rootObj.transform.Find("UI/UICamera");
    AdjustCamera(uiCameraObj);  // position = (Screen.width/2, Screen.height/2, 10)
                                // orthographicSize = Screen.height / 2
}
```

#### 4. 模糊效果切换

```csharp
// BlurPanel.cs:20,54 — 模糊时切换 Canvas 的渲染相机
m_uiCamera = GameObject.Find("GameFramework/UI/UICamera").GetComponent<Camera>();
m_rootCanvas.worldCamera = m_uiCamera;  // 恢复正常渲染
```

#### 5. MobileInputField 坐标计算

```csharp
// MobileInputField.cs:357 — 输入框定位
UICamera = GameObject.FindWithTag("UICamera").GetComponent<Camera>();
screenCoord = RectTransformUtility.WorldToScreenPoint(UICamera, corners[i]);
```

### 总结对比

| 维度 | Main Camera | UICamera |
|------|-------------|----------|
| 路径 | `GameFramework/JustForShake/Main Camera` | `GameFramework/UI/UICamera` |
| Tag | `MainCamera` | `UICamera` |
| 投影 | 透视（Perspective） | 正交（Orthographic） |
| 渲染内容 | 3D 场景（建筑/地形/行军/怪物） | 2D UI 界面 |
| CullingMask | 排除 Layer 5 (UI) | 只 Layer 5 (UI) + 15 (Grab) |
| Depth | 低（先渲染） | 90（后渲染，叠在上面） |
| ClearFlags | Skybox | Depth Only（保留 3D 底图） |
| 震屏 | 通过 `JustForShake` 父节点 Transform 抖动 | 不参与震屏 |
| 关闭场景 | `ToggleMainCamera(false)` 清 cullingMask → 3D 不渲染 | 不受影响，UI 正常显示 |
| 用途 | `Camera.main` / 世界坐标→屏幕 | Canvas.worldCamera / 屏幕→UI 坐标 |