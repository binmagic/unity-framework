using UnityEngine;
using System;

public class RandMove : MonoBehaviour
{
    private static float _pointCount = 5f;
    private static int SEGMENT_COUNT = 20;
    private static Vector3[] _paths = new Vector3[SEGMENT_COUNT];
    public AnimationCurve firstCurve;
    public AnimationCurve secondCurve;
    public Vector3 rotDir;
    public Vector3 startPos;
    public float upTime = 1;
    public float rotSpeed;
    public float moveHight = 1;
    private float deltaTime = 0;
    private float deltaTime1 = 0;
    public GameObject target;
    public Vector3 controlPointOffset;
    public FlyState flyState = FlyState.None;
    public float speed = 1;
    private Action onComplete;
    public float closeDis = 0.1f;
    
    public enum FlyState
    {
        None,
        Up,
        Track
    }
    
    public void StartFly(Vector3 startPos, GameObject target, Action onComplete)
    {
        deltaTime = 0;
        deltaTime1 = 0;
        this.startPos = startPos;
        this.target = target;
        this.onComplete = onComplete;
        transform.position = startPos;
        flyState = FlyState.Up;
    }
    
    // Update is called once per frame
    private void Update()
    {
        switch (flyState)
        {
            case FlyState.Up:
                deltaTime += Time.deltaTime;
                if (upTime > 0)
                {
                    float t = firstCurve.Evaluate(deltaTime / upTime);
                    transform.position = startPos + t * moveHight * Vector3.up;
                }
                if (deltaTime >= upTime)
                {
                    flyState = FlyState.Track;
                }
                break;
            case FlyState.Track:
                deltaTime1 += Time.deltaTime * speed;
                Vector3 pos = transform.position;
                Vector3 targetPos = target.transform.position;
                if (deltaTime1 >= 1 || Vector3.Distance(pos, targetPos) < closeDis)
                {
                    flyState = FlyState.None;
                    onComplete?.Invoke();
                }
                else
                {
                    float tt = secondCurve.Evaluate(deltaTime1);
                    Vector3 controlPos = (pos + targetPos) * middleValue + controlPointOffset;
                    transform.position = CalculateCubicBezierPointfor2C(tt, pos, controlPos, targetPos);
                }
                break;
        }
        transform.Rotate(Time.deltaTime * rotSpeed * rotDir);
    }
    public float middleValue = 0.5f;
    //获取二阶贝塞尔曲线路径数组
    private Vector3[] Bezier2Path(Vector3 startPos, Vector3 controlPos, Vector3 endPos)
    {
        // 这地方不好做缓存，因为startPos是做了一次随机的，所以这里很难有命中
        //List<Vector3> v = new List<Vector3>();
        for (int i = 1; i <= SEGMENT_COUNT; i++)
        {
            float t = i / (float)SEGMENT_COUNT;
            Vector3 pixel = CalculateCubicBezierPointfor2C(t, startPos, controlPos, endPos);

            _paths[i - 1] = pixel;
            //  v.Add(pixel);
        }
        //return v.ToArray();
        return _paths;
    }
    // 2阶贝塞尔曲线
    public static Vector3 Bezier2(Vector3 startPos, Vector3 controlPos, Vector3 endPos, float t)
    {
        return (1 - t) * (1 - t) * startPos + 2 * t * (1 - t) * controlPos + t * t * endPos;
    }

    // 3阶贝塞尔曲线
    public static Vector3 Bezier3(Vector3 startPos, Vector3 controlPos1, Vector3 controlPos2, Vector3 endPos, float t)
    {
        float t2 = 1 - t;
        return t2 * t2 * t2 * startPos
            + 3 * t * t2 * t2 * controlPos1
            + 3 * t * t * t2 * controlPos2
            + t * t * t * endPos;
    }
    /// <summary>
    /// 二次 贝塞尔 坐标点
    /// </summary>
    Vector3 CalculateCubicBezierPointfor2C(float t, Vector3 p0, Vector3 p1, Vector3 p2)
    {
        //B(t) = (1-t)(1-t)P0+ 2 (1-t) tP1 + ttP2,   0 <= t <= 1 
        float u = 1 - t;
        float tt = t * t;
        float uu = u * u;

        Vector3 p = uu * p0;
        p += 2 * u * t * p1;
        p += tt * p2;
        return p;
    }
}





