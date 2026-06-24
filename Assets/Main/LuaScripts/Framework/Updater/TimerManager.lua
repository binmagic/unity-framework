--[[
-- added by wsh @ 2017-12-18
-- 定时器管理：负责定时器获取、回收、缓存、调度等管理
-- 注意：
-- 1、任何需要定时更新的函数从这里注册，游戏逻辑层最好使用不带"Co"的接口
-- 2、带有"Co"的接口都是用于协程，它的调度会比普通更新后一步---次序依从Unity函数调用次序：https://docs.unity3d.com/Manual/ExecutionOrder.html
-- 3、UI界面倒计时刷新等不需要每帧去更新的逻辑最好用定时器，少用Updatable，定时器能很好避免频繁的无用调用
-- 4、定时器并非精确定时，误差范围和帧率相关
-- 5、循环定时器不会累积误差，这点和Updater的Update函数自己去控制时间刷新是一致的，很好用
-- 6、定时器是weak表，使用临时对象时不会持有引用
-- 7、慎用临时函数、临时闭包，所有临时对象要外部自行维护引用以保障生命周期，否则会被GC掉===>很重要***
-- 8、考虑到定时器可能会被频繁构造、回收，这里已经做了缓存池优化
--]]

local TimerManager = BaseClass("TimerManager", Singleton)

-- 构造函数
local function __init(self)
	-- handle
	self.__update_handle = nil
	-- 定时器列表
	self.__update_timer = {}
	-- 定时器缓存
	--self.__pool = {}
	-- 待添加的定时器列表
	self.__update_toadd = {}
	self.__coupdate_toadd = {}
	-- 删除列表
	self.__delete_table = {}
	
	-- 仅是下一帧执行
	self.__update_nextframe = {}
	self.__update_nextframe_toadd = {}
	
	-- 初始化
	self.updateInterval = 0.07  -- 目标间隔为0.07秒（每秒约15次）
	self.timeAccumulator = 0   -- 累计的时间
	self.unscaledTimeAccumulator = 0   -- 累计的时间
end

-- 延后回收定时器，必须全部更新完毕再回收，否则会有问题
-- （*）这个每帧都去循环，还是有一定的效率问题，
-- 因为每帧不管有没有要删除的都要去遍历，当timer数量多的时候就很明显了。
-- 优化成直接在update中展开了
local function DelayRecycle(self, timers)
	for timer,_ in pairs(timers) do
		if timer:IsOver() then
			timer:Stop()
			--table.insert(self.__pool, timer)
			timers[timer] = nil
		end
	end
end

-- Update回调
local function UpdateHandle(self)

	----------------------------------------------------------------
	-- 限帧处理，我们没有使用帧的timer，所以我们timer每秒处理15次即可
	-- 另外不要把这段代码封装成函数，减少lua调用函数的时间！
	-- 累加时间
	self.timeAccumulator = self.timeAccumulator + Time.deltaTime
	self.unscaledTimeAccumulator = self.unscaledTimeAccumulator + Time.unscaledDeltaTime

	-- 如果未达到目标间隔，直接返回
	if self.timeAccumulator < self.updateInterval then
		-- 这里更新一下帧处理，从名字来看，帧处理就是要帧处理
		self:UpdateNextFrameHandle()
		return
	end

	local timeDeltaTime = self.timeAccumulator
	local unscaledDeltaTime = self.unscaledTimeAccumulator
	
	-- 达到目标间隔，直接清0，避免追帧！
	self.timeAccumulator = 0 --self.timeAccumulator - self.updateInterval
	self.unscaledTimeAccumulator = 0
	----------------------------------------------------------------
	
	-- 更新定时器
	for timer,_ in pairs(self.__update_toadd) do
		self.__update_timer[timer] = true
		self.__update_toadd[timer] = nil
	end
	
	for timer,_ in pairs(self.__update_timer) do
		timer:Update(timeDeltaTime, unscaledDeltaTime)
		
		-- timer结束的话，插入到删除列表中
		if timer:IsOver() then
			table.insert(self.__delete_table, timer)
		end
	end
	
	-- 处理删除列表，直接在清空时完成停止和移除操作
	for i = #self.__delete_table, 1, -1 do
		local timer = self.__delete_table[i]
		timer:Stop()
		self.__update_timer[timer] = nil
		self.__delete_table[i] = nil
	end
	
	--DelayRecycle(self, self.__update_timer)
	
	-- 更新帧处理器
	self:UpdateNextFrameHandle()
end

