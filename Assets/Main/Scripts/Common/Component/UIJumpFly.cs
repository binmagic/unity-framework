using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class UIJumpFly : MonoBehaviour
{
    private Animator anim;
    private static int SEGMENT_COUNT = 20;
    private  Vector3[] _paths = new Vector3[SEGMENT_COUNT];
    public AnimationCurve firstCurve;
    public bool isRun = false;
    public Vector3 controlPointOffset;
    public float middlePos = 0.5f;
    public float moveTime;
    public Vector3 targetPos;
    private bool isFinish =false;
    private double delayTime = 0.0;
    private Action onComplete;
    // Start is called before the first frame update
    private void Awake()
    {
        anim = GetComponent<Animator>();
    }
    private Vector3[] Bezier2Path( Vector3 startPos, Vector3 controlPos, Vector3 endPos)
    {
        for (int i = 1; i <= SEGMENT_COUNT; i++)
        {
            float t = i / (float)SEGMENT_COUNT;
            Vector3 pixel = CalculateCubicBezierPointfor2C(t, startPos, controlPos, endPos);

            _paths[i - 1] = pixel;

        }

        return _paths;
    }

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
    public void DoJump()
    {
        
        anim.enabled = false;
        var startPos = transform.position;
        var destPos = targetPos;
        var cross = Vector3.Cross(startPos, destPos);
        Vector3 controlPos = Vector3.zero;
        if (cross.y > 0) //左边
        {
            controlPos = (startPos + destPos) * middlePos + controlPointOffset;
        }
        else//右边
        {
            controlPos = (startPos + destPos) * middlePos - controlPointOffset;
        }
        Vector3[] pathvec = Bezier2Path(startPos, controlPos, destPos);
        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOPath(pathvec, moveTime)).SetEase(firstCurve);
        seq.AppendCallback(() => { onComplete?.Invoke(); }).SetDelay((float)this.delayTime);

    }
    public void DoFly(Vector3 targetPos,Action onComplete=null,bool isLeft=false)
    {
        this.onComplete = onComplete;
        this.targetPos = targetPos;
        anim.SetTrigger(isLeft == true ? "left" : "right");

    }
    
    public void DoFlyNew(Vector3 targetPos,Action onComplete=null,bool isLeft=false, double delayTime = 0.0f)
    {
        this.onComplete = onComplete;
        this.targetPos = targetPos;
        this.delayTime = delayTime;
        anim.SetTrigger(isLeft == true ? "left" : "right");
    }
    private void OnDisable()
    {
        anim.enabled = true;
        isFinish = false;
    }
    private void OnEnable()
    {
        anim.enabled = true;
        isFinish = false;


    }
    // Update is called once per frame
    void Update()
    {

        if (isRun)
        {
            anim.SetTrigger("right");
            isRun = false;
        }

    }
}





