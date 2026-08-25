---
--- 船舱详情面板 — Config
--- 点击船舱格子后弹出，展示：舱室信息、产出数据、家具列表、升级入口
---
local UIShipCabinDetail = {
    Name       = UIWindowNames.UIShipCabinDetail,
    Layer      = UILayer.Normal,
    Ctrl       = require "UI.UIShipCabinDetail.Controller.UIShipCabinDetailCtrl",
    View       = require "UI.UIShipCabinDetail.View.UIShipCabinDetailView",
    PrefabPath = "Assets/Main/Prefabs/UI/UIShipCabinDetail/UIShipCabinDetail.prefab",
    -- isBlur 关闭：BlurURP 截屏流程在当前渲染配置下拿不到内容
    -- （控制台报 "Renderer at index 1 is missing for camera UICamera"），
    -- 会退化成 ui_white_block 4x4 纯白块，以 sortingOrder=199 全屏盖住整个面板，
    -- 表现为"详情界面一片灰"。面板自身已有 BgMask（alpha 0.7）做背景压暗，不需要毛玻璃。
    -- 若后续修好 BlurURP 渲染管线，可以再打开。
    isBlur     = false,
}

return {
    UIShipCabinDetail = UIShipCabinDetail,
}