local function DelayNextFrameAction(self, action)
	self.__update_nextframe_toadd[#self.__update_nextframe_toadd + 1] = action
end
local function UpdateNextFrameHandle(self)
	for _, action in ipairs(self.__update_nextframe) do
		action()
	end
	table.clear(self.__update_nextframe)
	
	-- 当前__update_nextframe已经为空表了，所以直接和toadd交换一下
	local t = self.__update_nextframe_toadd
	self.__update_nextframe_toadd = self.__update_nextframe
	self.__update_nextframe = t
end

-- 启动
local function Startup(self)
	Logger.Log('TimerManager Startup!')
	
	self:Dispose()
	self.__update_handle = UpdateBeat:CreateListener(UpdateHandle, TimerManager:GetInstance())
	UpdateBeat:AddListener(self.__update_handle)
end

-- 释放
local function Dispose(self)	
	Logger.Log('TimerManager Dispose!')
	
	if self.__update_handle ~= nil then
		UpdateBeat:RemoveListener(self.__update_handle)
		self.__update_handle = nil
	end

	self:Cleanup()
end

-- 清理：可用在场景切换前，不清理关系也不大，只是缓存池不会下降
local function Cleanup(self)
	Logger.Log('TimerManager Cleanup!')
	
	self.__update_timer = {}
	--self.__pool = {}
	self.__update_toadd = {}
	self.__coupdate_toadd = {}
	self.__delete_table = {}
end

-- 获取定时器
local function InnerGetTimer(self, delay, func, obj, one_shot, use_frame, unscaled)
	local timer = nil
	--if table.length(self.__pool) > 0 then
	--	timer = table.remove(self.__pool)
	--	if delay and func then
	--		timer:Init(delay, func, obj, one_shot, use_frame, unscaled)
	--	end
	--else
		timer = Timer.New(delay, func, obj, one_shot, use_frame, unscaled)
	--end
	return timer
end

-- 获取Update定时器
local function GetTimer(self, delay, func, obj, one_shot, use_frame, unscaled)
	assert(not self.__update_timer[timer] and not self.__update_toadd[timer])
	local timer = InnerGetTimer(self, delay, func, obj, one_shot, use_frame, unscaled)
	self.__update_toadd[timer] = true
	return timer
end

-- 做一个延时调用处理
-- 默认1秒后调用；如果可能中途终止，那么请接收返回值，然后调用[return value]:Stop()
local function DelayInvoke(self, callback, delayTime, userdata)
	delayTime = tonumber(delayTime or 1)
	local t = self:GetTimer(delayTime,
			function(userdata)
				callback(userdata)
			end,
			userdata, true, false, false)

	t:Start()
	return t
end

-- 析构函数
local function __delete(self)
	self:Cleanup()
	self.__update_handle = nil
	self.__update_timer = nil
	self.__update_toadd = nil
	self.__coupdate_toadd = nil
	self.__update_nextframe = nil
	self.__update_nextframe_toadd = nil
end

function TimerManager.getBetweenDays(day1, day2)
	day1 = math.modf(day1)
	day2 = math.modf(day2)
	local temp_last = day2 > day1 and day1 or day2
	local temp_cur = day2 > day1 and day2 or day1

	-- 上一个时间
	local lastYear = os.date("%Y", temp_last)
	local lastMonth = os.date("%m", temp_last)
	local lastDay = os.date("%d", temp_last)

	-- 当前时间
	local curYear = os.date("%Y", temp_cur)
	local curMonth = os.date("%m", temp_cur)
	local curDay = os.date("%d", temp_cur)

	--[[比较两个时间，返回相差多少时间]]
	local function timediff(long_time,short_time)
		local n_short_time,n_long_time,carry,diff = os.date('*t',short_time),os.date('*t',long_time),false,{}
		local colMax = {60,60,24,os.date('*t',os.time{year=n_short_time.year,month=n_short_time.month+1,day=0}).day,12,0}
		n_long_time.hour = n_long_time.hour - (n_long_time.isdst and 1 or 0) + (n_short_time.isdst and 1 or 0) -- handle dst  
		for i,v in ipairs({'sec','min','hour','day','month','year'}) do
			diff[v] = n_long_time[v] - n_short_time[v] + (carry and -1 or 0)
			carry = diff[v] < 0
			if carry then
				diff[v] = diff[v] + colMax[i]
			end
		end
		return diff
	end


	local n_long_time = os.date(os.time{year=curYear,month=curMonth,day=curDay,hour=0,min=0,sec=0});
	local n_short_time = os.date(os.time{year=lastYear,month=lastMonth,day=lastDay,hour=0,min=0,sec=0});


	local t_time = timediff(n_long_time,n_short_time);
	--local time_txt = string.format("%04d", t_time.year).."年"..string.format("%02d", t_time.month).."月"..string.format("%02d", t_time.day).."日   "..string.format("%02d", t_time.hour)..":"..string.format("%02d", t_time.min)..":"..string.format("%02d", t_time.sec);
	return t_time.month * 30 + t_time.day
end

TimerManager.__init = __init
TimerManager.__delete = __delete
TimerManager.Startup = Startup
TimerManager.Cleanup = Cleanup
TimerManager.Dispose = Dispose
TimerManager.GetTimer = GetTimer
TimerManager.GetCoTimer = GetCoTimer
TimerManager.DelayInvoke = DelayInvoke
TimerManager.UpdateNextFrameHandle = UpdateNextFrameHandle
TimerManager.DelayNextFrameAction = DelayNextFrameAction

return TimerManager;