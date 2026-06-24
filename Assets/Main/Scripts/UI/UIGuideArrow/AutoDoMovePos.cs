using System.Collections.Generic;
using UnityEngine;

public class AutoDoMovePos : MonoBehaviour
{

    public class PosParam
    {
        public Vector3 pos;
        public PositionType positionType;
    }

    public enum PositionType
    {
        World = 1,//世界坐标
        Screen = 2,//屏幕坐标
    }
    
    public enum PlayAnimName
    {
        Down = 1,//按下
        Up = 2,//抬起
    }
    public static float MoveSpeed = 500.0f;
    public static float DownTime = 0.8f;//按下手指的时间
    public static float UpTime = 0.75f;//抬起手指的时间
    private List<PosParam> _posList;
    private AutoDoMovePosMachine _machine;
    void Awake()
    {
        _posList = new List<PosParam>();
    }

    public void Init(string posLists)
    {
        _posList.Clear();
        if (!string.IsNullOrEmpty(posLists))
        {
            var spl = posLists.Split('|');
            for (int i = 0; i < spl.Length; ++i)
            {
                var spl1 = spl[i].Split(';');
                if (spl1.Length > 3)
                {
                    PosParam param = new PosParam();
                    param.pos = new Vector3(spl1[0].ToFloat(), spl1[1].ToFloat(), spl1[2].ToFloat());
                    param.positionType = (PositionType) spl1[3].ToInt();
                    _posList.Add(param);
                }
            }
        }
        _machine = new AutoDoMovePosMachine(this);
    }

    private void Update()
    {
        _machine?.OnUpdate(Time.deltaTime);
    }

    public float GetDownTime()
    {
        return DownTime;
    }
    public float GetUpTime()
    {
        return UpTime;
    }
    
    public float GetMoveSpeed()
    {
        return MoveSpeed;
    }
    public void ChangeStartPos()
    {
        transform.position = GetScreenPos(0);
    }
    public void ChangeEndPos()
    {
        transform.position = GetScreenPos(_posList.Count - 1);
    }
    
    public int GetMovePosListCount()
    {
        return _posList.Count;
    }
    
    public Vector3 GetScreenPos(int index)
    {
        if (index >= 0 && index < _posList.Count)
        {
            return _posList[index].pos;
            /*return _posList[index].positionType == PositionType.World
                ? SceneManager.World.WorldToScreenPoint(_posList[index].pos)
                : _posList[index].pos;*/
        }
        return Vector3.zero;
    }
}





