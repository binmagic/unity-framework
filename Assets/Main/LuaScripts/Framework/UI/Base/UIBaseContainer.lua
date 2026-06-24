--[[
-- added by wsh @ 2017-12-08
-- UI容器基类：当一个UI组件持有其它UI组件时，它就是一个容器类，它要负责调度其它UI组件的相关函数
-- 注意：
-- 1、window.view是窗口最上层的容器类
-- 2、AddComponent用来添加组件，一般在window.view的OnCreate中使用，RemoveComponent相反
-- 3、GetComponent用来获取组件，GetComponents用来获取一个类别的组件
-- 4、很重要：子组件必须保证名字互斥，即一个不同的名字要保证对应于Unity中一个不同的Transform
--]]

---@class UIBaseContainer : UIBaseComponent
local UIBaseContainer = BaseClass("UIBaseContainer", UIBaseComponent)
-- 基类，用来调用基类方法
local base = UIBaseComponent
local tinsert = table.insert
local tcount = table.count
local pairs = pairs
local assert = assert
local error = error
local type = type

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	self.components = {}
	self.length = 0
	self.__event_handlers = {}
end

-- 打开
local function OnEnable(self)
	base.OnEnable(self)
	
	if self.__update_handle then
		UpdateManager:GetInstance():RemoveUpdate(self.__update_handle)
		self.__update_handle = nil
	end
	if self.Update then
		self.__update_handle = function() self:Update() end
		UpdateManager:GetInstance():AddUpdate(self.__update_handle)
	end

	self:OnAddListener()
end

-- 关闭
local function OnDisable(self)
	self:OnRemoveListener()

	if self.__update_handle then
		UpdateManager:GetInstance():RemoveUpdate(self.__update_handle)
		self.__update_handle = nil
	end
	
	base.OnDisable(self)
end

-- 注册消息
local function OnAddListener(self)
end

-- 注销消息
local function OnRemoveListener(self)
end

-- 注册UI数据监听事件，别重写
local function AddUIListener(self, msg_name, callback)
	if self.__event_handlers ~= nil then
		if self.__event_handlers[msg_name] ~= nil then
			Logger.LogError(debug.traceback("Already contains listener:"..msg_name))
		end
		local bindFunc = function(...) callback(self, ...) end
		self.__event_handlers[msg_name] = bindFunc
		EventManager:GetInstance():AddListener(msg_name, bindFunc)
	else
		Logger.LogError("UIBaseContainer [AddUIListener]: self.__event_handlers is nil, stack traceback:" .. debug.traceback())
	end
end

-- 注销UI数据监听事件，别重写
local function RemoveUIListener(self, msg_name, callback)
	if self.__event_handlers ~= nil then
		local bindFunc = self.__event_handlers[msg_name]
		if not bindFunc then
			Logger.LogError(msg_name, " not register")
			return
		end
		self.__event_handlers[msg_name] = nil
		EventManager:GetInstance():RemoveListener(msg_name, bindFunc)
	else
		Logger.LogError("UIBaseContainer [RemoveUIListener]: self.__event_handlers is nil, stack traceback:" .. debug.traceback())
	end
	--UIManager:GetInstance():RemoveListener(msg_name, bindFunc)
end

--zlh: 加个removeAll的接口
function UIBaseContainer:RemoveAllUIListeners()
	if not self.__event_handlers then return end

	for name, bindFunc in pairs(self.__event_handlers) do
		EventManager:GetInstance():RemoveListener(name, bindFunc)
	end

	table.clear(self.__event_handlers)
end


local function UIBroadcast(self, msg_name, ...)
	--UIManager:GetInstance():Broadcast(msg_name, ...)
	EventManager:GetInstance():Broadcast(msg_name, bindFunc)
end

-- 遍历：注意，这里是无序的
local function Walk(self, callback, component_class)
	if self.components then
		for _,components in pairs(self.components) do
			for cmp_class,component in pairs(components) do
				if component_class == nil then
					callback(component)
				elseif cmp_class == component_class then
					callback(component)
				end
			end
		end
	else
		Logger.LogError("self.components nil? why?")
	end
end

-- 如果必要，创建新的记录，对应Unity下一个Transform下所有挂载脚本的记录表
local function AddNewRecordIfNeeded(self, id)
	if self.components[id] == nil then
		self.components[id] = {}
	end
end

