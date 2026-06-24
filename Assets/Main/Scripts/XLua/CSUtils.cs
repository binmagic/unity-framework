using System;
using System.Collections.Generic;
using System.Text;
using DG.Tweening;
using GameKit.Base;
using UnityEngine;
using UnityEngine.UI;
using XLua;


/// <summary>
// 把一些频繁固定的函数，放到这里处理
// 譬如一些固定的行为，这个行为调用频繁，且来回从lua和C#之间交换数据。
// 可以把这种函数定义如下，然后减少无用的传递和GC开销。
// 主要还是考虑效率
/// </summary>

public class CSUtils
{
    // 这个函数给屏幕点击特效的函数使用
    public static void SetPositionFromInput(Transform tf)
    {
        tf.position = Input.mousePosition;
    }
    
    public static Vector3 WorldPositionToUISpacePosition(Vector3 worldPosition)
    {
        var uiPosition = Camera.main.WorldToScreenPoint(worldPosition);
        uiPosition = GameObject.FindWithTag("UICamera").GetComponent<Camera>().ScreenToWorldPoint(uiPosition);
        return uiPosition;
    }
    
    public static void DOTweenTo_RectTransformPos_X(RectTransform _rectTransform, float endX, float time, Action callback = null)
    {
        float oldY = _rectTransform.anchoredPosition.y;
        DOTween.To(() => _rectTransform.anchoredPosition.x, 
            pos => _rectTransform.anchoredPosition = new Vector2(pos, oldY),
            endX, 
            time).onComplete = ()=>{ callback?.Invoke(); } ;
    }

    public static void DOTweenTo_RectTransformPos_Y(RectTransform _rectTransform, float endY, float time, Action callback = null)
    {
        float oldX = _rectTransform.anchoredPosition.x;
        DOTween.To(() => _rectTransform.anchoredPosition.y, 
            pos => _rectTransform.anchoredPosition = new Vector2(oldX, pos),
            endY, 
            time).onComplete = ()=>{ callback?.Invoke(); } ;
    }

    public static void DOTweenTo_MinWidth(LayoutElement _rectTransform, float endValue, float time, Action callback = null)
    {
        DOTween.To(() => _rectTransform.minWidth, 
            pos => _rectTransform.minWidth = pos,
            endValue, 
            time).onComplete = ()=>{ callback?.Invoke(); } ;
    }

    public static void DOTweenTo_ScrollRect_Horizontal(ScrollRect _scrollRect, float endValue, float time, Action callback = null)
    {
        DOTween.To(() => _scrollRect.horizontalNormalizedPosition, 
            pos => _scrollRect.horizontalNormalizedPosition = pos,
            endValue, 
            time).onComplete = ()=>{ callback?.Invoke(); } ;
    }

    static Vector3 topVec = new Vector3(0, 0, 0);
    static Vector3 downVec = new Vector3(0, 0, 0);
    static Collider[] colliders = new Collider[200];
    // public static int GetTriggerIds(float tx, float ty, float tz, float dx, float dy, float dz, float radius, GameObject srcObj, LuaTable outTable, string layerName)
    // {
    //     if (srcObj == null)
    //         return -1;
    //     
    //     LayerMask layerMask = LayerMask.GetMask(layerName);
    //     //计算面前的.因为不涉及z轴变换,所以直接忽略z轴,计算点乘
    //     var cityManPosition = srcObj.transform.position;
    //    
    //     int index = 1;
    //     topVec.Set(tx, ty, tz);
    //     downVec.Set(dx, dy, dz);
    //     int cnt = Physics.OverlapCapsuleNonAlloc(topVec, downVec, radius, colliders, layerMask);
    //     int _tmpCnt = cnt > colliders.Length ? colliders.Length : cnt;
    //     int ok_cnt = 0;
    //     for (int i = 0; i < _tmpCnt; ++i)
    //     {
    //         Collider _collider = colliders[i];
    //         var trigger = _collider.transform.GetComponentInParent<CitySpaceManTrigger>();
    //         if (trigger != null)
    //         {
    //             var collider_pos = _collider.transform.position;
    //             Debug.DrawLine(collider_pos, cityManPosition, Color.red, 200);
    //             Vector2 vec1 = new Vector2(collider_pos.x-cityManPosition.x, collider_pos.z-cityManPosition.z);
    //             Vector2 vec2 = new Vector2(srcObj.transform.forward.x, srcObj.transform.forward.z);
    //             if (Vector2.Dot(vec1, vec2) > 0)
    //             {
    //                 ++ok_cnt;
    //                 outTable.Set(index++, trigger.ObjectId);
    //             }
    //         }
    //     }
    //     return ok_cnt;
    // }

