# CLAUDE.md — 项目指南

## 项目概述

**类型**: 移动端 手机游戏（Android + iOS）
**Unity 版本**: 2022.3.62f3c1 (LTS)
**渲染管线**: Universal Render Pipeline (URP) 14.0.12
**脚本语言**: C# + Lua（通过 XLua 热更新框架）

---

## 目录结构

```
unity-framework/
├── Assets/                     # Unity 主资源目录
│   ├── Main/                   # 游戏核心资源和代码
│   │   ├── Scripts/            # C# 代码（Git 子模块: barrelscript.git）
│   │   ├── LuaScripts/         # Lua 热更新脚本
│   │   ├── DataTable/          # 数据表和本地化（Git 子模块: barreldata.git）
│   │   ├── Prefabs/            # 预制体（UI、角色、建筑、怪物、特效等）
│   │   ├── Scenes/             # 场景分区数据
│   │   ├── Animation/          # 动画资源
│   │   ├── Atlas/              # 图集
│   │   ├── Material/           # 材质
│   │   ├── Sprites/            # 精灵图（~16,639 个）
│   │   ├── Sound/              # 音效（~2,567 个）
│   │   ├── Proto/              # Protobuf 协议定义
│   │   ├── URPSettings/        # URP 渲染管线配置
│   │   └── ...
│   ├── Editor/                 # 编辑器扩展和工具
│   ├── Plugins/                # 第三方插件（DLL、SDK 等）
│   ├── Resources/              # Unity Resources 目录
│   └── StreamingAssets/        # 流式加载资源
├── ProjectSettings/            # Unity 项目设置
├── Packages/                   # Unity Package Manager 配置
├── MapEditor/                  # 独立的 Unity 子项目 — 地图编辑器
├── Tools/                      # 构建/辅助工具（Python27、LuaC、Xlsx2json、gradle、jenkins）
├── Docs/                       # 项目文档
├── proj_android/               # Android 导出工程（Gradle 构建）
├── proj_xcode/                 # iOS Xcode 导出工程
└── proj_CN/                    # 中国区专用工程配置
```

---

## 启动流程

```
Launch.unity
  → ApplicationLaunch.cs (MonoBehaviour, DontDestroyOnLoad)
    → 检测屏幕方向/布局
    → 下载热更资源（DownloadManifestState）
    → GameEntry.Init() 初始化所有核心管理器
    → XLuaManager 启动 Lua 虚拟机
    → GameMain.lua (Lua 入口)
      → AppStartupLoading.lua (加载流程)
```

---

## 核心架构

### C# 层 — 框架与底层

**入口类**: `GameEntry`（静态类，`Assets/Main/Scripts/Framework/GameEntry.cs`）

管理所有核心组件：
```csharp
GameEntry.Event       // 事件系统
GameEntry.Resource    // 资源管理
GameEntry.Network     // 网络连接
GameEntry.Sound       // 声效管理
GameEntry.Setting     // 客户端设置存储
GameEntry.Lua         // XLua 脚本管理
GameEntry.Shader      // Shader 管理
GameEntry.Data        // 玩家数据
GameEntry.pb          // Protobuf 预处理
GameEntry.Timer       // 定时器
GameEntry.GlobalData  // 全局数据
GameEntry.Sdk         // 原生系统 SDK
GameEntry.Device      // 设备信息
GameEntry.Localization // 本地化
GameEntry.ConfigCache // 配置缓存
GameEntry.BuildAnimatorManager // 建筑动画
```

### Lua 层 — 业务逻辑热更新

**入口文件**: `Assets/Main/LuaScripts/GameMain.lua`

**顶层目录（固定 10 个，不可新建）**:
| 目录 | 职责 |
|------|------|
| `Global/` | 全局模块加载与全局命名空间（`Global.lua` 是唯一加载入口，有依赖顺序） |
| `Framework/` | 框架层：OOP 系统、UI 基类、事件、定时器、日志 |
| `Common/` | Lua 语言级扩展与 C# 交互封装（与游戏逻辑无关） |
| `Util/` | 游戏业务工具类（全局 require） |
| `DataCenter/` | 数据管理中枢 + 各业务 Manager |
| `Net/` | 网络协议：消息定义、路由、消息类 |
| `UI/` | UI 窗口（MVC） |
| `Slg/` | SLG 业务（UI/DataCenter/Chat/Generated 并行体系） |
| `Scene/` | 场景内动态对象管理器（血条、气泡、特效、行军等） |
| `Loading/` | 启动加载流程、热更版本检测 |

**OOP 系统**: 所有类用 `BaseClass(name, super)`；类名=文件名=变量名三者一致；生命周期 `__init`（初始化字段）/ `__delete`（字段置 nil，一一对应）；单例继承 `Singleton` 用 `GetInstance()`；只读常量用 `ConstClass` 包装

