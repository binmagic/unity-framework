using System;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.UI;


public class UIScrollBase<T> where T : class
{
    public Transform content;
    public UIScrollController uiScroController;
    /// <summary>
    /// 当前出现在 Hierarchy 面板中的对象
    /// </summary>
    protected Dictionary<UIScrollItem, List<GameObject>> gameObjectsPerLine;
    protected List<T> dataList;
    private ScrollRect scroRect;

    /// <summary>
    /// 每行的cell数量
    /// </summary>
    private int numPerLine;
    /// <summary>
    /// 需要显示的行数
    /// </summary>
    private int viewCount;
    /// <summary>
    /// 每行之间的距离
    /// </summary>
    private float cellPadiding;
    /// <summary>
    /// 行高
    /// </summary>
    private float cellHeight;
    /// <summary>
    /// 行宽
    /// </summary>
    private float cellWidth;

    public Action<Vector2> onValueChanged;

    /// <summary>
    /// 给Item中的组建添加监听事件，如果有必要；添加事件前，先移除事件
    /// gameobject对应数据的获取：
    /// 绑定的数据可以通过将对象的名字ToInt()获得索引idx,然后调用GetDataByIndex(idx)在外部获取数据
    /// example:
    ///  btn.onClick.AddListener(() => {
    ///  int idx = obj.name.ToInt();
    ///  T data = UIScrollBase.GetDataByIndex(idx);
    ///  });
    /// </summary>
    public Action<GameObject> addListenerEvent;
    /// <summary>
    /// 根据传入的数据和对象刷新Item
    /// </summary>
    public Action<T, GameObject> freshEvent;

    #region Methods

    public GameObject GetFirstGameObjectByIndex()
    {
        GameObject ret = null;
        if (content.childCount > 0)
        {
            if (content.Find("Scroll0/0"))
            {
                ret = content.Find("Scroll0/0").gameObject;
            }
        }
        return ret;
    }
    public GameObject GetGameObjectByIndex(int idx)
    {
        GameObject ret = null;
        if (content.childCount > 0)
        {
            string str = string.Format("Scroll{0}/{1}", idx, idx);
            if (content.Find(str))
            {
                ret = content.Find(str).gameObject;
            }
        }
        return ret;
    }
    /// <summary>
    /// 在Start之前，先初始化参数设置
    /// </summary>
    /// <param name="content"></param>
    /// <param name="data">需要创建的数据列表</param>
    /// <param name="sr">ScrollRect组件</param>
    /// <param name="itemPrefab">动态创建的预设</param>
    /// <param name="rect">预设的宽度和高度</param>
    /// <param name="numPerLine">每个预设的cell数量</param>
    /// <param name="viewCount">需要显示的Item数</param>
    /// <param name="cellPadiding">每个Item之间的距离</param>
    public virtual void InitArguments(List<T> data, ScrollRect sr, Transform content, GameObject itemPrefab,
        Vector2 rect, int numPerLine, int viewCount = 6, float cellPadiding = 10)
    {
        gameObjectsPerLine = new Dictionary<UIScrollItem, List<GameObject>>();
        this.content = content;
        dataList = data;
        scroRect = sr;
        if (itemPrefab.GetComponent<UIScrollController>() == null)
            uiScroController = scroRect.gameObject.AddComponent<UIScrollController>();
        uiScroController.content = this.content.GetComponent<RectTransform>();//.rectTransform();
        uiScroController.movement = UIScrollController.Arrangement.Vertical;
        if (itemPrefab.GetComponent<UIScrollItem>() == null)
            itemPrefab.AddComponent<UIScrollItem>();
        uiScroController.itemPrefab = itemPrefab;

        this.numPerLine = numPerLine;
        this.viewCount = viewCount;
        this.cellPadiding = cellPadiding;
        cellHeight = rect.y;
        cellWidth = rect.x;
    }

