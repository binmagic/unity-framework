-- 这里主要保存一些游戏中运行的全局cache信息
-- 放到这里的主要原因是，方便游戏重启的时候删除
-- 不要在代码中自行去设置cache，统一在这里添加，否则到时候不要统一管理了！
-- 因为LUA和C#交互字符串是有开销的，包括LUA处理字符串也是有开销的


---@class Cache
local GlobalCache = {}


function GlobalCache.Init()
	
end


-- 动画相关的缓存获取
local AnimatorCache = {}
function GlobalCache.Animator_StringToHash(animName)
	local hashId = AnimatorCache[animName]
	if hashId == nil then
		hashId = CS.UnityEngine.Animator.StringToHash(animName)
		AnimatorCache[animName] = hashId
	end
	
	return hashId
end

-- 获取state0x字符串
local state0xTable = { "state01", "state02", "state03", "state04", "state05", "state06", "state07", "state08" }
function GlobalCache.GetState0xString(k)
	if k>=1 and k<=#state0xTable then
		return state0xTable[k]
	end

	local str = "state0" .. tostring(k)
	return str
end

-- 获取statex字符串
local state0 = "state0"
local statexTable = { "state1", "state2", "state3", "state4" }
function GlobalCache.GetStatexString(k)
	if k>=1 and k<=#statexTable then
		return statexTable[k]
	end
	
	if k==0 then 
		return state0
	end

	local str = "state" .. tostring(k)
	return str
end



-- XX相关的缓存获取


return GlobalCache




