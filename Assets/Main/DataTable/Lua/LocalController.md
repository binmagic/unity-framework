I have the full picture now. Here's how the `LuaDatatable` config tables get loaded.

## `LuaDatatable` 目录下配置表的加载机制

这批表共 **381 个 lua 文件、约 78MB**，是从 Excel 导出的游戏配置。加载分两层：**Lua 层触发 → C# 层实际读取文件**。

### 目录职责（注意有两份）

| 目录 | 用途 |
|------|------|
| `DataTable/Lua/LuaDatatable/` | **源文件**（.lua，开发/编辑器可读的明文表） |
| `DataTable/LuaTxt/` | **打包运行时用**（.bytes，编译后的字节码，进 AssetBundle） |

### 完整加载流程

```
业务代码: GetTableNumber(TableName.HeroColor, 2, "star_up_1")
   │
   ▼ (Common/LocalController.lua)
getTable("APS_hero_color")  →  内存无缓存
   │
   ▼ LoadTable()
require("LuaDatatable.APS_hero_color")   ← xmlPath="LuaDatatable." + 表名
   │
   ▼ XLua 触发自定义 loader
XLuaManager.CustomLoader(ref filepath)    (Scripts/XLua/XLuaManager.cs:433)
   │
   ├─ 把 "LuaDatatable.APS_hero_color" 的 '.' 换成 '/'
   │   → "LuaDatatable/APS_hero_color"
   │
   ├─ 拼路径：遍历 LuaRootPath = {
   │      "Assets/Main/LuaTxt/",
   │      "Assets/Main/DataTable/LuaTxt/"   ← 配置表在这
   │   }
   │   → "Assets/Main/DataTable/LuaTxt/LuaDatatable/APS_hero_color.bytes"
   │
   ├─ GameEntry.Resource.HasAsset(luafile)  → 从 AssetBundle 查
   ├─ GameEntry.Resource.LoadAsset(luafile, TextAsset)  → 加载 .bytes
   └─ 返回字节码给 XLua 执行 → 得到 {index=..., data=...} table
   │
   ▼ 回到 LocalController
缓存到 self.xmlValue["APS_hero_color"]   ← 下次直接命中，不再加载
```

### 关键机制

**1. 自定义 Lua Loader（核心）**
`XLuaManager.cs:142` 注册：`m_LuaEnv.AddLoader(CustomLoader)`。
所有 `require` 都会走这个 loader，它负责把 Lua 的模块名（点号分隔）转成物理路径，从 AssetBundle 读 `.bytes` 文件。

**2. 路径映射规则**
- `LuaDatatable.` 前缀（`LocalController.lua:79` 的 `xmlPath`）
- `.` → `/`，加 `.bytes` 后缀
- 根目录 `Assets/Main/DataTable/LuaTxt/`

**3. 懒加载 + 缓存**
- **不预加载**。381 个表不会启动时全读进来（78MB 太大）
- 首次 `GetTableXxx` 访问某表时才 `require` 加载
- 加载后缓存在 `LocalController.xmlValue`，后续零成本命中

**4. 编辑器调试分支**
`CustomLoader` 里还有一段（:505-516）：编辑器下优先从 `persistentDataPath` 读明文 `.lua`，方便断点调试；运行时才读 AssetBundle 里的 `.bytes`。

**5. AB 测试表**
`getTable` 会先经过 `GetABTestTableName`，根据玩家 AB 分组可能加载 `xxx_B` 变体表。

### 一句话总结

`LuaDatatable` 的表通过 **XLua 的自定义 loader（`XLuaManager.CustomLoader`）** 加载：业务用 `GetTableXxx` → `LocalController` 懒触发 `require("LuaDatatable.表名")` → loader 把它映射成 `Assets/Main/DataTable/LuaTxt/LuaDatatable/表名.bytes`，从 AssetBundle 读字节码执行，结果缓存复用。全程按需加载、加载一次缓存到底。