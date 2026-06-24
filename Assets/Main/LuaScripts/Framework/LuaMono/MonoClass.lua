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

