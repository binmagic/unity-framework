return {
    {
        Name = UIWindowNames.UILianLianLevelup,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianLevelup.prefab",
        View = require("Game.LianLian.UI.LianLianLevelup.LianLianLevelupView"),
        Ctrl = require("Game.LianLian.UI.LianLianLevelup.LianLianLevelupCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
