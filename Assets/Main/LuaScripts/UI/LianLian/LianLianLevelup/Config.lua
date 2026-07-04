local LianLianLevelup = {
    Name = UIWindowNames.LianLianLevelup,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianLevelup.LianLianLevelupView",
    Ctrl = require "UI.LianLian.LianLianLevelup.LianLianLevelupCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianLevelup.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianLevelup = LianLianLevelup,
}
