---@class Framework.Common.FSM
local FSM = BaseClass("FSM")

-- 构造函数
local function __init(self)
    self.states={}
    self.curStateIndex=-1
end

-- 析构函数
local function __delete(self)
    for _,v in pairs(self.states) do
        v:Delete()
    end
    self.states=nil
    self.curStateIndex=nil
end

--添加状态
local function AddState(self,stateIndex, state)
    if self.states[stateIndex] then
        Logger.LogError("状态重复：stateEnum")
    else
        self.states[stateIndex]=state
    end
end

--移除状态
local function RemoveState(self, stateIndex)
    self.states[stateIndex] = nil
end

local function ReplaceState(self, stateIndex, newState, ...)
    local oldState = self.states[stateIndex]
    self.states[stateIndex] = newState
    if stateIndex == self:GetStateIndex() then
        if oldState ~= nil then
            oldState:OnExit()
        end

        if newState ~= nil then
            newState:OnEnter(...)
        end
    end
end

--获取状态
local function GetStateIndex(self)
    return self.curStateIndex
end

local function GetCurState(self)
    local curStateIndex = self:GetStateIndex()
    return self.states[curStateIndex]
end

--改变状态
local function ChangeState(self,stateIndex,...)
    --if self.curStateIndex then
    --    Logger.Log("ChangeState from"..self.curStateIndex.." to"..stateIndex)
    --end

    if self.curStateIndex==stateIndex then
        if self.states[self.curStateIndex].OnTransToSelf then
            self.states[self.curStateIndex]:OnTransToSelf(...)
        end
        return
    end
    if self.curStateIndex>-1 then
        self.states[self.curStateIndex]:OnExit()
    end
    self.curStateIndex=stateIndex
    self.states[stateIndex]:OnEnter(...)
end

--更新当前状态
local function OnUpdate(self,...)
    if self.curStateIndex>-1 then
        local state = self.states[self.curStateIndex]
        if state ~= nil and state.OnUpdate ~= nil then
            state:OnUpdate(...)
        end
    end
end

--处理输入
local function HandleInput(self,...)
    if self.curStateIndex>-1 then
        local state = self.states[self.curStateIndex]
        if state ~= nil and state.HandleInput ~= nil then
            state:HandleInput(...)
        end
    end
end


FSM.__init = __init
FSM.__delete = __delete
FSM.AddState = AddState
FSM.RemoveState = RemoveState
FSM.ReplaceState = ReplaceState
FSM.GetStateIndex = GetStateIndex
FSM.GetCurState = GetCurState
FSM.ChangeState = ChangeState
FSM.OnUpdate = OnUpdate
FSM.HandleInput = HandleInput


return FSM