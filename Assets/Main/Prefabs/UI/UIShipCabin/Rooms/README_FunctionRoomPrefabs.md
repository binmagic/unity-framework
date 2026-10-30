# 功能舱 prefab 组件说明

这些房间不是一张合成大图。每个 `RoomScene_function_*.prefab` 都由多个独立的 UI Image 子物体拼成，运行时会作为 `RoomScene_function_xxx(Clone)` 挂到对应的 `RoomCell/RoomScene` 下。

展开 prefab 根节点后可以看到：

- `ImgRoomBg`：房间内部底图/墙面
- `ImgCeiling`、`ImgLightStrip`：顶部结构和灯带
- `ImgFloor`：底部地板
- `ImgPipeLeft`：侧边管线
- `ImgFurniture1`、`ImgFurniture2`：家具/工作台/设备等独立 Sprite
- `ImgProp`：小道具、屏幕、箱子或管路等独立 Sprite
- `ImgCharacter`：人物独立 Sprite

## 在 Unity 中查看

1. 在 Project 面板打开 `Assets/Main/Prefabs/UI/UIShipCabin/Rooms`。
2. 双击任意 `RoomScene_function_*.prefab`，进入 Prefab Mode。
3. 在 Hierarchy 展开 prefab 根节点，即可逐个选中背景、家具、道具和人物。
4. 运行游戏时，展开 `RoomCell_x/RoomScene/RoomScene_function_xxx(Clone)`；不要只展开下面的 `LockMask`、`ImgCollect`、`UnlockHint`，那几个是锁定状态 UI。

`RoomSceneMap.lua` 只负责按房间类型选择 prefab，不会把这些子组件合并成一张图。修改单个家具或人物时，可以直接在对应 prefab 中替换它的 Sprite、位置或尺寸。
