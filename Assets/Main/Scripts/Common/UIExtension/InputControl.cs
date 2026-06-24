using UnityEngine;

public delegate void MouseDownEvent(Vector2 mousePosition);
public delegate void MouseUpEvent(Vector2 mousePosition);
public delegate void MouseDragEvent(Vector2 dragVector);
public delegate void MouseClickEvent(Vector2 mousePosition);

public class InputControl : MonoBehaviour
{


    private bool isPress;
    private bool isClick;
    private bool tempPress;
    private Vector2 oldMousePosition;
    private Vector2 tempMousePosition;

    public event MouseDownEvent EVENT_MOUSE_DOWN;
    public event MouseUpEvent EVENT_MOUSE_UP;
    public event MouseDragEvent EVENT_MOUSE_DRAG;
    public event MouseClickEvent EVENT_MOUSE_CLICK;

    /// <summary>
    /// 拖动起始判断参数，可自行更改
    /// </summary>
    public const float JUDGE_DISTANCE = 1F;

    void Awake()
    {

        //以下代码可优化
        EVENT_MOUSE_DOWN += AvoidEmpty;
        EVENT_MOUSE_UP += AvoidEmpty;
        EVENT_MOUSE_DRAG += AvoidEmpty;
        EVENT_MOUSE_CLICK += AvoidEmpty;
    }

    void Start()
    {
        isPress = false;
        isClick = false;
    }

    /// <summary>
    /// 防空保护函数，无用处，可自行优化
    /// </summary>
    /// <param name="noUse"></param>
    private void AvoidEmpty(Vector2 noUse) { }

    void Update()
    {
        tempPress = Input.GetMouseButton(0);
        tempMousePosition = Input.mousePosition;
        // 两次状态不同，触发点击和抬起事件
        if (tempPress != isPress)
        {
            // 按下事件
            if (tempPress)
            {
                isClick = true;
                EVENT_MOUSE_DOWN(tempMousePosition);
            }
            // 抬起事件
            else
            {
                EVENT_MOUSE_UP(tempMousePosition);
                // 点击事件
                if (isClick)
                {
                    EVENT_MOUSE_CLICK(tempMousePosition);
                }
                isClick = false;
            }
        }
        // 按下的过程中发生了移动，发生事件变化
        else if (isClick && JudgeMove(oldMousePosition, tempMousePosition))
        {
            isClick = false;
        }
        // 拖动事件
        else if (tempPress && !isClick)
        {
            EVENT_MOUSE_DRAG(tempMousePosition - oldMousePosition);
        }

        isPress = tempPress;
        oldMousePosition = tempMousePosition;
    }

    /// <summary>
    /// 判断是否超出静止范围，用static速度更快
    /// </summary>
    /// <param name="p1"></param>
    /// <param name="p2"></param>
    /// <returns></returns>
    private static bool JudgeMove(Vector2 p1, Vector2 p2)
    {
        return Mathf.Abs(p1.x - p2.x) > JUDGE_DISTANCE || Mathf.Abs(p1.y - p2.y) > JUDGE_DISTANCE;
    }

}





