local LianLianWin = {
    Name = UIWindowNames.LianLianWin,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianWin.LianLianWinView",
    Ctrl = require "UI.LianLian.LianLianWin.LianLianWinCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianWin.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianWin = LianLianWin,
}
