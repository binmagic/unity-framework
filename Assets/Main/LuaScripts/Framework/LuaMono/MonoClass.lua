--[[
-- [INPUT]: 依赖 Framework/LuaMono/LuaMonoBase 作为父类、Common/BaseClass 的 BaseClass、xlua.util 的 move_end
-- [OUTPUT]: 对外提供全局 MonoClass(classname) 工厂(直接返回实例)及全局 yield_return/yield_return_null/yield_break 协程辅助函数
-- [POS]: LuaMono 模块工厂入口，一步派生 LuaMonoBase 并 New 出与 C# MonoBehaviour 绑定的 Lua Mono 实例；Awake/OnDestroy 生命周期由 C# 侧回调驱动
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

--[[
-- 用来定义Unity的LUA侧的Mono
--]]

local LuaMonoBase = require "Framework.LuaMono.LuaMonoBase"
local util = require 'xlua.util'

-- 新建一个和C#侧的MonoBehaviour绑定的LUA类
-- LuaMonoBase中主要是协程的一些操作
function MonoClass(classname)
	local LuaMonoBase = BaseClass(classname, LuaMonoBase)
	return LuaMonoBase.New()
end

function yield_return(t)
	coroutine.yield(t)
end

function yield_return_null()
	coroutine.yield()
end

-- 协程中途停止，需要提前返回move_end
function yield_break()
	coroutine.yield(util.move_end)
end

