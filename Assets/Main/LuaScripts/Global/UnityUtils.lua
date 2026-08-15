--[[
-- [INPUT]: 依赖 App 判断编辑器态操作 GameObject
-- [OUTPUT]: 不返回值；向全局命名空间注入 SetGameObjectDebugName 等 Unity 相关小工具函数
-- [POS]: Global 模块的 Unity 零散工具集，收纳直接挂到全局的轻量 GameObject 辅助函数；由 Global.lua 以副作用方式 require
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

---------------------------------------------------------------------
-- 这里存放一些Unity相关的小函数
---------------------------------------------------------------------

function SetGameObjectDebugName(obj, name)
	if App.IsEditor() then
		obj.name = name
	end
end


