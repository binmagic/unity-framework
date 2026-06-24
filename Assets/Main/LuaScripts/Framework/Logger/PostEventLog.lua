---
--- 打点日志
--- 这个类暂时不要挪到lua，因为C#还会用。暂时先用C#的。
--- Lua这边的代码，暂时屏蔽一下
---
local CSPostEventLog = CS.PostEventLog
local PostEventLog = {}

PostEventLog.Defines = 
{   
	LAUNCH = "LAUNCH" ,
	OBB_FETCH = "OBB_FETCH",
	OBB_SUCCESS = "OBB_SUCCESS",

	CHECK_VERSION_START = "CHECK_VERSION_START",
	CHECK_VERSION_SUCCESS = "CHECK_VERSION_SUCCESS",
	CHECK_VERSION_FAILED = "CHECK_VERSION_FAILED",
	CHECK_VERSION_TIMEOUT = "CHECK_VERSION_TIMEOUT",
	CHECK_VERSION_ONUPDATE = "CHECK_VERSION_ONUPDATE",
	CHECK_VERSION_PARSE_ERROR = "CHECK_VERSION_PARSE_ERROR",

	DOWNLOAD_MANIFEST_START = "DOWNLOAD_MANIFEST_START",
	DOWNLOAD_MANIFEST_SUCCESS = "DOWNLOAD_MANIFEST_SUCCESS",
	DOWNLOAD_MANIFEST_FAILED = "DOWNLOAD_MANIFEST_FAILED",
	DOWNLOAD_MANIFEST_TIMEOUT = "DOWNLOAD_MANIFEST_TIMEOUT",

	DOWNLOAD_START = "DOWNLOAD_START",
	DOWNLOAD_FINISH = "DOWNLOAD_FINISH",
	DOWNLOAD_FAILED = "DOWNLOAD_FAILED",

	START_CONNECT = "START_CONNECT",
	CONNECT_TIME_OUT = "CONNECT_TIME_OUT",
	GET_SERVERLIST = "GET_SERVERLIST",
	SERVERLIST_TIME_OUT = "SERVERLIST_TIME_OUT",
	SERVERLIST_FAILED = "SERVERLIST_FAILED",
	LONG_TIME_NOT_PUSH_INIT = "LONG_TIME_NOT_PUSH_INIT",

	LOGIN_START = "LOGIN_START",
	LOGIN_FINISH = "LOGIN_FINISH",
	LOGIN_COMPLETE = "LOGIN_COMPLETE",
	LOGIN_FAILED = "LOGIN_FAILED",
	SERVER_STATUS = "SERVER_STATUS",
	PUSH_INIT_RECV = "PUSH_INIT_RECV",
	LOGIN_PARSE_ERROR = "LOGIN_PARSE_ERROR",
	DISCONNECT_RETRY = "DISCONNECT_RETRY",
	SOCKET_ERROR = "SOCKET_ERROR",
	DNS_SUCESS = "DNS_SUCESS",
	SOCKET_SHUTDOWN = "SOCKET_SHUTDOWN",
	APP_QUIT = "APP_QUIT",
}

-- 记录一个打点
-- 直接使用C#的接口
function PostEventLog.Record(action, ...)
	local ok, ret = xpcall(CS.PostEventLog.Record, debug.traceback, action, ...)
	return ok
end

--[[
-- 保存action的次数的map； k = string, v = int
local actionCountMap = {}

-- posteventId
local posteventId = tostring(os.time() * math.random(10000,99999))

-- post的网址
local POSTURL = "http://analyse-lm.readygo.tech/clientevent.php"

-- 发送的参数
local paramN = { "param0", "param1", "param2", "param3" }

-- 参数的table
local params = {}

function PostEventLog.getActionCount(action)
	
	if string.IsNullOrEmpty(action) then
		return 0
	end
	
	if (actionCountMap[action]) then
		actionCountMap[action] = actionCountMap[action] + 1
	else
		actionCountMap[action] = 1
	end
		
	return actionCountMap[action]
end
	
function PostEventLog.Record2(action, ...)
    --CSPostEventLog.Record(action, ...)
	
	if LuaEntry.GlobalData:IsDebug() then
		-- return
	end
	
	-- 最多就带4个参数了
	local arglen = select("#", ...)
	if arglen > 4 then
		arglen = 4
	end
	
	for i=1,arglen do
		local t = paramN[i]
		params[t] = select(i, ...)
	end
	
	PostEventLog.RecordInternal(action, params)
end


function PostEventLog.RecordInternal(action, dictionary)
	
	local m = {}
	
	m["action"] = action or "Unknown"
	m["actioncount"] = PostEventLog.getActionCount(action)
	m["timestamp"] = os.time() * 1000 -- 暂时先如此
	m["posteventId"] = posteventId

	m["uid"] = Setting:GetPublicString(SettingKeys.GAME_UID, "")
	m["zone"] = Setting:GetPublicString(SettingKeys.SERVER_ZONE, "")

	m["deviceId"] = LuaEntry.GlobalData:GetDeviceUid()
	m["country"] = LuaEntry.GlobalData:GetFromCountry()
	
	m["version"] = LuaEntry.GlobalData:GetVersion()
	m["buildcode"] = LuaEntry.GlobalData:GetVersionCode()
	m["platform"] = LuaEntry.GlobalData:GetAnalyticID()
	
	--sb.Append("&net=").Append(GameEntry.Device.GetNetworkTypeDesc());
	m["line"] = LuaEntry.Network:GetCurLineName()

	if (dictionary ~= nil) then
		for k,v in dictionary do
			m[k] = v
		end
	end
	
	local string = table.concat(m, "&")
	
	-- 直接使用自带的异步post
	CS.WebRequestManager.Post(POSTURL, string, 
		function(request, err, userdata)
			if err == true then
				print("post error!")
				return
			end
			print("post ok!")	
		end)
end
--]]

function PostEventLog:Track(...)
	
end

return PostEventLog