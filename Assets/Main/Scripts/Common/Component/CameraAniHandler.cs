// /***
//  * Created by zhangliheng.
//  * DateTime: 2023/07/06 6:33 PM
//  * Description: 相机动画控制脚本 一份clip可以复用在多个位置
//  ***/

/**
 * [INPUT]: 依赖 UnityEngine 的 Camera/AnimationClip/Coroutine 逐帧采样，依赖 Matrix4x4 做相机位姿变换；编辑器下依赖 UnityEditor 暂停调试
 * [OUTPUT]: 对外提供 CameraAniHandler 组件的 Enter/Exit 接口，以参照 Transform 为基准播放/回退相机动画并回调结果
 * [POS]: Common/Component 的相机动画控制器，用状态机(Idle/Apply/Recover)保证动画不可打断，一份 clip 可复用于多个位置
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System;
using System.Collections;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public class CameraAniHandler : MonoBehaviour
{
    public bool pauseAtFirstFrame = false;
    [SerializeField] AnimationClip[] ClipList;

    private Camera camera;
    private Coroutine _coroutine;
    private AnimationClip _curClip;
    private Transform _reference;
    private Action<bool> _callback;
    
    private enum State
    {
        Idle,
        Apply,
        Recover
    }

    private State _curState = State.Idle;
    
    private void Awake()
    {
        camera = GetComponent<Camera>();
    }
    
    public bool Enter(string clipName, Transform reference, Action<bool> callback)
    {
        if (_curState != State.Idle)
        {
            //Debug.LogError("相机动画不可打断！");
            if (callback != null) callback(false);
            return false;
        }
        
        _curClip = GetClipByName(clipName);
        if (_curClip == null)
        {
            Debug.LogError($"PlayAnimation clip is nil! name:{clipName}");
            if (callback != null) callback(false);
            return false;
        }

        _reference = reference;
        _callback = callback;
        _coroutine = StartCoroutine(ApplyAnimation());
        
        return true;
    }

    public bool Exit(Transform reference, Action<bool> callback)
    {
        if (timeCounter <= 0)
        {
            if (callback != null) callback(false);
            return false;
        }
        
        if (_curState == State.Recover)
        {
            if (callback != null) callback(false);
            return false;
        }
        
        StopCoroutine(_coroutine);
        _callback = callback;
        _reference = reference;
        _coroutine = StartCoroutine(RecoverAnimation());

        return true;
    }
    

    private Matrix4x4 originMatrix;
    private float timeCounter;
    
    private IEnumerator ApplyAnimation()
    {
#if UNITY_EDITOR
        if (pauseAtFirstFrame)
        {
            EditorApplication.isPaused = true;
        }
#endif
        
        transform.position = _reference.position;
        transform.rotation = Quaternion.identity;
        originMatrix = camera.transform.localToWorldMatrix;
        Debug.Log("=================originMatrix:=======================");
        Debug.Log(originMatrix);

        _curState = State.Apply;
        for (timeCounter = 0f; timeCounter < _curClip.length; timeCounter += Time.deltaTime)
        {
            SampleOnce(_curClip, timeCounter);
            yield return null;
        }

        _curState = State.Idle;
        if (_callback != null)
        {
            _callback(true);
            _callback = null;
        }
    }
    
    private IEnumerator RecoverAnimation()
    {
#if UNITY_EDITOR
        if (pauseAtFirstFrame)
        {
            EditorApplication.isPaused = true;
        }
#endif
    
        transform.position = _reference.position;
        transform.rotation = Quaternion.identity;
        originMatrix = camera.transform.localToWorldMatrix;
        Debug.Log("=================originMatrix:=======================");
        Debug.Log(originMatrix);
        _curState = State.Recover;
        for (; timeCounter > 0; timeCounter -= Time.deltaTime)
        {
            SampleOnce(_curClip, timeCounter);
            yield return null;
        }

        _curState = State.Idle;
        if (_callback != null)
        {
            _callback(true);
            _callback = null;
        }
    }

    private void SampleOnce(AnimationClip clip, float time)
    {
        clip.SampleAnimation(camera.gameObject, time);
        var m = camera.transform.localToWorldMatrix;
        Debug.Log($"=================time:{time}=======================");
        Debug.Log(m);

        var final = originMatrix * m; //(inverse ? m.inverse : m);
        var pos = final.MultiplyPoint(Vector3.zero);
        Debug.Log($"**************pos:{pos}, rotate:{final.rotation.eulerAngles}, fov:{camera.fieldOfView}*******************");
        camera.transform.position = pos;
        camera.transform.rotation = final.rotation;
    }
    
    private AnimationClip GetClipByName(string clipName)
    {
        foreach (var t in ClipList)
        {
            if (t.name == clipName)
            {
                return t;
            }
        }

        return null;
    }

}





