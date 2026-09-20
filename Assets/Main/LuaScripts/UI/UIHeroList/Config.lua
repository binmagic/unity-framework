---
--- 英雄图鉴列表 — Config
--- 船舱底部导航"英雄"页签点开，四阵营页签筛选 + 卡片网格，点卡片进详情
---
local UIHeroList = {
    Name       = UIWindowNames.UIHeroList,
    Layer      = UILayer.Normal,
    Ctrl       = require "UI.UIHeroList.Controller.UIHeroListCtrl",
    View       = require "UI.UIHeroList.View.UIHeroListView",
    PrefabPath = "Assets/Main/Prefabs/UI/UIHeroList/UIHeroList.prefab",
    -- isBlur 关闭：BlurURP 截屏流程在当前渲染配置下拿不到内容，参考 UIShipCabinDetail/UIBuildingPanel 的既有教训
    isBlur     = false,
}

return {
    UIHeroList = UIHeroList,
}
