using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace GameKit.Base
{
    [System.Serializable]
    public class ItemWrap 
    {
        public GameObject prefab;
        public object userdata;
    }

    [RequireComponent(typeof(ScrollRect))]
    public class UnlimitedScrollView : MonoBehaviour
    {
        private ScrollRect scroll;
        private readonly List<ItemWrap> wraps = new List<ItemWrap>();
        private readonly Dictionary<ItemWrap, GameObject> items = new Dictionary<ItemWrap, GameObject>();

        private HorizontalOrVerticalLayoutGroup group;
        private float spacing;
        private bool inited;
        private bool beginDrag;
        private Vector2 beginDragPosition;

        [SerializeField]
        private int headIndex;
        [SerializeField]
        private int tailIndex = -1;

        private bool toHead;
        private bool toTail;

        public delegate void DragOnHeadOrTailOfTheScrollViewDelegate(int d);
        public delegate void OnPointerDownScrollViewDelegate();
        public delegate void BeginDragDelegate(int head, int tail);

        public DragOnHeadOrTailOfTheScrollViewDelegate DragOnHeadOrTailOfTheScrollView;
        public OnPointerDownScrollViewDelegate OnPointerDownScrollView;
        public BeginDragDelegate OnBeginDrag;

        public delegate void ItemMoveInDelegate(GameObject itemObj, object userData);
        public delegate void ItemMoveOutDelegate(GameObject itemObj, object userData);

        public ItemMoveInDelegate OnItemMoveIn;
        public ItemMoveOutDelegate OnItemMoveOut;

        public int HeadIndex
        {
            get
            {
                return headIndex;
            }
        }

        public int TailIndex
        {
            get
            {
                return tailIndex;
            }
        }

        public bool ToHead
        {
            set
            {
                toHead = value;
                toTail &= !toHead;
            }
        }
        public bool ToTail
        {
            set
            {
                toTail = value;
                toHead &= !toTail;
            }
        }

        public Vector2 ViewportSize
        {
            get
            {
                return scroll.viewport.rect.size;
            }
        }

        public Vector2 ContentSize
        {
            get
            {
                return scroll.content.rect.size;
            }
        }

        public Vector2 ContentPosition
        {
            get
            {
                return scroll.content.anchoredPosition;
            }
            set
            {
                scroll.content.anchoredPosition = value;
            }
        }

        public Vector2 Velocity
        {
            get
            {
                return scroll.velocity;
            }
            set
            {
                scroll.velocity = value;
            }
        }

        private void Update()
        {
            if (!inited)
            {
                Initialize();
                return;
            }

            if (toTail && tailIndex < wraps.Count - 1)
            {
                CreateItem(wraps[++tailIndex]);
            }

            if (toHead && headIndex > 0)
            {
                GameObject go = CreateItem(wraps[--headIndex]);
                go?.transform.SetAsFirstSibling();
            }

            if (toHead)
            {
                if (scroll.vertical)
                    scroll.verticalNormalizedPosition = 1;
                else if (scroll.horizontal)
                    scroll.horizontalNormalizedPosition = 0;
            }

            if (toTail)
            {
                if (scroll.vertical)
                    scroll.verticalNormalizedPosition = 0;
                else if (scroll.horizontal)
                    scroll.horizontalNormalizedPosition = 1;
            }

            if ((scroll.vertical && ContentSize.y < ViewportSize.y) || (scroll.horizontal && ContentSize.x < ViewportSize.x))
            {
                if (headIndex > 0)
                {
                    GameObject go = CreateItem(wraps[--headIndex]);
                    go?.transform.SetAsFirstSibling();
                }
                else if (tailIndex < wraps.Count - 1)
                {
                    CreateItem(wraps[++tailIndex]);
                }
            }
        }

        private void Awake()
        {
            scroll = GetComponent<ScrollRect>();

            if (scroll.vertical != scroll.horizontal)
            {
                if (scroll.vertical)
                {
                    group = scroll.content.GetComponent<VerticalLayoutGroup>();
                }
                else if (scroll.horizontal)
                {
                    group = scroll.content.GetComponent<HorizontalLayoutGroup>();
                }

                if (group == null)
                {
                    Debug.LogError("Only support HorizontalOrVerticalLayoutGroup in UnlimitedScrollView component, you can use UnlimitedScrollGrid or other component to support your custom style.");
                    enabled = false;
                    return;
                }

                spacing = group.spacing;
            }
            else
            {
                Debug.LogError("Vertical or Horizontal must be different in UnlimitedScrollView component for now");
                enabled = false;
                return;
            }

            if (scroll.horizontalScrollbar != null)
                scroll.horizontalScrollbar.gameObject.SetActive(false);
            if (scroll.verticalScrollbar != null)
                scroll.verticalScrollbar.gameObject.SetActive(false);
        }

        private void OnEnable()
        {
            scroll.onValueChanged.AddListener(OnValueChanged);
        }

        private void OnDisable()
        {
            scroll.onValueChanged.RemoveListener(OnValueChanged);
            Clear();
        }

        private void OnPointerDown()
        {
            OnPointerDownScrollView?.Invoke();
        }

        private void OnDragBegin()
        {
            beginDrag = true;
            beginDragPosition = scroll.normalizedPosition;

            toTail = false;
            toHead = false;

            OnBeginDrag?.Invoke(headIndex, tailIndex);
        }

        private void OnDragEnd()
        {
            beginDrag = false;

            if (scroll.vertical)
            {
                if (scroll.normalizedPosition.y - beginDragPosition.y > 0.1f && scroll.normalizedPosition.y > 1 && headIndex == 0)
                {
                    DragOnHeadOrTailOfTheScrollView?.Invoke(1);
                }
                else if (beginDragPosition.y - scroll.normalizedPosition.y > 0.1f && scroll.normalizedPosition.y < 0 && tailIndex == wraps.Count - 1)
                {
                    DragOnHeadOrTailOfTheScrollView?.Invoke(0);
                }
                else
                {
                    OnValueChanged(scroll.normalizedPosition);
                }
            }
            else if (scroll.horizontal)
            {
                if (scroll.normalizedPosition.x - beginDragPosition.x > 0.1f && scroll.normalizedPosition.x > 1 && headIndex == 0)
                {
                    DragOnHeadOrTailOfTheScrollView?.Invoke(1);
                }
                else if (beginDragPosition.x - scroll.normalizedPosition.x > 0.1f && scroll.normalizedPosition.x < 0 && tailIndex == wraps.Count - 1)
                {
                    DragOnHeadOrTailOfTheScrollView?.Invoke(0);
                }
                else
                {
                    OnValueChanged(scroll.normalizedPosition);
                }
            }
        }

        private void Initialize()
        {
            if (ViewportSize == Vector2.zero)
                return;


            if (scroll.vertical)
            {
                InitVertical();
            }
            else if (scroll.horizontal)
            {
                InitHorizontal();
            }

            inited = true;
        }

        private void InitVertical()
        {
            Vector2 CalcContentSize = new Vector2(group.padding.left + group.padding.right, group.padding.top + group.padding.bottom);
            if (toTail)
            {
                tailIndex = wraps.Count - 1;
                for (int i = tailIndex; i >= 0; --i)
                {
                    if (CalcContentSize.y < ViewportSize.y)
                    {
                        headIndex = i;
                        GameObject go = CreateItem(wraps[i]);
                        if (go != null)
                        {
                            go.transform.SetAsFirstSibling();
                            CalcContentSize = new Vector2(CalcContentSize.x, CalcContentSize.y + go.GetComponent<RectTransform>().rect.size.y);
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            else
            {
                headIndex = 0;
                for (int i = 0; i < wraps.Count; ++i)
                {
                    if (CalcContentSize.y <= ViewportSize.y)
                    {
                        tailIndex = i;
                        GameObject go = CreateItem(wraps[i]);
                        if (go != null)
                            CalcContentSize = new Vector2(CalcContentSize.x, CalcContentSize.y + go.GetComponent<RectTransform>().rect.size.y);
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }

        private void InitHorizontal()
        {
            Vector2 CalcContentSize = new Vector2(group.padding.left + group.padding.right, group.padding.top + group.padding.bottom);
            if (toTail)
            {
                tailIndex = wraps.Count - 1;
                for (int i = tailIndex; i >= 0; --i)
                {
                    if (CalcContentSize.x < ViewportSize.x)
                    {
                        headIndex = i;
                        GameObject go = CreateItem(wraps[i]);
                        if (go != null)
                        {
                            go.transform.SetAsFirstSibling();
                            CalcContentSize = new Vector2(CalcContentSize.x + go.GetComponent<RectTransform>().rect.size.x, CalcContentSize.y);
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            else
            {
                headIndex = 0;
                for (int i = 0; i < wraps.Count; ++i)
                {
                    if (CalcContentSize.x <= ViewportSize.x)
                    {
                        tailIndex = i;
                        GameObject go = CreateItem(wraps[i]);
                        if (go != null)
                            CalcContentSize = new Vector2(CalcContentSize.x + go.GetComponent<RectTransform>().rect.size.x, CalcContentSize.y);
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }

        public void Clear()
        {
            inited = false;
            beginDrag = false;
            headIndex = 0;
            tailIndex = -1;

            wraps.Clear();

            foreach (var v in items)
            {
                if (v.Value == null)
                {
                    continue;
                }
                
                OnItemMoveOut?.Invoke(v.Value, v.Key.userdata);
                
                v.Value.Recycle();
            }
            items.Clear();
        }

        public int GetItemWrapCount()
        {
            return wraps.Count;
        }

        public GameObject GetItem(ItemWrap wrap)
        {
            if (items.TryGetValue(wrap, out GameObject go))
                return go;

            return null;
        }

        public ItemWrap GetItemWrap(object userdata)
        {
            return wraps.Find(p => p.userdata == userdata);
        }

        public ItemWrap GetItemWrap(int index)
        {
            if (index < 0 || index >= wraps.Count)
                return null;

            return wraps[index];
        }

        public void AddItemWrap(GameObject prefab, object userdata)
        {
            wraps.Add(new ItemWrap { prefab = prefab, userdata = userdata });
        }

        public void InsertItemWrap(int index, GameObject prefab, object userdata)
        {
            if (index < 0 || index >= wraps.Count)
                return;

            wraps.Insert(index, new ItemWrap { prefab = prefab, userdata = userdata });

            if (index <= headIndex)
                headIndex++;

            if (index <= tailIndex)
                tailIndex++;

            //Debug.LogFormat("Insert {0} at {1}, headIndex = {2}, tailIndex = {3}", index, prefab.name, headIndex, tailIndex);
        }

        public void RemoveItemWrap(object userdata)
        {
            ItemWrap item = GetItemWrap(userdata);
            if (item != null)
            {
                for (int index = 0; index < wraps.Count; ++index)
                {
                    if (wraps[index] == item)
                    {
                        RemoveItemWrap(index);
                        break;
                    }
                }
            }
        }

        public void RemoveItemWrap(int index)
        {
            if (index < 0 || index >= wraps.Count)
                return;

            wraps.RemoveAt(index);

            if (index < headIndex)
                headIndex--;

            if (index <= tailIndex)
                tailIndex--;
        }

        private GameObject CreateItem(ItemWrap wrap)
        {
            if (wrap.prefab == null)
                return null;
            
            var go = wrap.prefab.Spawn(scroll.content);
            OnItemMoveIn?.Invoke(go, wrap.userdata);

            items[wrap] = go;
            return go;
        }

        private void DeleteItem(ItemWrap wrap)
        {
            if (items.TryGetValue(wrap, out GameObject go))
            {
                OnItemMoveOut?.Invoke(go, wrap.userdata);
                go.Recycle();
                items[wrap] = null;
            }
        }

        public void AddItemToTail(GameObject prefab, object userdata)
        {
            bool isTail = tailIndex == wraps.Count - 1;

            AddItemWrap(prefab, userdata);

            if (isTail)
            {
                CreateItem(wraps[++tailIndex]);
            }

            ToTail = isTail;
        }

        void OnValueChanged(Vector2 vector2)
        {
            if (!inited)
                return;

            int count = scroll.content.childCount;
            if (count > 0 && wraps.Count > 0)
            {
                if (!beginDrag)
                {
                    if (scroll.vertical)
                    {
                        float topHeight = items[wraps[headIndex]].GetComponent<RectTransform>().rect.height;
                        float bottomHeight = items[wraps[tailIndex]].GetComponent<RectTransform>().rect.height;

                        if (ContentPosition.y > ViewportSize.y + topHeight + spacing && tailIndex < wraps.Count - 1) // Drag to higher
                        {
                            DeleteItem(wraps[headIndex++]);

                            ContentPosition = new Vector2(ContentPosition.x, ContentPosition.y - topHeight - spacing);

                            CreateItem(wraps[++tailIndex]);
                        }
                        else if (ContentPosition.y < ViewportSize.y && headIndex > 0) // Drag to lower
                        {
                            if (ContentSize.y - ContentPosition.y - ViewportSize.y > bottomHeight + spacing)
                            {
                                DeleteItem(wraps[tailIndex--]);
                            }

                            GameObject go = CreateItem(wraps[--headIndex]);
                            if (go != null)
                            {
                                go.transform.SetAsFirstSibling();
                                float height = go.GetComponent<RectTransform>().rect.height;
                                ContentPosition = new Vector2(ContentPosition.x, ContentPosition.y + height + spacing);
                            }
                        }
                        else if (ContentSize.y - ContentPosition.y - ViewportSize.y < 0 && tailIndex < wraps.Count - 1) // shorter than viewport
                        {
                            CreateItem(wraps[++tailIndex]);
                        }
                    }
                    else if (scroll.horizontal)
                    {
                        // TODO HorizontalLayoutGroup
                        float leftWidth = items[wraps[headIndex]].GetComponent<RectTransform>().rect.width;
                        float rightWidth = items[wraps[tailIndex]].GetComponent<RectTransform>().rect.width;

                        if (-ContentPosition.x > ViewportSize.x + leftWidth + spacing && tailIndex < wraps.Count - 1) // Drag to higher
                        {
                            DeleteItem(wraps[headIndex++]);

                            ContentPosition = new Vector2(ContentPosition.x + leftWidth + spacing, ContentPosition.y);

                            CreateItem(wraps[++tailIndex]);
                        }
                        else if (-ContentPosition.x < ViewportSize.x && headIndex > 0) // Drag to lower
                        {
                            if (ContentSize.x + ContentPosition.x - ViewportSize.x > rightWidth + spacing)
                            {
                                DeleteItem(wraps[tailIndex--]);
                            }

                            GameObject go = CreateItem(wraps[--headIndex]);
                            if (go != null)
                            {
                                go.transform.SetAsFirstSibling();
                                float width = go.GetComponent<RectTransform>().rect.width;
                                ContentPosition = new Vector2(ContentPosition.x - width - spacing, ContentPosition.y);
                            }
                        }
                        else if (ContentSize.x + ContentPosition.x - ViewportSize.y < 0 && tailIndex < wraps.Count - 1) // shorter than viewport
                        {
                            CreateItem(wraps[++tailIndex]);
                        }
                    }
                    else
                    {

                    }
                }
            }
        }

    }
}





