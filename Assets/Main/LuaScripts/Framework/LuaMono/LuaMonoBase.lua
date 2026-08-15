--[[
-- [INPUT]: 依赖 Common/BaseClass 的 BaseClass、xlua.util 的 cs_generator，self.Mono 为绑定的 C# MonoBehaviour
-- [OUTPUT]: 对外提供 LuaMonoBase 基类，暴露对象级 StartCoroutine/StopCoroutine
-- [POS]: LuaMono 模块基类，为 Lua 侧模拟 MonoBehaviour 提供协程能力；由 MonoClass 工厂派生并绑定真实 Mono 对象，与 Common/Coroutine(全局单点协程)相对，此为每对象独立
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--]]

--
-- lua 的 MonoBehaviour
-- 注意事项：
-- 1. self.Mono 是真实的MonoBehaviour对象
-- 2. 不要把任何私有变量写到全局的local里，否则生成多对象时有可能导致变量被覆盖
-- 3. 文件末尾不要直接return此表，需要return一个New表
-- 4. 初始化代码写到Awake里，释放代码写到OnDestroy里
-- 5. 没有Update函数！需要的话自己添加Update
--

local LuaMonoBase = BaseClass("LuaMonoBase")
local util = require 'xlua.util'

-- 在LUA端开启一个携程
function LuaMonoBase:StartCoroutine(func)
	if func == nil then
		return nil
	end
	
	local t = util.cs_generator(func)
	self.co = t
	return self.Mono:StartCoroutine(t)
end

function LuaMonoBase:StopCoroutine(cor)
	if cor then
		-- FIXME: 这里停止后，coroutine.wrap怎么停止或者释放？
		self.Mono:StopCoroutine(cor)
	end
end


return LuaMonoBase


