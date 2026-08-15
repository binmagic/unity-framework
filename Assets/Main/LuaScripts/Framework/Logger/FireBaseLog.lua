--[[
-- [INPUT]: 依赖 CS.GameEntry.Sdk 的 Crashlytics 系列接口、全局 App 的 IsEditor/IsDebug、全局 XPCALL 保护调用
-- [OUTPUT]: 对外提供 FireBaseLog 表，暴露 SetCustomValue/CrashlyticsAddLog/CrashlyticsSetUserId
-- [POS]: Logger 模块的崩溃诊断通道，向 Firebase Crashlytics 写自定义键值/日志/用户标识为崩溃提供线索；仅在真机发布环境生效(编辑器与调试期直接跳过)，与本地 Logger、打点 PostEventLog 三者互补
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

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