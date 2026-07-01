return {
    {
        Name = UIWindowNames.LianLianSettings,
        Layer = UILayer.Dialog,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianSettings.prefab",
        View = require("UI.LianLian.LianLianSettings.LianLianSettingsView"),
        Ctrl = require("UI.LianLian.LianLianSettings.LianLianSettingsCtrl"),
        Priority = 4,
        isBlur = true,
    }
}
