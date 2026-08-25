using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;

public class ShipCabinDetailAnimator : MonoBehaviour
{
    public float slideInDuration  = 0.35f;
    public float slideOutDuration = 0.25f;

    // buildId → 内景 prefab 名的映射统一放在 Lua 侧 UI/UIShipCabin/RoomSceneMap.lua，
    // 这里通过 CSharpCallLuaInterface.GetRoomSceneName 查询，避免两份表打架。
    // 测试场景（无 Lua 环境）下走 FallbackSceneNames。
    private static readonly string[] FallbackSceneNames = new string[]
    {
        "",                         // 占位，索引0不用
        "RoomScene_power_room",     // 1  聚变能源核心
        "RoomScene_command_center", // 2  枢纽指挥中心
        "RoomScene_command_max",    // 3  全域最高指挥中枢
        "RoomScene_warehouse",      // 4  食材仓库
        "RoomScene_warehouse",      // 5  金属仓库
        "RoomScene_power_max",      // 6  电力仓库
        "RoomScene_shipyard",       // 7  零重力装配船坞A组
        "RoomScene_shipyard",       // 8  零重力装配船坞B组
        "RoomScene_shipyard",       // 9  零重力装配船坞C组
        "RoomScene_shipyard",       // 10 零重力装配船坞D组
        "RoomScene_lab",            // 11 矿石精炼阵列
        "RoomScene_lab_max",        // 12 能源采集舱
    };

    private const string FallbackDefaultScene = "RoomScene_warehouse";

    // Lua 调 Show(buildId, sceneName) 时把内景名放这里，LoadRoomScene 取用后清空
    private string _pendingSceneName;

    /// <summary>
    /// 取 buildId 对应的内景 prefab 名。
    /// 优先用 Lua 传入的值（RoomSceneMap 是唯一真相源）；
    /// 纯 C# 测试场景没有 Lua 传参时，退回本地回退表（只覆盖 buildId 1~12）。
    /// </summary>
    string GetRoomSceneName(int buildId)
    {
        if (!string.IsNullOrEmpty(_pendingSceneName))
            return _pendingSceneName;

        if (buildId >= 1 && buildId < FallbackSceneNames.Length)
            return FallbackSceneNames[buildId];
        return FallbackDefaultScene;
    }

    private const string RoomScenePrefabPath =
        "Assets/Main/Prefabs/UI/UIShipCabin/Rooms/";

    private const string BuildingPanelPrefabPath =
        "Assets/Main/Prefabs/UI/Build/UIBuildingPanel.prefab";

    private RectTransform _panelRT;
    private Image         _bgImage;       // 直接操作 Image.color.a，不用 CanvasGroup
    private RectTransform _roomPreviewRT;
    private float         _panelHeight;
    private Vector2       _panelRestPos;   // 面板停靠位置（取自 prefab，滑入/滑出的基准）
    private bool          _isAnimating;
    private GameObject    _cabinPreview;  // UIShipCabin_Preview，弹出时隐藏，关闭时恢复
    private int           _currentBuildId;
    private GameObject    _upgradePanelInst; // UIBuildingPanel 实例

    // 测试场景建筑等级记录（运行时内存，不持久化）
    private readonly System.Collections.Generic.Dictionary<int, int> _buildingLevels
        = new System.Collections.Generic.Dictionary<int, int>();

    private int GetBuildingLevel(int buildId)
    {
        return _buildingLevels.TryGetValue(buildId, out var lv) ? lv : 1;
    }

    private bool _initialized;

    void Awake()
    {
        // 初始化推迟到 EnsureInitialized()，避免 AddComponent 时序问题导致 Find 失败
    }

    void EnsureInitialized()
    {
        if (_initialized) return;
        _initialized = true;

        var panelGO = transform.Find("MainPanel");
        if (panelGO != null)
            _panelRT = panelGO.GetComponent<RectTransform>();

        var bgMaskGO = transform.Find("BgMask");
        if (bgMaskGO != null)
            _bgImage = bgMaskGO.GetComponent<Image>();

        var previewNode = transform.Find("RoomPreview");
        if (previewNode != null)
            _roomPreviewRT = previewNode.GetComponent<RectTransform>();

        // 记住 prefab 里配的停靠位置（面板底边抬高了 100 以露出常驻导航栏）。
        // 必须在这里取而不是在 Show() 里——Hide 可能先于 Show 被调用，
        // 那时若还是 (0,0) 面板会滑到错误位置。
        if (_panelRT != null)
            _panelRestPos = _panelRT.anchoredPosition;

        FixDetailPanelLayout();

        // 仅在测试场景（Lua 运行时不可用）时绑定 C# 升级回调
        // 生产流程中 Lua 侧 UIShipCabinDetailView.ComponentDefine 已绑定，不需要 C# 再绑
        bool isTestScene = (GameEntry.Lua == null);
        if (isTestScene)
        {
            // 绑定升级箭头按钮
            var btnArrow = transform.Find("MainPanel/TitleBar/BtnUpgradeArrow");
            if (btnArrow != null)
            {
                var btn = btnArrow.GetComponent<Button>();
                if (btn != null)
                    btn.onClick.AddListener(OnClickUpgradeArrow);
            }

        }
    }

