using System;
using System.Collections;
using System.Collections.Generic;
using BitBenderGames;
using Cinemachine.Utility;
using GameFramework;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

//
// 本节内容都是xLua中关于优化的一些处理
// 我们在Lua中操作UI的时候，会有大量xLua和C#的交互操作
// 如果不是内置类型的话，性能会有一些开销。尤其是struct开销，比class还要略大
// 大致原理：新建一个userdata对象
// 如果是引用类型（class），会存在ObjectTranslator的objects列表中，然后用一个id表示class
// 如果是值类型（struct），会把这个数据直接pack到userdata里，此时userdata是一个CSharpStruct对象
// 
// 从Lua往C#传递值也是一样，尽量都使用int,float这些，string也要尽量少用。
// 这个类，就是简单优化一下UI常用的struct和其他非必要的传递开销
// 参考： https://www.cnblogs.com/zwywilliam/p/5999924.html
// 

[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
[UnityEngine.Scripting.Preserve]
public static class xLuaOptiUtils
{
    /******************** Quaternion ********************/
    public static void Quaternion_LookRotation(float forwardX, float forwardY, float forwardZ, float upX, float upY,
        float upZ,
        out float x, out float y, out float z, out float w)
    {
        var forward = new Vector3(forwardX, forwardY, forwardZ);
        var up = new Vector3(upX, upY, upZ);
        var q = forward == Vector3.zero ? Quaternion.identity : Quaternion.LookRotation(forward, up);
        x = q.x;
        y = q.y;
        z = q.z;
        w = q.w;
    }

    public static void Quaternion_RotateTowards(float fromX, float fromY, float fromZ, float fromW, float toX,
        float toY,
        float toZ, float toW, float maxDegreesDelta,
        out float x, out float y, out float z, out float w)
    {
        var from = new Quaternion(fromX, fromY, fromZ, fromW);
        var to = new Quaternion(toX, toY, toZ, toW);
        var q = Quaternion.RotateTowards(from, to, maxDegreesDelta);
        x = q.x;
        y = q.y;
        z = q.z;
        w = q.w;
    }

    public static void Quaternion_ToEulerAngles(float qX, float qY, float qZ, float qW, out float x, out float y,
        out float z)
    {
        var q = new Quaternion(qX, qY, qZ, qW);
        var angle = q.ToEulerAngles();
        x = angle.x;
        y = angle.y;
        z = angle.z;
    }

    public static void Quaternion_EulerToQuat(float x, float y, float z, out float qx, out float qy, out float qz,
        out float qw)
    {
        var q = Quaternion.Euler(x, y, z);
        qx = q.x;
        qy = q.y;
        qz = q.z;
        qw = q.w;
    }

    public static void ToEulerAngles(this Quaternion q, out float x, out float y, out float z)
    {
        var angle = q.ToEulerAngles();
        x = angle.x;
        y = angle.y;
        z = angle.z;
    }

    public static void Quaternion_MulVec3(float qX, float qY, float qZ, float qW, float vX, float vY, float vZ,
        out float x, out float y, out float z)
    {
        var q = new Quaternion(qX, qY, qZ, qW);
        var v = q * new Vector3(vX, vY, vZ);
        x = v.x;
        y = v.y;
        z = v.z;
    }
    
    public static bool SimpleMove(this CharacterController cc, float x, float y, float z)
    {
        return cc.SimpleMove(new Vector3(x, y, z));
    }

    public static void Move(this CharacterController cc, float x, float y, float z)
    {
        cc.Move(new Vector3(x, y, z));
    }
    
    /****************************************************/



    /******************** RectTransform ********************/
    public static void Set_offsetMax(this RectTransform rt, float x, float y)
    {
        rt.offsetMax = new Vector2(x, y);
    }

    public static void Get_offsetMax(this RectTransform rt, out float x, out float y)
    {
        var s = rt.offsetMax;
        x = s.x;
        y = s.y;
    }

    public static void Set_offsetMin(this RectTransform rt, float x, float y)
    {
        rt.offsetMin = new Vector2(x, y);
    }

    public static void Get_offsetMin(this RectTransform rt, out float x, out float y)
    {
        var s = rt.offsetMin;
        x = s.x;
        y = s.y;
    }

    public static void Set_anchorMin(this RectTransform rt, float x, float y)
    {
        rt.anchorMin = new Vector2(x, y);
    }

    public static void Get_anchorMin(this RectTransform rt, out float x, out float y)
    {
        var s = rt.anchorMin;
        x = s.x;
        y = s.y;
    }

    public static void Set_anchorMax(this RectTransform rt, float x, float y)
    {
        rt.anchorMax = new Vector2(x, y);
    }

    public static void Get_anchorMax(this RectTransform rt, out float x, out float y)
    {
        var s = rt.anchorMax;
        x = s.x;
        y = s.y;
    }

    public static void Set_anchoredPosition(this RectTransform rt, float x, float y)
    {
        rt.anchoredPosition = new Vector2(x, y);
    }

    public static void Get_anchoredPosition(this RectTransform rt, out float x, out float y)
    {
        var s = rt.anchoredPosition;
        x = s.x;
        y = s.y;
    }

    public static void Set_anchoredPosition3D(this RectTransform rt, float x, float y, float z)
    {
        rt.anchoredPosition3D = new Vector3(x, y, z);
    }

    public static void Get_anchoredPosition3D(this RectTransform rt, out float x, out float y, out float z)
    {
        var s = rt.anchoredPosition3D;
        x = s.x;
        y = s.y;
        z = s.z;
    }

    public static void Set_pivot(this RectTransform rt, float x, float y)
    {
        rt.pivot = new Vector2(x, y);
    }

    public static void Get_pivot(this RectTransform rt, out float x, out float y)
    {
        var s = rt.pivot;
        x = s.x;
        y = s.y;
    }

    public static void Set_sizeDelta(this RectTransform rt, float x, float y)
    {
        rt.sizeDelta = new Vector2(x, y);
    }

    public static void Set_sizeDelta_x(this RectTransform rt, float x)
    {
        rt.sizeDelta = new Vector2(x, rt.sizeDelta.y);
    }

    public static void Set_sizeDelta_y(this RectTransform rt, float y)
    {
        rt.sizeDelta = new Vector2(rt.sizeDelta.x, y);
    }

    public static void Get_sizeDelta(this RectTransform rt, out float x, out float y)
    {
        var s = rt.sizeDelta;
        x = s.x;
        y = s.y;
    }

    public static void Get_sizeDelta_x(this RectTransform rt, out float x)
    {
        var s = rt.sizeDelta;
        x = s.x;
    }

    public static void Get_sizeDelta_y(this RectTransform rt, out float y)
    {
        var s = rt.sizeDelta;
        y = s.y;
    }
    /******************** RectTransform ********************/

    /******************** Transform ********************/
    public static void Set_position(this Transform t, float x, float y, float z)
    {
        t.position = new Vector3(x, y, z);
    }

    public static void Set_positionX(this Transform t, float x)
    {
        var oldp = t.position;
        t.position = new Vector3(x, oldp.y, oldp.z);
    }

    public static void Set_positionY(this Transform t, float x, float y, float z)
    {
        var oldp = t.position;
        t.position = new Vector3(oldp.x, y, oldp.z);
    }

    public static void Set_positionZ(this Transform t, float x, float y, float z)
    {
        var oldp = t.position;
        t.position = new Vector3(oldp.x, oldp.y, z);
    }

    public static void Get_position(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.position;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_localPosition(this Transform t, float x, float y, float z)
    {
        t.localPosition = new Vector3(x, y, z);
    }

    public static void Get_localPosition(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.localPosition;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_localScale(this Transform t, float x, float y, float z)
    {
        t.localScale = new Vector3(x, y, z);
    }

    public static void Get_localScale(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.localScale;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Get_lossyScale(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.lossyScale;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_eulerAngles(this Transform t, float x, float y, float z)
    {
        t.eulerAngles = new Vector3(x, y, z);
    }

    public static void Get_eulerAngles(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.eulerAngles;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_localEulerAngles(this Transform t, float x, float y, float z)
    {
        t.localEulerAngles = new Vector3(x, y, z);
    }

    public static void Get_localEulerAngles(this Transform rt, out float x, out float y, out float z)
    {
        var v = rt.localEulerAngles;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_rotation(this Transform t, float x, float y, float z, float w)
    {
        t.rotation = new Quaternion(x, y, z, w);
    }

    public static void Get_rotation(this Transform t, out float x, out float y, out float z, out float w)
    {
        var v = t.rotation;
        x = v.x;
        y = v.y;
        z = v.z;
        w = v.w;
    }

    public static void Set_localRotation(this Transform t, float x, float y, float z, float w)
    {
        t.localRotation = new Quaternion(x, y, z, w);
    }

    public static void Get_localRotation(this Transform t, out float x, out float y, out float z, out float w)
    {
        var v = t.localRotation;
        x = v.x;
        y = v.y;
        z = v.z;
        w = v.w;
    }

    public static void Set_forward(this Transform t, float x, float y, float z)
    {
        t.forward = new Vector3(x, y, z);
    }

    public static void Get_forward(this Transform t, out float x, out float y, out float z)
    {
        var v = t.forward;
        x = v.x;
        y = v.y;
        z = v.z;
    }

    public static void Set_positionAndRotation(this Transform rt, float x, float y, float z,
        float rx, float ry, float rz, float rw)
    {
        var v = new Vector3(x, y, z);
        var r = new Quaternion(rx, ry, rz, rw);
        rt.SetPositionAndRotation(v, r);
    }

    // for GameObject
    public static void Set_position(this GameObject go, float x, float y, float z)
    {
        Set_position(go.transform, x, y, z);
    }

    public static void Get_position(this GameObject go, out float x, out float y, out float z)
    {
        Get_position(go.transform, out x, out y, out z);
    }

    public static void Set_localPosition(this GameObject go, float x, float y, float z)
    {
        Set_localPosition(go.transform, x, y, z);
    }

    public static void Get_localPosition(this GameObject go, out float x, out float y, out float z)
    {
        Get_localPosition(go.transform, out x, out y, out z);
    }

    public static void Set_localScale(this GameObject go, float x, float y, float z)
    {
        Set_localScale(go.transform, x, y, z);
    }

    public static void Get_localScale(this GameObject go, out float x, out float y, out float z)
    {
        Get_localScale(go, out x, out y, out z);
    }

    public static void Set_eulerAngles(this GameObject go, float x, float y, float z)
    {
        Set_eulerAngles(go.transform, x, y, z);
    }

    public static void Get_eulerAngles(this GameObject go, out float x, out float y, out float z)
    {
        Get_eulerAngles(go.transform, out x, out y, out z);
    }

    public static void Set_localEulerAngles(this GameObject go, float x, float y, float z)
    {
        Set_localEulerAngles(go.transform, x, y, z);
    }

    public static void Get_localEulerAngles(this GameObject go, out float x, out float y, out float z)
    {
        Get_localEulerAngles(go.transform, out x, out y, out z);
    }

    public static void Set_rotation(this GameObject go, float x, float y, float z, float w)
    {
        Set_rotation(go.transform, x, y, z, w);
    }

    public static void Get_rotation(this GameObject go, out float x, out float y, out float z, out float w)
    {
        Get_rotation(go.transform, out x, out y, out z, out w);
    }

    public static void Set_localRotation(this GameObject go, float x, float y, float z, float w)
    {
        Set_localRotation(go.transform, x, y, z, w);
    }

    public static void Get_localRotation(this GameObject go, out float x, out float y, out float z, out float w)
    {
        Get_localRotation(go.transform, out x, out y, out z, out w);
    }

    public static void Set_forward(this GameObject go, float x, float y, float z)
    {
        Set_forward(go.transform, x, y, z);
    }

    public static void Get_forward(this GameObject go, out float x, out float y, out float z)
    {
        Get_forward(go.transform, out x, out y, out z);
    }

    public static void Set_positionAndRotation(this GameObject go, float x, float y, float z,
        float rx, float ry, float rz, float rw)
    {
        Set_positionAndRotation(go.transform, x, y, z, rx, ry, rz, rw);
    }
    
    public static void Reset_localPosition(this Transform rt)
    {
        Set_localPosition(rt, 0,0, 0);
    }

    public static void Reset_localScale(this Transform rt)
    {
        Set_localScale(rt, 0, 0, 0);
    }

    // for GameObject
    public static void Reset_localPosition(this GameObject go)
    {
        Reset_localPosition(go.transform);
    }
    
    public static void Reset_localScale(this GameObject go)
    {
        Reset_localScale(go.transform);
    }
    /******************** Transform ********************/


    /******************** UGUI ********************/
    // 大部分UGUI相关的优化函数直接从Graphic这个接口导出就完了；这个比导出相应的组件（如Image，Button等）会多执行几次循环；其浪费性能可以忽略不计。
    // 关于xLua是如何实现导出数据的元表继承关系，请参考xlua的C源代码cls_indexer这个函数
    // UnityEngine.UI.Graphic
    public static void Set_color(this Graphic graphic, float r, float g, float b, float a)
    {
        graphic.color = new Color(r, g, b, a);
    }

    public static void Set_color_r(this Graphic graphic, float r)
    {
        var c = graphic.color;
        graphic.color = new Color(r, c.g, c.b, c.a);
    }

    public static void Set_color_g(this Graphic graphic, float g)
    {
        var c = graphic.color;
        graphic.color = new Color(c.r, g, c.b, c.a);
    }

    public static void Set_color_b(this Graphic graphic, float b)
    {
        var c = graphic.color;
        graphic.color = new Color(c.r, c.g, b, c.a);
    }

    public static void Set_color_a(this Graphic graphic, float a)
    {
        var c = graphic.color;
        graphic.color = new Color(c.r, c.g, c.b, a);
    }

    public static void Get_color(this Graphic graphic, out float r, out float g, out float b, out float a)
    {
        var color = graphic.color;
        r = color.r;
        g = color.g;
        b = color.b;
        a = color.a;
    }

    public static void Get_color_r(this Graphic graphic, out float r)
    {
        var color = graphic.color;
        r = color.r;
    }

    public static void Get_color_g(this Graphic graphic, out float g)
    {
        var color = graphic.color;
        g = color.g;
    }

    public static void Get_color_b(this Graphic graphic, out float b)
    {
        var color = graphic.color;
        b = color.b;
    }

    public static void Get_color_a(this Graphic graphic, out float a)
    {
        var color = graphic.color;
        a = color.a;
    }

    // SpriteRenderer
    public static void Set_size(this SpriteRenderer r, float x, float y)
    {
        r.size = new Vector2(x, y);
    }

    public static void Get_size(this SpriteRenderer r, out float x, out float y)
    {
        var s = r.size;
        x = s.x;
        y = s.y;
    }

    public static void Set_color(this SpriteRenderer sr, float r, float g, float b, float a)
    {
        sr.color = new Color(r, g, b, a);
    }

    public static void Set_color_r(this SpriteRenderer sr, float r)
    {
        var c = sr.color;
        sr.color = new Color(r, c.g, c.b, c.a);
    }

    public static void Set_color_g(this SpriteRenderer sr, float g)
    {
        var c = sr.color;
        sr.color = new Color(c.r, g, c.b, c.a);
    }

    public static void Set_color_b(this SpriteRenderer sr, float b)
    {
        var c = sr.color;
        sr.color = new Color(c.r, c.g, b, c.a);
    }

    public static void Set_color_a(this SpriteRenderer sr, float a)
    {
        var c = sr.color;
        sr.color = new Color(c.r, c.g, c.b, a);
    }

    public static void Set_color_a(this SpriteMeshRenderer sr, float a)
    {
        var c = sr.color;
        sr.color = new Color(c.r, c.g, c.b, a);
    }

    public static void Get_color(this SpriteRenderer sr, out float r, out float g, out float b, out float a)
    {
        var s = sr.color;
        r = s.r;
        g = s.g;
        b = s.b;
        a = s.a;
    }

    public static void Get_color_r(this SpriteRenderer sr, out float r)
    {
        var s = sr.color;
        r = s.r;
    }

    public static void Get_color_g(this SpriteRenderer sr, out float g)
    {
        var s = sr.color;
        g = s.g;
    }

    public static void Get_color_b(this SpriteRenderer sr, out float b)
    {
        var s = sr.color;
        b = s.b;
    }

    public static void Get_color_a(this SpriteRenderer sr, out float a)
    {
        var s = sr.color;
        a = s.a;
    }

    /******************** UGUI ********************/

    public static void Get_TargetPos(this MobileTouchCamera touchCamera, out float x, out float y, out float z)
    {
        var v = touchCamera.GetFinger0PosWorld();
        x = v.x;
        y = v.y;
        z = v.z;
    }


    /********************* TextMeshProUGUI **************************/
    public static void Native_SetText(this TextMeshProUGUI text, string value)
    {
        if (value != null)
        {
            //目前C项目没有场景用到反转义 徒增消耗 因此先屏蔽
            //text.text = System.Text.RegularExpressions.Regex.Unescape(value);
            text.text = value;
        }
        else
        {
            //Log.Error("value is null!");
            text.text = "";
        }
    }

    public static void Native_SetText(this TextMeshProUGUI text, int value)
    {
        var str = StringUtils.IntToString(value);
        text.Native_SetText(str);
    }
    
    public static void SetTextCacheID(this TextMeshProUGUI text, int cacheID)
    {
        var str = LuaStringLookupTable.Get(cacheID);
        text.Native_SetText(str);
    }
    
    // 获取字符数量
    public static int GetCharacterCount(this TextMeshProUGUI text)
    {
        var info = text.textInfo;
        if (info != null)
        {
            return info.characterCount;
        }

        return 0;
    }
    
    public static void Native_SetText(this Text text, string value)
    {
        text.text = value ?? "";
    }
    
    // 有些控件设置数字，譬如道具数量等，使用这个接口可以简单处理一下GC问题
    public static void Native_SetText(this Text text, int value)
    {
        var str = StringUtils.IntToString(value);
        text.Native_SetText(str);
    }

    public static void SetTextCacheID(this Text text, int cacheID)
    {
        var str = LuaStringLookupTable.Get(cacheID);
        text.Native_SetText(str);
    }
    
    public static void Native_SetText(this TMP_InputField text, string value)
    {
        if (value != null)
        {
            text.text = value;
        }
        else
        {
            text.text = "";
        }
    }

    public static void Native_SetText(this TMP_InputField text, int value)
    {
        var str = StringUtils.IntToString(value);
        text.Native_SetText(str);
    }
    
    public static void SetTextCacheID(this TMP_InputField text, int cacheID)
    {
        var str = LuaStringLookupTable.Get(cacheID);
        text.Native_SetText(str);
    }
    
    public static void Native_SetText(this SuperTextMesh text, string value)
    {
        text.text = value ?? "";
    }
    
    public static void Native_SetText(this SuperTextMesh text, int value)
    {
        var str = StringUtils.IntToString(value);
        text.Native_SetText(str);
    }
    
    public static void SetTextCacheID(this SuperTextMesh text, int cacheID)
    {
        var str = LuaStringLookupTable.Get(cacheID);
        text.Native_SetText(str);
    }
    
    // NavMesh
    public static void SetDestinationXYZ(this UnityEngine.AI.NavMeshAgent agent, float x, float y, float z)
    {
        agent.SetDestination(new Vector3(x, y, z));
    }

    public static void Get_velocity(this UnityEngine.AI.NavMeshAgent agent, out float x, out float y, out float z)
    {
        x = agent.velocity.x;
        y = agent.velocity.y;
        z = agent.velocity.z;
    }
    
    public static bool IsVelocityZero(this UnityEngine.AI.NavMeshAgent agent)
    {
        // Vector3 v = agent.velocity;
        if (agent.velocity.AlmostZero())
        {
            return true;
        }

        return false;
    }

    /********************* Camera **************************/
    public static void WorldToScreenPoint_opti(this Camera camera, float x, float y, float z, out float ox, out float oy, out float oz)
    { 
        Vector3 position = new Vector3(x, y, z);
        Vector3 ret = camera.WorldToScreenPoint(position);
        ox = ret.x;
        oy = ret.y;
        oz = ret.z;
    }


    public static void WorldToViewportPoint_opti(this Camera camera, float x, float y, float z, out float ox, out float oy, out float oz)
    {
        Vector3 position = new Vector3(x, y, z);
        Vector3 ret = camera.WorldToViewportPoint(position);
        ox = ret.x;
        oy = ret.y;
        oz = ret.z;
    }
    
    public static void ViewportToWorldPoint_opti(this Camera camera, float x, float y, float z, out float ox, out float oy, out float oz)
    {
        Vector3 position = new Vector3(x, y, z);
        Vector3 ret = camera.ViewportToWorldPoint(position);
        ox = ret.x;
        oy = ret.y;
        oz = ret.z;
    }
    
    public static void ScreenToWorldPoint_opti(this Camera camera, float x, float y, float z, out float ox, out float oy, out float oz)
    {
        Vector3 position = new Vector3(x, y, z);
        Vector3 ret = camera.ScreenToWorldPoint(position);
        ox = ret.x;
        oy = ret.y;
        oz = ret.z;
    }

    public static bool HasCsClass(int cacheId)
    {
        var className = LuaStringLookupTable.Get(cacheId);
        if (string.IsNullOrEmpty(className))
            return false;
        
        return Type.GetType(className) != null;
    }

    public static SuperScrollView.LoopListViewItem2 NewListViewItem(this SuperScrollView.LoopListView2 loopList, int itemPrefabNameCacheId)
    {
        var prefabName = LuaStringLookupTable.Get(itemPrefabNameCacheId);
        if (string.IsNullOrEmpty(prefabName))
            return null;

        return loopList.NewListViewItem(prefabName);
    }
}





