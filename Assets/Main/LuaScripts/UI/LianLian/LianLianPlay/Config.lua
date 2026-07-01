return {
    {
        Name = UIWindowNames.LianLianPlay,
        Layer = UILayer.Normal,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianPlay.prefab",
        View = require("UI.LianLian.LianLianPlay.LianLianPlayView"),
        Ctrl = require("UI.LianLian.LianLianPlay.LianLianPlayCtrl"),
        Priority = 4,
        isBlur = false,
        hideCamera = false,
    }
}
