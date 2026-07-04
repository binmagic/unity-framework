local LianLianMain = {
    Name = UIWindowNames.LianLianMain,
    Layer = UILayer.Normal,
    View = require "UI.LianLian.LianLianMain.LianLianMainView",
    Ctrl = require "UI.LianLian.LianLianMain.LianLianMainCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianMain.prefab",
    Priority = 4,
    isBlur = false,
    hideCamera = false,
}

return {
    LianLianMain = LianLianMain,
}
