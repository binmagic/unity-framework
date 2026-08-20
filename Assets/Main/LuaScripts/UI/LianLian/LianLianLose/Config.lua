local LianLianLose = {
    Name = UIWindowNames.LianLianLose,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianLose.LianLianLoseView",
    Ctrl = require "UI.LianLian.LianLianLose.LianLianLoseCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianLose.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianLose = LianLianLose,
}
