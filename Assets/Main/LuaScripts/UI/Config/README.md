

两者是**常量定义 → 注册使用**的关系：

### UIWindowNames.lua — 定义窗口名常量

```lua
UIWindowNames = {
    UIBagView = "UIBagView",
    UIScience = "UIScience",
    ...  -- ~1461 行
}
return ConstClass("UIWindowNames", UIWindowNames)
```

纯粹的**字符串常量字典**，key 和 value 同名。作用是避免全项目散落硬编码字符串，拼写错误时 `ConstClass` 的只读保护会在调试模式下报错。

### UIConfig.lua — 用常量做 key 注册配置路径

```lua
local UIConfig = {
    [UIWindowNames.UIBagView] = "UI.UIBagView.Config",
    [UIWindowNames.UIScience] = "UI.UIScienceInfo.Config",
    ...  -- ~1088 行
}
return ConstClass("UIConfig", UIConfig)
```

用 `UIWindowNames.XXX` 作为 key，映射到对应的 Config 模块路径。

### 关系图

```
UIWindowNames.lua          UIConfig.lua              XXX/Config.lua
─────────────────          ────────────              ──────────────
常量名 → 字符串            常量名 → Config路径        Layer/View/Ctrl/PrefabPath

  UIWindowNames.UIBagView ──→ UIConfig[UIWindowNames.UIBagView] ──→ require("UI.UIBagView.Config")
       ↓                                                                     ↓
  "UIBagView"                                                    { Name, Layer, Ctrl, View, PrefabPath }
```

### 使用关系

| 场景 | 用谁 |
|------|------|
| 打开窗口 | `UIManager:OpenWindow(UIWindowNames.UIBagView)` |
| 查配置 | `UIConfig[UIWindowNames.UIBagView]` → 得到路径 → require |
| 判断窗口是否打开 | `UIManager:IsOpen(UIWindowNames.UIBagView)` |
| 关闭窗口 | `UIManager:CloseWindow(UIWindowNames.UIBagView)` |

### 一句话总结

`UIWindowNames` 是所有窗口的**ID 常量表**（提供类型安全的名字引用），`UIConfig` 是以这些常量为 key 的**配置注册表**（告诉 UIManager 每个窗口对应哪个 Config 模块）。新增一个 UI 界面需要两步：先在 `UIWindowNames` 加一个常量，再在 `UIConfig` 注册它的 Config 路径。