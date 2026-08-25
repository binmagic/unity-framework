using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// 挂在场景 Canvas 下，持久化绑定船舱预览的房间点击事件。
/// 点击任意 Room_N → 通过 ShipCabinDetailAnimator.Show(roomIndex) 弹出详情面板
/// 关闭由 ShipCabinDetailAnimator 内部绑定处理
/// </summary>
public class ShipCabinPreviewClickHandler : MonoBehaviour
{
    // Room_1~12 对应的 RoomScene prefab 名称（与 ShipCabinDetailAnimator 保持一致）
    private static readonly string[] RoomSceneNames = new string[]
    {
        "",                         // 占位，索引0不用
        "RoomScene_command_center", // Room_1  聚变能源核心
        "RoomScene_comms",          // Room_2  枢纽指挥中心
        "RoomScene_command_max",    // Room_3  全域最高指挥中枢
        "RoomScene_warehouse",      // Room_4  食材仓库
        "RoomScene_warehouse",      // Room_5  金属仓库
        "RoomScene_power_max",      // Room_6  电力仓库
        "RoomScene_shipyard",       // Room_7  零重力装配船坞A组
        "RoomScene_shipyard",       // Room_8  零重力装配船坞B组
        "RoomScene_shipyard",       // Room_9  零重力装配船坞C组
        "RoomScene_shipyard",       // Room_10 零重力装配船坞D组
        "RoomScene_lab",            // Room_11 矿石精炼阵列
        "RoomScene_lab_max",        // Room_12 能源采集舱
    };

    private const string RoomScenePrefabPath =
        "Assets/Main/Prefabs/UI/UIShipCabin/Rooms/";

    // Building_Config 前 12 行对应的建筑名称（buildId 1~12）
    private static readonly string[] BuildingNames = new string[]
    {
        "",                 // 占位，索引0不用
        "聚变能源核心",     // 1
        "枢纽指挥中心",     // 2
        "全域最高指挥中枢", // 3
        "食材仓库",         // 4
        "金属仓库",         // 5
        "电力仓库",         // 6
        "零重力装配船坞A组",// 7
        "零重力装配船坞B组",// 8
        "零重力装配船坞C组",// 9
        "零重力装配船坞D组",// 10
        "矿石精炼阵列",     // 11
        "能源采集舱",       // 12
    };

    public static string GetBuildingName(int buildId)
    {
        return (buildId >= 1 && buildId < BuildingNames.Length)
            ? BuildingNames[buildId]
            : ("舱室" + buildId);
    }

    private GameObject              _cabinPreview;
    private GameObject              _detailPreview;
    private ShipCabinDetailAnimator _animator;

    void Start()
    {
        var canvas = GameObject.Find("Canvas");
        if (canvas == null) { Debug.LogError("[ShipPreview] Canvas not found"); return; }

        _cabinPreview  = canvas.transform.Find("UIShipCabin_Preview")?.gameObject;
        _detailPreview = canvas.transform.Find("UIShipCabinDetail_Preview")?.gameObject;

        if (_cabinPreview == null)  { Debug.LogError("[ShipPreview] UIShipCabin_Preview not found");  return; }
        if (_detailPreview == null) { Debug.LogError("[ShipPreview] UIShipCabinDetail_Preview not found"); return; }

        _animator = _detailPreview.GetComponent<ShipCabinDetailAnimator>();
        if (_animator == null)
            _animator = _detailPreview.AddComponent<ShipCabinDetailAnimator>();

        // 启动时清理可能残留的升级弹窗（编辑器调试时可能遗留）
        var canvasT = canvas.transform;
        for (int i = canvasT.childCount - 1; i >= 0; i--)
        {
            var child = canvasT.GetChild(i);
            if (child.name.Contains("UIBuildingPanel"))
                UnityEngine.Object.Destroy(child.gameObject);
        }

        _cabinPreview.SetActive(true);
        _detailPreview.SetActive(false);

        int bound = 0;
        for (int i = 1; i <= 12; i++)
        {
            var roomT = _cabinPreview.transform.Find("ShipBody/Rooms/Room_" + i);
            if (roomT == null) continue;

            // 更新房间名称（从配置表名称映射直接写入）
            RefreshRoomCell(roomT, i);

            var btn = roomT.GetComponent<Button>();
            if (btn == null) btn = roomT.gameObject.AddComponent<Button>();

            btn.onClick.RemoveAllListeners();

            var anim = _animator;
            int idx  = i;
            btn.onClick.AddListener(() =>
            {
                Debug.Log("[ShipPreview] Room_" + idx + " clicked");
                anim.Show(idx);
            });
            bound++;
        }

        Debug.Log("[ShipPreview] Ready. Bound " + bound + " room buttons.");

        // 加载 RoomScene 缩略图到每个格子的 Inner 节点
        for (int i = 1; i <= 12; i++)
        {
            var roomT = _cabinPreview.transform.Find("ShipBody/Rooms/Room_" + i);
            if (roomT != null) LoadRoomSceneIntoCell(roomT, i);
        }

        // 绑定详情面板的关闭按钮（BgMask / BtnClose / BtnBack）
        BindClose(_detailPreview, "BgMask");
        BindClose(_detailPreview, "MainPanel/BtnClose");
        BindClose(_detailPreview, "MainPanel/Footer/BtnBack");
        Debug.Log("[ShipPreview] BindClose done");
    }

