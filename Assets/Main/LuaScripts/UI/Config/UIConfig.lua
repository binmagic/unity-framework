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