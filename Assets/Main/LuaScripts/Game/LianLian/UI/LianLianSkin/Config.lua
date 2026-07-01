return {
    {
        Name = UIWindowNames.UILianLianSkin,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianSkin.prefab",
        View = require("Game.LianLian.UI.LianLianSkin.LianLianSkinView"),
        Ctrl = require("Game.LianLian.UI.LianLianSkin.LianLianSkinCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
