--[[
-- 建筑点击界面配置
-- 包含建筑信息展示 + 升级逻辑
--]]

local UIBuildingPanel = {
    Name = UIWindowNames.UIBuildingPanel,
    Layer = UILayer.Normal,
    Ctrl = require "UI.UIBuildingPanel.Controller.UIBuildingPanelCtrl",
    View = require "UI.UIBuildingPanel.View.UIBuildingPanelView",
    PrefabPath = "Assets/Main/Prefabs/UI/Build/UIBuildingPanel.prefab",
    -- isBlur 关闭：BlurURP 截屏在当前渲染配置下拿不到内容
    -- （控制台报 "Renderer at index 1 is missing for camera UICamera"），
    -- 会降级成 ui_white_block 不透明白块盖住整个面板。
    -- 详见 requirements/knowledge/errors/blur-overlay-covers-panel.md
    isBlur = false,
}

return {
    UIBuildingPanel = UIBuildingPanel,
}

