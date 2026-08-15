--[[
-- [INPUT]: 依赖 CS.GameFramework.Log 的 Info/Error/SetWriteLogLevel、CS.CommonUtils.IsDebug、全局 App 的 IsDebug/IsEditor、table.dump
-- [OUTPUT]: 对外提供 Logger 表，暴露 Debug/DebugFormat/Log/LogFormat/LogError/LogErrorFormat/LogTable 及日志级别读写
-- [POS]: Logger 模块核心，Lua 层唯一日志出口(禁止裸 print)，按 writeLogLevel(0关/1全/2仅错)分级并桥接到 C# 日志系统；错误日志附 traceback 以便崩溃排查，是 FireBaseLog/PostEventLog 之外的本地日志通道
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-11-30
-- Logger系统：Lua中所有错误日志输出均使用本脚本接口，以便上报服务器
--]]

local Logger = {}
local Debug_Log = CS.GameFramework.Log.Info
local Debug_LogError = CS.GameFramework.Log.Error
local writeLogLevel = 1 
-- writeLogLevel = 0 表示不写LOG
-- writeLogLevel = 1 表示写LOG
-- writeLogLevel = 2 表示只写LOG Error
local isDebug = CS.CommonUtils.IsDebug()

local function MakeMsg(...)
	if writeLogLevel == 0 or writeLogLevel == 2 then
		return nil
	end

	local msg
	local c = select('#', ...)
	if c == 0 then
		return
	elseif c == 1 then
		msg = select(1, ...)
	else
		msg = table.concat({...}, "")
	end
	
	return msg
end

local function MakeErrorMsg(...)
	if writeLogLevel == 0 then
		return nil
	end
	
	local msg
	local c = select('#', ...)
	if c == 0 then
		return
	elseif c == 1 then
		msg = select(1, ...)
	else
		msg = table.concat({...}, "")
	end

	return msg
end
		
function Logger.Debug(...)
	
	if App.IsDebug() or App.IsEditor() then
		local msg = MakeMsg(...)
		if not msg then return end
	
		--if isDebug then
		--Debug_Log(debug.traceback(msg, 2))
		--else
		Debug_Log(msg)
		--end
	end
end

function Logger.DebugFormat(fmt, ...)
	if App.IsDebug() or App.IsEditor() then
		if writeLogLevel == 0 or writeLogLevel == 2 then
			return nil
		end
		
		local msg = string.format(fmt, ...)
		--if isDebug then
		--Debug_Log(debug.traceback(msg, 2))
		--else
		Debug_Log(msg)
		--end
	end
end

function Logger.Log(...)
	local msg = MakeMsg(...)
	if not msg then return end
	
	--if isDebug then
		--Debug_Log(debug.traceback(msg, 2))
	--else
		Debug_Log(msg)   
	--end
end

function Logger.LogFormat(fmt, ...)
	if writeLogLevel == 0 or writeLogLevel == 2 then
		return nil
	end
	
	local msg = string.format(fmt, ...)
	--if isDebug then
		--Debug_Log(debug.traceback(msg, 2))
	--else
		Debug_Log(msg)
	--end
end

function Logger.LogError(...)
	
	local msg = MakeErrorMsg(...)
	if not msg then return end
	
	if isDebug then
		Debug_LogError(debug.traceback(msg, 2))
	else
		Debug_LogError(msg)
	end
end

function Logger.LogErrorFormat(fmt, ...)
	if writeLogLevel == 0 then
		return nil
	end

	local msg = string.format(fmt, ...)
	if isDebug then
		Debug_LogError(debug.traceback(msg, 2))
	else
		Debug_LogError(msg)
	end
end

function Logger.LogTable(tbl, desc, nesting)
	if writeLogLevel == 0 or writeLogLevel == 2 then
		return nil
	end

	local str = table.dump(tbl, false, nesting)
	Logger.Log('desc: ', str)
	return
end

function Logger.GetLogLevel()
	return writeLogLevel
end

function Logger.SetLogLevel(level)
	if level > 2 then level = 2 end
	if level < 0 then level = 0 end
	if writeLogLevel ~= level then
		CS.GameFramework.Log.SetWriteLogLevel(level)
		writeLogLevel = level
	end
end

return Logger