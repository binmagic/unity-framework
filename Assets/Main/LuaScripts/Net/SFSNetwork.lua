
local MsgMap = require "Net.Config.MsgMap"
local Network = CS.GameEntry.Network
local MsgTypeMap = {}

local SFSNetwork = {}

local function GetMsgType(cmd)
	local msgType = MsgTypeMap[cmd]
	if msgType == nil then
		local msgTypePath = MsgMap[cmd]
		if msgTypePath ~= nil then
			msgType = require(msgTypePath);
			MsgTypeMap[cmd] = msgType
		end
	end
	return msgType;
end

function SFSNetwork.SendMessage(cmd, ...)
	local msgType = GetMsgType(cmd)
	local msg = msgType:NewMessage(...)
	--Network:SendLuaMessage(_ToID(cmd), msg:ToBinary())
	--LuaEntry.Network:SendLuaMessage(_ToID(cmd), msg:ToBinary())
	LuaEntry.Network:SendLuaMessageEx(cmd, msg.sfsObj)
end

function SFSNetwork.SendCrossMessage(cmd, ...)
	local msgType = GetMsgType(cmd)
	local msg = msgType:NewMessage(...)
	LuaEntry.NetworkCross:SendLuaMessageEx(cmd, msg.sfsObj)
end

-- 在xpcall内处理消息的函数体
local function SafeHandleMessage(msgType, t)
	local msg = msgType:NewEmpty()
	msg:HandleMessage(t)
	return true	
end

function SFSNetwork.HandleMessage(cmd, t)
	local msgType = GetMsgType(cmd)
	if msgType ~= nil then
		local ok, errorMsg = xpcall(SafeHandleMessage, debug.traceback, msgType, t)
		if not ok then
			local now = UITimeManager:GetInstance():GetServerSeconds()
			--CommonUtil.SendErrorMessageToServer(now, now, errorMsg)
			Logger.LogError(errorMsg)
			return false
		end
	end
	return false
end

return SFSNetwork