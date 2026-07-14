local LianLianDebug = {
    Name = UIWindowNames.LianLianDebug,
    Layer = UILayer.TopCanvas,
    View = require "UI.LianLian.LianLianDebug.LianLianDebugView",
    Ctrl = require "UI.LianLian.LianLianDebug.LianLianDebugCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianDebug.prefab",
    Priority = 4,
    isBlur = false,
    hideCamera = false,
}

return {
    LianLianDebug = LianLianDebug,
}
