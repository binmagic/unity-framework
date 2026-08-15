--[[
-- [INPUT]: 依赖 Common/BaseClass 的 BaseClass 工厂与 _class_type 机制
-- [OUTPUT]: 对外提供 Singleton 基类，暴露 GetInstance/Startup/Delete 及 __init/__delete 生命周期
-- [POS]: Common OOP 系统在 BaseClass 之上的单例范式扩展，全局唯一实例挂在类表的 Instance 字段上；各 Manager(TimerManager/UpdateManager/TimeUpManager 等)继承它获得单例语义
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-12-05
-- 单例类
--]]

---@class Singleton
local Singleton = BaseClass("Singleton");

local function __init(self)
	assert(rawget(self._class_type, "Instance") == nil, self._class_type.__cname.." to create singleton twice!")
	rawset(self._class_type, "Instance", self)
end

local function __delete(self)
	rawset(self._class_type, "Instance", nil)
end

-- 只是用于启动模块
local function Startup(self)
end

-- 不要重写
local function GetInstance(self)
	if rawget(self, "Instance") == nil then
		rawset(self, "Instance", self.New())
	end
	assert(self.Instance ~= nil)
	return self.Instance
end

-- 不要重写
local function Delete(self)
	self.Instance = nil
end

Singleton.__init = __init
Singleton.__delete = __delete
Singleton.Startup = Startup
Singleton.GetInstance = GetInstance
Singleton.Delete = Delete

return Singleton;
