# UI Prefab 制作规范

基于 Unity MCP + prefab 全量分析（`Prefabs/UI` 1565 + `Prefabs/Slg/UI` 818 + `UICommonSubPart` 55 + `UICommonSubPartNew` 20，约 2458 个 UI prefab、5 万+ 节点）总结。
用于指导创建/生成 UI prefab，与 Lua 侧 `ui-coding-conventions.md`、`ui-components-reference.md` 配套。

---

## 一、目录归属（与 Lua 模块目录镜像对应）

| Prefab 目录 | 存放内容 | 对应 Lua |
|------|----------|----------|
| `Assets/Main/Prefabs/UI/` | 通用/非 SLG 界面 prefab | `LuaScripts/UI/` |
| `Assets/Main/Prefabs/Slg/UI/` | SLG 战略玩法界面 prefab | `LuaScripts/Slg/UI/` |
| `Assets/Main/Prefabs/UICommonSubPart/` | 旧版通用子部件（文本/按钮模板） | 被各界面引用 |
| `Assets/Main/Prefabs/UICommonSubPartNew/` | 新版通用子部件（`*_new` 后缀，新界面优先用） | 被各界面引用 |

规则：
- prefab 目录结构与 Lua 模块目录**镜像对应**（`Prefabs/UI/UIBagView/` ↔ Lua `UI/UIBagView/`）
- prefab 文件名 = Lua Config 中 `PrefabPath` 指向的名字，通常 = View 类名（如 `UIBagView.prefab`）
- 新建通用子部件优先放 `UICommonSubPartNew/` 并加 `_new` 后缀

---

## 二、根节点规范（必须 RectTransform，Layer=UI(5)）

所有 UI prefab 根节点**必须**是 `RectTransform`（不是普通 Transform），`m_Layer: 5`（UI 层）。

根据界面类型选择锚点：

### 全屏界面（主流，全屏拉伸）

```
AnchorMin (0, 0)   AnchorMax (1, 1)   AnchoredPosition (0, 0)   SizeDelta (0, 0)   Pivot (0.5, 0.5)
```

铺满父容器，自适应任意分辨率。全屏界面、背景层界面用这个。

### 居中弹窗（固定尺寸）

```
AnchorMin (0.5, 0.5)   AnchorMax (0.5, 0.5)   AnchoredPosition (0, y偏移)   SizeDelta (宽, 高)   Pivot (0.5, 0.5)
```

居中显示，固定宽高（如 `750 x 1625`、`674 x 1040`）。弹窗、提示框用这个。

### 靠边/侧栏面板（单轴拉伸）

```
AnchorMin (0, 0)   AnchorMax (0, 1)   SizeDelta (宽, 0)   -- 竖向拉伸、固定宽
```

侧边栏、抽屉式面板用这个（如背包 `SizeDelta (340, 0)`）。

**Canvas 参考分辨率**：主用 `800 x 600`（竖屏基准），部分横屏界面用 `1334 x 750` / `1750 x 750`。

---

## 三、组件选型（用项目封装组件，非 Unity 原生）

项目对 Unity UGUI 组件做了封装，**优先用封装版**。实测频率：

| 需求 | 用这个（项目封装/主流） | 禁用 | 频率 |
|------|------------------------|------|------|
| 文本 | **TextMeshProUGUI**（TMP） | 原生 Text | 20587 |
| 文本(带描边/特效封装) | `NewTMPText` | | 3317 |
| 按钮 | `NewButton`（含点击音效/防连点/灰化） | 原生 Button | 3275 |
| 图片 | Image（UGUI）+ SpriteAtlas | | 大量 |
| 透明度/整组交互 | CanvasGroup | | 2794 |
| 动画 | Animator | | 1859 |
| 独立渲染排序 | 嵌套 Canvas + `UIOrderInLayerSetUp` | | 1646 + 1021 |
| 挡点击/透明区 | `Empty4Raycast`（省 overdraw） | 带图空 Image | 2045 |