    /// <summary>
    /// 修正 MainPanel 内布局问题（prefab 中 pivot/anchor 设置导致按钮超出屏幕）。
    /// </summary>
    void FixDetailPanelLayout()
    {
        // BtnClose：pivot 右上角(1,1)，往左内缩 22px 避免刚好压在屏幕右边缘
        var btnClose = transform.Find("MainPanel/BtnClose");
        if (btnClose != null)
        {
            var rt = btnClose.GetComponent<RectTransform>();
            if (rt != null)
            {
                rt.pivot            = new Vector2(1f, 1f);
                rt.anchoredPosition = new Vector2(-22f, 0f);
            }
        }

        // BtnUpgradeArrow：右边界缩进 66px（BtnClose 宽 44 + 内缩 22）避免与 BtnClose 重叠
        var btnArrow = transform.Find("MainPanel/TitleBar/BtnUpgradeArrow");
        if (btnArrow != null)
        {
            var rt = btnArrow.GetComponent<RectTransform>();
            if (rt != null)
            {
                rt.anchorMax        = new Vector2(1f, 1f);
                rt.anchoredPosition = new Vector2(-66f, 0f);
                rt.offsetMin        = new Vector2(rt.offsetMin.x, rt.offsetMin.y);
            }
        }

        // Footer：pivot 改为底部中心(0.5,0)，anchoredPos=(0,0) 贴 MainPanel 底边
        var footer = transform.Find("MainPanel/Footer");
        if (footer != null)
        {
            var rt = footer.GetComponent<RectTransform>();
            if (rt != null)
            {
                rt.pivot            = new Vector2(0.5f, 0f);
                rt.anchoredPosition = Vector2.zero;
            }
        }

        // RoomPreview 容器本身是纯展示区域，关掉 raycastTarget 避免遮挡上层按钮
        var roomPreview = transform.Find("RoomPreview");
        if (roomPreview != null)
        {
            foreach (var img in roomPreview.GetComponentsInChildren<UnityEngine.UI.Image>(true))
                img.raycastTarget = false;
            foreach (var raw in roomPreview.GetComponentsInChildren<UnityEngine.UI.RawImage>(true))
                raw.raycastTarget = false;
        }
    }

    /// <summary>
    /// 弹出详情面板，并在顶部展示 buildId 对应的舱室内景。
    /// 内景名由调用方（Lua）按 RoomSceneMap 传入；传空则回退到本地表。
    /// </summary>
    /// <param name="buildId">Building_Config 的 id</param>
    /// <param name="sceneName">内景 prefab 名，来自 Lua 的 RoomSceneMap</param>
    public void Show(int buildId, string sceneName)
    {
        _pendingSceneName = sceneName;
        Show(buildId);
    }

    /// <summary>
    /// 弹出详情面板。内景名走 GetRoomSceneName 解析（Lua 未传入时用本地回退表）。
    /// </summary>
    public void Show(int buildId)
    {
        _currentBuildId = buildId;
        // 先激活再初始化，避免 Awake 时序问题
        gameObject.SetActive(true);
        EnsureInitialized();
        // 切换房间时关闭残留的升级弹窗
        CloseUpgradePanel();
        LoadRoomScene(buildId);
        Show();
        RefreshDetailData(buildId);
    }

    public void Show()
    {
        if (_isAnimating) return;

        // 隐藏船舱总览（弹出详情时不需要显示总览）
        if (_cabinPreview == null)
        {
            var canvas = GameObject.Find("Canvas");
            if (canvas != null)
                _cabinPreview = canvas.transform.Find("UIShipCabin_Preview")?.gameObject;
        }
        if (_cabinPreview != null) _cabinPreview.SetActive(false);

        gameObject.SetActive(true);

        if (_panelRT == null)
        {
            Debug.LogWarning("[ShipCabinDetailAnimator] MainPanel not found");
            return;
        }

        _panelHeight = _panelRT.rect.height;
        if (_panelHeight <= 0) _panelHeight = 800f;

        // 停靠位置已在 EnsureInitialized 里从 prefab 取好，这里不能再读
        // _panelRT.anchoredPosition —— 重复打开时面板可能还在屏幕外的位置上，
        // 读到的会是动画中间态而不是停靠位。

        // 初始状态：面板在屏幕外，BgMask 完全透明
        _panelRT.anchoredPosition = new Vector2(_panelRestPos.x, _panelRestPos.y - _panelHeight);
        SetBgAlpha(0f);

        _isAnimating = true;
        DOTween.Kill(_panelRT);
        DOTween.Kill(_bgImage);
        _panelRT.DOAnchorPos(_panelRestPos, slideInDuration)
            .SetEase(Ease.OutCubic)
            .OnComplete(() => { _isAnimating = false; });
        if (_bgImage != null)
            _bgImage.DOFade(0.7f, slideInDuration).SetEase(Ease.OutCubic);
    }

