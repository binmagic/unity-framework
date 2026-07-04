
## `JustForShake/Main Camera` 完整使用分析

### 节点结构

```
GameFramework3D.prefab
└── GameFramework 1 (根)
    └── JustForShake (普通 Transform 空节点)
        └── Main Camera (嵌套 prefab: Main Camera.prefab)
            ├── Camera (Unity Camera 组件, Tag=MainCamera)
            ├── MobileTouchCamera (触摸相机控制：缩放/平移/惯性)
            ├── CameraMove (自定义相机平移动画)
            ├── Outliner (EPO 描边特效)
            ├── UniversalAdditionalCameraData (URP 相机数据)
            ├── Animator (相机动画)
            └── HudCamera (子相机，HUD 渲染)
```

**`JustForShake` 节点的作用**：作为 Main Camera 的**父节点/中间层**，用于震屏效果。震屏时晃动 `JustForShake` 的 Transform，而不是直接改 Main Camera 的 Transform（这样相机本身的位置/旋转逻辑不受影响）。

---

### 代码中的使用

#### 1. UIManager.lua — 获取相机引用 + 控制显隐

`Framework/UI/UIManager.lua:16,46`

```lua
local MainCamera = "GameFramework/JustForShake/Main Camera"  -- 路径常量

-- Startup 中通过 GameObject.Find 获取引用
self.mainCamera = GameObject.Find(MainCamera)
```

#### 2. UIBaseView.lua — 打开全屏 UI 时关闭 3D 相机（节省渲染开销）

`Framework/UI/Base/UIBaseView.lua:198-218`

```lua
function UIBaseView:TryHideMainCamera()
    -- 躲避球战斗中不禁用主相机
    if DataCenter.LWBattleManager:IsInBattleLevel() then return end

    local needHideCamera = self.blurOrderNum > 0 or self.winConfig ~= nil and self.winConfig.hideCamera
    if needHideCamera then
        SceneManager.ToggleMainCamera(false)  -- 关闭
        self.hasHideCamera = true
    end
end

function UIBaseView:TryRecoverMainCamera()
    if self.hasHideCamera then
        SceneManager.ToggleMainCamera(true)   -- 恢复
        self.hasHideCamera = false
    end
end
```

**触发时机**：
- `TryHideMainCamera` — UI 窗口打开时，如果配置了 `hideCamera` 或有模糊层，关闭 3D 相机
- `TryRecoverMainCamera` — UI 窗口关闭/播放 MoveOut 动画时恢复（`UIManager.lua:808`）

#### 3. SceneManager.ToggleMainCamera — 引用计数式开关

`Global/SceneManager.lua:656-725`

```lua
function SceneManager.ToggleMainCamera(t)
    -- 引用计数（支持多层UI叠加关闭相机）
    self.cameraVisibilityRef = self.cameraVisibilityRef + (t and -1 or 1)

    local camera = CS.UnityEngine.Camera.main
    if t then
        -- 恢复：ref 降到 0 时才真正开启
        if self.cameraVisibilityRef == 0 then
            camera.cullingMask = self.cacheCullingMask          -- 恢复 cullingMask
            cameraData.renderPostProcessing = self.cachePostProcessing  -- 恢复后处理
            cameraData.requiresDepthOption = self.cacheDepthTextureMode
        end
    else
        -- 关闭：ref 升到 1 时真正关闭（第一层UI）
        if self.cameraVisibilityRef == 1 then
            self.cacheCullingMask = camera.cullingMask
            camera.cullingMask = 0          -- 设为 0 = 什么都不渲染
            cameraData.renderPostProcessing = false
            cameraData.requiresDepthOption = Off
        end
    end
end
```

**原理**：不是 `SetActive(false)` 禁用相机 GameObject，而是把 `cullingMask = 0`（什么都不渲染）+ 关闭后处理/深度。这样相机对象还在，`Camera.main` 依然有效，但 GPU 不画 3D 场景了。

#### 4. CameraMove.cs — 相机平移动画

`Scripts/Scene/CameraCom/CameraMove.cs`

挂在 Main Camera 上，负责相机**移动到目标位置**的动画（如镜头移到 NPC 处对话、进入/退出建筑第一视角等）。通过 `MobileTouchCamera` 配合触摸缩放/平移。

#### 5. GuideCityAnimManager.lua — 引导动画中控制相机

`DataCenter/GuideCityManager/SU_GuideCityAnimManager.lua:56-61`

```lua
function GuideCityAnimManager:MainCameraSetActive(active)
    if MainCamera == nil then
        MainCamera = CS.UnityEngine.Camera.main
    end
    if MainCamera ~= nil then
        MainCamera.gameObject:SetActive(active)  -- 引导动画时直接启停相机
    end
end
```

#### 6. 战斗相机（BarrelCameraHandler / DOShakePosition）

`DataCenter/LWBattle/Logic/ParkourBattle/Component/BarrelCameraHandler.lua:17`

```lua
self.camera = CS.UnityEngine.Camera.main
-- 战斗中获取主相机做震屏: DOShakePosition
```

---

### 总结：JustForShake/Main Camera 的核心用途

| 使用方 | 文件 | 做什么 |
|--------|------|--------|
| UIManager | `Framework/UI/UIManager.lua:46` | `GameObject.Find` 缓存引用 |
| UIBaseView | `Framework/UI/Base/UIBaseView.lua:198-218` | 全屏 UI 打开时关闭 3D 渲染（省性能） |
| SceneManager | `Global/SceneManager.lua:656-725` | `ToggleMainCamera` 引用计数式 cullingMask 开关 |
| CameraMove.cs | `Scripts/Scene/CameraCom/CameraMove.cs` | 相机平移动画（移到 NPC/建筑/恢复） |
| GuideCityAnimManager | `DataCenter/GuideCityManager/SU_GuideCityAnimManager.lua` | 引导动画中 SetActive 相机 |
| 战斗模块 | `DataCenter/LWBattle/.../BarrelCameraHandler.lua` | 战斗震屏/镜头控制 |
| DOTween 震屏 | 多处战斗/技能代码 | `DOShakePosition` 震动 JustForShake 节点 |

**`JustForShake` 这个空父节点的设计意图**：震屏时 DOTween 对 `JustForShake` 做 `DOShakePosition`，这样不会干扰 `Main Camera` 本身由 `MobileTouchCamera`/`CameraMove` 控制的位置逻辑——两者独立叠加。