原则：
- **文本一律用 TMP 系**（TextMeshProUGUI / NewTMPText），禁止用旧 `Text`
- **按钮用 `NewButton`**（封装了点击音效、防连点、灰化等）
- **纯挡点击/透明区域用 `Empty4Raycast`**，不放带图空 Image（减 overdraw 省 drawcall）
- 需要淡入淡出/整体禁用交互 → 加 `CanvasGroup`
- **按钮子节点的文本（NewTMPText / TMP）必须关闭 `RaycastTarget`**（设为 false）。原因：`NewTMPText` 实现了 `IPointerClickHandler`，若子文本 RaycastTarget=1，点击 raycast 命中文本后 Unity 会把 PointerClick 派发给文本自身而非父按钮，导致按钮 onClick 永不触发。这是项目级的强制规则，所有按钮子文本一律 RaycastTarget=0。

---

## 四、节点命名规范（与 Lua `AddComponent(组件,"节点路径")` 强绑定）

节点名一旦被 Lua 引用就**不要随意改**（否则 `AddComponent` 路径失效报错）。

### 高频通用节点名（沿用项目既有命名）

| 分类 | 命名 | 说明 |
|------|------|------|
| 背景 | `bg` / `Bg` / `Background` / `ImgBg` | 界面/面板背景 |
| 图标 | `icon` / `Icon` / `ItemIcon` | 图标 |
| 标题 | `Title` / `TitleText` / `TitleBg` / `Common_img_title` | 标题文本/底图 |
| 关闭按钮 | `CloseBtn` / `BtnClose` / `Common_btn_close` | 关闭按钮 |
| 滚动三件套 | `ScrollView` / `Viewport` / `Content` | 滚动列表 |
| 遮罩 | `Mask` / `ImgMask` / `Particle_Mask` | 遮罩/裁剪 |
| 面板 | `Panel` / `Root` | 子面板/根容器 |
| 品质框 | `ImgQuality` | 道具/英雄品质底 |
| 特效 | `VX` / `glow` / `lizi` | 特效节点 |
| 填充 | `Fill` / `Fill Area` | 进度条填充 |

### 通用容器名

- `UICommonPopUpTitle` — 弹窗标题栏容器
- `UICommonFullTop` / `fullTop` — 全屏界面顶部栏
- `UICommonBg_mid` — 通用中型背景

### 命名原则

1. 交互节点用稳定语义名（`CloseBtn`/`ConfirmBtn`/`TitleText`），路径与 Lua `ComponentDefine()` 一致
2. 通用弹窗结构复用既有容器名
3. 纯装饰/无脚本引用的节点可用 `Image` / `Image_1` 等默认名
4. 命名一旦被 Lua 引用**不可随意修改**

---

## 五、组织形式（层级结构）

### 全屏界面典型结构

```
UIXxxView (根, RectTransform 全屏拉伸, Layer=UI)
├── UICommonFullTop / fullTop      -- 顶部栏（标题 + 关闭 + 资源条）
│   ├── Common_img_title
│   │   └── titleText (TMP)
│   └── CloseBtn (NewButton)
├── Bg / Background                 -- 背景
├── Content / Panel                 -- 主内容区
│   └── ScrollView                  -- 列表
│       └── Viewport
│           └── Content
└── VX / Effect                     -- 特效层（置顶）
```

### 弹窗典型结构

```
UIXxxView (根, RectTransform 居中固定尺寸)
├── UICommonPopUpTitle              -- 弹窗标题栏
│   ├── Common_img_title / titleText
│   ├── CloseBtn (NewButton)
│   └── panel                       -- 半透明点击关闭区(Empty4Raycast)
└── ImgBg / Bg                      -- 弹窗主体背景
    └── ...内容
```

### 组织原则

1. **背景在最底层，特效/飘字在最上层**（RootOrder 靠后 = 靠前显示）
2. **列表严格用 ScrollView → Viewport → Content 三层结构**（配合 UIScrollView/UILoopListView2）
3. **cell/item 单独做成 prefab**，不要内嵌在窗口 prefab 里（放同目录，如 `UIBagCell.prefab`）
4. **可复用的子部件引用 `UICommonSubPartNew/` 里的模板 prefab**，保持全局风格统一
5. 需要独立渲染排序的子树挂 `Canvas` + `UIOrderInLayerSetUp`

---

## 六、通用子部件（UICommonSubPart / UICommonSubPartNew）