    public virtual void SetItemPrefab(GameObject go)
    {
        uiScroController.itemPrefab = go;
    }

    public List<T> GetDataList()
    {
        return dataList;
    }

    /// <summary>
    /// 重新设置数据列表
    /// </summary>
    public void ReSetDataList(List<T> newList)
    {
        if (newList == null)
        {
            throw new NotImplementedException("传入的数据为null");
        }
        dataList = newList;
        uiScroController.DataCount = dataList.Count;
    }

    /// <summary>
    /// 设置移动的方向 type == 0 :Vertical  type == 1 :Horizontal
    /// </summary>
    /// <param name="type">
    /// type == 0 :Vertical
    /// type == 1 :Horizontal
    /// </param>
    public void SetArrangement(int type)
    {
        switch (type)
        {
            case 0:
                uiScroController.movement = UIScrollController.Arrangement.Vertical;
                break;
            case 1:
                uiScroController.movement = UIScrollController.Arrangement.Horizontal;
                break;
            default:
                break;
        }
    }

    /// <summary>
    /// 开始动态创建
    /// </summary>
    public void Start()
    {
        uiScroController.OnInitItem += OnInitItem;

        float f = (float)dataList.Count * 1.0f / numPerLine;
        int itemCount = Mathf.CeilToInt(f);

        uiScroController.viewCount = viewCount;
        uiScroController.cellPadiding = cellPadiding;
        uiScroController.cellHeight = cellHeight;
        uiScroController.cellWidth = cellWidth;

        uiScroController.Init(itemCount, scroRect);
        uiScroController.OnAddItem += OnAddItem;
        uiScroController.OnRemoveItem += OnRemoveItem;
        uiScroController.OnDelItem += OnDelItem;
        uiScroController.OnValueChanged += OnValueChanged;
    }

    /// <summary>
    /// 根据索引获取数据
    /// </summary>
    /// <param name="index"></param>
    /// <returns></returns>
    public T GetDataByIndex(int index)
    {
        //SystemDebuger.DebugMgr.Log("index == " + index);
        if (index >= 0 && index < dataList.Count)
        {
            T data = dataList[index];
            return data;
        }
        else
        {
            throw new NotImplementedException("index out of range --> index == " + index + " ; range" + 0 + "," + dataList.Count);
        }
    }
    //不可使用
    public void ResetScrollList(List<T> newList)
    {
        if (newList == null)
        {
            GameFramework.Log.Debug("newList == null");
        }

        int tempLine = Mathf.FloorToInt(dataList.Count / numPerLine);
        int originalLines = dataList.Count % numPerLine == 0 ? tempLine : tempLine + 1;

        int newTempLine = Mathf.FloorToInt(newList.Count / numPerLine);
        int latestLines = newList.Count % numPerLine == 0 ? newTempLine : newTempLine + 1;

        if (originalLines > latestLines)
        {
            //减少行数
            int deleteLines = originalLines - latestLines;
            //判断是否需要 Delete Item Form Panel
            if (latestLines >= viewCount)
            {
                uiScroController.DataCount -= deleteLines;
                dataList = newList;
                TryLocation(0);
            }
            else
            {
                int deleteItemNum = 0;
                if (originalLines >= viewCount)
                {
                    deleteItemNum = viewCount - latestLines;
                }
                else
                {
                    deleteItemNum = originalLines - latestLines;
                }

                List<int> currentShowIndexList = new List<int>();
                for (int i = 0; i < uiScroController.itemList.Count; i++)
                {
                    GameObject itemGo = uiScroController.itemList[i].gameObject;
                    int r = 0;
                    int.TryParse(itemGo.name.Replace("Scroll", string.Empty), out r);
                    currentShowIndexList.Add(r);
                }

                currentShowIndexList.Sort((x, y) =>
                {
                    if (x > y) return 1;
                    else if (x < y) return -1;
                    else return 0;
                });

                //for (int i = 0; i < currentShowIndexList.Count; i++)
                //{
                //    UnityEngine.Debug.Log(currentShowIndexList[i]);
                //}

                for (int i = 0; i < deleteItemNum; i++)
                {
                    uiScroController.DelItem(currentShowIndexList[i]);
                }
            }
        }
    }

