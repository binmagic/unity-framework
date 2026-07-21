--[[
-- added by wsh @ 2017-11-30
-- UI模块配置表，添加新UI模块时需要在此处加入
--]]

local UIConfig = {
	-- 连连看游戏
	[UIWindowNames.LianLianMain] = "UI.LianLian.LianLianMain.Config",
	[UIWindowNames.LianLianPlay] = "UI.LianLian.LianLianPlay.Config",
	[UIWindowNames.LianLianWin] = "UI.LianLian.LianLianWin.Config",
	[UIWindowNames.LianLianLose] = "UI.LianLian.LianLianLose.Config",
	[UIWindowNames.LianLianRevive] = "UI.LianLian.LianLianRevive.Config",
	[UIWindowNames.LianLianLevelup] = "UI.LianLian.LianLianLevelup.Config",
	[UIWindowNames.LianLianSettings] = "UI.LianLian.LianLianSettings.Config",
	[UIWindowNames.LianLianSkin] = "UI.LianLian.LianLianSkin.Config",
	[UIWindowNames.LianLianToast] = "UI.LianLian.LianLianToast.Config",
	[UIWindowNames.LianLianTest] = "UI.LianLian.LianLianTest.Config",
	[UIWindowNames.LianLianDebug] = "UI.LianLian.LianLianDebug.Config",
	[UIWindowNames.LianLianUnlock] = "UI.LianLian.LianLianUnlock.Config",
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