    void LoadRoomScene(int buildId)
    {
        if (_roomPreviewRT == null) return;
        if (buildId < 1) return;

        // 清除旧的内景实例（DestroyImmediate 同帧生效）。
        // 只删内景，不能清空 RoomPreview 的全部子节点 —— prefab 里还挂着常驻的 UI
        // （OutputBar 产量条等），全删会把它们一起删掉，运行时就再也找不回来。
        for (int i = _roomPreviewRT.childCount - 1; i >= 0; i--)
        {
            var child = _roomPreviewRT.GetChild(i);
            if (child.name.StartsWith("RoomScene_"))
                DestroyImmediate(child.gameObject);
        }

        string sceneName = GetRoomSceneName(buildId);
        _pendingSceneName = null;   // 取用后清空，避免下次切换沿用上一次的内景
        if (string.IsNullOrEmpty(sceneName))
        {
            Debug.LogWarning("ShipCabinDetailAnimator LoadRoomScene 拿不到内景名 buildId=" + buildId);
            return;
        }

#if UNITY_EDITOR
        var prefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(
            RoomScenePrefabPath + sceneName + ".prefab");
#else
        var prefab = Resources.Load<GameObject>("UI/UIShipCabin/Rooms/" + sceneName);
#endif
        if (prefab == null)
        {
            Debug.LogWarning("[ShipCabinDetailAnimator] RoomScene not found: " + sceneName);
            return;
        }

        var inst = Instantiate(prefab, _roomPreviewRT);
        // 垫在最底，让 prefab 里常驻的 UI（OutputBar 产量条等）浮在内景之上。
        // Instantiate 默认追加到末尾 = 最后绘制 = 会盖住那些 UI。
        inst.transform.SetAsFirstSibling();
        var rt   = inst.GetComponent<RectTransform>() ?? inst.AddComponent<RectTransform>();

        // RoomScene 是纯展示性内容，所有 Image/RawImage 关掉 raycastTarget，
        // 避免遮挡 MainPanel 上的按钮点击（BtnClose 等）
        foreach (var img in inst.GetComponentsInChildren<UnityEngine.UI.Image>(true))
            img.raycastTarget = false;
        foreach (var raw in inst.GetComponentsInChildren<UnityEngine.UI.RawImage>(true))
            raw.raycastTarget = false;

        // 拉伸铺满 RoomPreview，不做缩放。
        //
        // 为什么不用缩放：内景设计尺寸 223x230（宽高比 0.97，近正方），而预览窗是
        // 宽扁的（914x380，比 2.41）。等比缩放两条路都不可接受：
        //   contain（取较小比例）→ 只填 40% 宽，左右各留 273 逻辑px 黑边
        //   cover （取较大比例）→ 铺满宽度但高度涨到 1114，裁掉 665px（约60%），
        //                          天花板/灯带/船员上半身全被切掉
        //
        // 内景 prefab 的结构本身支持拉伸：ImgRoomBg / ImgCeiling / ImgLightStrip /
        // ImgFloor 都是横向拉伸锚定（aMin.x=0 aMax.x=1），会自己延展；
        // ImgFurniture / ImgProp / ImgCharacter 是固定尺寸贴边锚定，保持原大小。
        // 所以直接把根节点拉伸到预览窗大小即可，既无黑边也不裁切。
        rt.anchorMin        = Vector2.zero;
        rt.anchorMax        = Vector2.one;
        rt.pivot            = new Vector2(0.5f, 0.5f);
        rt.offsetMin        = Vector2.zero;
        rt.offsetMax        = Vector2.zero;
        rt.anchoredPosition = Vector2.zero;
        rt.localScale       = Vector3.one;
    }

    void OnDisable()
    {
        DOTween.Kill(_panelRT);
        DOTween.Kill(_bgImage);
        _isAnimating = false;
    }

    void SetBgAlpha(float a)
    {
        if (_bgImage == null) return;
        var c = _bgImage.color;
        c.a = a;
        _bgImage.color = c;
    }

    // ---------------------------------------------------------------
    // 升级弹窗（测试场景用，正式流程由 Lua UIBuildingPanel 负责）
    // ---------------------------------------------------------------

    void OnClickUpgradeArrow()
    {
        Debug.Log($"[ShipCabinDetailAnimator] OnClickUpgradeArrow clicked, _currentBuildId={_currentBuildId}");
        if (_currentBuildId < 1 || _currentBuildId >= BuildingCfgs.Length)
        {
            Debug.LogWarning($"[ShipCabinDetailAnimator] OnClickUpgradeArrow 拒绝: buildId={_currentBuildId} 超出范围");
            return;
        }

        // 真实游戏：交给 Lua 的 UIShipCabinDetailCtrl:OpenUpgradePanel 走完整升级流程
        if (GameEntry.Lua != null)
        {
            GameEntry.Lua.Call("CSharpCallLuaInterface.OpenShipBuildingUpgrade", _currentBuildId);
            return;
        }

        // 测试场景（Lua 运行时不可用）：走 C# 模拟弹窗
        ShowUpgradePanel(_currentBuildId);
    }