    public void ClearController()
    {
        if (content != null)
        {
            Vector2 pos = uiScroController.content.anchoredPosition;
            pos.x = Mathf.Abs(uiScroController.GetPosition(0).x);
            pos.y = Mathf.Abs(uiScroController.GetPosition(0).y);
            uiScroController.content.anchoredPosition = pos;

            //TryLocation(0);
            scroRect.enabled = true;
            for (int i = 0; i < content.childCount; i++)
            {
                GameObject.Destroy(content.GetChild(i).gameObject);
            }
            content.DetachChildren();
        }
        if (uiScroController != null)
        {
            uiScroController.RemoveScript();
            uiScroController = null;
        }
    }

    public void TryRefreshShowUI()
    {
        int startsWith = uiScroController.currentPosIndex;    //当前UIRoleItemModel第一行
        TryRefreshUIData(startsWith, content);
    }

    /// <summary>
    /// 根据索引插入一条角色信息
    /// </summary>
    /// <param name="idx">非UIScrollItem的索引,RoleInfos列表的索引</param>
    public void InsertByIndex(int idx, T insertItem)
    {
        if (uiScroController.currentPosIndex == -1)
        {
            uiScroController.currentPosIndex = 0;
        }
        int startsWith = uiScroController.currentPosIndex;//当前显示UIRoleItemModel第一行
        if (dataList.Count % numPerLine == 0)
        {
            dataList.Insert(idx, insertItem);//插入到当前索引。
            //Log(" 需要另起行" + " startsWith=" + startsWith + " beforeCount=" + beforeCount + " afterCount" + afterCount);
            if (uiScroController.DataCount < uiScroController.viewCount)
            {
                //SystemDebuger.DebugMgr.Log("2222222222222");
                int insertPosIndex = uiScroController.DataCount;
                UIScrollItem uiItemScroll = uiScroController.AddItem(insertPosIndex);
                if (!gameObjectsPerLine.ContainsKey(uiItemScroll))
                {
                    //插入的这行 是直接插入到末尾并尝试刷新数据 
                    SingeItemMap(dataList.Count - 1, uiItemScroll);
                }
                else
                {
                    SingeItemMap(dataList.Count - 1, uiItemScroll, gameObjectsPerLine[uiItemScroll]);
                }
            }
            else
            {
                //SystemDebuger.DebugMgr.Log("DataCount == " + uiScroController.DataCount + "      viewCount ==" + uiScroController.viewCount);

                uiScroController.DataCount += 1;
            }

            TryRefreshUIData(startsWith, content);
        }
        else
        {
            //直接插入到RoleInfo集合中
            if (idx < dataList.Count)
            {
                //插到指定位置
                dataList.Insert(idx, insertItem);
            }
            else
            {
                //放到末尾
                dataList.Add(insertItem);
            }
            TryRefreshUIData(startsWith, content);
        }
    }

    public int GetCurrentPosIndex
    {
        get
        {
            return uiScroController.currentPosIndex;
        }
    }

    /// <summary>
    /// 追加
    /// </summary>
    public void AppendInsert(List<T> insertList)
    {
        Debug.LogErrorFormat("AppendInsert GetCurrentPosIndex={0}", GetCurrentPosIndex);
        InsertByIndex(GetCurrentPosIndex, insertList);
    }

