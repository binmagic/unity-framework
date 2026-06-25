# UI 模块目录结构规范

基于 `Assets/Main/LuaScripts/UI/` 全目录扫描（561 个模块目录）总结的完整规则。

---

## 整体统计

| 类型 | 数量 | 说明 |
|------|------|------|
| 标准 MVC 模式（有 View/ 子目录） | 472 | 正式界面，主流方式 |
| 平铺模式（有 Config.lua，无子目录） | 10 | 简单弹窗/轻量界面 |
| 分组目录（无 Config.lua，包含多个子窗口） | 44 | 功能模块聚合目录 |
| 公共组件目录（无 Config.lua，无子目录） | 34 | 可复用 UI 组件 |

---

## 模式一：标准 MVC 结构（主流，84%）

**适用场景**：任何有交互逻辑的正式界面。

### 目录结构

```
UI/{模块名}/
    Config.lua                          -- 必须
    View/{模块名}View.lua               -- 必须（View 目录内通常只有 1 个文件）
    Controller/{模块名}Ctrl.lua         -- 可选（有业务逻辑时添加）
    Component/{组件名}.lua              -- 可选（有子组件时添加）
```

### Config.lua 模板

```lua
local UIBagView = {
    Name = UIWindowNames.UIBagView,
    Layer = UILayer.Normal,
    Ctrl = require "UI.UIBagView.Controller.UIBagCtrl",
    View = require "UI.UIBagView.View.UIBagView",
    PrefabPath = "Assets/Main/Prefabs/Slg/UI/UIBagView/UIBagView.prefab",
}

return {
    UIBagView = UIBagView,
}
```

### 无 Controller 变体

有 View/ 子目录但不需要 Ctrl 时，Ctrl 字段省略或设 nil：

```lua
local UIAlLeaderCongratulate = {
    Name = UIWindowNames.UIAlLeaderCongratulate,
    Layer = UILayer.Normal,
    View = require "UI.UIAlliance.UIAlLeaderCongratulate.View.UIAlLeaderCongratulateView",
    PrefabPath = "Assets/Main/Prefabs/UI/Alliance/UIAlLeaderCongratulate.prefab",
}
```

### 关键数据

- View/ 目录内 lua 文件数：**461 个模块只有 1 个**，极少数有 2-4 个
- Controller/ 目录内 lua 文件数：**全部只有 1 个**
- Component/ 出现率：232/472（49%）

---

## 模式二：平铺模式（简化，10 个模块）

**适用场景**：简单弹窗、单一展示界面。特征：无 Controller 逻辑，1-2 个视图文件。

### 目录结构

```
UI/{模块名}/
    Config.lua                    -- 必须
    {模块名}View.lua              -- 视图文件，直接平铺在模块根目录
    {模块名}Item.lua              -- 可选，列表子项组件
```

**无 View/ 子目录，无 Controller/ 子目录。**

### Config.lua 模板

```lua
local DigTreasureGift = {
    Name = UIWindowNames.DigTreasureGift,
    Layer = UILayer.Normal,
    Ctrl = nil,
    View = require "UI.DigTreasureGift.DigTreasureGiftView",
    PrefabPath = "Assets/Main/Prefabs/UI/Alliance/DigTreasureGift/DigTreasureGiftView.prefab",
}

return {
    DigTreasureGift = DigTreasureGift,
}
```

### 与标准模式的区别

| 对比项 | 标准 MVC | 平铺模式 |
|--------|----------|----------|
| View 引用路径 | `"UI.XXX.View.XXXView"` | `"UI.XXX.XXXView"` |
| Controller | 有或省略 | 必须为 nil |
| 文件数 | 3+ | 2-3 |
| 子目录 | View/ Controller/ Component/ | 无 |

### 使用此模式的条件（全部满足）

1. 无 Controller 逻辑（Ctrl = nil）
2. 视图文件 ≤ 2 个（View + 可选 Item）
3. 无需 Component 子组件目录

---

## 模式三：分组目录（44 个）

**适用场景**：多个相关窗口的聚合目录（如 UIAlliance 下有 29 个子窗口）。

### 目录结构

```
UI/{分组名}/                         -- 分组目录本身，无 Config.lua
    {子窗口A}/                       -- 每个子窗口独立使用模式一或模式二
        Config.lua
        View/{子窗口A}View.lua
        Controller/{子窗口A}Ctrl.lua
    {子窗口B}/
        Config.lua
        {子窗口B}View.lua            -- 简单子窗口可平铺
    Common/                          -- 可选，分组内共享组件
        XXXCell.lua
```

