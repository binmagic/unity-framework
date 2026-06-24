--[[
-- added by wsh @ 2017-12-18
-- 更新管理，负责Unity侧Update对Lua脚本的调用
-- 注意：
-- 1、别直接用tolua的UpdateBeat所有需要以上三个更新函数的脚本，都从这里注册。
-- 2、tolua的event没有使用weak表，直接使用tolua的更新系统会导致脚本被event持有引用而无法释放---除非每次都记得手动去释放
--]]

local Messenger = require "Framework.Common.Messenger"
local UpdateManager = BaseClass("UpdateManager", Singleton)
local UpdateMsgName = "Update"

-- 构造函数
local function __init(self)
	-- 消息中心
	self.ui_message_center = nil
	-- Update
	self.__update_handle = nil
end

-- Update回调
local function UpdateHandle(self)
	self.ui_message_center:Broadcast(UpdateMsgName)
end

-- 启动
local function Startup(self)
	self:Dispose()
	self.__update_handle = UpdateBeat:CreateListener(UpdateHandle, UpdateManager:GetInstance())
	UpdateBeat:AddListener(self.__update_handle)
	self.ui_message_center = Messenger.New()
end

-- 释放
local function Dispose(self)
	if self.__update_handle ~= nil then
		UpdateBeat:RemoveListener(self.__update_handle)
		self.__update_handle = nil
	end
end

-- 清理：消息系统不需要强行清理
local function Cleanup(self)
end

-- 添加Update更新
local function AddUpdate(self, e_listener)
	self.ui_message_center:AddListener(UpdateMsgName, e_listener)
end

-- 移除Update更新
local function RemoveUpdate(self, e_listener)
	self.ui_message_center:RemoveListener(UpdateMsgName, e_listener)
end

-- 析构函数
local function __delete(self)
	self:Cleanup()
	self.ui_message_center = nil
end

UpdateManager.__init = __init
UpdateManager.Startup = Startup
UpdateManager.Dispose = Dispose
UpdateManager.Cleanup = Cleanup
UpdateManager.AddUpdate = AddUpdate
UpdateManager.RemoveUpdate = RemoveUpdate
UpdateManager.__delete = __delete
return UpdateManager;