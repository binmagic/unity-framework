--[[
-- added by wsh @ 2017-11-28
-- 消息系统
-- 使用范例：
-- local Messenger = require "Framework.Common.Messenger";
-- local TestEventCenter = Messenger.New() --创建消息中心
-- TestEventCenter:AddListener(Type, callback) --添加监听
-- TestEventCenter:AddListener(Type, callback, ...) --添加监听
-- TestEventCenter:Broadcast(Type, ...) --发送消息
-- TestEventCenter:RemoveListener(Type, callback, ...) --移除监听
-- TestEventCenter:Cleanup() --清理消息中心
-- 注意：
-- 1、模块实例销毁时，要自动移除消息监听，不移除的话不能自动清理监听
-- 2、使用弱引用，即使监听不手动移除，消息系统也不会持有对象引用，所以对象的销毁是不受消息系统影响的
-- 3、换句话说：广播发出，回调一定会被调用，但回调参数中的实例对象，可能已经被销毁，所以回调函数一定要注意判空
--]]

local Messenger = BaseClass("Messenger");
local empty_table = {}

---------------------------------------------------
-- 这里整一个空表集合池
local __emptyTableList = {}

local function __popATable()
	local c = #__emptyTableList
	local ret
	if c > 0 then
		ret = __emptyTableList[c]
		__emptyTableList[c] = nil
	else
		ret = {}
	end

	return ret
end

local function __recycleATable(t)
	if t then
		table.clear(t)
		table.insert(__emptyTableList, t)
	end
end
---------------------------------------------------


local function __init(self)
	self.events = {}
end

local function __delete(self)
	self.events = nil	
end

local function AddListener(self, e_type, e_listener, ...)
	local event = self.events[e_type]
	if event == nil then
		event = setmetatable({}, {__mode = "k"})
		self.events[e_type] = event
	end

	if event[e_listener] ~= nil then
		Logger.LogError("event: " .. tostring(e_type) .. ", Already contains listener : " .. tostring(e_listener))
		return
	end
	
	-- 如果没有初始参数的话，这里就先设置成一个空表（没有额外开销）
	-- 否则需要将初始参数pack到一个table里，到时候展开使用
	if select('#', ...) == 0 then
		event[e_listener] = empty_table
	else
		event[e_listener] = setmetatable(SafePack(...), {__mode = "kv"}) 
	end
end

local function Broadcast(self, e_type, ...)
	local event = self.events[e_type]
	if event == nil then
		return
	end
	
	-- arglen表示用户传递的参数
	local arglen = select("#", ...)
	local ok, msg

	-- (*)注这里非常重要，可能产生潜在BUG!
	-- 重入：指在处理这个类型的时候，又开始添加删除这个类型的监听
	-- 因为你还得解决重入的不同类型重入。即：在broadcast的处理函数里又去boradcast其他类型
	-- 要处理的没有BUG，代码编写会比较复杂
	-- 所以这里就先放到一个临时的缓存列表中，牺牲了一点效率换来了绝对安全
	local tmp_event = __popATable()
	for k,v in pairs(event) do
		tmp_event[k] = v
	end
		
	-- 减少lua的gc，这里没必要每次都concat
	for k, v in pairs(tmp_event) do
		-- 因为tmp_event是个快照，所以每次需要判断一下真正的实体中是否存在，有可能运行中已经删除了
		if event[k] == nil then
			goto continue
		end
		
		local vlen = v.n and v.n or #v
		if arglen > 0 and vlen > 0 then
			local args = ConcatSafePack(v, SafePack(...))
			ok, msg = xpcall(k, debug.traceback, SafeUnpack(args))
		elseif vlen > 0 then
			ok, msg = xpcall(k, debug.traceback, table.unpack(v, 1, vlen))
		elseif arglen > 0 then
			ok, msg = xpcall(k, debug.traceback, ...)
		else
			ok, msg = xpcall(k, debug.traceback)
		end
				
		if not ok then
			local now = UITimeManager:GetInstance():GetServerSeconds()
			CommonUtil.SendErrorMessageToServer(now, now, msg)
			Logger.LogError(msg)
		end
			
		::continue::
	end
	
	__recycleATable(tmp_event)

end

local function RemoveListener(self, e_type, e_listener)
	
	-- FIXME: 这个地方加一个LOG，打印一下这种情况。上线给删除即可
	if e_type == nil or e_listener == nil then
		Logger.LogError(debug.traceback())	
		return
	end
	
	local event = self.events[e_type]
	if event == nil then
		return
	end

	event[e_listener] = nil
end

local function RemoveListenerByType(self, e_type)
	self.events[e_type] = nil
end

local function Cleanup(self)
	self.events = {}
end

local function Dump(self)
	if App.IsEditor() then
		Logger.Debug("Messenger Dump...")
		for k,v in pairs(self.events) do
			local c = table.count(v)
			if c > 0 then
				Logger.Debug("  e_type = ", tostring(k))
			end
		end
	end
end

Messenger.__init = __init 
Messenger.__delete = __delete
Messenger.AddListener = AddListener
Messenger.Broadcast = Broadcast
Messenger.RemoveListener = RemoveListener
Messenger.RemoveListenerByType = RemoveListenerByType
Messenger.Cleanup = Cleanup
Messenger.Dump = Dump

return Messenger;