### 典型示例

```
UI/UIAlliance/                       -- 分组（29个子窗口）
    UIAlLeaderVote/
        Config.lua
        View/UIAlLeaderVoteView.lua
        Component/AlLeaderCandidateItem.lua
    UIAllianceAlertDetail/
        Config.lua
        Controller/UIAllianceAlertDetailCtrl.lua
        View/UIAllianceAlertDetailView.lua
        Component/...
```

### 多层嵌套分组

分组可以嵌套一层（但不超过两层）：

```
UI/UIHero2/                          -- 一级分组
    UIHeroDress/                     -- 二级分组
        UIGetDress/                  -- 子窗口（平铺模式）
            Config.lua
            UIGetDressView.lua
        UIHeroDressList/             -- 子窗口（平铺模式）
            Config.lua
            UIHeroDressListView.lua
            UIHeroDressRow.lua
    Common/                          -- 分组共享组件
        UIHeroCellBig.lua
```

### UIConfig.lua 中的路径对应

分组模式下，UIConfig 路径包含分组名：

```lua
-- 一级分组
[UIWindowNames.UIAlLeaderVote] = "UI.UIAlliance.UIAlLeaderVote.Config",

-- 二级分组
[UIWindowNames.UIGetDress] = "UI.UIHero2.UIHeroDress.UIGetDress.Config",
```

---

## 模式四：公共组件目录（34 个）

**适用场景**：可复用的 UI 组件，被其他窗口 require 引用，不是独立窗口。

### 特征

- **无 Config.lua**
- **无 View/ Controller/ 子目录**
- 不注册到 UIWindowNames 和 UIConfig
- 不由 UIManager:OpenWindow 打开
- 通过 `require "UI.UICommonItem.XXX"` 被其他模块引用

### 典型示例

```
UI/UICommonItem/           -- 公共 Item 组件（8 个 lua）
UI/UICommonTab/            -- 通用 Tab 组件（5 个 lua）
UI/UICommonResItem/        -- 资源 Item 组件（2 个 lua）
UI/RedPoint/               -- 红点组件（1 个 lua）
UI/BuildCanUpgradeEffect/  -- 建筑特效组件（1 个 lua）
```

---

## 命名规范总结

| 文件类型 | 命名规则 | 示例 |
|----------|----------|------|
| View 文件 | `{窗口名}View.lua` | `UIBagView.lua` |
| Controller 文件 | `{窗口名}Ctrl.lua` | `UIBagCtrl.lua` |
| Component 文件 | `{描述性名称}.lua` | `UIBagCell.lua`、`ResourceItem.lua` |
| Config 文件 | 固定为 `Config.lua` | `Config.lua` |

---

## 选择决策树

```
新增一个 UI 功能
  │
  ├─ 是独立可打开的窗口？
  │   ├─ 是 → 需要注册到 UIWindowNames + UIConfig
  │   │   ├─ 有 Controller 逻辑 或 文件数 > 2？
  │   │   │   ├─ 是 → 模式一（标准 MVC）
  │   │   │   └─ 否 → 模式二（平铺）
  │   │   │
  │   │   └─ 属于某个功能模块的多个窗口之一？
  │   │       └─ 是 → 放在模式三（分组目录）下，子窗口用模式一或二
  │   │
  │   └─ 否（被其他窗口引用的组件）→ 模式四（公共组件目录）
  │
  └─ 已有同类分组目录？
      ├─ 是 → 放入已有分组
      └─ 否，且相关窗口 ≥ 3 个 → 新建分组目录
```

---

## 禁止事项

1. **禁止在 LuaScripts/ 下新建顶层目录**（如 `Game/`、`MiniGame/`）
2. **禁止 UIConfig 路径使用非 `UI.` / `Slg.UI.` 前缀**
3. **禁止 UIWindowNames 使用非 `Name = "Name"` 格式**
4. **禁止平铺模式有 Controller**（有 Controller 就必须用标准 MVC）
5. **禁止分组目录有 Config.lua**（分组目录不是窗口）
6. **禁止窗口目录无 Config.lua**（所有可打开的窗口都必须有 Config.lua）
