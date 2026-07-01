return {
    {
        Name = UIWindowNames.UILianLianMain,
        Layer = UILayer.Normal,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianMain.prefab",
        View = require("Game.LianLian.UI.LianLianMain.LianLianMainView"),
        Ctrl = require("Game.LianLian.UI.LianLianMain.LianLianMainCtrl"),
        Priority = 4,
        isBlur = false,
        hideCamera = false,
    }
}
