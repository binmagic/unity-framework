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