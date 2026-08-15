--[[
-- [INPUT]: 依赖 DataClass 生成可实例化的数据结构模板
-- [OUTPUT]: 对外提供 UIWindow 数据类，字段含 Name/Layer/Ctrl/View/PrefabPath/State/OpenOptions/CloseTimer/InstanceRequest
-- [POS]: UI 框架中一个窗口的运行时数据载体，由 UIManager 创建并持有，串联该窗口的 View/Ctrl 实例与加载状态；窗口名必须与预设名一致
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-11-30
-- UIWindow数据，用以表示一个窗口
-- 注意：
-- 1、窗口名字必须和预设名字一致
--]]

local UIWindow = {
	-- 窗口名字
	Name = nil,
	-- layer对象
	Layer = nil,
	-- Ctrl实例
	Ctrl = nil,
	-- View实例
	View = nil,
	-- 预设路径
	PrefabPath = nil,
	-- 界面状态
	State = 0,
	-- 打开参数
	OpenOptions = nil, --{},

	CloseTimer = nil,
	InstanceRequest = nil,
}
	
return DataClass("UIWindow", UIWindow)