local LianLianRevive = {
    Name = UIWindowNames.LianLianRevive,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianRevive.LianLianReviveView",
    Ctrl = require "UI.LianLian.LianLianRevive.LianLianReviveCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianRevive.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianRevive = LianLianRevive,
}
