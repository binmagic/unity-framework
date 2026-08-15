---------------------------------------------------------------------
-- aps_client (C) CompanyName, All Rights Reserved
-- Date: 2023-08-30 19:00:59
-- Unity 协程的LUA支持
---------------------------------------------------------------------

--[[
-- [INPUT]: 依赖 xlua.util 的 cs_generator/move_end，依赖 CS.ApplicationLaunch.Instance 承载 C# 协程
-- [OUTPUT]: 对外提供 Coroutine 表，暴露 Start/Stop 及 yield_return/yield_return_null/yield_break 封装
-- [POS]: Common 层对 Unity C# 协程的 Lua 侧薄封装，把 Lua 迭代器接到 MonoBehaviour 的 StartCoroutine 上；与 LuaMono 的协程能力互补(此为全局单点，LuaMonoBase 为对象级)
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

local util = require 'xlua.util'
local Mono = CS.ApplicationLaunch.Instance
local Coroutine = {}

function Coroutine.Start(func)
	local t = util.cs_generator(func)
	return Mono:StartCoroutine(t)
end

function Coroutine.Stop(coroutine)
	Mono:StopCoroutine(coroutine)
end

function Coroutine.yield_return(t)
	coroutine.yield(t)
end

function Coroutine.yield_return_null()
	coroutine.yield()
end

-- 协程中途停止，需要提前返回move_end
function Coroutine.yield_break()
	coroutine.yield(util.move_end)
end

return Coroutine

