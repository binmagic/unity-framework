# UI/
> L2 | 父级: ../../../CLAUDE.md

UI 窗口配置层。当前仅落地 Config/ 下的两张路由表，窗口 Lua（MVC 的 View/Model/Ctrl）待后续落地到 UI/ 下对应目录。UIWindowNames 登记窗口名常量，UIConfig 把窗口名映射到 Config 类路径，二者配对供 UIManager:OpenWindow 使用。

## 注册规则
- UIWindowNames.lua：格式 `Name = "Name",`（key 与 value 同名），新增窗口先在此登记
- UIConfig.lua：格式 `[UIWindowNames.XXX] = "UI.路径.Config",`，据此定位窗口 Config 类
- Config 路径前缀仅允许 `UI.`，连连看窗口统一用 `UI.LianLian.` 前缀，禁止自创命名空间
- 窗口 Lua 放 UI/ 下，不可新建顶层目录

## 成员清单
Config/UIWindowNames.lua: 窗口名常量表，ConstClass 只读并注入全局；按名引用窗口避免硬编码字符串
Config/UIConfig.lua: 窗口路由表，ConstClass 只读，窗口名→Config 类 require 路径（连连看统一 UI.LianLian.XXX.Config）

[PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