    void ShowUpgradePanel(int buildId)
    {
        // 如果已有实例，先销毁
        if (_upgradePanelInst != null)
            Destroy(_upgradePanelInst);

#if UNITY_EDITOR
        var prefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(BuildingPanelPrefabPath);
#else
        var prefab = Resources.Load<GameObject>("UI/Build/UIBuildingPanel");
#endif
        if (prefab == null)
        {
            Debug.LogWarning("[ShipCabinDetailAnimator] UIBuildingPanel prefab not found");
            return;
        }

        var canvas = GameObject.Find("Canvas");
        var parent = canvas != null ? canvas.transform : transform;
        _upgradePanelInst = Instantiate(prefab, parent);

        // 设置 layer 为 UI（与 Canvas 一致），否则 UICamera cullingMask 过滤掉，弹窗不可见
        int uiLayer = LayerMask.NameToLayer("UI");
        SetLayerRecursively(_upgradePanelInst, uiLayer);

        // 根节点全屏遮罩 Image 关掉 raycastTarget，让点击穿透到 BgPanel 里的按钮
        var rootImg = _upgradePanelInst.GetComponent<UnityEngine.UI.Image>();
        if (rootImg != null) rootImg.raycastTarget = false;

        // 全屏铺满
        var rt = _upgradePanelInst.GetComponent<RectTransform>();
        if (rt != null)
        {
            rt.anchorMin        = Vector2.zero;
            rt.anchorMax        = Vector2.one;
            rt.offsetMin        = Vector2.zero;
            rt.offsetMax        = Vector2.zero;
        }

        // 给弹窗加独立 Canvas + GraphicRaycaster，sortingOrder 高于主 Canvas（0），
        // 保证弹窗的所有按钮 raycast 优先级高于底层 Detail 面板的任何节点。
        var overrideCanvas = _upgradePanelInst.AddComponent<Canvas>();
        overrideCanvas.overrideSorting = true;
        overrideCanvas.sortingOrder    = 10;
        _upgradePanelInst.AddComponent<UnityEngine.UI.GraphicRaycaster>();

        // 修正 BgPanel 布局（Prefab 内节点层级可能导致内容偏移）
        FixUpgradePanelLayout(_upgradePanelInst.transform);

        FillUpgradePanelData(_upgradePanelInst, buildId);
    }

    static void FixUpgradePanelLayout(Transform root)
    {
        var bgPanel = root.Find("BgPanel");
        if (bgPanel == null) return;

        // BgPanel: 700×420 居中卡片
        var bgRt = bgPanel.GetComponent<RectTransform>();
        if (bgRt != null)
        {
            bgRt.anchorMin        = new Vector2(0.5f, 0.5f);
            bgRt.anchorMax        = new Vector2(0.5f, 0.5f);
            bgRt.pivot            = new Vector2(0.5f, 0.5f);
            bgRt.sizeDelta        = new Vector2(700, 420);
            bgRt.anchoredPosition = Vector2.zero;
        }

        // 将散落在 root 下的内容节点 reparent 到 BgPanel
        string[] nodesToReparent = { "Header", "CostRoot", "PrereqRow", "Footer", "BtnClose" };
        foreach (var nodeName in nodesToReparent)
        {
            var node = root.Find(nodeName);
            if (node != null) node.SetParent(bgPanel, false);
        }

        // Header: 顶部居中，往下 24px，高度 110
        var header = bgPanel.Find("Header");
        if (header != null)
        {
            var rt = header.GetComponent<RectTransform>();
            if (rt != null) { rt.anchorMin = new Vector2(0.5f,1f); rt.anchorMax = new Vector2(0.5f,1f); rt.pivot = new Vector2(0.5f,1f); rt.sizeDelta = new Vector2(660,110); rt.anchoredPosition = new Vector2(0,-24); }
        }

        // CostRoot: Header 下方（-24-110-16=-150），高度 80
        var costRoot = bgPanel.Find("CostRoot");
        if (costRoot != null)
        {
            var rt = costRoot.GetComponent<RectTransform>();
            if (rt != null) { rt.anchorMin = new Vector2(0.5f,1f); rt.anchorMax = new Vector2(0.5f,1f); rt.pivot = new Vector2(0.5f,1f); rt.sizeDelta = new Vector2(660,80); rt.anchoredPosition = new Vector2(0,-150); }
        }

        // Footer: 底部居中，往上 25px，高度 90
        var footer = bgPanel.Find("Footer");
        if (footer != null)
        {
            var rt = footer.GetComponent<RectTransform>();
            if (rt != null) { rt.anchorMin = new Vector2(0.5f,0f); rt.anchorMax = new Vector2(0.5f,0f); rt.pivot = new Vector2(0.5f,0f); rt.sizeDelta = new Vector2(660,90); rt.anchoredPosition = new Vector2(0,25); }
        }

        // BtnClose: BgPanel 右上角内侧
        var btnClose = bgPanel.Find("BtnClose");
        if (btnClose != null)
        {
            var rt = btnClose.GetComponent<RectTransform>();
            if (rt != null) { rt.anchorMin = new Vector2(1f,1f); rt.anchorMax = new Vector2(1f,1f); rt.pivot = new Vector2(1f,1f); rt.sizeDelta = new Vector2(56,56); rt.anchoredPosition = new Vector2(-10,-10); }
        }

        // 修复 CostItem 布局：水平排列，图标+名称+数量
        FixCostItemLayout(costRoot);
    }

