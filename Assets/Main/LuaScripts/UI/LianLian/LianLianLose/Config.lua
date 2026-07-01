return {
    {
        Name = UIWindowNames.LianLianLose,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianLose.prefab",
        View = require("UI.LianLian.LianLianLose.LianLianLoseView"),
        Ctrl = require("UI.LianLian.LianLianLose.LianLianLoseCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
