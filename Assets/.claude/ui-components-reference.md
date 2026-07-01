# UI 组件参考手册

基于 `Framework/UI/Component/` 组件定义 + `UI/` 目录使用统计（约 40 个框架组件，业务组件数百个）总结。
所有组件通过 `self:AddComponent(组件类, "节点路径")` 挂载到 UI 节点上使用。

---

## 一、AddComponent 核心用法

所有 UI 组件统一通过 `UIBaseContainer:AddComponent` 绑定（`Framework/UI/Base/UIBaseContainer.lua:174`）：

```lua
-- 语法：self:AddComponent(组件类, 相对节点路径, ...额外参数)
self.closeBtn = self:AddComponent(UIButton, "fullTop/CloseBtn")
self.title = self:AddComponent(UITextMeshProUGUIEx, "TitleText")
self.icon = self:AddComponent(UIImage, "Icon")
```

- 第 1 参：组件类（框架组件或业务 Component 类）
- 第 2 参：相对当前节点的 Prefab 子路径（用 `/` 分隔），空串 `""` 表示自身节点
- 返回：组件实例，缓存到 `self.xxx` 字段
- 内部会复用已存在的同节点同类型组件（不会重复创建）

配套方法：
- `self:GetComponent(id, class)` — 获取已挂组件
- `self:RemoveComponent(id, class)` / `RemoveComponents(class)` — 移除
- `self:AddUIListener(EventId.Xxx, self.OnXxx)` / `RemoveAllUIListeners()` — 事件监听
- `self:AddUIEffect(VFXAssets.Xxx, {parentNode=..}, cb)` / `RemoveUIEffect(key)` — 特效
- `self:DelayInvoke(func, dt)` / `DoNextFrame(func)` — 定时/下一帧
- `self:GameObjectInstantiateAsync(prefabPath, onComplete, parent)` — 异步实例化

---

## 二、高频框架组件（按使用量排序）

### UITextMeshProUGUIEx（文本，最常用 ~6000 次）

TMP 富文本组件，UI 文本首选。

```lua
self.txt = self:AddComponent(UITextMeshProUGUIEx, "Text")
self.txt:SetText("hello")              -- 直接设文本
self.txt:SetLocalText(dialogId, ...)   -- 用本地化 ID 设文本（推荐，支持多语言 + 格式化参数）
self.txt:SetText_Cache(text)           -- 带缓存的设文本（降 GC）
self.txt:SetColor(color) / SetColorRGBA(r,g,b,a)
self.txt:SetAlpha(a)
self.txt:SetFontSize(size)
self.txt:SetAlignment(alignment)
self.txt:SetColorGradient(tl, tr, bl, br)  -- 四角渐变
self.txt:SetCodeEffectText(str, cb, startIdx, speed)  -- 打字机效果
self.txt:SetEnable(enable)
local s = self.txt:GetText()
```

### UIButton（按钮，~3900 次）

```lua
self.btn = self:AddComponent(UIButton, "CloseBtn")
self.btn:SetOnClick(function() self:CloseSelf() end)   -- 闭包
self.btn:SetOnClick(BindCallback(self, self.OnClick))  -- 或 BindCallback（推荐，降 GC）
self.btn:SetInteractable(true)     -- 可交互
self.btn:SetEnabled(true)          -- 启用/禁用
self.btn:SetSprite(spr)            -- 设置图片
self.btn:LoadSprite(path, default) -- 加载图片
self.btn:SetNativeSize()
self.btn:SetSafeClickMode(on)      -- 防连点
self.btn:SetParam(param) / GetParam()  -- 附带参数
```

### UIBaseContainer（容器/子节点，~3600 次）

用于把一个节点当作可控子节点（显隐、位移、作为其他组件的父）。

```lua
self.panel = self:AddComponent(UIBaseContainer, "Content")
self.panel:SetActive(true)          -- 显隐
self.panel:GetActive()
self.panel:SetLocalPosition(v) / SetLocalPositionXYZ(x,y,z)
self.panel:SetAnchoredPosition(v) / SetAnchoredPositionXY(x,y)
self.panel:SetLocalScale(v) / SetLocalScaleXYZ(x,y,z)
self.panel:SetSizeDelta(v) / SetSizeDeltaXY(x,y)
```

> 所有 UI 组件都继承自 UIBaseContainer/UIBaseComponent，因此上述 transform 类方法（位置/缩放/锚点/尺寸/显隐）**所有组件通用**。

### UIImage（图片，~2700 次）

```lua
self.img = self:AddComponent(UIImage, "Icon")
self.img:LoadSprite("Assets/Main/Sprites/UI/xxx.png", defaultPath)  -- 加载图集图片
self.img:LoadHeadEx(uid, pic, picVer, default, cb)  -- 加载玩家头像
self.img:SetFillAmount(0.5)        -- 填充比例（进度条）
self.img:SetColor(c) / SetColorRGBA(r,g,b,a) / SetAlpha(a)
self.img:SetMaterial(mat)
self.img:SetNativeSize()
self.img:SetRaycastTarget(false)   -- 是否接收点击
self.img:SetSizeByWidth(w) / SetSizeByHeight(h)
self.img:SetEnable(enable)
```

