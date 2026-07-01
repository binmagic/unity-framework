return {
    {
        Name = UIWindowNames.LianLianWin,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianWin.prefab",
        View = require("UI.LianLian.LianLianWin.LianLianWinView"),
        Ctrl = require("UI.LianLian.LianLianWin.LianLianWinCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