    /// <summary>
    /// 整块的插入
    /// </summary>
    /// <param name="startIdx">需要插入的位置</param>
    /// <param name="insertList">数据块</param>
    public void InsertByIndex(int startIdx, List<T> insertList)
    {
        int startsWith = 0;
        for (int i = 0; i < insertList.Count; i++)
        {
            var insertItem = insertList[insertList.Count - 1 - i];
            if (uiScroController.currentPosIndex == -1)
            {
                uiScroController.currentPosIndex = 0;
            }
            startsWith = uiScroController.currentPosIndex;
            if (dataList.Count % numPerLine == 0)
            {
                dataList.Insert(startIdx, insertItem);
                if (uiScroController.DataCount < uiScroController.viewCount)
                {
                    UIScrollItem uiItemScroll = uiScroController.AddItem(uiScroController.DataCount);
                    if (!gameObjectsPerLine.ContainsKey(uiItemScroll))
                    {
                        SingeItemMap(dataList.Count - 1, uiItemScroll);
                    }
                    else
                    {
                        SingeItemMap(dataList.Count - 1, uiItemScroll, gameObjectsPerLine[uiItemScroll]);
                    }
                }
                else
                {
                    uiScroController.DataCount += 1;
                }
            }
            else
            {
                if (startIdx < dataList.Count)
                {
                    dataList.Insert(startIdx, insertItem);
                }
                else
                {
                    dataList.Add(insertItem);
                }
            }
        }
        TryRefreshUIData(startsWith, content);
    }

    /// <summary>
    /// 根据索引删除一条信息
    /// </summary>
    /// <param name="idx">非UIScrollItem的索引,RoleInfos列表的索引</param>
    public void RemoveByIdx(int idx)
    {
        uiScroController.currentPosIndex = uiScroController.currentPosIndex == -1 ? 0 : uiScroController.currentPosIndex;
        int startsWith = uiScroController.currentPosIndex;
        Remove(idx);
        TryRefreshUIData(startsWith, content);
    }

    /// <summary>
    /// 根据索引列表删除多条索引信息
    /// </summary>
    /// <param name="idxList"></param>
    public void RemoveByIdx(List<int> idxList)
    {
        var tmp = idxList.OrderByDescending(e => e).ToList();
        //tmp.ForEach(v => Debug.LogWarning("idx = " + v));
        int startsWith = 0;
        for (int i = 0; i < tmp.Count; i++)
        {
            uiScroController.currentPosIndex = uiScroController.currentPosIndex == -1 ? 0 : uiScroController.currentPosIndex;
            startsWith = uiScroController.currentPosIndex;
            Remove(tmp[i]);
        }
        TryRefreshUIData(startsWith, content);
    }

    private void Remove(int idx)
    {
        dataList.RemoveAt(idx);

        if (dataList.Count % numPerLine == 0)
        {
            if (uiScroController.DataCount <= uiScroController.viewCount)
            {
                int lastPosIndex = uiScroController.DataCount - 1;
                uiScroController.DelItem(lastPosIndex);
            }
            else
            {
                uiScroController.DataCount -= 1;
            }
        }
    }

    /// <summary>
    /// 尝试根据索引进行定位
    /// </summary>
    public void TryLocation(int idx)
    {
        //Debug. Log("idx=" + idx + " roleInfos.Count=" + dataList. Count);
        //需要根据idx 算出它在第几行
        if (dataList.Count == 0)
        {
            return;
        }
        if (idx < dataList.Count)
        {
            int itemIndex = idx == 0 ? 0 : Mathf.CeilToInt(idx / numPerLine) - 1;//得到行数索引
            Vector2 pos = uiScroController.content.anchoredPosition;
            pos.x = Mathf.Abs(uiScroController.GetPosition(itemIndex).x);
            pos.y = Mathf.Abs(uiScroController.GetPosition(itemIndex).y);
            uiScroController.content.anchoredPosition = pos;
            //scrollRect.movementType = ScrollRect.MovementType.Unrestricted;
            uiScroController.OnValueChange(pos);
            TryRefreshShowUI();
            //scrollRect.movementType = ScrollRect.MovementType.Elastic;
            //Debug. Log("idx=" + idx + " itemIndex=" + itemIndex + " pos=" + pos);
        }
    }

