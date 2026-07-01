return {
    {
        Name = UIWindowNames.UILianLianWin,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianWin.prefab",
        View = require("Game.LianLian.UI.LianLianWin.LianLianWinView"),
        Ctrl = require("Game.LianLian.UI.LianLianWin.LianLianWinCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