    static void FixCostItemLayout(Transform costRoot)
    {
        if (costRoot == null) return;
        for (int i = 0; i < costRoot.childCount; i++)
        {
            var item = costRoot.GetChild(i);
            if (!item.gameObject.activeSelf) continue;

            var itemRt = item.GetComponent<RectTransform>();
            // CostItem 本身：左对齐，从左边开始排列，高度 80
            itemRt.anchorMin        = new Vector2(0f, 0.5f);
            itemRt.anchorMax        = new Vector2(0f, 0.5f);
            itemRt.pivot            = new Vector2(0f, 0.5f);
            itemRt.sizeDelta        = new Vector2(400, 60);
            itemRt.anchoredPosition = new Vector2(30, 0);

            // ImgIcon: 左侧 60×60
            var imgIcon = item.Find("ImgIcon");
            if (imgIcon != null)
            {
                var rt = imgIcon.GetComponent<RectTransform>();
                rt.anchorMin = new Vector2(0f, 0.5f); rt.anchorMax = new Vector2(0f, 0.5f);
                rt.pivot = new Vector2(0f, 0.5f);
                rt.sizeDelta = new Vector2(60, 60); rt.anchoredPosition = Vector2.zero;
            }

            // TxtName: 图标右侧
            var txtName = item.Find("TxtName");
            if (txtName != null)
            {
                var rt = txtName.GetComponent<RectTransform>();
                rt.anchorMin = new Vector2(0f, 0.5f); rt.anchorMax = new Vector2(0f, 0.5f);
                rt.pivot = new Vector2(0f, 0.5f);
                rt.sizeDelta = new Vector2(120, 50); rt.anchoredPosition = new Vector2(70, 0);
            }

            // TxtAmount: 名称右侧
            var txtAmt = item.Find("TxtAmount");
            if (txtAmt != null)
            {
                var rt = txtAmt.GetComponent<RectTransform>();
                rt.anchorMin = new Vector2(0f, 0.5f); rt.anchorMax = new Vector2(0f, 0.5f);
                rt.pivot = new Vector2(0f, 0.5f);
                rt.sizeDelta = new Vector2(160, 50); rt.anchoredPosition = new Vector2(200, 0);
            }
        }
    }

    void FillUpgradePanelData(GameObject panel, int buildId)
    {
        var cfg      = BuildingCfgs[buildId];
        int curLevel = GetBuildingLevel(buildId);
        int nextLevel = curLevel + 1;
        bool isMax   = curLevel >= cfg.levelLimit;

        // FixUpgradePanelLayout 已将 Header/CostRoot/Footer/BtnClose reparent 到 BgPanel 下
        var t = panel.transform.Find("BgPanel") ?? panel.transform;

        // 标题：「聚变能源核心  升至N级」 或 「已满级」
        SetPanelTMP(t, "Header/TxtTitle", isMax
            ? string.Format("{0}  已满级", cfg.name)
            : string.Format("{0}  升至{1}级", cfg.name, nextLevel));

        SetPanelTMP(t, "Header/TxtTime", isMax ? "" : "所需时间：1秒");

        // 资源费用
        var costAmounts = UpgradeCosts.ContainsKey(buildId)
            ? UpgradeCosts[buildId]
            : new[] { new UpgradeCostEntry { resName = "金属", amount = buildId * 1000, resIconPath = ResIconPath_Metal } };

        for (int i = 1; i <= 5; i++)
        {
            var itemT = t.Find("CostRoot/CostItem_" + i);
            if (itemT == null) break;
            if (!isMax && i - 1 < costAmounts.Length)
            {
                itemT.gameObject.SetActive(true);
                var entry = costAmounts[i - 1];

                SetPanelTMP(itemT, "TxtName", entry.resName);

                var amtT = itemT.Find("TxtAmount");
                if (amtT != null)
                {
                    var txtComp = amtT.GetComponent<Text>();
                    if (txtComp != null)
                    {
                        txtComp.text  = string.Format("0 / {0}", entry.amount);
                        txtComp.color = new Color(0.95f, 0.3f, 0.3f, 1f);
                    }
                }

#if UNITY_EDITOR
                var imgIconT = itemT.Find("ImgIcon");
                if (imgIconT != null && !string.IsNullOrEmpty(entry.resIconPath))
                {
                    var sp = UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>(entry.resIconPath);
                    if (sp != null)
                    {
                        var img = imgIconT.GetComponent<Image>();
                        if (img != null) img.sprite = sp;
                    }
                }
#endif
            }
            else
            {
                itemT.gameObject.SetActive(false);
            }
        }

        // 前置条件行隐藏（测试场景不验证）
        var prereqRow = t.Find("PrereqRow");
        if (prereqRow != null) prereqRow.gameObject.SetActive(false);

        // 关闭/取消按钮
        var panelToClose = panel;
        System.Action closeAction = () =>
        {
            if (panelToClose != null)
                DestroyImmediate(panelToClose);
            _upgradePanelInst = null;
        };

        var btnClose  = t.Find("BtnClose");
        var btnCancel = t.Find("Footer/BtnCancel");
        if (btnClose  != null) { var b = btnClose.GetComponent<Button>();  if (b != null) b.onClick.AddListener(() => closeAction()); }
        if (btnCancel != null) { var b = btnCancel.GetComponent<Button>(); if (b != null) b.onClick.AddListener(() => closeAction()); }

        // 确认升级按钮
        var btnConfirm = t.Find("Footer/BtnConfirm");
        if (btnConfirm != null)
        {
            var b = btnConfirm.GetComponent<Button>();
            if (isMax)
            {
                SetPanelTMP(btnConfirm, "TxtLabel", "已满级");
                if (b != null) b.interactable = false;
            }
            else
            {
                SetPanelTMP(btnConfirm, "TxtLabel", "确认升级");
                if (b != null)
                {
                    b.interactable = true;
                    b.onClick.AddListener(() =>
                    {
                        DoUpgrade(buildId);
                        closeAction();
                    });
                }
            }
        }
    }

