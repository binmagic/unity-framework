return {
    {
        Name = UIWindowNames.LianLianMain,
        Layer = UILayer.Normal,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianMain.prefab",
        View = require("UI.LianLian.LianLianMain.LianLianMainView"),
        Ctrl = require("UI.LianLian.LianLianMain.LianLianMainCtrl"),
        Priority = 4,
        isBlur = false,
        hideCamera = false,
    }
}