**方法定义两种风格**（单文件内不混用）: ① `local function` + 末尾导出 ② `function Class:Method()`；文件末尾必须 `return 类变量`

**详细总纲见 `Assets/.claude/lua-architecture.md`**

**UI 框架**: MVC 模式
- `UIBaseView` — 视图层
- `UIBaseModel` — 数据模型层
- `UIBaseCtrl` — 控制器层

**UI 层级顺序**: Scene → Background → UIResource → Normal → Info → Dialog → Guide → TopMost → TopCanvas

**UI 模块注册规则**:
- `UIWindowNames.lua`: 窗口名常量表，格式 `Name = "Name",`（4空格缩进，key=value同名）
- `UIConfig.lua`: 窗口路由表，格式 `[UIWindowNames.XXX] = "UI.路径.Config",`（tab缩进）
- Config 路径前缀只允许 `UI.` 或 `Slg.UI.`，禁止自创命名空间
- Lua 文件放 `LuaScripts/UI/` 或 `LuaScripts/Slg/UI/` 下，不可新建顶层目录
- 详细规则见 `Assets/.claude/rules.md`
- 目录结构规范见 `Assets/.claude/ui-directory-structure.md`

**全局资源表（`Assets/Main/LuaScripts/Global/EnumType.lua`）**:
- `UIConfig` + `UIWindowNames`: 窗口 prefab，配套 `UIManager:OpenWindow`
- `UIAssets`: 直接实例化的 cell/item/子组件 prefab，配套 `InstantiateAsync`
- `VFXAssets`: UI 特效 prefab，配套 `AddUIEffect`/`RemoveUIEffect`
- `SoundAssets`: 音效路径常量表，配套 `SUSoundUtil.PlayEffect`

**SoundAssets 定义规则**（`EnumType.lua` 约 1438 行）:
- 全局表，把逻辑名映射到音效资源路径
- 格式 `逻辑名 = "音效路径", -- 中文注释`（说明音效用途）
- 缩进：4 空格
- 逻辑名 PascalCase，业务音效惯用 `Music_Effect_` 前缀，部分用 `Effect_` / `Click_` / `SU_` / `UI_` 前缀
- 路径两种写法：① 短路径（相对 Sound 根目录），如 `"effect_open"`、`"btn/StereoButtons"`、`"city/TrainTroops"`；② 完整路径，如 `"Assets/Main/Sound/Effect/ui/xxx.ogg"`（需精确指定文件时用）
- 短路径按子目录组织：`building/`、`city/`、`ui/`、`btn/`、`world/`、`barrel_new/` 等
- 使用：`SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Button)`，循环音效用 `PlayLoopEffect`，背景乐用 `PlaySound`
- 可拼接动态后缀：`SoundAssets.Click_Monster_Female .. tostring(index)`
- 禁止：硬编码音效字符串（必须走 SoundAssets）、逻辑名重复、新建其他全局音效表
- 详细规则见 `Assets/.claude/rules.md`

**全局模块加载**: `Assets/Main/LuaScripts/Global/Global.lua`

### 数据层（DataCenter）

- **DataCenter** (`LuaScripts/DataCenter/DataCenter.lua`): 全局数据管理中枢，懒加载所有 Manager
- 访问方式: `DataCenter.XxxManager:Method()`（全局可用，首次访问时 `require` + `New()` 并缓存）
- 类角色（按后缀）: `*Manager` 管理器（注册到 DataCenter）、`*Template` 配置行类、`*Info` 数据实体、`*Data` 数据管理器
- 生命周期: `__init(self)` 初始化字段 / `__delete(self)` 字段置 nil（一一对应，防泄漏）
- 网络回调命名: `XxxHandle`（响应）、`PushXxxHandle`（推送）；处理后用 `EventManager:Broadcast` 通知 UI
- 新增管理器两步: ① `Managers` 表加 `XxxManager = "DataCenter.Xxx.XxxManager"` ② 末尾加 `---@field XxxManager XxxManager`
- **LuaEntry** (`LuaScripts/DataCenter/Global/LuaEntry.lua`): 与 DataCenter 并列的核心数据入口（类似 C# `GameEntry.Data`）
  - 持有最核心高频数据: `LuaEntry.Player`（玩家）、`LuaEntry.DataConfig`（配置）、`LuaEntry.Resource`（资源）、`LuaEntry.Effect`、`LuaEntry.GlobalData`、`LuaEntry.Network`
  - 冒号方法风格的单例表（非 BaseClass）；生命周期 `Init/onMessage/StartGame/EndGame/Uninit` 由框架调用
  - 登录消息回来时 `onMessage` 会**重新 New** Player 等对象（防数据串乱）→ 不要缓存 `LuaEntry.Player` 引用，每次直接取
  - 随开局启动的 Manager 在 `LuaEntry:StartGame()` 中 `Startup`，并在 `EndGame()` 对应 `Delete`
  - 访问 `LuaEntry.Player` 前框架须已 `Init()`（登录前/简化流程可能为 nil，需判空）