    /// <summary>
    /// 尝试更新UI数据
    /// </summary>
    /// <param name="startsWith">UIScrollItem起始行</param>
    /// <param name="content">content</param>
    private void TryRefreshUIData(int startsWith, Transform content)
    {
        for (int i = 0; i < uiScroController.viewCount; i++)
        {
            int tempIdx = startsWith + i;
            string childName = "Scroll" + tempIdx;

            Transform scrollTrans = content.Find(childName);
            if (scrollTrans != null)
            {
                UIScrollItem scrollItem = scrollTrans.GetComponent<UIScrollItem>();
                if (gameObjectsPerLine.ContainsKey(scrollItem))
                {
                    List<GameObject> cellList = gameObjectsPerLine[scrollItem];
                    //int uiModelIndex = tempIdx * numPerLine;

                    //SystemDebuger.DebugMgr.Log("scroll name == " + scrollItem.transform.name + "    cell count == " + cellList.Count);

                    for (int j = 0; j < cellList.Count; j++)
                    {
                        GameObject cellGo = cellList[j];
                        int cellIdx = tempIdx * numPerLine + j;

                        //SystemDebuger.DebugMgr.Log("cellIdx == " + cellIdx);

                        T cellData = default(T);

                        //SystemDebuger.DebugMgr.LogError(uiMagicModel.name);

                        cellGo.name = cellIdx.ToString();

                        if (cellIdx < dataList.Count)
                        {
                            cellData = dataList[cellIdx];

                            if (freshEvent != null)
                            {
                                freshEvent(cellData, cellGo);
                                cellGo.SetActive(true);
                            }
                            //uiRoleItemModel. levelTxt. text = roleInfoIndex. ToString();
                        }
                        else
                        {
                            cellGo.SetActive(false);
                            cellGo.name = "[Hiding]";
                        }
                    }
                }
                else
                {
                    Debug.LogWarning("uiMagicItemModelDic. ContainsKey(scrollItem) ===== " + false.ToString());
                }
            }
        }
    }

    /// <summary>
    /// 根据单个UIScrollItem映射并刷新 UIMagicItemModel 数据
    /// </summary>
    /// <param name="startIdxPerLine">行ID</param>
    /// <param name="scrollItem"></param>
    /// <param name="gos"></param>
    private void SingeItemMap(int startIdxPerLine, UIScrollItem scrollItem, List<GameObject> gos = null)
    {
        GameObject lineGo = scrollItem.gameObject;
        int count = lineGo.transform.childCount;
        GameObject cellGo = null;
        for (int j = 0; j < count; j++)
        {
            //string childName = "Item" + (j + 1);
            Transform cell = null;
            if (gos == null)
            {
                //itemModel = new GameObject();
                cell = lineGo.transform.GetChild(j);
                //if (cell == null)
                //{
                //   UnityEngine.Debug.LogError(lineGo.name + "  " + "not find childName !!!=" + childName);
                //}

                cellGo = cell.gameObject;

                if (addListenerEvent != null)
                {
                    addListenerEvent(cellGo);
                }
                //监听事件绑定完成之后显示
                //cellGo.SetActive(true);
            }
            else
            {
                cellGo = gos[j];
                cell = cellGo.transform;
            }

            int idx = j + startIdxPerLine;
            cell.name = idx.ToString();
            T cellData = default(T);

            if (idx < dataList.Count)
            {
                cellData = dataList[idx];
                if (freshEvent != null)
                {
                    freshEvent(cellData, cell.gameObject);
                    cell.gameObject.SetActive(true);
                }
            }
            else
            {
                //判断第一个是否有数据
                if (j == 0)
                {
                    lineGo.SetActive(false);

                }
                else
                {
                    cellGo.SetActive(false);
                }
            }

            EntryContainer(scrollItem, cellGo);

            //if (gameObjectsPerLine.ContainsKey(scrollItem))
            //{
            //    //避免重复添加
            //    if (cellGos == null)
            //    {
            //        gameObjectsPerLine[scrollItem].Add(cellGo);
            //    }
            //}
            //else
            //{
            //    gameObjectsPerLine[scrollItem] = new List<GameObject>();
            //    gameObjectsPerLine[scrollItem].Add(cellGo);
            //}
        }
    }

