---------------------------------------------------------------------
-- 这里存放一些Unity相关的小函数
---------------------------------------------------------------------

function SetGameObjectDebugName(obj, name)
	if App.IsEditor() then
		obj.name = name
	end
end


