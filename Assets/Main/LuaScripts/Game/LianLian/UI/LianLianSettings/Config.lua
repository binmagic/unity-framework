return {
    {
        Name = UIWindowNames.UILianLianSettings,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianSettings.prefab",
        View = require("Game.LianLian.UI.LianLianSettings.LianLianSettingsView"),
        Ctrl = require("Game.LianLian.UI.LianLianSettings.LianLianSettingsCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
