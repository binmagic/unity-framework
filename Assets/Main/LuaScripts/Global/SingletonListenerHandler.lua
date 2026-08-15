--[[
-- [INPUT]: 依赖 Framework 的 BaseClass/Singleton、EventManager 单例、TimerManager 单例，依赖 App/Logger
-- [OUTPUT]: 对外提供 SingletonListenerHandler 类（继承 Singleton），暴露与 ListenerHandler 一致的成组监听接口
-- [POS]: Global 模块的单例版事件监听基类，供全局唯一存在的管理器复用同一套自动清理的订阅逻辑，是 ListenerHandler 的单例孪生
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

---
--- Created by liujiang.
--- DateTime: 2025/05/23 11:44
---
---

---@class SingletonListenerHandler:Singleton
local SingletonListenerHandler = BaseClass("SingletonListenerHandler", Singleton)

function SingletonListenerHandler:__init()
    self.__event_handlers = {}
    self.delayEvents = {}
end

function SingletonListenerHandler:__delete()
    self:RemoveAllListeners()
    self:RemoveAllDelayEvents()
end

function SingletonListenerHandler:AddListener(msg_name, callback)
    local bindFunc = function(...) callback(self, ...) end
    self.__event_handlers[msg_name] = bindFunc
    EventManager:GetInstance():AddListener(msg_name, bindFunc)
end

function SingletonListenerHandler:RemoveListener(msg_name)
    local bindFunc = self.__event_handlers[msg_name]
    if not bindFunc then
		if App.IsEditor() then
        	Logger.LogError(msg_name, " not register")
		end
        return
    end
    self.__event_handlers[msg_name] = nil
    EventManager:GetInstance():RemoveListener(msg_name, bindFunc)
end

function SingletonListenerHandler:RemoveAllListeners()
    if not self.__event_handlers then return end

    for name, bindFunc in pairs(self.__event_handlers) do
        EventManager:GetInstance():RemoveListener(name, bindFunc)
    end

    self.__event_handlers = {}
end

function SingletonListenerHandler:AddDelayEvent(callback, delay)
    if callback == nil then
        return
    end
    
    local timer = TimerManager:GetInstance():DelayInvoke(callback, delay)
    table.insert(self.delayEvents, timer)
end

function SingletonListenerHandler:RemoveAllDelayEvents()
    if self.delayEvents ~= nil then
        for _,v in pairs(self.delayEvents) do
            v:Stop()
        end
        
        self.delayEvents = {}
    end
end

return SingletonListenerHandler
