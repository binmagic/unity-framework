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