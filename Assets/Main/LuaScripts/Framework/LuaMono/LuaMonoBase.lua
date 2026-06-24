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