    // 测试场景升级逻辑：等级+1，刷新详情面板显示
    void DoUpgrade(int buildId)
    {
        var cfg      = BuildingCfgs[buildId];
        int curLevel = GetBuildingLevel(buildId);
        if (curLevel >= cfg.levelLimit)
        {
            Debug.LogWarning($"[ShipCabinDetailAnimator] DoUpgrade 拒绝：buildId={buildId} 已满级 lv={curLevel}/{cfg.levelLimit}");
            return;
        }

        int newLevel = curLevel + 1;
        _buildingLevels[buildId] = newLevel;

        Debug.Log($"[ShipCabinDetailAnimator] 升级成功 buildId={buildId} {curLevel}→{newLevel}/{cfg.levelLimit}");

        // 刷新详情面板的等级显示
        SetTMP("MainPanel/TitleBar/TxtLevel", newLevel + "级");

        // 满级时隐藏升级箭头按钮
        if (newLevel >= cfg.levelLimit)
        {
            var btnArrow = transform.Find("MainPanel/TitleBar/BtnUpgradeArrow");
            if (btnArrow != null) btnArrow.gameObject.SetActive(false);
        }
    }

    static void SetLayerRecursively(GameObject go, int layer)
    {
        go.layer = layer;
        for (int i = 0; i < go.transform.childCount; i++)
            SetLayerRecursively(go.transform.GetChild(i).gameObject, layer);
    }

    void CloseUpgradePanel()
    {
        if (_upgradePanelInst != null)
        {
            Destroy(_upgradePanelInst);
            _upgradePanelInst = null;
        }
    }

    // 在 panel 内按路径查找 TMP 并设置文本
    static void SetPanelTMP(Transform root, string path, string text)
    {
        var t = root.Find(path);
        if (t == null) return;
        var tmp = t.GetComponent<TextMeshProUGUI>();
        if (tmp != null) { tmp.text = text; return; }
        // 兼容旧 Text 组件
        var txt = t.GetComponent<UnityEngine.UI.Text>();
        if (txt != null) txt.text = text;
    }

    // ---------------------------------------------------------------
    // 升级费用静态数据（来自 Building_Levelup_Config 第1级）
    // ---------------------------------------------------------------

    // 资源图标路径常量
    private const string ResIconPath_Metal = "Assets/Landscape/Main/Sprites/ItemIcons/Common_icon_metal.png";

    struct UpgradeCostEntry
    {
        public string resName;
        public int    amount;
        public string resIconPath; // Assets 路径，Editor 模式下加载图标用
    }

    private static readonly System.Collections.Generic.Dictionary<int, UpgradeCostEntry[]>
        UpgradeCosts = new System.Collections.Generic.Dictionary<int, UpgradeCostEntry[]>
    {
        { 1,  new[]{ new UpgradeCostEntry{ resName="金属", amount=1000,  resIconPath=ResIconPath_Metal } }},
        { 2,  new[]{ new UpgradeCostEntry{ resName="金属", amount=2000,  resIconPath=ResIconPath_Metal } }},
        { 3,  new[]{ new UpgradeCostEntry{ resName="金属", amount=3000,  resIconPath=ResIconPath_Metal } }},
        { 4,  new[]{ new UpgradeCostEntry{ resName="金属", amount=4000,  resIconPath=ResIconPath_Metal } }},
        { 5,  new[]{ new UpgradeCostEntry{ resName="金属", amount=5000,  resIconPath=ResIconPath_Metal } }},
        { 6,  new[]{ new UpgradeCostEntry{ resName="金属", amount=6000,  resIconPath=ResIconPath_Metal } }},
        { 7,  new[]{ new UpgradeCostEntry{ resName="金属", amount=7000,  resIconPath=ResIconPath_Metal } }},
        { 8,  new[]{ new UpgradeCostEntry{ resName="金属", amount=8000,  resIconPath=ResIconPath_Metal } }},
        { 9,  new[]{ new UpgradeCostEntry{ resName="金属", amount=9000,  resIconPath=ResIconPath_Metal } }},
        { 10, new[]{ new UpgradeCostEntry{ resName="金属", amount=10000, resIconPath=ResIconPath_Metal } }},
        { 11, new[]{ new UpgradeCostEntry{ resName="金属", amount=11000, resIconPath=ResIconPath_Metal } }},
        { 12, new[]{ new UpgradeCostEntry{ resName="金属", amount=12000, resIconPath=ResIconPath_Metal } }},
    };

    // ---------------------------------------------------------------
    // 建筑配置静态数据（直接从 Building_Config.lua 提取，不依赖 Lua 运行时）
    // ---------------------------------------------------------------

    struct BuildingCfg
    {
        public string name;
        public int    levelLimit;
        public int    produceCD;    // 秒
        public int    productBase;  // 每次产出量
        public int    produceLimit; // 产出上限，0=无限
        public string productResId; // 产出资源ID字符串（如 "102002"）
    }