复用型 prefab 模板，命名体现"样式+尺寸"：

| 命名模式 | 含义 | 示例 |
|----------|------|------|
| `btnTxt_{颜色}_{尺寸}_new` | 带文字按钮 | `btnTxt_green_big_new`、`btnTxt_yellow_mid_new` |
| `Text_{数字}` / `Text_{样式}` | 文本模板 | `Text_bold`、`Text_blue`、`Text_20` |
| `content_{用途}` | 内容文本 | `content_num`、`content_Level` |

按钮标准尺寸（锚点均居中 `(0.5,0.5)`）：

| 尺寸 | SizeDelta |
|------|-----------|
| big | 200 x 80 |
| mid | 119 x (自适应高) |
| small | 120 x 60 |

新界面用按钮/文本**优先复用 `UICommonSubPartNew/` 模板**，不随意造新尺寸。

---

## 七、结合 NGUI 制作逻辑的对照（历史迁移背景）

| NGUI 概念 | 本项目 UGUI 对应做法 |
|-----------|---------------------|
| UIRoot / 统一缩放 | Canvas + CanvasScaler（参考分辨率 800x600），根节点全屏拉伸 |
| depth 深度排序 | RootOrder（子节点顺序）+ 必要时 `UIOrderInLayerSetUp` / 嵌套 Canvas |
| UIWidget 锚点 | RectTransform 锚点（全屏 0-1 拉伸 / 居中 0.5 固定尺寸） |
| UIButton | `NewButton`（封装音效/防连点/灰化） |
| UILabel | TextMeshProUGUI / `NewTMPText` |
| UISprite + Atlas | Image + SpriteAtlas（图集晚绑定，见 rules.md） |
| 碰撞盒挡点击 | `Empty4Raycast`（无图挡射线，省 overdraw） |

---

## 八、创建 UI Prefab 的完整流程

1. **建根节点**：GameObject + RectTransform，Layer=UI(5)，命名=View类名，按类型设锚点（全屏/居中/侧栏）
2. **搭通用框架**：全屏界面加 `UICommonFullTop`（标题+关闭），弹窗加 `UICommonPopUpTitle`
3. **加内容节点**：背景 `Bg`、主体 `Content`/`Panel`，列表用 `ScrollView/Viewport/Content` 三层
4. **选组件**：文本用 TMP、按钮用 `NewButton`、挡点击用 `Empty4Raycast`、透明控制用 `CanvasGroup`
5. **命名交互节点**：所有要被 Lua `AddComponent` 引用的节点用稳定语义名，路径与 Lua `ComponentDefine()` 一致
6. **复用子部件**：按钮/文本从 `UICommonSubPartNew/` 拖模板
7. **cell 拆分**：列表项另存为独立 prefab，放同目录
8. **存放路径**：SLG 界面放 `Prefabs/Slg/UI/{模块}/`，通用界面放 `Prefabs/UI/{模块}/`，与 Lua Config 的 `PrefabPath` 一致

---

## 九、禁止事项

1. **禁止根节点用普通 Transform**（UI 根必须 RectTransform，Layer=UI）
2. **禁止用旧版 `Text`**（一律 TMP：TextMeshProUGUI / NewTMPText）
3. **禁止用原生 `Button`**（用 `NewButton`）
4. **禁止用带图空 Image 挡点击**（用 `Empty4Raycast`，省 overdraw）
5. **禁止随意改被 Lua 引用的节点名/层级路径**
6. **禁止把 cell/item 内嵌进窗口 prefab**（拆成独立 prefab）
7. **禁止列表不走 ScrollView/Viewport/Content 三层结构**
8. **禁止按钮/文本随意造新尺寸**（复用 `UICommonSubPartNew` 档位）
9. **禁止 prefab 存放路径与 Lua Config 的 PrefabPath 不一致**
10. **禁止 prefab 目录结构脱离 Lua 模块目录的镜像关系**
11. **禁止按钮子文本开启 RaycastTarget**（`NewTMPText` 实现了 `IPointerClickHandler`，子文本 RaycastTarget=1 会截走按钮的点击事件。所有按钮内的 Text/TMP 子节点必须 `m_RaycastTarget: 0`）