### UIText（旧版文本，~2200 次）

Unity 原生 Text，老代码用；**新代码优先用 UITextMeshProUGUIEx**。

### UIBaseComponent（~530 次）

组件基类，提供 `AddUIEffect`/`RemoveUIEffect` 等，一般不直接 AddComponent，而是作为其他组件的基类。

---

## 三、列表 / 滚动组件

### UIScrollView（通用滚动列表，~400 次）

回收复用式滚动列表，通过 MoveIn/MoveOut 回调管理 cell。

```lua
self.scroll = self:AddComponent(UIScrollView, "ScrollView")
self.scroll:SetOnItemMoveIn(function(itemObj, index) self:OnItemMoveIn(itemObj, index) end)
self.scroll:SetOnItemMoveOut(function(itemObj, index) self:OnItemMoveOut(itemObj, index) end)
self.scroll:SetTotalCount(#dataList)   -- 设置总数
self.scroll:RefreshCells()             -- 刷新
self.scroll:RefillCells(offset, fill)  -- 重填
self.scroll:ScrollToCell(index, speed) -- 滚到指定项
self.scroll:ClearCells()

-- MoveIn 回调里挂业务 cell 组件
function View:OnItemMoveIn(itemObj, index)
    local cell = self.scroll:AddComponent(SomeCell, itemObj)
    cell:ReInit(dataList[index])
end
```

### UILoopListView2（循环列表，~35 次）

另一套循环列表实现，用 `InitListView(count, onGetItemByIndex)` 驱动。

```lua
self.list = self:AddComponent(UILoopListView2, "ScrollView")
self.list:InitListView(totalCount, function(loopScroll, index)
    return self:OnGetItemByIndex(loopScroll, index)
end)
```

### GridInfinityScrollView（网格无限滚动，~35 次）

```lua
self.grid = self:AddComponent(GridInfinityScrollView, "Grid")
self.grid:Init(onInit, onUpdate, onDestroy, obj)
self.grid:SetItemCount(count)
self.grid:ForceUpdate()
```

### UIScrollRect / UIScrollViewEx / UIScrollPage

底层滚动矩形 / 扩展滚动 / 翻页滚动，特定场景使用。

---

## 四、交互组件

### UIToggle（开关/页签，~280 次）

```lua
self.toggle = self:AddComponent(UIToggle, "Toggle")
self.toggle:SetIsOn(true, force)
self.toggle:GetIsOn()
self.toggle:SetOnValueChanged(function(isOn) self:OnToggle(isOn) end)
self.toggle:SetGroup(group)            -- 单选组
self.toggle:SetIsOnWithoutNotify(t)    -- 设值不触发回调
self.toggle:SetInteractable(v)
```

### UISlider（滑条/进度，~240 次）

```lua
self.slider = self:AddComponent(UISlider, "Slider")
self.slider:SetValue(0.5)
self.slider:GetValue()
self.slider:SetOnValueChanged(function(v) self:OnSlide(v) end)
self.slider:DOValue(endValue, duration, callback)  -- 补间动画
self.slider:SetFillColor(color)
self.slider:SetInteractable(v)
```

### UIInput / UITMPInput（输入框）

```lua
self.input = self:AddComponent(UIInput, "InputField")  -- 或 UITMPInput（TMP版）
self.input:SetText(text) / GetText()
self.input:SetOnEndEdit(function(text) ... end)
self.input:SetOnValueChange(function(text) ... end)
self.input:Select()
```

### UIDropdown / UITMPDropdown（下拉框）

### UIEventTrigger（事件触发器，~50 次）

处理拖拽、按下、长按等复杂交互。

```lua
self.trigger = self:AddComponent(UIEventTrigger, "Area")
self.trigger:OnPointerDown(function(e) ... end)
self.trigger:OnPointerUp(function(e) ... end)
self.trigger:OnBeginDrag(fn) / OnDrag(fn) / OnEndDrag(fn)
self.trigger:OnLongPress(fn)
self.trigger:OnPointerClick(fn)
```

---

## 五、视觉 / 动画组件

### UIAnimator（动画，~310 次）

```lua
self.animator = self:AddComponent(UIAnimator, "Content")
self.animator:Play(name, layer, normalizedTime)
self.animator:SetBool(name, val) / SetTrigger(name) / ResetTrigger(name)
self.animator:SetSpeed(speed)
local t = self.animator:PlayAnimationReturnTime(animName)  -- 播放并返回时长
```

### UICanvasGroup（透明度/交互组，~33 次）

```lua
self.cg = self:AddComponent(UICanvasGroup, "Panel")
self.cg:SetAlpha(0.5)
self.cg:SetInteractable(v)
self.cg:SetBlocksRaycasts(v)
```

### UIShadow / UIOutline（阴影 / 描边，~110 / ~11 次）

文本或图片的阴影、描边效果。

### UIRawImage（原始图，~30 次）

用于大图 / 动态贴图 / RenderTexture。

