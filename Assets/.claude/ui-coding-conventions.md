# UI Lua 代码编写规范

基于 `Assets/Main/LuaScripts/UI/` 全目录代码分析总结。

---

## 一、类定义规范

### 基类选择

| 文件类型 | 基类 | 说明 |
|----------|------|------|
| View 文件 | `UIBaseView` | 独立窗口的视图 |
| Controller 文件 | `UIBaseCtrl` | 窗口控制器 |
| Component 文件 | `UIBaseContainer` | 子组件/列表项 |
| 公共组件 | `UIBaseContainer` | 跨窗口复用的组件 |

### 类定义模板

```lua
-- 标准写法（主流，占 95%+）
local base = UIBaseView
---@class UIBagView : UIBaseView
---@field ctrl UIBagCtrl
local UIBagView = BaseClass("UIBagView", UIBaseView)
```

规则：
- 变量名 = 类名 = `BaseClass` 第一个参数（三者必须一致）
- 用 `local base = 基类` 缓存基类引用
- 可选 EmmyLua `---@class` 注解（132/666 个 View 文件有使用）
- **禁止用 `def` 作变量名**（仅 5 个遗留文件使用，不要模仿）

### 返回值

所有文件末尾必须 `return 类名变量`：

```lua
return UIBagView
```

---

## 二、方法定义风格

### 主流风格：`function ClassName:Method()`（81%）

```lua
function UIBagView:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
    self:ReInit()
end

function UIBagView:OnDestroy()
    self:DataDestroy()
    self:ComponentDestroy()
    base.OnDestroy(self)
end
```

### Controller 私有方法风格

Controller 中允许 `local function` + 末尾导出的写法：

```lua
local function CloseSelf(self)
    UIManager.Instance:DestroyWindow(UIWindowNames.UIScience)
end

local function IsUnLockScience(self, scienceId)
    -- 内部逻辑
end

-- 末尾导出
UIScienceCtrl.CloseSelf = CloseSelf
UIScienceCtrl.IsUnLockScience = IsUnLockScience

return UIScienceCtrl
```

也可以直接用冒号方法（两种均可）：

```lua
function UITrainCtrl:Close()
    UIManager.Instance:DestroyWindowByLayer(UILayer.Background, false)
end

return UITrainCtrl
```

### 禁止的风格

```lua
-- ❌ 不要用 def.Method = function(self) 风格（遗留代码，不模仿）
def.OnCreate = function(self)
    -- ...
end
```

---

## 三、View 文件生命周期方法

### 标准方法调用顺序

```lua
function MyView:OnCreate()       -- 1. 创建时调用一次
    base.OnCreate(self)
    self:ComponentDefine()       -- 绑定 UI 组件
    self:DataDefine()            -- 初始化数据字段
    self:ReInit()                -- 首次填充数据
end

function MyView:OnEnable()       -- 2. 窗口每次显示时
    -- 刷新
end

function MyView:OnAddListener()  -- 3. 注册事件监听
    base.OnAddListener(self)
    self:AddUIListener(EventId.XXX, self.OnXXX)
end

function MyView:OnRemoveListener() -- 4. 移除事件监听
    base.OnRemoveListener(self)
    self:RemoveAllUIListeners()
end

function MyView:OnDisable()      -- 5. 窗口隐藏时
    -- 停止动画等
end

function MyView:OnDestroy()      -- 6. 销毁时
    self:DataDestroy()
    self:ComponentDestroy()
    base.OnDestroy(self)
end
```

### 各方法职责

| 方法 | 职责 | 是否必须 |
|------|------|----------|
| `ComponentDefine()` | 用 `self:AddComponent` 绑定所有 UI 组件 | 必须 |
| `ComponentDestroy()` | 清理组件引用（如清空滚动列表） | 可选 |
| `DataDefine()` | 初始化 self 上的数据字段 | 必须 |
| `DataDestroy()` | 重置数据字段、停止定时器 | 必须 |
| `ReInit()` | 根据 `self:GetUserData()` 填充界面数据 | 大多数需要 |
| `OnAddListener()` | 注册 EventId 事件监听 | 有事件时必须 |
| `OnRemoveListener()` | 移除事件监听 | 与 OnAddListener 配对 |

---

## 四、UI 组件绑定规范

> 所有框架组件和业务通用组件的完整 API 参考见 `Assets/.claude/ui-components-reference.md`

### AddComponent 模式

```lua
function MyView:ComponentDefine()
    -- 方式一：路径变量（推荐，占 70%）
    self.back_btn = self:AddComponent(UIButton, back_btn_path)
    self.title = self:AddComponent(UITextMeshProUGUIEx, title_path)
    
    -- 方式二：内联字符串（简单情况可用）
    self.close_btn = self:AddComponent(UIButton, "UICommonPopUpTitle/CloseBtn")
end
```

### 路径变量定义

路径定义在文件顶部（类定义之后、方法之前）：

```lua
local back_btn_path = "UICommonFullTop/CloseBtn"
local title_path = "UICommonFullTop/titleText"
local scroll_view_path = "BgGo/MiddleBg/ScrollView"
```

命名规则：`local {描述性名称}_path = "Prefab节点路径"`

### 字段命名

- **主流（99%）**：`self.xxx`（无前缀），如 `self.close_btn`、`self.title`、`self.scrollView`
- **极少数**：`self.mXxx`（m 前缀，仅 8 个文件），不推荐模仿

---

## 五、事件绑定规范

### 按钮点击

