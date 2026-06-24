---------------------------------------------------------------------
-- aps_client (C) CompanyName, All Rights Reserved
-- Date: 2023-08-30 19:00:59
-- Unity 协程的LUA支持
---------------------------------------------------------------------

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

