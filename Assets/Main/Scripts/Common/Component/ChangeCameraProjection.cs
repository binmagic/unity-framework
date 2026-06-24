using System;
using UnityEngine;

/// <summary>
/// 一个简单的摄像机切换 Pers <-> Orth
/// </summary>
public class ChangeCameraProjection : MonoBehaviour
{
    private static readonly float MAXChangeTime = 1.0f;
    private float m_changeTime = 0.0f;
    private bool m_isUpdateToPers = false;
    private bool m_isUpdateToOrth = false;
    private Matrix4x4 m_curMatrix;
    private bool m_isInitOrthMatrix = false;
    private Matrix4x4 m_orthMatrix;
    private bool m_isInitPersMatrix = false;
    private Matrix4x4 m_persMatrix;
    private Camera m_camera;

    private void Awake()
    {
        m_camera = GetComponent<Camera>();
    }

    public void ChangeToPers()
    {
        bool isOrth = Camera.main.orthographic;
        if (!isOrth || m_isUpdateToPers)
            return;
        m_isUpdateToPers = true;
        if (!m_isInitPersMatrix)
        {
            m_camera.orthographic = false;
            m_camera.ResetProjectionMatrix();
            m_persMatrix = m_camera.projectionMatrix;
            m_camera.orthographic = true;
            m_isInitPersMatrix = true;
        }
    }

    public void ChangeToOrth()
    {
        bool isOrth = Camera.main.orthographic;
        if (!isOrth || m_isUpdateToOrth)
            return;
        m_isUpdateToOrth = true;
        if (!m_isInitOrthMatrix)
        {
            m_camera.orthographic = true;
            m_camera.ResetProjectionMatrix();
            m_orthMatrix = m_camera.projectionMatrix;
        }
    }

    private void LateUpdate()
    {
        if (!m_isUpdateToOrth && !m_isUpdateToPers)
            return;
        if (m_isUpdateToOrth)
        {
            m_curMatrix = m_camera.projectionMatrix;
            
        }
    }
}