-- 记录Component
local function RecordComponent(self, id, component_class, component)
	-- 同一个Transform不能挂两个同类型的组件
	if self.components[id][component_class] ~= nil then
		Logger.LogError('RecordComponent error!')
		--self:RemoveComponent(id, component_class)
	end
	assert(self.components[id][component_class] == nil, "Already exist component_class : ", component_class.__cname)
	
	self.components[id][component_class] = component
end

--[[禁用SetName
-- 子组件改名回调
local function OnComponentSetName(self, component, new_name)
	AddNewRecordIfNeeded(self, new_name)
	-- 该名字对应Unity的Transform下挂载的所有脚本都要改名
	local old_name = component:GetName()
	local components = self.components[old_name]
	for k,v in pairs(components) do
		v:SetName(new_name)
		RecordComponent(self, new_name, k, v)
	end
	self.components[old_name] = nil
end
]]--

-- 子组件销毁
local function OnComponentDestroy(self, component)
	self.length = self.length - 1
end

-- 添加组件
-- 多种重载方式
-- 指定Lua侧组件类型和必要参数，新建组件并添加，多种重载方式：
--    A）inst:AddComponent(ComponentTypeClass, relative_path)
--    B）inst:AddComponent(ComponentTypeClass, unity_gameObject)
local function AddComponent(self, component_target, var_arg, ...)
	--临时兼容处理
	if type(var_arg) == 'string' then
		if not string.IsNullOrEmpty(var_arg) then
			local tf = self.transform:Find(_ToID(var_arg))
			if tf ~= nil then
				local id = tf.gameObject:GetInstanceID()
				local c = self:GetComponent(id, component_target)
				if c ~= nil then
					if c:GetActiveInHierarchy() then
						c:OnEnable()
					end
					return c
				end
			else
				Logger.LogError('添加组件失败，预设路径 : '..var_arg..' 不存在 ')
			end
		end
	else
		local id = var_arg:GetInstanceID()
		local c = self:GetComponent(id, component_target)
		if c ~= nil then
			if c:GetActiveInHierarchy() then
				c:OnEnable()
			end
			return c
		end
	end
	
	assert(component_target.__ctype == ClassType.class)
	local component_inst = nil
	local component_class = nil
	component_inst = component_target.New(self, var_arg)
	component_class = component_target
	component_inst:OnCreate(...)
	
	local id = component_inst:GetInstanceID()
	AddNewRecordIfNeeded(self, id)
	RecordComponent(self, id, component_class, component_inst)
	self.length = self.length + 1

	if component_inst:GetActiveInHierarchy() then
		component_inst:OnEnable()
	end
	
	return component_inst
end

-- 获取组件
local function GetComponent(self, id, component_class)
	--尝试兼容以前老的name方式
	--if type(id) == 'string' then
	--	
	--	
	--	Logger.Log('GetComponent 请改用gameObject:GetInstanceID()做参数')
	--	local go = self.transform:FindChildEx(id)
	--	if go then
	--		id = go:GetInstanceID()
	--	else
	--		Logger.LogError('GetComponent 错误!')
	--		return nil
	--	end
	--end
	
	local components = self.components[id]
	if components == nil then
		return nil
	end
	
	if component_class == nil then
		-- 必须只有一个组件才能不指定类型，这一点由外部代码保证
		assert(tcount(components) == 1, "Must specify component_class while there are more then one component!")
		for _,component in pairs(components) do
			return component
		end
	else
		return components[component_class]
	end
end

-- 获取一系列组件：2种重载方式
-- 1、获取一个类别的组件
-- 2、获取某个id（GameObject）下的所有组件
local function GetComponents(self, component_target)
	local components = {}
	if type(component_target) == "table" then
		self:Walk(function(component)
			tinsert(components, component)
		end, component_target)
	elseif type(component_target) == "string" then
		components = self.components[component_target]
	elseif type(component_target) == 'number' then
		components = self.components[component_target]
	else
		error("GetComponents params err!")
	end
	return components
end

-- 获取组件个数
local function GetComponentsCount(self)
	return self.length
end

-- 移除组件
local function RemoveComponent(self, id, component_class)
	--尝试兼容以前老的name方式
	if type(id) == 'string' then
		Logger.Log('RemoveComponent 请改用gameObject:GetInstanceID()做参数')
		local go = self.transform:FindChildEx(id)
		if go then
			id = go.gameObject:GetInstanceID()
		else
			Logger.Debug('RemoveComponent 错误!')
			return nil
		end
	end
	
	local component = self:GetComponent(id, component_class)
	if not component then
		return
	end

	component:SetActive(false)
	
	local cmp_class = component._class_type
	component:Delete()
	self.components[id][cmp_class] = nil