    /*
     * 这个函数我们使用胶囊碰撞检测下一帧小人是否发生碰撞,如果发生碰撞
     * 我们可以拿到碰撞点的法线,通过法线和up求叉乘可以求出来切线的方向
     * 将切线的方向和forward 点乘,如果小于0表示需要向切线的反方向移动,如果大于0则需要向切线方向移动
     */
    public static bool Hit(Transform transform, float radius, float speed, out Vector3 oritation)
    {
        float realRadius = radius;
        radius = 0.54f;
//        Debug.Log($">>>hit 1");
        speed *= 3.0f;
        LayerMask layerMask = LayerMask.GetMask("Default");
        var downPos = transform.position;
        var topPos = transform.position + new Vector3(0, 1, 0);
        RaycastHit hitInfo;
        RaycastHit hitInfo1;
        
        if (Physics.CapsuleCast(downPos, topPos, radius, transform.forward, out hitInfo, speed, layerMask))
        {
//            Collider[] _arrayC = Physics.OverlapCapsule(downPos, topPos, radius, layerMask);
////            Debug.Log($">>>hit 2  count{_arrayC.Length}");
//            if (_arrayC != null && _arrayC.Length > 1)
//            {
////                Debug.Log($">>>hit 3");
//                oritation = Vector3.zero;
//                return true;
//            }

            RaycastHit hitInfo2;
            if (Physics.CapsuleCast(downPos, topPos, realRadius, transform.forward, out hitInfo2, speed, layerMask))
            {
//                Debug.Log($">>>hit 3");
                oritation = Vector3.zero;
                return true;
            }

//            Debug.DrawRay(hitInfo.point, hitInfo.normal, Color.green, 0.5f);

            var qiexian = Vector3.Cross(hitInfo.normal, Vector3.up);
            if (Vector3.Dot(transform.forward, qiexian) > 0)
            {
                oritation = qiexian;
            }
            else
            {
                oritation = -qiexian;
            }
            
//            Debug.DrawRay(hitInfo.point, oritation, Color.cyan, 0.5f);
            
            //在计算出新的方向的时候还是需要重新计算一次,否则有可能在夹角的时候,直接进入
            if (Physics.CapsuleCast(downPos, topPos, radius, oritation, out hitInfo1, speed, layerMask))
            {
//                Debug.Log($">>>hit 4");
//                Debug.DrawRay(hitInfo1.point, hitInfo1.normal, Color.red, 0.5f);
                oritation = Vector3.zero;
                return true;
            }
//            Debug.Log($">>>hit 5");
            return true;
        }
        oritation = Vector3.zero;
        return false;
    }
    
    /*
    * 这个函数我们使用胶囊碰撞检测下一帧小人是否发生碰撞,如果发生碰撞
    * 我们可以拿到碰撞点的法线,通过法线和up求叉乘可以求出来切线的方向
    * 将切线的方向和forward 点乘,如果小于0表示需要向切线的反方向移动,如果大于0则需要向切线方向移动
    */
    public static bool Hit2(Vector3 pos,Vector3 forward, float radius, float speed, out Vector3 oritation)
    {
        LayerMask layerMask = LayerMask.GetMask("Default");
        var downPos = pos;
        var topPos = pos + new Vector3(0, 1, 0);
        RaycastHit hitInfo;
        if (Physics.CapsuleCast(downPos, topPos, radius, forward, out hitInfo, speed, layerMask))
        {
            Debug.DrawRay(hitInfo.point, hitInfo.normal, Color.red, 0.5f);
            oritation = Vector3.zero;
            return true;
        }
        
        oritation = Vector3.zero;
        return false;
    }

    public static bool HitPlane(Vector3 pos, Vector3 forward, float maxDis, out Vector3 hitPoint)
    {
        maxDis = 10;
        Ray ray = new Ray(pos, forward);
        hitPoint = Vector3.zero;
        LayerMask layerMask = LayerMask.GetMask("Hide");
        RaycastHit[] hit = new RaycastHit[16];
        // var endPos = Vector3.Normalize(forward) * maxDis + pos;
        // Debug.DrawLine(pos, endPos, Color.yellow, 15);
        // Debug.DrawRay(pos, forward, Color.red, 15);
        if (Physics.RaycastNonAlloc(ray, hit, maxDis, layerMask) > 0)
        {
            hitPoint = hit[0].point;
            return true;
        }

        return false;
    }
}