```lua
self.raw = self:AddComponent(UIRawImage, "RawImage")
self.raw:SetTexture(texture)
self.raw:LoadSprite(path, default, forceReplaceTexture)
```

### CircleImage（圆形图，~15 次）

```lua
self.circle = self:AddComponent(CircleImage, "Head")
self.circle:LoadSprite(path, default)
self.circle:SetIsCircle(true)
```

### UISpine（Spine 骨骼动画）

```lua
self.spine = self:AddComponent(UISpine, "SpineNode")
self.spine:SetAnimation(trackIndex, animName, loop)
self.spine:AddAnimation(trackIndex, animName, loop, delay)
self.spine:SetGray(isGray) / SetColor(color) / SetFreeze(isFreeze)
self.spine:ClearTracks()
```

### UITweenNumberText（数字滚动，~23 次）

数字变化的补间动画（战力、金币等）。

```lua
self.num = self:AddComponent(UITweenNumberText, "PowerText")
self.num:SetNum(num)
self.num:TweenToNum(targetNum, duration, delay, scale, callback)
```

### UILayout（布局）

- `UIHorizontalOrVerticalLayoutGroup` — 横/竖布局组
- `UILayoutElement` — 布局元素

---

## 六、业务通用组件（跨窗口复用，位于 UI/ 下的公共组件目录）

这些不是框架组件，而是业务层封装的可复用组件，同样用 `AddComponent` 挂载：

| 组件 | 用途 | 使用量 |
|------|------|--------|
| `UIPlayerHead` / `UIPlayerHeadNew` | 玩家头像（框架级） | ~173 |
| `UICommonResItem` | 通用资源/奖励项 | ~142 |
| `UICommonItem` | 通用道具项 | ~84 |
| `UICommonHead` | 通用头部 | ~11 |
| `UIHeroCellSmall` / `UIHeroCell` | 英雄格子 | ~50 |
| `UIHeroStars` | 英雄星级 | ~28 |
| `UIHeroSkill` | 英雄技能 | ~13 |
| `AllianceFlagItem` | 联盟旗帜 | ~69 |
| `UIGiftPackagePoint` | 礼包红点 | ~67 |
| `RewardItem` / `ActivityRewardItem` / `UIGiftRewardCell` | 奖励展示项 | — |
| `CommonGoodsShopItem` | 商店商品项 | ~20 |
| `HeroModelViewer` | 英雄模型展示 | ~14 |
| `UIPVEMainResourceBar` | 资源条 | ~14 |
| `UIMedalCell` | 勋章格子 | ~12 |

业务组件均继承 `UIBaseContainer`，核心方法约定：`SetData(data)` / `ReInit(data)` 填充数据。

---

## 七、组件使用规范

1. **文本首选 `UITextMeshProUGUIEx`**，本地化文本用 `SetLocalText(dialogId)` 而非硬编码字符串
2. **按钮回调优先 `BindCallback(self, self.Method)`**（降 GC），简单逻辑可用闭包
3. **图片路径**统一走 `LoadSprite`（自动触发图集加载），路径以 `.png` 结尾
4. **列表用 UIScrollView**（MoveIn/MoveOut 回调 + AddComponent 挂 cell），大数据量用循环/网格滚动
5. **transform 操作**（位置/缩放/显隐/尺寸）所有组件通用（继承自 UIBaseContainer）
6. **组件实例缓存到 `self.xxx`**，在 `ComponentDefine()` 中统一 AddComponent
7. **特效用 `AddUIEffect(VFXAssets.Xxx)` + `RemoveUIEffect`**（成对），见 rules.md
8. **不要手动 Instantiate**，用 `GameObjectInstantiateAsync` 或 UIAssets + 组件系统

---

## 八、框架组件全表（Framework/UI/Component）

文本类：`UIText`、`UINewText`、`UITextMeshProUGUI`、`UITextMeshProUGUIEx`、`UINewTMPText`、`UITweenNumberText`
图片类：`UIImage`、`UIRawImage`、`CircleImage`
交互类：`UIButton`、`UIToggle`、`UISlider`、`UIInput`、`UITMPInput`、`UIDropdown`、`UITMPDropdown`、`UIEventTrigger`
容器/布局：`UIBaseContainer`、`UICanvas`、`UICanvasGroup`、`UIHorizontalOrVerticalLayoutGroup`、`UILayoutElement`、`UILayerComponent`
滚动列表：`UIScrollView`、`UIScrollViewEx`、`UIScrollViewExclusive`、`UIScrollRect`、`UIScrollPage`、`UILoopListView2`、`UIUnlimitedScrollView`、`GridInfinityScrollView`、`HorizontalInfinityScrollView`
动画/视觉：`UIAnimator`、`UISimpleAnimation`、`UISpine`、`UIShadow`、`UIOutline`
业务封装：`UIPlayerHead`、`UIPlayerHeadNew`、`UICommonHead`
其他：`UIBoxCollider2D`
扩展（ComponentExt）：`UIButton_LongPress`、`UIEmpty4Raycast`、`GetHDRIntensity`
