
local Messenger = require "Framework.Common.Messenger"
local EventNotify = CS.EventNotify

---@class EventManager : Singleton
local EventManager = BaseClass("EventManager", Singleton)

local function __init(self)
    self.messenger = Messenger.New()
    self.usedEventByCS = {} --key:eventId, value:reference num 
end

local function __delete(self)
	self.messenger:Dump()
    self.messenger = nil
    self.usedEventByCS = nil
end

local function AddListener(self, eventId, handler)
    self.messenger:AddListener(eventId, handler)
end

local function RemoveListener(self, eventId, handler)
    self.messenger:RemoveListener(eventId, handler)
end

local function Broadcast(self, eventId, userData)
    --Logger.Log('#zlh# Broadcast! eventId:' .. tostring(table.keyof(EventId, eventId)))
    --如果CS端没有监听当前消息id的话 就不再传递给CS了 直接分派给lua的handle去处理 避免多绕一圈
    local usedByCS = self:GetCSReference(eventId) > 0
    if not usedByCS then
        self:DispatchCSEvent(eventId, userData)
        return
    end
    
    if userData == nil then
        EventNotify.Fire(eventId)
        return
    end
    --print(">>>>>lsz 广播消息  eventid: " .. tostring(eventId))
    local t = type(userData)
    if t == "number" then
        EventNotify.FireLong(eventId, userData)
    elseif t == "boolean" then
        EventNotify.FireBool(eventId, userData)
    elseif t == "string" then
        EventNotify.FireString(eventId, userData)
    elseif t == "table" and userData.ToBinary then
        --EventNotify.FireSFSObject(eventId, userData:ToBinary())
        Logger.LogError("#EventManager# 不要用sfsObj来作为参数传递,ToBinary太耗了! 改用luaTable!")
    elseif t == "table" then
        EventNotify.FireLuaTable(eventId, userData)
    else
    Logger.LogError("broadcast type error ", eventId)
    end
end

local function DispatchCSEvent(self, eventId, userData)
    self.messenger:Broadcast(eventId, userData)
end

local function DispatchCSEventSFSObject(self, eventId, userData)
	Logger.LogError("DispatchCSEventSFSObject error!")
    --local sfsObj = SFSObject.NewFromBinary(userData)
    --self.messenger:Broadcast(eventId, sfsObj)
end


-------------------CS正在使用的事件记录--------------------------
local function GetCSReference(self, eventId)
    return self.usedEventByCS[eventId] or 0
end

local function IncreaseCSRef(self, eventId)
    local ref = self:GetCSReference(eventId)
    self.usedEventByCS[eventId] = ref + 1

    if App.IsEditor() then
        if ref > 20 then
            Logger.Log(string.format("<color=red>#IncreaseCSRef# eventId:[%d] ref:{%d} 被同时监听次数过多，需要注意！</color>", eventId, ref+1))
        end
    end
end

local function DecreaseCSRef(self, eventId)
    local ref = self:GetCSReference(eventId)
    self.usedEventByCS[eventId] = math.max(ref - 1, 0)
end

local function ClearCSRef(self)
    self.usedEventByCS = {}
end
----------------------------------------------------------------


EventManager.__init = __init
EventManager.__delete = __delete
EventManager.AddListener = AddListener
EventManager.RemoveListener = RemoveListener
EventManager.Broadcast = Broadcast
EventManager.DispatchCSEvent = DispatchCSEvent
EventManager.DispatchCSEventSFSObject = DispatchCSEventSFSObject

EventManager.GetCSReference = GetCSReference
EventManager.IncreaseCSRef = IncreaseCSRef
EventManager.DecreaseCSRef = DecreaseCSRef
EventManager.ClearCSRef = ClearCSRef

return EventManager