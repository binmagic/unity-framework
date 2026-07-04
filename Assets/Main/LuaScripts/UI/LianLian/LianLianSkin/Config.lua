local LianLianSkin = {
    Name = UIWindowNames.LianLianSkin,
    Layer = UILayer.Dialog,
    View = require "UI.LianLian.LianLianSkin.LianLianSkinView",
    Ctrl = require "UI.LianLian.LianLianSkin.LianLianSkinCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianSkin.prefab",
    Priority = 4,
    isBlur = true,
}

return {
    LianLianSkin = LianLianSkin,
}