    private void EntryContainer(UIScrollItem scrollItem, GameObject cellGo)
    {
        if (gameObjectsPerLine.ContainsKey(scrollItem))
        {
            if (!gameObjectsPerLine[scrollItem].Contains(cellGo))
            {
                gameObjectsPerLine[scrollItem].Add(cellGo);
            }
        }
        else
        {
            gameObjectsPerLine[scrollItem] = new List<GameObject>();
            gameObjectsPerLine[scrollItem].Add(cellGo);
        }

        if (!cellGo.activeSelf)
        {
            cellGo.name = "[Hiding]";
        }

        if (!scrollItem.gameObject.activeSelf)
        {
            scrollItem.gameObject.name = "[Hiding]";
        }
    }

    #region UIScrollItem 回调

    /// <summary>
    /// UIScrollItem 初始完毕回调
    /// </summary>
    /// <param name="items"></param>
    private void OnInitItem(List<UIScrollItem> items)
    {
        int rowId = 0;
        for (int i = 0; i < items.Count; i++)
        {
            SingeItemMap(rowId, items[i]);
            rowId += numPerLine;
        }
    }

    /// <summary>
    /// 删除单个UIScrollItem回调 不回收
    /// </summary>
    /// <param name="arg1">UIScrollItem</param>
    private void OnDelItem(UIScrollItem arg1)
    {
        if (gameObjectsPerLine.ContainsKey(arg1))
        {
            gameObjectsPerLine.Remove(arg1);
        }
    }

    /// <summary>
    /// 添加单个UIScrollItem回调
    /// </summary>
    /// <param name="arg1"></param>
    private void OnAddItem(UIScrollItem arg1)
    {
        if (!gameObjectsPerLine.ContainsKey(arg1))
        {
            //之所以加这个判断,两种情况
            //1.OnAddItem事件一个是当我们自己直接调用生成时,例如没有达到6行时调用,会被添加到uiRoleItemModelDic
            //2.当UIScrollControll自己调用时,_unUsedQueue 没有库存时，会新增那么这个时候uiRoleItemModelDic里是不存在的
            //SystemDebuger.DebugMgr.LogError("不存在 UIScrollItem=" + arg1.name);
            SingeItemMap(dataList.Count - 1, arg1);
        }
        if (uiScroController.currentPosIndex == -1)
        {
            uiScroController.currentPosIndex = 0;
        }
        int startsWith = uiScroController.currentPosIndex;//当前UIRoleItemModel第一行
        TryRefreshUIData(startsWith, content);
        //SystemDebuger.DebugMgr.Log(arg1.Index + " 新插入一行=" + arg1.name);
    }

    /// <summary>
    /// 去除单个UIScrollItem回调 可回收
    /// </summary>
    /// <param name="arg1">arg1</param>
    private void OnRemoveItem(UIScrollItem arg1)
    {
        //SystemDebuger.DebugMgr.Log(arg1.Index + "销毁一行 =" + arg1.name);
        if (uiScroController.currentPosIndex == -1)
        {
            uiScroController.currentPosIndex = 0;
        }
        int startsWith = uiScroController.currentPosIndex;//当前UIRoleItemModel第一行
        TryRefreshUIData(startsWith, content);
    }

    private void OnValueChanged(Vector2 pos)
    {
        if (onValueChanged != null)
            onValueChanged(pos);
    }
    #endregion

    #endregion
}





