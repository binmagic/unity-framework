--[[
-- [INPUT]: 依赖 Net.Config.MsgMap 路由表、CS.GameEntry.Network、LuaEntry.Network/NetworkCross 发送、UITimeManager/Logger
-- [OUTPUT]: 对外提供 SFSNetwork 表，暴露 SendMessage/SendCrossMessage 发送与 HandleMessage 收包分发
-- [POS]: Net 模块的消息收发入口，按 cmd 经 MsgMap 懒加载消息类完成序列化/反序列化；收包在 xpcall 内隔离单条崩溃，是业务与 C# 网络层之间的门面
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

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