- 详细规则见 `Assets/.claude/datacenter-conventions.md`

### 网络架构

- **SmartFox2X**: 主要服务端通信协议
- **Protobuf**: 序列化支持
- **BestHTTP**: HTTP 通信层
- **CrossNetworkManager**: 跨服网络支持

---

## 代码统计

| 文件类型 | 数量 |
|---|---|
| C# 文件（Assets 总计） | ~6,750 |
| C# 文件（排除 3rdParty） | ~4,678 |
| Lua 脚本 | ~533 |
| Prefab 预制体 | ~4,049 |
| Unity 场景 | 17 |
| Shader / ShaderGraph | ~239 |
| 音效文件 | ~2,567 |
| 精灵文件 | ~16,639 |

---

## 关键代码路径

### C# 核心模块

| 模块 | 路径 | 说明 |
|---|---|---|
| 应用入口 | `Assets/Main/Scripts/Application/ApplicationLaunch.cs` | 游戏启动 MonoBehaviour |
| 框架入口 | `Assets/Main/Scripts/Framework/GameEntry.cs` | 全局静态管理类 |
| 资源管理 | `Assets/Main/Scripts/Framework/ResourceManager.cs` | 资源加载/卸载 |
| 网络管理 | `Assets/Main/Scripts/Manager/NetworkManager.cs` | 网络连接管理 |
| 场景管理 | `Assets/Main/Scripts/Scene/SceneManager.cs` | 场景切换 |
| 城市场景 | `Assets/Main/Scripts/Scene/City/` | 建筑建造、LOD、渲染优化 |
| 世界地图 | `Assets/Main/Scripts/Scene/World/` | 区块化管理、行军、战争迷雾 |
| PVE 战斗 | `Assets/Main/Scripts/Scene/PVE/` | 寻路网格、技能、子弹物理 |
| RVO 碰撞 | `Assets/Main/Scripts/Scene/RVO/` | Agent、KdTree、Simulator |
| UI 系统 | `Assets/Main/Scripts/UI/` | UI 管理（~50 个文件） |
| XLua 桥接 | `Assets/Main/Scripts/XLua/` | Lua 热更新桥接 |
| SDK 管理 | `Assets/Main/Scripts/Framework/SDKManager/` | 平台抽象层 |

### Lua 核心模块

| 模块 | 路径 | 说明 |
|---|---|---|
| 入口 | `GameMain.lua` | Lua 主入口 |
| 全局配置 | `Global/Global.lua` | 全局模块加载 |
| UI 管理 | `Framework/UI/UIManager.lua` | UI 操作、层级、缓存 |
| UI 基类 | `Framework/UI/Base/UIBaseView.lua` | UI 视图基类 |
| 事件系统 | `Framework/UI/Message/EventManager.lua` | 事件订阅/派发 |
| 网络层 | `Net/NetworkManager.lua` | 网络消息处理 |
| 定时器 | `Framework/Updater/TimerManager.lua` | 定时器管理 |
| 日志 | `Framework/Logger/Logger.lua` | 日志系统 |

---

## 第三方库

### Unity Package Manager 依赖

**直接依赖**（manifest.json）：

| 包 | 版本 | 来源 | 说明 |
|---|---|---|---|
| `com.unity.render-pipelines.universal` | 14.0.12 | builtin | URP 渲染管线 |
| `com.unity.cinemachine` | 2.10.7 | registry | 摄像机系统 |
| `com.unity.textmeshpro` | 3.0.9 | registry | 文本渲染 |
| `com.unity.timeline` | 1.7.7 | registry | 时间轴动画 |
| `com.unity.ugui` | 1.0.0 | builtin | UI 系统基础 |
| `com.esotericsoftware.spine.spine-unity` | 4.3 | git | Spine 2D 骨骼动画 |
| `com.esotericsoftware.spine.spine-csharp` | 4.3 | git | Spine C# 核心库 |
| `com.besty.unity-skills` | git | git | Unity 技能系统 |
| `com.unity.collab-proxy` | 2.7.1 | registry | Unity Collaborate |
| `com.unity.test-framework` | 1.1.33 | registry | 测试框架 |
| `com.unity.feature.development` | 1.0.1 | builtin | 开发工具集（含 IDE 支持、Profiler、代码覆盖率等） |
| `com.unity.ide.rider` | 3.0.40 | registry | JetBrains Rider 支持 |
| `com.unity.ide.visualstudio` | 2.0.27 | registry | Visual Studio 支持 |
| `com.unity.ide.vscode` | 1.2.5 | registry | VS Code 支持 |

**间接依赖**（被直接依赖自动引入）：

