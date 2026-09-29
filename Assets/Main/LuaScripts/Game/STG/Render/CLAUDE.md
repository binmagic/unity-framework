# Game/STG/Render/

> L2 | 父级: `Assets/CLAUDE.md`（`Game/` 目录暂无 L2，见下方「上游缺口」）

## 定位

STG 关卡的**背景表现层**。消费 `Game/STG/DataCenter/StgLevelConfig.lua` 解析出的 `cfg.backgroundLayers`，把编辑器（`Assets/Editor/STG/Panels/BackgroundConfigPanel.cs`）里配好的滚屏贴图带与散布装饰渲染出来。

与同级目录的边界：`Spawner/` 产出战斗实体（敌机/波次），`Entity/` 是可交互的门与机关，本目录只负责**不参与战斗判定的背景画面**——不吃点击（`raycastTarget=false`）、不做碰撞、不影响结算。

依赖方向单向向下：`UI/UIPlaneBattle/View/UIPlaneBattleView.lua` → `StgBackgroundRenderer` → `StgBackgroundLayer`。反向不依赖，本目录不认识 View。

## 成员清单

`StgBackgroundLayer.lua`: 单层背景渲染器。两件事——① 循环贴图带（`useTileLoop`）：多张图首尾相接铺成无限带，随卷轴下移，滚出屏底的 tile 复用节点接到带顶；② 散布装饰物（`enableScatterSpawn`）：按随机间隔 + 加权规则（`Mathf.GetRandomByWeight`）在屏顶外撒装饰物，出屏回收进手写池（`freeList`/`active`，对标 `UI/UIPlaneBattle/Component/BulletPool.lua`）。工作在 UGUI 参考分辨率像素空间（750x1625，锚点父节点底部中心）。

`StgBackgroundRenderer.lua`: 多层总管。按 `orderInLayer` 升序创建各层（UGUI 靠 sibling index 决定绘制顺序，升序 = 远景在下、近景在上），统一驱动 `Update`/`Destroy`。`Setup` 可重复调用（重进关卡时先 `ClearLayers` 再建），`ClearLayers`（清层留壳，可重建）与 `Destroy`（整个不要了）语义分离。

## 关键设计决策

**接带高度必须留一张预备图**。tile 的回收条件是"整张滚到屏底之下"，所以带底那张在被接到带顶前，最多会先下移一整张图的高度——这期间带顶在往下掉。若初始只铺到"刚好盖过屏顶"，带顶会掉到屏顶之下，屏幕顶部露出空带。故铺带条件是 `(n-1) × 图高 ≥ 屏高`。这与编辑器预览 `StgPreviewTileStrip.BuildStrips` 的"强制至少再铺一张"同源（commit `462ae91` 修的黑屏 bug），但那边是世界单位、单张图远大于画幅所以 2 张即可兜底，这里是像素空间、单张图常小于屏高，必须按高度算够。

**tile 高度以贴图原生高度为准，`tileWorldHeight` 只能兜底**。`StgLevelConfig.ParseBackgroundLayers` 会解析 `tileWorldHeight`，但编辑器 `StgLevelJsonIO` 从不导出该字段，运行时恒为默认值 0——拿它当主来源会让整条带高度为 0 全叠在一起。编辑器预览侧同样按原生高度做接带定位，两边一致才能保证"预览所见 = 真机所得"。

**算法与编辑器预览刻意保持一致**。`Assets/Editor/STG/Preview/StgPreviewTileStrip.cs` 与 `StgPreviewRuntime.cs`（`TickLayerScatterSpawn`/`PickWeightedRule`）是本目录的权威参考实现。改这里的接带或散布规则时，必须同步确认编辑器侧行为，否则策划在编辑器里调出来的效果和真机跑出来的会对不上。

## 已知缺口

- `change_scroll_speed` 时间轴事件目前 `StgBattleLogic` 未消费，滚动速度固定读 `basicScroll.baseSpeed × speedMultiplier`。等逻辑侧支持动态调速后，把 `Setup` 传入的 `scrollSpeedProvider` 改成读 logic 的当前速度字段即可（该参数就是为此预留的间接层）。
- `layerType == "player"`（编辑器语义：跟随主机移动的层）当前与 `parallax` 同样处理，等策划确认跟随规则（幅度／是否只跟 X）后在 `StgBackgroundLayer` 内分流。

## 上游缺口

`Game/` 与 `Game/STG/` 尚无 L2 文档，且 `Assets/CLAUDE.md`（L1）的「Lua 顶层目录（固定 10 个）」清单里没有 `Game/`——L1 与实际目录结构已不同构（SEVERE-003）。本目录的父级链接暫指向 L1，待 `Game/` 层级补齐 L2 后改为指向 `Game/STG/CLAUDE.md`。

[PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
