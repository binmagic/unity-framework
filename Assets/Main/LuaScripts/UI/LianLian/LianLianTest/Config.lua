local LianLianTest = {
    Name = UIWindowNames.LianLianTest,
    Layer = UILayer.Normal,
    View = require "UI.LianLian.LianLianTest.LianLianTestView",
    Ctrl = require "UI.LianLian.LianLianTest.LianLianTestCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianTest.prefab",
    Priority = 4,
    isBlur = false,
    hideCamera = false,
}

return {
    LianLianTest = LianLianTest,
}
