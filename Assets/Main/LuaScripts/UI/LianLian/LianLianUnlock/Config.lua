local LianLianUnlock = {
    Name = UIWindowNames.LianLianUnlock,
    Layer = UILayer.TopCanvas,
    View = require "UI.LianLian.LianLianUnlock.LianLianUnlockView",
    Ctrl = require "UI.LianLian.LianLianUnlock.LianLianUnlockCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianUnlock.prefab",
    Priority = 4,
    isBlur = false,
    hideCamera = false,
}

return {
    LianLianUnlock = LianLianUnlock,
}
