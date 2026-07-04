local LianLianSettings = {
    Name = UIWindowNames.LianLianSettings,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianSettings.LianLianSettingsView",
    Ctrl = require "UI.LianLian.LianLianSettings.LianLianSettingsCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianSettings.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianSettings = LianLianSettings,
}
