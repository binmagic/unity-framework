return {
    {
        Name = UIWindowNames.UILianLianRevive,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianRevive.prefab",
        View = require("Game.LianLian.UI.LianLianRevive.LianLianReviveView"),
        Ctrl = require("Game.LianLian.UI.LianLianRevive.LianLianReviveCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
