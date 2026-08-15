--[[
-- [INPUT]: 依赖 UIWindowNames 的窗口名常量作为键、Framework 的 ConstClass 做只读包装
-- [OUTPUT]: 返回只读 UIConfig 路由表，把窗口名映射到其 Config 类 require 路径（连连看统一 UI.LianLian.XXX.Config）
-- [POS]: UI 模块的窗口路由表，与 UIWindowNames 配对；UIManager 开窗时据此定位 Config 类。路径前缀仅允许 UI.，连连看窗口用 UI.LianLian. 前缀
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--[[
-- added by wsh @ 2017-11-30
-- UI模块配置表，添加新UI模块时需要在此处加入
--]]

local UIConfig = {
	-- 连连看游戏
	[UIWindowNames.UILianLianMain] = "UI.LianLian.LianLianMain.Config",
	[UIWindowNames.UILianLianPlay] = "UI.LianLian.LianLianPlay.Config",
	[UIWindowNames.UILianLianWin] = "UI.LianLian.LianLianWin.Config",
	[UIWindowNames.UILianLianLose] = "UI.LianLian.LianLianLose.Config",
	[UIWindowNames.UILianLianRevive] = "UI.LianLian.LianLianRevive.Config",
	[UIWindowNames.UILianLianLevelup] = "UI.LianLian.LianLianLevelup.Config",
	[UIWindowNames.UILianLianSettings] = "UI.LianLian.LianLianSettings.Config",
	[UIWindowNames.UILianLianSkin] = "UI.LianLian.LianLianSkin.Config",
	[UIWindowNames.UILianLianToast] = "UI.LianLian.LianLianToast.Config",
	[UIWindowNames.UILianLianTest] = "UI.LianLian.LianLianTest.Config",
}
--[[
local UIConfig = {}
for _,ui_module in pairs(UIModule) do 
	for _,ui_config in pairs(ui_module) do
		local ui_name = ui_config.Name
		assert(UIConfig.ui_name == nil, "Aready exsits : "..ui_name)
		if ui_config.View then
			assert(ui_config.PrefabPath ~= nil and #ui_config.PrefabPath > 0, ui_name.." PrefabPath empty.")
		end
		UIConfig[ui_name] = ui_config
	end
end
]]
return ConstClass("UIConfig", UIConfig)