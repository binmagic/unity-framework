--[[
-- [INPUT]: 依赖 xLua 对 UnityEngine.Object 的 IsNull 桥接方法与 Lua type 判断
-- [OUTPUT]: 对外提供全局函数 IsNull/IsNotNull
-- [POS]: Common/Tools/UnityEngine 的空引用判定,解决 xLua 下已销毁 UnityObject 不等于 nil 的陷阱,是全项目判空的统一入口
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
-- added by wsh @ 2017-12-27

-- xlua对UntyEngine的Object判空不能直接判nil
-- https://github.com/Tencent/xLua/blob/master/Assets/XLua/Doc/faq.md
function IsNull(unity_object)
	if unity_object == nil then
		return true
	end
	
	if type(unity_object) == "userdata" and unity_object.IsNull ~= nil then
		return unity_object:IsNull()
	end
	
	return false
end

function IsNotNull(unity_object) return not IsNull(unity_object) end
