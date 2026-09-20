---
--- 英雄详情 — Config
--- 点英雄图鉴卡片后弹出，展示英雄四维属性 + 设为出战
---
local UIHeroDetail = {
    Name       = UIWindowNames.UIHeroDetail,
    Layer      = UILayer.Normal,
    Ctrl       = require "UI.UIHeroDetail.Controller.UIHeroDetailCtrl",
    View       = require "UI.UIHeroDetail.View.UIHeroDetailView",
    PrefabPath = "Assets/Main/Prefabs/UI/UIHeroDetail/UIHeroDetail.prefab",
    isBlur     = false,
}

return {
    UIHeroDetail = UIHeroDetail,
}
