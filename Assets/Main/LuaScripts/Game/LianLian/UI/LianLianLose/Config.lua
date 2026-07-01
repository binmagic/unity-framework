return {
    {
        Name = UIWindowNames.UILianLianLose,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianLose.prefab",
        View = require("Game.LianLian.UI.LianLianLose.LianLianLoseView"),
        Ctrl = require("Game.LianLian.UI.LianLianLose.LianLianLoseCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