end

-- 移除一系列组件：2种重载方式
-- 1、移除一个类别的组件
-- 2、移除某个name（Transform）下的所有组件
local function RemoveComponents(self, component_target)
	local components = self:GetComponents(component_target)
	if not components then
		return
	end
	for _,component in pairs(components) do
		component:SetActive(false)
		--local cmp_name = component:GetName()
		local cmp_id = component:GetInstanceID()
		local cmp_class = component._class_type
		component:Delete()
		self.components[cmp_id][cmp_class] = nil
	end
end

-- 销毁
local function OnDestroy(self)
	if self.__update_handle then
		UpdateManager:GetInstance():RemoveUpdate(self.__update_handle)
		self.__update_handle = nil
	end
	if self.__event_handlers then
		for k,v in pairs(self.__event_handlers) do
			self:RemoveUIListener(k, v)
		end
		self.__event_handlers = nil
	end
	if self.components then
		self:Walk(function(component)
			component:Delete()
		end)
		self.components = nil
	end
	self.isDestroy = true
	base.OnDestroy(self)
end

local function IsDestroy(self)
	if self.isDestroy == true then
		return true
	end
	return false
end

--[[
	不传值表示下一帧执行
]]
local function DelayInvoke(self, action, dt)
	dt = dt or 0
	local t = TimerManager:GetInstance():DelayInvoke(function()
		if self:IsDestroy() then return end
		if action ~= nil then
			action()
		end
	end, dt)
	return t
end

local function DoNextFrame(self, action)
	TimerManager:GetInstance():DelayNextFrameAction(function()
		if self:IsDestroy() then return end
		if action ~= nil then
			action()
		end
	end)
end

local function SetActiveRecursive(com)
	local state, changed
	if com.activeCached ~= nil then
		local oldActive = com.activeCached
		com.activeCached = nil
		state = com:GetActiveInHierarchy()
		changed = oldActive ~= state
	else
		state = com:GetActiveInHierarchy()
		changed = true
	end

	if com.components ~= nil then
		for _,components in pairs(com.components) do
			for _,childCom in pairs(components) do
				SetActiveRecursive(childCom)
			end
		end
	end

	if changed then
		if state then
			com:OnEnable()
		else
			com:OnDisable()
		end
	end
end

local function SetActive(self, active)
	if active then
		if self:GetActiveInHierarchy() then
			return
		end
	else
		if not self:GetActiveInHierarchy() then
			self.activeSelf = false
			if not IsNull(self.gameObject) then
				self.gameObject:SetActive(false)
			else
				self:SetInitActiveSelf(false)
			end
			return
		end
	end
	
	self.activeSelf = active;
	if not IsNull(self.gameObject) then
		self.gameObject:SetActive(active)
	else
		self:SetInitActiveSelf(active)
	end
	SetActiveRecursive(self)
end

--刷新动态添加的UIEffect order
function UIBaseContainer:ResortUIEffect()
	base.ResortUIEffect(self)

	if self.components ~= nil then
		self:Walk(function(component)
			component:ResortUIEffect()
		end)
	end
end


UIBaseContainer.SetActive = SetActive
UIBaseContainer.OnCreate = OnCreate
UIBaseContainer.OnEnable = OnEnable
UIBaseContainer.AddUIListener = AddUIListener
UIBaseContainer.RemoveUIListener = RemoveUIListener
UIBaseContainer.UIBroadcast = UIBroadcast
UIBaseContainer.OnAddListener = OnAddListener
UIBaseContainer.OnRemoveListener = OnRemoveListener
UIBaseContainer.Walk = Walk
UIBaseContainer.OnComponentSetName = OnComponentSetName
UIBaseContainer.OnComponentDestroy = OnComponentDestroy
UIBaseContainer.AddComponent = AddComponent
UIBaseContainer.GetComponent = GetComponent
UIBaseContainer.GetComponents = GetComponents
UIBaseContainer.GetComponentsCount = GetComponentsCount
UIBaseContainer.RemoveComponent = RemoveComponent
UIBaseContainer.RemoveComponents = RemoveComponents
UIBaseContainer.OnDisable = OnDisable
UIBaseContainer.OnDestroy = OnDestroy
UIBaseContainer.DelayInvoke = DelayInvoke
UIBaseContainer.IsDestroy = IsDestroy
UIBaseContainer.DoNextFrame = DoNextFrame

return UIBaseContainer