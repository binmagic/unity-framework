---------------------------------------------------------------------
-- aps_client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2023-06-13 14:37:06
-- 给Firebase打一些LOG，目的是给查找崩溃提供一些线索
---------------------------------------------------------------------

local FireBaseLog = {}
local cs_sdk = CS.GameEntry.Sdk

function FireBaseLog.SetCustomValue(key, value)
	if App.IsEditor() or App.IsDebug() then
		return
	end
	
	XPCALL(function ()
			cs_sdk:CrashlyticsSetCustomValue(key, value)
		end)
end

function FireBaseLog.CrashlyticsAddLog(log)
	if App.IsEditor() or App.IsDebug() then
		return
	end
	
	XPCALL(function ()
			cs_sdk:CrashlyticsAddLog(log)
		end)
end

function FireBaseLog.CrashlyticsSetUserId(userId)
	if App.IsEditor() or App.IsDebug() then
		return
	end
	
	XPCALL(function ()
			cs_sdk:CrashlyticsSetUserId(userId)
		end)
end


return FireBaseLog