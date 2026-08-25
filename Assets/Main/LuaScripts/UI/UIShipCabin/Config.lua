---
--- 隆隆冒险号 船舱配置主界面 — Config
--- 横屏全屏界面：左侧属性面板 + 中间3x4格子 + 右侧模块列表 + 底部出发
---
local UIShipCabin = {
    Name       = UIWindowNames.UIShipCabin,
    Layer      = UILayer.Normal,
    Ctrl       = require "UI.UIShipCabin.Controller.UIShipCabinCtrl",
    View       = require "UI.UIShipCabin.View.UIShipCabinView",
    PrefabPath = "Assets/Main/Prefabs/UI/UIShipCabin/UIShipCabin.prefab",
}

return {
    UIShipCabin = UIShipCabin,
}