    /// <summary>
    /// 刷新单个房间格子的文字显示。
    /// 测试场景无 Lua 运行时，模拟：前8个格子已解锁，后4个未解锁。
    /// 正式流程由 Lua UIShipCabinView.RefreshRooms() 覆盖刷新。
    /// </summary>
    void RefreshRoomCell(Transform roomT, int buildId)
    {
        bool unlocked = (buildId <= 8);

        // 名称
        SetTMPText(roomT.Find("TxtName"), GetBuildingName(buildId));

        // 等级（已解锁才显示）
        var txtLevelT = roomT.Find("TxtLevel");
        if (txtLevelT != null)
        {
            txtLevelT.gameObject.SetActive(unlocked);
            if (unlocked) SetTMPText(txtLevelT, "Lv.1");
        }

        // 状态（已解锁才显示，模拟几种状态）
        var txtStatusT = roomT.Find("TxtStatus");
        if (txtStatusT != null)
        {
            txtStatusT.gameObject.SetActive(unlocked);
            if (unlocked)
            {
                // 模拟：1-3号仓库已完成，4-6号生产中有倒计时，7-8号空闲
                if (buildId <= 3)
                    SetTMPText(txtStatusT, "已完成");
                else if (buildId <= 6)
                    SetTMPText(txtStatusT, "02:30");
                else
                    SetTMPText(txtStatusT, "空闲");
            }
        }

        // 锁定遮罩
        var imgLock = roomT.Find("ImgLock");
        if (imgLock != null)
            imgLock.gameObject.SetActive(!unlocked);

        // 可领取角标（1-3号可领取）
        var imgCollect = roomT.Find("ImgCollect");
        if (imgCollect != null)
            imgCollect.gameObject.SetActive(unlocked && buildId <= 3);
    }

    static void SetTMPText(Transform t, string text)
    {
        if (t == null) return;
        var tmp = t.GetComponent<TextMeshProUGUI>();
        if (tmp != null) tmp.text = text;
    }

    void BindClose(GameObject panel, string path)
    {
        var t = panel.transform.Find(path);
        if (t == null) return;
        var btn = t.GetComponent<Button>() ?? t.gameObject.AddComponent<Button>();
        // 不调用 RemoveAllListeners，避免清掉 ShipCabinDetailAnimator.EnsureInitialized 里已绑的 listener
        btn.onClick.AddListener(() => _animator.HideWithCallback(null));
    }

    /// <summary>
    /// 把对应的 RoomScene prefab 加载到格子的 Inner 节点，铺满显示。
    /// </summary>
    void LoadRoomSceneIntoCell(Transform roomT, int roomIndex)
    {
        if (roomIndex < 1 || roomIndex >= RoomSceneNames.Length) return;

        var inner = roomT.Find("Inner");
        if (inner == null) return;

        // 清除旧实例
        for (int i = inner.childCount - 1; i >= 0; i--)
            DestroyImmediate(inner.GetChild(i).gameObject);

        string sceneName = RoomSceneNames[roomIndex];
        if (string.IsNullOrEmpty(sceneName)) return;

#if UNITY_EDITOR
        var prefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(
            RoomScenePrefabPath + sceneName + ".prefab");
#else
        var prefab = Resources.Load<GameObject>("UI/UIShipCabin/Rooms/" + sceneName);
#endif
        if (prefab == null)
        {
            Debug.LogWarning("[ShipPreview] RoomScene not found: " + sceneName);
            return;
        }

        var inst = Instantiate(prefab, inner);
        var rt   = inst.GetComponent<RectTransform>() ?? inst.AddComponent<RectTransform>();
        // 铺满 Inner
        rt.anchorMin        = Vector2.zero;
        rt.anchorMax        = Vector2.one;
        rt.offsetMin        = Vector2.zero;
        rt.offsetMax        = Vector2.zero;

        // 关掉所有 raycastTarget，避免遮挡房间按钮点击
        foreach (var img in inst.GetComponentsInChildren<UnityEngine.UI.Image>(true))
            img.raycastTarget = false;
        foreach (var raw in inst.GetComponentsInChildren<UnityEngine.UI.RawImage>(true))
            raw.raycastTarget = false;
    }
}
