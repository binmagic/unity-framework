---
--- 探险玩法：2D飞机 + 数字门 战斗
--- 全屏子玩法窗口：主机左右滑动 + 僚机自动开火 + 数字门/油桶推进 + boss结算
---
local UIPlaneBattle = {
    Name       = UIWindowNames.UIPlaneBattle,
    Layer      = UILayer.Normal,
    Ctrl       = require "UI.UIPlaneBattle.Controller.UIPlaneBattleCtrl",
    View       = require "UI.UIPlaneBattle.View.UIPlaneBattleView",
    PrefabPath = "Assets/Main/Prefabs/UI/UIPlaneBattle/UIPlaneBattle.prefab",
}

return {
    UIPlaneBattle = UIPlaneBattle,
}
