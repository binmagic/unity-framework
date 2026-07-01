return {
    {
        Name = UIWindowNames.UILianLianPlay,
        Layer = UILayer.Normal,
        PrefabPath = "Assets/Main/Prefabs/UI/LianLian/LianLianPlay.prefab",
        View = require("Game.LianLian.UI.LianLianPlay.LianLianPlayView"),
        Ctrl = require("Game.LianLian.UI.LianLianPlay.LianLianPlayCtrl"),
        Priority = 4,
        isBlur = false,
        hideCamera = false,
    }
}