```lua
-- 方式一：闭包（简单逻辑）
self.close_btn:SetOnClick(function()
    SUSoundUtil.PlayEffect(SoundAssets.Music_Effect_Button)
    self:CloseSelf()
end)

-- 方式二：BindCallback（Component 中常用）
self.btn:SetOnClick(BindCallback(self, self.OnClick))
```

### 事件系统

```lua
function MyView:OnAddListener()
    base.OnAddListener(self)
    self:AddUIListener(EventId.RefreshItems, self.OnRefreshList)
    self:AddUIListener(EventId.VipDataRefresh, self.VipUpdate)
end

function MyView:OnRemoveListener()
    base.OnRemoveListener(self)
    self:RemoveAllUIListeners()
end
```

---

## 六、Controller 编写规范

### 职责

Controller 负责**数据获取和业务逻辑**，不持有 UI 组件引用：

- 关闭窗口
- 从 DataCenter 获取/过滤/排序数据
- 发送网络请求
- 跳转到其他窗口

### 模板

```lua
---@class UIBagCtrl : UIBaseCtrl
local UIBagCtrl = BaseClass("UIBagCtrl", UIBaseCtrl)

function UIBagCtrl:CloseSelf()
    UIManager:GetInstance():DestroyWindow(UIWindowNames.UIBagView)
end

function UIBagCtrl:GetItemList()
    -- 从 DataCenter 获取数据、过滤、排序
    return result
end

return UIBagCtrl
```

---

## 七、Component 编写规范

### 职责

Component 是窗口内的**子组件/列表项**，继承 `UIBaseContainer`。

### 模板

```lua
---@class UIBagCell : UIBaseContainer
local UIBagCell = BaseClass("UIBagCell", UIBaseContainer)
local base = UIBaseContainer

function UIBagCell:OnCreate()
    base.OnCreate(self)
    self:ComponentDefine()
    self:DataDefine()
end

function UIBagCell:OnDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
end

function UIBagCell:ComponentDefine()
    self.icon = self:AddComponent(UIImage, "Icon")
    self.name = self:AddComponent(UITextMeshProUGUIEx, "Name")
    self.btn = self:AddComponent(UIButton, "")
    self.btn:SetOnClick(BindCallback(self, self.OnClick))
end

function UIBagCell:SetData(data)
    -- 填充数据到 UI
end

return UIBagCell
```

---

## 八、Config.lua 编写规范

### 标准 MVC Config

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

### 平铺模式 Config（简单弹窗）

```lua
local DigTreasureGift = {
    Name = UIWindowNames.DigTreasureGift,
    Layer = UILayer.Normal,
    Ctrl = nil,
    View = require "UI.DigTreasureGift.DigTreasureGiftView",
    PrefabPath = "Assets/Main/Prefabs/UI/Alliance/DigTreasureGift/DigTreasureGiftView.prefab",
    isBlur = true,
}

return {
    DigTreasureGift = DigTreasureGift,
}
```

### 可选字段

| 字段 | 必须 | 说明 |
|------|------|------|
| `Name` | 是 | 对应 UIWindowNames 常量 |
| `Layer` | 是 | UILayer 枚举值 |
| `View` | 是 | View 类的 require 路径 |
| `PrefabPath` | 是 | Prefab 的完整 Assets 路径 |
| `Ctrl` | 否 | Controller 类，无逻辑时为 nil 或省略 |
| `isBlur` | 否 | 是否启用背景模糊 |

---

## 九、文件创建决策表

| 要做什么 | 创建哪些文件 |
|----------|-------------|
| 新增完整功能界面 | Config.lua + View/{Name}View.lua + Controller/{Name}Ctrl.lua |
| 新增展示界面（无逻辑） | Config.lua + View/{Name}View.lua（无 Controller） |
| 新增简单弹窗（≤2文件） | Config.lua + {Name}View.lua（平铺，无子目录） |
| 新增列表项/子面板 | Component/{Name}.lua（继承 UIBaseContainer） |
| 新增跨窗口复用组件 | UI/{ComponentName}/{ComponentName}.lua（公共组件目录） |
| 新增一组相关窗口（≥3个） | 先建分组目录，每个子窗口独立 Config |

---

## 十、命名规范总结

| 对象 | 命名规则 | 示例 |
|------|----------|------|
| View 类名 | `UI{功能名}View` 或 `{功能名}View` | `UIBagView`、`UIScienceView` |
| Controller 类名 | `UI{功能名}Ctrl` 或 `{功能名}Ctrl` | `UIBagCtrl`、`UIScienceCtrl` |
| Component 类名 | 描述性名称 | `UIBagCell`、`ScienceCellNew`、`ResourceItem` |
| 路径变量 | `{描述}_path` | `back_btn_path`、`title_path` |
| self 字段 | camelCase（无前缀） | `self.closeBtn`、`self.title` |
| 局部常量 | camelCase 或 UPPER_CASE | `rowItemCount`、`rowCellHight` |
| require 变量 | PascalCase（类名） | `local UICommonItem = require "..."` |

---

## 十一、禁止事项

1. **禁止 View 文件中写数据获取/排序逻辑**（放 Controller）
2. **禁止 Controller 持有 UI 组件引用**（只做数据逻辑）
3. **禁止用 `def` 作变量名**（遗留代码，新代码用具名类变量）
4. **禁止 self.mXxx 命名**（遗留风格，新代码用 self.xxx）
5. **禁止 Component 文件继承 UIBaseView**（必须继承 UIBaseContainer）
6. **禁止在 OnDestroy 之前调用 base.OnDestroy**（先清理自己再调父类）
7. **禁止漏写 return**（所有文件末尾必须 return 类变量）