    // buildId 1~12，索引0占位
    // 字段来自 Building_Config.lua：列3=name, 列8=level_limit,
    //   列28=product(资源id), 列29=product_max("产出量,上限"), 列57=produce_cd, 列58=product_base
    private static readonly BuildingCfg[] BuildingCfgs = new BuildingCfg[]
    {
        default, // [0] 占位
        new BuildingCfg { name="聚变能源核心",     levelLimit=28, produceCD=30,  productBase=20, produceLimit=1000, productResId="102002" }, // 1
        new BuildingCfg { name="枢纽指挥中心",     levelLimit=8,  produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 2
        new BuildingCfg { name="全域最高指挥中枢", levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 3
        new BuildingCfg { name="食材仓库",         levelLimit=15, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 4
        new BuildingCfg { name="金属仓库",         levelLimit=15, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 5
        new BuildingCfg { name="电力仓库",         levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 6
        new BuildingCfg { name="零重力装配船坞A组",levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 7
        new BuildingCfg { name="零重力装配船坞B组",levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 8
        new BuildingCfg { name="零重力装配船坞C组",levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 9
        new BuildingCfg { name="零重力装配船坞D组",levelLimit=20, produceCD=0,   productBase=0,  produceLimit=0,    productResId="" },         // 10
        new BuildingCfg { name="矿石精炼阵列",     levelLimit=25, produceCD=60,  productBase=60, produceLimit=4743000, productResId="102002"}, // 11
        new BuildingCfg { name="能源采集舱",       levelLimit=21, produceCD=60,  productBase=60, produceLimit=4746000, productResId="102002"}, // 12
    };

    // ---------------------------------------------------------------
    // 数据刷新（直接读静态配置，测试场景无 Lua 运行时也能正确显示）
    // ---------------------------------------------------------------

    void RefreshDetailData(int buildId)
    {
        if (buildId < 1 || buildId >= BuildingCfgs.Length)
        {
            Debug.LogWarning("[ShipCabinDetailAnimator] Invalid buildId: " + buildId);
            return;
        }

        var cfg = BuildingCfgs[buildId];

        // --- 标题栏 ---
        SetTMP("MainPanel/TitleBar/TxtName",  cfg.name);
        // 读取当前运行时等级（首次为1级，升级后反映最新等级）
        int curLv = GetBuildingLevel(buildId);
        SetTMP("MainPanel/TitleBar/TxtLevel", curLv + "级");

        // --- 升级箭头按钮（未满级时显示）---
        var btnArrow = transform.Find("MainPanel/TitleBar/BtnUpgradeArrow");
        if (btnArrow != null)
            btnArrow.gameObject.SetActive(cfg.levelLimit > 1 && curLv < cfg.levelLimit);

        // --- 数据行 ---
        bool hasProduct = cfg.produceCD > 0 && cfg.productBase > 0;
        int outputPerHour = hasProduct
            ? Mathf.RoundToInt(cfg.productBase * (3600f / cfg.produceCD))
            : 0;

        SetTMP("MainPanel/DataRow/DataCol_0/TxtTime",
            hasProduct ? FormatSeconds(cfg.produceCD) : "--");
        SetTMP("MainPanel/DataRow/DataCol_1/TxtOutput",
            hasProduct ? FormatNumber(outputPerHour) + "/h" : "--");
        SetTMP("MainPanel/DataRow/DataCol_2/TxtLimit",
            hasProduct ? (cfg.produceLimit > 0 ? FormatNumber(cfg.produceLimit) : "∞") : "--");

        // --- 升级进度条（默认隐藏）---
        var upgradeBar = transform.Find("MainPanel/UpgradeBar");
        if (upgradeBar != null) upgradeBar.gameObject.SetActive(false);

        // --- 家具列表（每个建筑最多展示2件，静态数据来自 Furniture_Config）---
        var furniturePanel = transform.Find("MainPanel/FurniturePanel");
        if (furniturePanel != null)
        {
            var furnitures = BuildingFurnitures.ContainsKey(buildId)
                ? BuildingFurnitures[buildId]
                : new FurnitureCfg[0];

            for (int i = 1; i <= 2; i++)
            {
                var itemT = transform.Find("MainPanel/FurniturePanel/FurnitureItem_" + i);
                if (itemT == null) break;
                if (i - 1 < furnitures.Length)
                {
                    itemT.gameObject.SetActive(true);
                    var fur = furnitures[i - 1];
                    SetTMP(itemT, "TxtName",  fur.name);
                    SetTMP(itemT, "TxtLevel", "建筑Lv." + fur.unlockBuildLevel + "解锁");
                }
                else
                {
                    itemT.gameObject.SetActive(false);
                }
            }
            // 第3、4个槽位始终隐藏（只展示2件）
            for (int i = 3; i <= 4; i++)
            {
                var itemT = transform.Find("MainPanel/FurniturePanel/FurnitureItem_" + i);
                if (itemT != null) itemT.gameObject.SetActive(false);
            }
            furniturePanel.gameObject.SetActive(furnitures.Length > 0);
        }

        // --- BtnCollect 隐藏（无可领取产出）---
        var btnCollect = transform.Find("MainPanel/Footer/BtnCollect");
        if (btnCollect != null) btnCollect.gameObject.SetActive(false);

        // --- BtnUpgrade 隐藏（升级入口统一走右上角 BtnUpgradeArrow）---
        var btnUpgrade = transform.Find("MainPanel/Footer/BtnUpgrade");
        if (btnUpgrade != null) btnUpgrade.gameObject.SetActive(false);

        Debug.Log(string.Format("[ShipCabinDetail] buildId={0} name={1} cd={2}s output={3}/h limit={4}",
            buildId, cfg.name, cfg.produceCD, outputPerHour, cfg.produceLimit));
    }

    // ---------------------------------------------------------------
    // 辅助
    // ---------------------------------------------------------------

    void SetTMP(string path, string text)
    {
        var t = transform.Find(path);
        if (t == null) return;
        var tmp = t.GetComponent<TextMeshProUGUI>();
        if (tmp != null) tmp.text = text;
    }

    static string FormatSeconds(int seconds)
    {
        if (seconds <= 0) return "已完成";
        int d = seconds / 86400;
        int h = (seconds % 86400) / 3600;
        int m = (seconds % 3600)  / 60;
        int s = seconds % 60;
        if (d > 0) return string.Format("{0}天{1:D2}:{2:D2}:{3:D2}", d, h, m, s);
        if (h > 0) return string.Format("{0}时{1:D2}分{2:D2}秒",     h, m, s);
        if (m > 0) return string.Format("{0}分{1:D2}秒",             m, s);
        return s + "秒";
    }

    static string FormatNumber(int num)
    {
        if (num >= 100000000) return string.Format("{0:F1}亿", num / 100000000f);
        if (num >= 10000)     return string.Format("{0:F1}万", num / 10000f);
        return num.ToString();
    }

    public void Hide()
    {
        if (_panelRT == null) { gameObject.SetActive(false); return; }
        _DoHide(null);
    }

    /// <summary>
    /// 播放关闭动画，结束后执行回调（Lua 侧用于在动画结束后调 DestroyWindow）。
    /// </summary>
    public void HideWithCallback(System.Action onFinished)
    {
        if (_panelRT == null) { gameObject.SetActive(false); onFinished?.Invoke(); return; }
        _DoHide(onFinished);
    }

    void _DoHide(System.Action onFinished)
    {
        DOTween.Kill(_panelRT);
        DOTween.Kill(_bgImage);
        _isAnimating = true;

        // 滑出终点同样基于停靠位置，不能写死 x=0/y=-h
        var endPos = new Vector2(_panelRestPos.x, _panelRestPos.y - _panelHeight);
        _panelRT.DOAnchorPos(endPos, slideOutDuration)
            .SetEase(Ease.InCubic)
            .OnComplete(() =>
            {
                _isAnimating = false;
                gameObject.SetActive(false);
                if (_cabinPreview != null) _cabinPreview.SetActive(true);
                onFinished?.Invoke();
            });

        if (_bgImage != null)
            _bgImage.DOFade(0f, slideOutDuration).SetEase(Ease.InCubic);
    }

    // SetTMP 重载：在指定的父 Transform 下查找子节点
    void SetTMP(Transform parent, string childName, string text)
    {
        var t = parent.Find(childName);
        if (t == null) return;
        var tmp = t.GetComponent<TextMeshProUGUI>();
        if (tmp != null) tmp.text = text;
    }

    // ---------------------------------------------------------------
    // 家具静态数据（来自 Furniture_Config，每个建筑取前2件）
    // ---------------------------------------------------------------

    struct FurnitureCfg
    {
        public string name;
        public int    unlockBuildLevel;
    }

    private static readonly System.Collections.Generic.Dictionary<int, FurnitureCfg[]>
        BuildingFurnitures = new System.Collections.Generic.Dictionary<int, FurnitureCfg[]>
    {
        { 1,  new[]{ new FurnitureCfg{ name="环形操作台",                   unlockBuildLevel=1 },
                     new FurnitureCfg{ name="沉浸式监控席位",               unlockBuildLevel=1 } }},
        { 2,  new[]{ new FurnitureCfg{ name="巨型球形全息投影系统",         unlockBuildLevel=1 },
                     new FurnitureCfg{ name="阶梯式弧形多屏联动操作台阵列", unlockBuildLevel=1 } }},
        { 3,  new[]{ new FurnitureCfg{ name="超大型全域全息战略中枢球",     unlockBuildLevel=1 },
                     new FurnitureCfg{ name="全域协同操控台",               unlockBuildLevel=1 } }},
        { 4,  new[]{ new FurnitureCfg{ name="重型金属货架",                 unlockBuildLevel=1 },
                     new FurnitureCfg{ name="温控集装箱",                   unlockBuildLevel=1 } }},
        { 5,  new[]{ new FurnitureCfg{ name="大型露天物料斗",               unlockBuildLevel=1 },
                     new FurnitureCfg{ name="门式起重机",                   unlockBuildLevel=1 } }},
        { 6,  new[]{ new FurnitureCfg{ name="黑色超级电容柜",               unlockBuildLevel=1 },
                     new FurnitureCfg{ name="高压配电柜",                   unlockBuildLevel=1 } }},
        { 7,  new[]{ new FurnitureCfg{ name="机械臂",                       unlockBuildLevel=1 },
                     new FurnitureCfg{ name="激光扫描仪",                   unlockBuildLevel=1 } }},
        { 11, new[]{ new FurnitureCfg{ name="巨型等离子熔炼炉",             unlockBuildLevel=1 },
                     new FurnitureCfg{ name="矿石传送带",                   unlockBuildLevel=1 } }},
        { 12, new[]{ new FurnitureCfg{ name="光子捕捉网阵列",               unlockBuildLevel=1 },
                     new FurnitureCfg{ name="电压转换器柜",                 unlockBuildLevel=1 } }},
    };

}
