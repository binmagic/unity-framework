using System;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CameraSphericalMoveWithEase : MonoBehaviour
{
    public enum Dir
    {
        Front = 0,
        LF = 1,
        LB = 2,
        RF = 3,
        RB,
        Init
    }

    public Vector3 centerPos;
    
    public float Radius = 14;
    public float InitRadius = 20; 
    public Transform cameraTransform; // 摄像机
    public float duration = 2.0f; // 持续时间
    public Dir curDir = Dir.Init;

    //第一步,我们获取到几个点,然后获取角度,然后获取到球面上的点
    public Transform targetNode;
    public List<Vector3> spherePoint = new List<Vector3>();
    
    //在刚开始进行移动时候的位置
    private Vector3 startSlerpPos = Vector3.zero;
    private bool slerpLock = false;

    private float m_dt = 0.0f;
    private Vector3 m_targetPos;
    
    private float startTime;

    private float m_difThetaRad = 0;
    private float m_startThetaRad = 0;

    private float m_difPhiRad = 0;

    private float m_startPhiRad = 0;

    private float m_curRadius = 0;
    private float m_tarRadius = 0;
        
    /*
     * 整体思路
     * 在刚开始转动的时候,我们获取到当前的xz平面的夹角,在此时我们做一个判定是否大于PI,如果小于PI证明是在半圈内,我们可以正常转动,如果大于PI
     * 则为 (dst-src) > PI ? (dst-src)-2PI : (dst-src),然后我们在转动的时候就是按照当前的src + deltaArc
     */

    void OnGUI()
    {
        // Set the size and position of the buttons
        int buttonWidth = 100;
        int buttonHeight = 50;

        // Button 1
        if (GUI.Button(new Rect(10, 10, buttonWidth, buttonHeight), "Front"))
        {
            MoveToFront();
        }

        // Button 2
        if (GUI.Button(new Rect(10, 70, buttonWidth, buttonHeight), "LF"))
        {
            MoveToLF();
        }

        // Button 3
        if (GUI.Button(new Rect(10, 130, buttonWidth, buttonHeight), "LB"))
        {
            MoveToLB();
        }

        // Button 4
        if (GUI.Button(new Rect(10, 190, buttonWidth, buttonHeight), "RF"))
        {
            MoveToRF();
        }

        // Button 5
        if (GUI.Button(new Rect(10, 250, buttonWidth, buttonHeight), "RB"))
        {
            MoveToRB();
        }
        
        if (GUI.Button(new Rect(10, 250+60, buttonWidth, buttonHeight), "iNIT"))
        {
            MoveCameraToPoint(Dir.Init);
        }
    }

    public void MoveToFront()
    {
        MoveCameraToPoint(Dir.Front);
    }

    public void MoveToLF()
    {
        MoveCameraToPoint(Dir.LF);
    }
    public void MoveToLB()
    {
        MoveCameraToPoint(Dir.LB);
    }
    public void MoveToRF()
    {
        MoveCameraToPoint(Dir.RF);
    }
    public void MoveToRB()
    {
        MoveCameraToPoint(Dir.RB);
    }



    public void InitPoint()
    {
        for (int i = 1; i < 7; ++i)
        {
            var node = targetNode.Find($"point{i}");
            var norDir = Vector3.Normalize(node.position-centerPos);
            float _radius = Radius;
            if (i - 1 == (int) Dir.Init)
                _radius = InitRadius;
            spherePoint.Add(norDir*_radius + centerPos);
        }
    }

    void Start()
    {
        InitPoint();
        cameraTransform = GameObject.Find("A_CheKu(Clone)/CameraGroup/Camera_Main").transform;
        var pos = spherePoint[(int) curDir];
        cameraTransform.position = pos;
        cameraTransform.LookAt(centerPos);
        m_curRadius = InitRadius;
    }

    // 移动摄像机到目标点
    public void MoveCameraToPoint(Dir dirPos)
    {
        if (slerpLock == true || dirPos == curDir)
            return;
        slerpLock = true;
        startTime = Time.time;
        startSlerpPos = cameraTransform.position;
        Vector3 targetPoint = spherePoint[(int) dirPos];
        m_targetPos = targetPoint;
        curDir = dirPos;
        
        //计算差值
        float startTheta, startPhi;
        float targetTheta, targetPhi;
        //第一个返回值表示ver,第二个表示 hor
        ConvertToSpherical(startSlerpPos-centerPos , out startTheta, out startPhi);
        ConvertToSpherical(m_targetPos-centerPos , out targetTheta, out targetPhi);

        m_startThetaRad = startTheta;
        m_startPhiRad = startPhi;
        m_difThetaRad = (targetTheta - startTheta) > MathF.PI
            ? (targetTheta - startTheta) - MathF.PI * 2
            : (targetTheta - startTheta);
        targetPhi = targetPhi < 0 ? targetPhi + Mathf.PI * 2 : targetPhi;
        startPhi = startPhi < 0 ? startPhi + Mathf.PI * 2 : startPhi;
        
        m_difPhiRad = (targetPhi - startPhi) > MathF.PI
            ? (targetPhi - startPhi) - MathF.PI * 2
            : (targetPhi - startPhi);

        m_tarRadius = dirPos == Dir.Init ? InitRadius : Radius;


        // 使用 DOTween 的内置缓动效果进行球面插值移动
        // DOTween.To(() => 0f, t => UpdateCameraPosition(t, targetPoint), 1f, duration)
        //     .SetEase(Ease.InOutSine) // 使用内置缓动效果，这里是 Ease.InOutSine
        //     .OnComplete(() =>
        //     {
        //         cameraTransform.position = targetPoint;
        //         slerpLock = false;
        //         curDir = dirPos;
        //     }); // 完成后设置位置为目标点
    }

    void Update()
    {
        if (slerpLock == false)
            return;
        // 计算插值因子
        float t = (Time.time - startTime) / duration;

        // 将三维坐标转换为球面坐标
        
        // 在经度和纬度上进行插值
        float interpolatedPhi = m_startPhiRad + Mathf.Lerp(0, m_difPhiRad, t);
        float interpolatedTheta = m_startThetaRad+ Mathf.Lerp(0, m_difThetaRad, t);

        Debug.Log($"phi: {interpolatedPhi-Mathf.PI*2}");
        // 将球面坐标转换回三维坐标
        Vector3 interpolatedPosition = ConvertToCartesian(interpolatedTheta, interpolatedPhi) ;

        float _radius = Mathf.Lerp(m_curRadius, m_tarRadius, t);
        // 更新摄像机位置
        cameraTransform.position = interpolatedPosition * _radius + centerPos;

        // 始终让摄像机朝向球心
        cameraTransform.LookAt(centerPos);

        // 如果到达目标位置，切换到下一个目标位置
        if (t >= 1.0f)
        {
            startTime = Time.time;
            cameraTransform.position = m_targetPos;
            cameraTransform.LookAt(centerPos);
            slerpLock = false;
            m_curRadius = m_tarRadius;
        }
    }

    // 将三维坐标转换为球面坐标
    void ConvertToSpherical(Vector3 cartesian, out float theta, out float phi)
    {
        float radius = cartesian.magnitude;
        theta = Mathf.Acos(cartesian.y / radius); // 纬度
        phi = Mathf.Atan2(cartesian.z, cartesian.x); // 经度
    }

    // 将球面坐标转换为三维坐标
    Vector3 ConvertToCartesian(float theta, float phi)
    {
        float x = Mathf.Sin(theta) * Mathf.Cos(phi);
        float y = Mathf.Cos(theta);
        float z = Mathf.Sin(theta) * Mathf.Sin(phi);
        return new Vector3(x, y, z);
    }

}





