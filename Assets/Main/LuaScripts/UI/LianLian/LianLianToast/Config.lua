local LianLianToast = {
    Name = UIWindowNames.LianLianToast,
    Layer = UILayer.TopMost,
    View = require "UI.LianLian.LianLianToast.LianLianToastView",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianToast.prefab",
    Priority = 4,
}

return {
    LianLianToast = LianLianToast,
}
