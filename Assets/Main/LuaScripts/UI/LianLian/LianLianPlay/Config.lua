local LianLianPlay = {
    Name = UIWindowNames.LianLianPlay,
    Layer = UILayer.Normal,
    View = require "UI.LianLian.LianLianPlay.LianLianPlayView",
    Ctrl = require "UI.LianLian.LianLianPlay.LianLianPlayCtrl",
    PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianPlay.prefab",
    Priority = 4,
    isBlur = false,
    hideCamera = false,
}

return {
    LianLianPlay = LianLianPlay,
}