| 包 | 版本 | 被谁引入 | 说明 |
|---|---|---|---|
| `com.unity.burst` | 1.8.21 | URP | 高性能编译 |
| `com.unity.mathematics` | 1.2.6 | URP / Burst | 数学库 |
| `com.unity.render-pipelines.core` | 14.0.12 | URP | 渲染管线核心 |
| `com.unity.shadergraph` | 14.0.12 | URP | Shader 可视化编辑 |
| `com.unity.render-pipelines.universal-config` | 14.0.10 | URP | URP 配置 |
| `com.unity.nuget.newtonsoft-json` | 3.2.1 | unity-skills | JSON 序列化（Newtonsoft.Json） |
| `com.unity.performance.profile-analyzer` | 1.2.3 | feature.development | 性能分析器 |
| `com.unity.testtools.codecoverage` | 1.2.6 | feature.development | 代码覆盖率 |
| `com.unity.editorcoroutines` | 1.0.0 | feature.development | 编辑器协程 |
| `com.unity.settings-manager` | 2.1.0 | testtools.codecoverage | 设置管理 |
| `com.unity.searcher` | 4.9.2 | ShaderGraph | 搜索器 |
| `com.unity.ext.nunit` | 1.0.6 | test-framework / Rider | NUnit 测试框架扩展 |

**内置模块**（`com.unity.modules.*`，均 1.0.0）：

ai, androidjni, animation, assetbundle, audio, cloth, director, imageconversion, imgui, jsonserialize, particlesystem, physics, physics2d, screencapture, terrain, terrainphysics, tilemap, ui, uielements, umbra, unityanalytics, unitywebrequest（含 assetbundle / audio / texture / www 扩展）, vehicles, video, vr, wind, xr

### 关键第三方库（Assets/Main/Scripts/3rdParty）

| 库 | 说明 |
|---|---|
| **XLua** | 腾讯 Lua 热更新框架 |
| **Best HTTP** | HTTP 网络库 |
| **SmartFox2X** | SmartFox Server 客户端 |
| **Google.Protobuf** | Protobuf 序列化 |
| **LitJson** | JSON 解析 |
| **SQLite4Unity3d** | SQLite 数据库 |
| **XAssetPro** | 资源管理/热更 |
| **Graphy** | 性能监控面板 |
| **GPUSkinning** | GPU 蒙皮动画 |
| **DOTween** | 动画缓动库 |
| **Odin Inspector** | Unity 编辑器增强 |

---

## 国际化

支持 **16 种语言**（`Assets/Main/DataTable/Localization/`）：
Arabic、ChineseSimplified、ChineseTraditional、English、French、German、Italian、Japanese、Korean、PortuguesePortugal、Russian、Spanish、Thai、Turkish、Vietnamese
[CLAUDE.md](CLAUDE.md)
**注意**: 阿拉伯语需要 RTL 布局适配（`Assets/Main/Scripts/UI/Arabic/`）

---

## 构建与部署

- **Android**: Gradle 构建（`proj_android/`），支持多 Gradle 版本（5.6.4/6.5/6.8）
- **iOS**: Xcode 工程（`proj_xcode/`）
- **CI/CD**: Jenkins
- **中国区**: 专用工程配置（`proj_CN/`）
- **启动场景**: `Assets/Launch.unity`（EditorBuildSettings 中唯一配置的场景）

---

## Git 子模块

```gitmodules
[submodule "Assets/Main/Scripts"]
    path = Assets/Main/Scripts
    url = http://10.7.88.20/cc/barrelscript.git
[submodule "Assets/Main/DataTable"]
    path = Assets/Main/DataTable
    url = http://10.7.88.20/cc/barreldata.git
```

**注意**: Scripts 和 DataTable 是独立的 Git 子模块，修改时需要注意提交到对应的子模块仓库。

---

## 项目文档

详细文档位于 `Docs/` 目录：
- `客户端启动流程/` — 启动流程说明
- `数据库/` — 客户端数据库接口文档
- `XLua文档/` — XLua 使用文档
- `功能文档/` — 各功能模块文档（世界、行军、英雄、编队等）
- `动更发布流程/` — 热更新发布流程
- `美术规范文档/` — 美术资源规范
- `Shader使用说明/` — Shader 使用说明

---

## 相关文档

- **Lua 整体架构与编写规范（总纲）**: `Assets/.claude/lua-architecture.md`
- **编码规范**: `Assets/.claude/rules.md`
- **参考文档**: `Assets/.claude/reference.md`
- **UI 目录结构规范**: `Assets/.claude/ui-directory-structure.md`
- **UI 代码编写规范**: `Assets/.claude/ui-coding-conventions.md`
- **UI 组件参考手册**: `Assets/.claude/ui-components-reference.md`
- **DataCenter 编写规范**: `Assets/.claude/datacenter-conventions.md`
