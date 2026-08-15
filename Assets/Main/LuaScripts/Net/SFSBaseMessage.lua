--[[
-- [INPUT]: 依赖 Framework 的 BaseClass、全局 SFSObject 构造数据对象
-- [OUTPUT]: 对外提供 SFSBaseMessage 类，暴露 NewEmpty/NewMessage 工厂与 OnCreate/HandleMessage/ToBinary 供子类覆写
-- [POS]: Net 模块的消息基类，约定每条协议 Message 的双向骨架——OnCreate 写发送包、HandleMessage 解收包；Net/Msgs 下所有消息类继承它
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

---@class SFSBaseMessage
local SFSBaseMessage = BaseClass("SFSBaseMessage")

local function NewEmpty(msgType)
	return msgType.New(true)
end

local function NewMessage(msgType, ...)
	return msgType.New(false, ...)
end

local function __init(self, isEmpty, ...)
	if not isEmpty then
		---@type SFSObject
		self.sfsObj = SFSObject.New()
		self:OnCreate(...)
	end
end

local function OnCreate(self)
end

local function HandleMessage(self, t)
end

local function OnDestroy(self)
end

local function ToBinary(self)
	return self.sfsObj:ToBinary()
end

local function __delete(self)
	self.sfsObj = nil
	self:OnDestroy()
end

SFSBaseMessage.__init = __init
SFSBaseMessage.NewEmpty = NewEmpty
SFSBaseMessage.NewMessage = NewMessage
SFSBaseMessage.OnCreate = OnCreate
SFSBaseMessage.HandleMessage = HandleMessage
SFSBaseMessage.ToBinary = ToBinary
SFSBaseMessage.OnDestroy = OnDestroy
SFSBaseMessage.__delete = __delete

return SFSBaseMessage