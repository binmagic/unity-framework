//------------------------------------------------------------
// Game Framework v3.x
// Copyright © 2013-2018 Jiang Yin. All rights reserved.
// Homepage: http://gameframework.cn/
// Feedback: mailto:jiangyin@gameframework.cn
//------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Text;
using GameFramework;
using Main.Scripts.Network;
using TMPro;
using Unity.IL2CPP.CompilerServices;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Playables;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Scripting;
using UnityEngine.UI;
using LuaAPI = XLua.LuaDLL.Lua;
using Object = UnityEngine.Object;

/// <summary>
/// Unity 扩展。
/// </summary>
[Il2CppSetOption(Option.NullChecks, false)]
[Preserve]
public static class UnityExtension_Common
{
    public static int ToInt(this string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return 0;
        }

        // if (str.Equals(" "))
        //     return 0;

        // 我们数值中会有大量的0-9这样的数值处理，所以这简单处理一下
        if (str.Length == 1)
        {
            if (str[0] >= '0' && str[0] <= '9')
            {
                return str[0] - '0';
            }

            if (str[0] == ' ')
            {
                return 0;
            }
        }

        int i = 0;
        if (int.TryParse(str, out i) == false)
        {
            // if (Log.Write)
            // {
            //     Log.Error("ToInt error!!!! str: {0}", str);
            // }
        }

        return i;
    }


    public static int ToInt(this object obj)
    {
        if (obj is string)
        {
            return ToInt((string) obj);
        }

        int i = 0;
        try
        {
            //int.TryParse(obj.ToString(), out i);
            //return i;
            i = Convert.ToInt32(obj);
        }
        catch (Exception e)
        {
            // if (Log.Write)
            // {
            //     Log.Error("ToInt exception !!!! try ToString");
            // }

            // FIXME: 有些obj不能直接ToInt32，必须要ToString之后再转
            // 理论来说，这属于一个调用问题，但是这里也得做一个兼容，毕竟这个接口的参数是object
            return ToInt(obj.ToString());
        }

        return i;
    }

    // 这个函数用来实现ReadOnlySpan.ToInt，这个转化只支持10进制。
    // 目前这个代码支持前端有空格，但不支持数字中间有空格的情况。
    public static int ToInt(this ReadOnlySpan<char> str)
    {
        int sign = 1, Base = 0, i = 0;
        char chr_i;
        
        // if whitespaces then ignore.
        while (i < str.Length && str[i] == ' ')
        {
            i++;
        }

        // sign of number
        if (i < str.Length)
        {
            if (str[i] == '-' || str[i] == '+')
            {
                sign = 1 - 2 * (str[i++] == '-' ? 1 : 0);
            }
        }

        // checking for valid input
        while (i < str.Length)
        {
            // 缓存一下，不要每次去取了，这里貌似C#没有做优化处理
            chr_i = str[i];
            if (chr_i >= '0' && chr_i <= '9')
            {
                // handling overflow test case
                if (Base > int.MaxValue / 10 || (Base == int.MaxValue / 10 && chr_i - '0' > 7))
                {
                    if (sign == 1)
                        return int.MaxValue;
                    else
                        return int.MinValue;
                }

                Base = 10 * Base + (chr_i - '0');
            }
            else
            {
                break;
            }

            i++;
        }

// #if UNITY_EDITOR && !FINAL_RELEASE
//         int ttt = str.ToString().ToInt();
//         if (ttt != Base * sign)
//         {
//             Log.Error("BUGBUGBUG! ToInt() not same!");
//         }
// #endif

        return Base * sign;
    }

    public static float ToFloat(this string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return 0;
        }

        float i = 0f;
        try
        {
            i = Convert.ToSingle(str);
        }
        catch (Exception e)
        {
            Debug.LogErrorFormat("ToFloat error!!!! str: {0}", str);
        }

        return i;
    }

    public static string GetFullPath(this Transform transform)
    {
        if (transform.parent == null)
        {
            return transform.name;
        }
        else
        {
            return GetFullPath(transform.parent) + "/" + transform.name;
        }
    }
    
    // 为了直接从ReadOnlySpan -> float!
    public static float ToFloat(this ReadOnlySpan<char> str)
    {
        if (str.Length == 0)
        {
            return 0;
        }
        
        float f = (float) Strtod_CSharp.strtod(str);

// #if UNITY_EDITOR && !FINAL_RELEASE
//         float ttt = str.ToString().ToFloat();
//         if (!Mathf.Approximately(f, ttt))
//         {
//             Log.Error("BUGBUGBUG! ToFloat() not same!");
//         }
// #endif

        return f;
    }

    // ReadOnlySpan => ToULong
    public static ulong ToULong(this ReadOnlySpan<char> str)
    {
        ulong u = Strtoul_CSharp.strtoul(str);

// #if UNITY_EDITOR
//         ulong ttt = Convert.ToUInt64(str.ToString());
//         if (ttt != u)
//         {
//             Log.Error("BUGBUGBUG! ToULong() not same!");
//         }
// #endif
        return u;
    }

    public static float ToFloat(this long value)
    {
        float i = 0f;
        try
        {
            i = Convert.ToSingle(value);
        }
        catch (Exception e)
        {
            // if (Log.Write)
            // {
            //     Log.Error("ToFloat exception !!!! try ToString");
            // }

            return ToFloat(value.ToString());
        }
        return i;
    }

    public static float ToFloat(this object obj)
    {
        if (obj is string)
        {
            return ToFloat((string) obj);
        }

        float i = 0f;
        try
        {
            i = Convert.ToSingle(obj);
        }
        catch (Exception e)
        {
            // if (Log.Write)
            // {
            //     Log.Error("ToFloat exception !!!! try ToString");
            // }

            return ToFloat(obj.ToString());
        }

        return i;
    }

    public static long ToLong(this string str)
    {
        long i = 0;
        if (str.Contains("."))
        {
            List<string> strVec = new List<string>();
            StringUtils.SplitString(str, '.', ref strVec);
            long.TryParse(strVec[0], out i);
        }
        else
        {
            long.TryParse(str, out i);
        }

        return i;
    }

    public static GameObject Instantiate(this GameObject go)
    {
        if (go != null)
        {
            return GameObject.Instantiate(go);
        }

        return go;
    }

    public static void Destroy(this GameObject go)
    {
        if (go != null)
        {
            GameObject.Destroy(go);
        }
    }

    /// <summary>
    /// 获取 GameObject 是否在场景中。
    /// </summary>
    /// <param name="gameObject">目标对象。</param>
    /// <returns>GameObject 是否在场景中。</returns>
    /// <remarks>若返回 true，表明此 GameObject 是一个场景中的实例对象；若返回 false，表明此 GameObject 是一个 Prefab。</remarks>
    public static bool InScene(this GameObject gameObject)
    {
        return gameObject.scene.name != null;
    }

    /// <summary>
    /// 递归设置游戏对象的层次。
    /// </summary>
    /// <param name="gameObject"><see cref="UnityEngine.GameObject" /> 对象。</param>
    /// <param name="layer">目标层次的编号。</param>
    public static void SetLayerRecursively(this GameObject gameObject, int layer)
    {
        Transform[] transforms = gameObject.GetComponentsInChildren<Transform>(true);
        for (int i = 0; i < transforms.Length; i++)
        {
            transforms[i].gameObject.layer = layer;
        }
    }
    
    //排除指定层级
    public static void CullCameraMask(this Camera camera, string layerMask)
    {
        int _layerMask = 1 << LayerMask.NameToLayer(layerMask);
        camera.cullingMask &= ~_layerMask;
    }

    public static void SetTagRecursively(this GameObject gameObject, string tag)
    {
        Transform[] transforms = gameObject.GetComponentsInChildren<Transform>(true);
        for (int i = 0; i < transforms.Length; i++)
        {
            transforms[i].gameObject.tag = tag;
        }
    }

    /// <summary>
    /// 取 <see cref="UnityEngine.Vector3" /> 的 (x, y, z) 转换为 <see cref="UnityEngine.Vector2" /> 的 (x, z)。
    /// </summary>
    /// <param name="vector3">要转换的 Vector3。</param>
    /// <returns>转换后的 Vector2。</returns>
    public static Vector2 ToVector2(this Vector3 vector3)
    {
        return new Vector2(vector3.x, vector3.z);
    }

    /// <summary>
    /// 取 <see cref="UnityEngine.Vector2" /> 的 (x, y) 转换为 <see cref="UnityEngine.Vector3" /> 的 (x, 0, y)。
    /// </summary>
    /// <param name="vector2">要转换的 Vector2。</param>
    /// <returns>转换后的 Vector3。</returns>
    public static Vector3 ToVector3(this Vector2 vector2)
    {
        return new Vector3(vector2.x, 0f, vector2.y);
    }

    // 编辑器模式下只能使用DestroyImmediate
    // 而运行模式使用DestroyImmediate又会有隐患。。。所以这个函数出现了
    public static void DestroyEx(this GameObject obj)
    {
        if (Application.isPlaying)
        {
            GameObject.Destroy(obj);
        }
        else
        {
            GameObject.DestroyImmediate(obj, false);
        }
    }
    
    public static void SetTimeStamp(this Text text, long leftMilliSecond)
    {
        text.text = GameEntry.Timer.MilliSecondToFmtString(leftMilliSecond);
    }

    // 删除所有子节点，这个处理放到C#，由LUA端调用即可
    public static void DeleteAllChildNodes(this Transform transform)
    {
        int childs = transform.childCount;
        for (int i = childs - 1; i > 0; i--)
        {
            GameObject.Destroy(transform.GetChild(i).gameObject);
        }
    }
    
    public static void SetVolume_VignetteCenter(this Volume volume, Vector2 center)
    {
        List<VolumeComponent> list = volume.profile.components;
        for (int i = 0; i < list.Count; ++i)
        {
            if (list[i] is Vignette)
            {
                Vignette vignette = list[i] as Vignette;
                if (vignette != null)
                {
                    vignette.center.Override(center);
                }
            }
        }
    }
}


[Il2CppSetOption(Option.NullChecks, false)]
[Preserve]
public static class UnityExtension_Transform
{
    
    /// <summary>
    /// 设置绝对位置的 x 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">x 坐标值。</param>
    public static void SetPositionX(this Transform transform, float newValue)
    {
        Vector3 v = transform.position;
        v.x = newValue;
        transform.position = v;
    }

    /// <summary>
    /// 设置绝对位置的 y 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">y 坐标值。</param>
    public static void SetPositionY(this Transform transform, float newValue)
    {
        Vector3 v = transform.position;
        v.y = newValue;
        transform.position = v;
    }

    /// <summary>
    /// 设置绝对位置的 z 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">z 坐标值。</param>
    public static void SetPositionZ(this Transform transform, float newValue)
    {
        Vector3 v = transform.position;
        v.z = newValue;
        transform.position = v;
    }

    /// <summary>
    /// 增加绝对位置的 x 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">x 坐标值增量。</param>
    public static void AddPositionX(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.position;
        v.x += deltaValue;
        transform.position = v;
    }

    /// <summary>
    /// 增加绝对位置的 y 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">y 坐标值增量。</param>
    public static void AddPositionY(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.position;
        v.y += deltaValue;
        transform.position = v;
    }

    /// <summary>
    /// 增加绝对位置的 z 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">z 坐标值增量。</param>
    public static void AddPositionZ(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.position;
        v.z += deltaValue;
        transform.position = v;
    }

    /// <summary>
    /// 设置相对位置的 x 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">x 坐标值。</param>
    public static void SetLocalPositionX(this Transform transform, float newValue)
    {
        Vector3 v = transform.localPosition;
        v.x = newValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 设置相对位置的 y 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">y 坐标值。</param>
    public static void SetLocalPositionY(this Transform transform, float newValue)
    {
        Vector3 v = transform.localPosition;
        v.y = newValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 设置相对位置的 z 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">z 坐标值。</param>
    public static void SetLocalPositionZ(this Transform transform, float newValue)
    {
        Vector3 v = transform.localPosition;
        v.z = newValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 增加相对位置的 x 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">x 坐标值。</param>
    public static void AddLocalPositionX(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localPosition;
        v.x += deltaValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 增加相对位置的 y 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">y 坐标值。</param>
    public static void AddLocalPositionY(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localPosition;
        v.y += deltaValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 增加相对位置的 z 坐标。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">z 坐标值。</param>
    public static void AddLocalPositionZ(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localPosition;
        v.z += deltaValue;
        transform.localPosition = v;
    }

    /// <summary>
    /// 设置相对尺寸的 x 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">x 分量值。</param>
    public static void SetLocalScaleX(this Transform transform, float newValue)
    {
        Vector3 v = transform.localScale;
        v.x = newValue;
        transform.localScale = v;
    }

    /// <summary>
    /// 设置相对尺寸的 y 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">y 分量值。</param>
    public static void SetLocalScaleY(this Transform transform, float newValue)
    {
        Vector3 v = transform.localScale;
        v.y = newValue;
        transform.localScale = v;
    }

    /// <summary>
    /// 设置相对尺寸的 z 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="newValue">z 分量值。</param>
    public static void SetLocalScaleZ(this Transform transform, float newValue)
    {
        Vector3 v = transform.localScale;
        v.z = newValue;
        transform.localScale = v;
    }

    /// <summary>
    /// 增加相对尺寸的 x 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">x 分量增量。</param>
    public static void AddLocalScaleX(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localScale;
        v.x += deltaValue;
        transform.localScale = v;
    }

    /// <summary>
    /// 增加相对尺寸的 y 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">y 分量增量。</param>
    public static void AddLocalScaleY(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localScale;
        v.y += deltaValue;
        transform.localScale = v;
    }

    /// <summary>
    /// 增加相对尺寸的 z 分量。
    /// </summary>
    /// <param name="transform"><see cref="UnityEngine.Transform" /> 对象。</param>
    /// <param name="deltaValue">z 分量增量。</param>
    public static void AddLocalScaleZ(this Transform transform, float deltaValue)
    {
        Vector3 v = transform.localScale;
        v.z += deltaValue;
        transform.localScale = v;
    }
    
    public static Transform FindChildEx(this Transform root, string childName, bool includeInVisible)
    {
        if (root == null) return null;
        var ts = root.transform.GetComponentsInChildren<Transform>(includeInVisible);
        foreach (var t in ts)
        {
            if (t.gameObject.name == childName)
                return t;
        }

        return null;
    }
    
    public static Transform FindChildIdEx(this Transform root, int childNameId, bool includeInVisible)
    {
        var name = LuaStringLookupTable.Get(childNameId);
        return FindChildEx(root, name, includeInVisible);
    }
}

[Il2CppSetOption(Option.NullChecks, false)]
[Preserve]
public static class UnityExtension_StringLookup
{
    // ---------------- SimpleAnimation ----------------------
    public static bool Play(this SimpleAnimation ani, int stateNameToId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        return ani.Play(stateName);
    }
    
    public static void Rewind(this SimpleAnimation ani, int stateNameToId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        ani.Rewind(stateName);
    }

    public static bool IsPlaying(this SimpleAnimation ani, int stateNameToId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        return ani.IsPlaying(stateName);
    }
    
    public static void PlayQueued(this SimpleAnimation simpleAni, int stateNameToId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        simpleAni.PlayQueued(stateName);
    }
    
    public static SimpleAnimation.State GetState(this SimpleAnimation simpleAni, int stateNameToId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        return simpleAni.GetState(stateName);
    }

    public static bool HasState(this SimpleAnimation simpleAni, int stateNameId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        return simpleAni.HasState(stateName);
    }
    
    public static float GetClipLength(this SimpleAnimation simpleAni, int stateNameId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        return simpleAni.GetClipLength(stateName);
    }

    public static float GetClipTime(this SimpleAnimation simpleAni, int stateNameId)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        return simpleAni.GetClipTime(stateName);
    }
    
    public static void CrossFade(this SimpleAnimation simpleAni, int stateNameId, float fadeLength)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        simpleAni.CrossFade(stateName, fadeLength);
    }

    public static void CrossFadeQueued(this SimpleAnimation simpleAni, int stateNameId, float fadeLength, QueueMode queueMode)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        simpleAni.CrossFadeQueued(stateName, fadeLength, queueMode);
    }
    
    public static void SetStateSpeed(this SimpleAnimation simpleAni, int stateNameId, float speed)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        simpleAni.SetStateSpeed(stateName, speed);
    }

    public static void SetStateTime(this SimpleAnimation simpleAni, int stateNameId, float time)
    {
        var stateName = LuaStringLookupTable.Get(stateNameId);
        simpleAni.SetStateTime(stateName, time);
    }
    // ---------------- SimpleAnimation ----------------------
    
    /*public static void PlayAnimation(this SurvivalLodEx lodEx, int animationNameId)
    {
        var aniName = LuaStringLookupTable.Get(animationNameId);
        lodEx.PlayAnimation(aniName);
    }*/


    public static void Play(this Animator ani, int stateNameToId, int layerIdx, float normalizedTime)
    {
        var stateName = LuaStringLookupTable.Get(stateNameToId);
        ani.Play(stateName, layerIdx, normalizedTime);
    }

    public static void SetTrigger(this Animator ani, int triggerNameToId)
    {
        var triggerName = LuaStringLookupTable.Get(triggerNameToId);
        ani.SetTrigger(triggerName);
    }

    public static Transform Find(this Transform tran, int pathToId)
    {
        var path = LuaStringLookupTable.Get(pathToId);
        return tran.Find(path);
    }

    public static void EnableKeyword(this Material mater, int id)
    {
        var str = LuaStringLookupTable.Get(id);
        mater.EnableKeyword(str);
    }
    
    public static void DisableKeyword(this Material mater, int id)
    {
        var str = LuaStringLookupTable.Get(id);
        mater.DisableKeyword(str);
    }

    public static InstanceRequest InstantiateAsync(this ResourceManager resMgr, int prefabPathId, Action<InstanceRequest> callback = null, Transform presetParent = null)
    {
        return InstantiateAsyncId(resMgr, prefabPathId, callback, presetParent);
    }
        
    public static InstanceRequest InstantiateAsyncId(this ResourceManager resMgr, int prefabPathId,
        Action<InstanceRequest> callback = null, Transform presetParent = null)
    {
        var path = LuaStringLookupTable.Get(prefabPathId);
        if (path.IsNullOrEmpty())
        {
            Log.Info("not found path id!");
            return null;
        }

        var req = resMgr.InstantiateAsync(path, presetParent);
        if (req != null)
        {
            if (callback != null)
            {
                req.completed += callback;
            }

            return req;
        }

        return null;
    }
    
    // 播放音效
    public static int PlayEffect(this SoundComponent sound, int effectId, bool loop = false, float volume = 1.0f, int groupId = -1)
    {
        var effect = LuaStringLookupTable.Get(effectId);
        var groupName = LuaStringLookupTable.Get(groupId);
        return sound.PlayEffect(effect, loop, volume, groupName);
    }

    public static int PlaySound(this SoundComponent sound, int effectId, string soundGroupName, SoundComponent.PlaySoundParams playSoundParams,
        object userData, Action<bool, int> action = null)
    {
        var effect = LuaStringLookupTable.Get(effectId);
        return sound.PlaySound(effect, soundGroupName, playSoundParams, userData, action);
    }

    public static int PlayWorldScopeEffect(this SoundComponent sound, int effectId, bool loop = false)
    {
        var effect = LuaStringLookupTable.Get(effectId);
        return sound.PlayWorldScopeEffect(effect, loop);
    }
    
    public static bool IsAssetDownloaded(this ResourceManager res, int pathId)
    {
        var path = LuaStringLookupTable.Get(pathId);
        return res.IsAssetDownloaded(path);
    }

    public static void SetName(this Object obj, int nameId)
    {
        var name = LuaStringLookupTable.Get(nameId);
        if (name == null) name = "";
        obj.name = name;
    }
    
    public static void LoadSprite(this Image image, int spritePathId, string defaultSprite = null)
    {
        var spritePath = LuaStringLookupTable.Get(spritePathId);
        UnityUIExtension.LoadSprite(image, spritePath, defaultSprite);
    }
    
    public static void LoadSprite(this CircleImage image, int spritePathId, string defaultSprite = null)
    {
        var spritePath = LuaStringLookupTable.Get(spritePathId);
        UnityUIExtension.LoadSprite(image, spritePath, defaultSprite);
    }
    
    public static void LoadSprite(this SpriteRenderer spriteRenderer, int spritePathId, string defaultSprite = null)
    {
        var spritePath = LuaStringLookupTable.Get(spritePathId);
        UnityUIExtension.LoadSprite(spriteRenderer, spritePath, defaultSprite);
    }
    
    public static void LoadSprite(this SpriteMeshRenderer meshRenderer, int spritePathId, string defaultSprite = null)
    {
        var spritePath = LuaStringLookupTable.Get(spritePathId);
        UnityUIExtension.LoadSprite(meshRenderer, spritePath, defaultSprite);
    }
    
    // 发送lua消息这里以后得深度处理一下，目前先简单处理一下
    public static void SendLuaMessage(this NetworkManager netMgr, int msgToId, byte[] sfsObjBinary)
    {
        var msgId = LuaStringLookupTable.Get(msgToId);
        netMgr.SendLuaMessage(msgId, sfsObjBinary);
    }

    public static void onSendRequest(this FutureManager mgr, int fuid, int msgIntId)
    {
        var msgId = LuaStringLookupTable.Get(msgIntId);
        mgr.onSendRequest(fuid, msgId);
    }

    public static void StopGroupSound(this SoundComponent s, int soundGroupNameId)
    {
        var soundGroupName = LuaStringLookupTable.Get(soundGroupNameId);
        s.StopGroupSound(soundGroupName);
    }
}

[Il2CppSetOption(Option.NullChecks, false)]
[Preserve]
public static class UnityExtension_LocalText
{
    static object[] arrParam = new object[16];

    private static string GetParamString()
    {
        IntPtr L = GameEntry.Lua.Env.L;

        // top上至少有2个参数，即obj和dialogId
        int gen_param_count = LuaAPI.lua_gettop(L);
        if (gen_param_count < 2)
        {
            return "";
        }

        string dialogId = "";
        if (LuaAPI.lua_isinteger(L, 2))
        {
            int nDialog = LuaAPI.xlua_tointeger(L, 2);
            dialogId = StringUtils.IntToString(nDialog);
        }
        else if (LuaAPI.lua_isstring(L, 2))
        {
            dialogId = LuaAPI.lua_tostring(L, 2);
        }

        if (gen_param_count == 2)
        {
            string s = GameEntry.Localization.GetString(dialogId, null);
            return s;
        }

        if (gen_param_count > 16)
        {
            Log.Error("SetLocalText too much params! max count = 0");
            gen_param_count = 16;
        }

        int param_count = gen_param_count - 2;
        for (int i = 0; i < param_count; ++i)
        {
            int index = i + 3;
            if (LuaAPI.lua_isinteger(L, index))
            {
                arrParam[i] = LuaAPI.xlua_tointeger(L, index);
            }
            else if (LuaAPI.lua_isnumber(L, index))
            {
                arrParam[i] = LuaAPI.lua_tonumber(L, index);
            }
            else
            {
                arrParam[i] = LuaAPI.lua_tostring(L, index);
            }

            if (arrParam[i] == null)
            {
                arrParam[i] = "";
            }
        }

        // 其余置null
        Array.Clear(arrParam, param_count, arrParam.Length - param_count);
        return GameEntry.Localization.GetString(dialogId, arrParam);
    }

    public static void SetLocalText(this Text obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    public static void SetLocalText(this NewText obj)
    {
        string result = GetParamString();
        obj.text = result;
    }
    
    public static void SetLocalText(this NewTMP3DText obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    public static void SetLocalText(this TextMeshPro obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    public static void SetLocalText(this TextMeshProUGUI obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    public static void SetLocalText(this InputField obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    public static void SetLocalText(this SuperTextMesh obj)
    {
        string result = GetParamString();
        obj.text = result;
    }

    private static StringFormat SF = new StringFormat();
    public static void SetLocalTextFormat(this Text obj, int formatId)
    {
        var format = LuaStringLookupTable.Get(formatId);
        var str = SF.vsprintf(format);
        obj.text = str;
    }
}   


[Il2CppSetOption(Option.NullChecks, false)]
[Preserve]
public static class UnityExtension_Component
{
    public static Component FindAndGetComponent(this Transform tran, string path, Type type)
    {
        var child = tran.Find(path);
        if (child == null)
        {
            return null;
        }
        
        var t = child.GetComponent(type);
        return t;
    }

    public static T FindAndGetComponent<T>(this Transform tran, int pathId)
    {
        var path = LuaStringLookupTable.Get(pathId);
        return FindAndGetComponent<T>(tran, path);
    }
    
    public static T FindAndGetComponent<T>(this Transform tran, string path)
    {
        var child = tran.Find(path);
        if (child == null)
        {
            return default(T);
        }

        var t = child.GetComponent<T>();
        return t;
    }

    public static Component GetComponent_RectTransform(this Transform tran)
    {
        return tran.GetComponent<RectTransform>();
    }
    
    public static Component GetComponent_RectTransform(this GameObject obj)
    {
        return obj.GetComponent<RectTransform>();
    }
    
    public static Component FindAndGet_RectTransform(this Transform tran, string path)
    {
        return FindAndGetComponent<RectTransform>(tran, path);
    }
    
    public static Component FindAndGet_RectTransform(this Transform tran, int pathId)
    {
        return FindAndGetComponent<RectTransform>(tran, pathId);
    }
    
    public static Component GetComponent_Text(this Transform tran)
    {
        return tran.GetComponent<Text>();
    }
    
    public static Component GetComponent_Text(this GameObject obj)
    {
        return obj.GetComponent<Text>();
    }
    
    public static Component FindAndGet_Text(this Transform tran, string path)
    {
        return FindAndGetComponent<Text>(tran, path);
    }
    
    public static Component FindAndGet_Text(this Transform tran, int pathId)
    {
        return FindAndGetComponent<Text>(tran, pathId);
    }
    
    public static Component GetComponent_Image(this Transform tran)
    {
        return tran.GetComponent<Image>();
    }
    
    public static Component GetComponent_Image(this GameObject obj)
    {
        return obj.GetComponent<Image>();
    }
    
    public static Component FindAndGet_Image(this Transform tran, string path)
    {
        return FindAndGetComponent<Image>(tran, path);
    }
    
    public static Component FindAndGet_Image(this Transform tran, int pathId)
    {
        return FindAndGetComponent<Image>(tran, pathId);
    }
    
    public static Component GetComponent_SpriteRenderer(this Transform tran)
    {
        return tran.GetComponent<SpriteRenderer>();
    }
    
    public static Component GetComponent_SpriteRenderer(this GameObject obj)
    {
        return obj.GetComponent<SpriteRenderer>();
    }
    
    public static Component FindAndGet_SpriteRenderer(this Transform tran, string path)
    {
        return FindAndGetComponent<SpriteRenderer>(tran, path);
    }
    
    public static Component FindAndGet_SpriteRenderer(this Transform tran, int pathId)
    {
        return FindAndGetComponent<SpriteRenderer>(tran, pathId);
    }

    public static Component GetComponent_Button(this Transform tran)
    {
        return tran.GetComponent<Button>();
    }
    
    public static Component GetComponent_Button(this GameObject obj)
    {
        return obj.GetComponent<Button>();
    }
    
    public static Component FindAndGet_Button(this Transform tran, string path)
    {
        return FindAndGetComponent<Button>(tran, path);
    }
    
    public static Component FindAndGet_Button(this Transform tran, int pathId)
    {
        return FindAndGetComponent<Button>(tran, pathId);
    }
    
    public static Component GetComponent_TextMeshPro(this Transform tran)
    {
        return tran.GetComponent<TextMeshProUGUI>();
    }
    
    public static Component GetComponent_TextMeshPro(this GameObject obj)
    {
        return obj.GetComponent<TextMeshProUGUI>();
    }
    
    public static Component FindAndGet_TextMeshPro(this Transform tran, string path)
    {
        return FindAndGetComponent<TextMeshProUGUI>(tran, path);
    }
    
    public static Component FindAndGet_TextMeshPro(this Transform tran, int pathId)
    {
        return FindAndGetComponent<TextMeshProUGUI>(tran, pathId);
    }
    
    public static Component GetComponent_Animator(this Transform tran)
    {
        return tran.GetComponent<Animator>();
    }
    
    public static Component GetComponent_Animator(this GameObject obj)
    {
        return obj.GetComponent<Animator>();
    }
    
    public static Component FindAndGet_Animator(this Transform tran, string path)
    {
        return FindAndGetComponent<Animator>(tran, path);
    }

    public static Component FindAndGet_Animator(this Transform tran, int pathId)
    {
        return FindAndGetComponent<Animator>(tran, pathId);
    }
    
    public static Component GetComponent_SimpleAnimation(this Transform tran)
    {
        return tran.GetComponent<SimpleAnimation>();
    }
    
    public static Component GetComponent_SimpleAnimation(this GameObject obj)
    {
        return obj.GetComponent<SimpleAnimation>();
    }
    
    public static Component FindAndGet_SimpleAnimation(this Transform tran, string path)
    {
        return FindAndGetComponent<SimpleAnimation>(tran, path);
    }

    public static Component FindAndGet_SimpleAnimation(this Transform tran, int pathId)
    {
        return FindAndGetComponent<SimpleAnimation>(tran, pathId);
    }

    public static Component GetComponent_UIEventTrigger(this Transform tran)
    {
        return tran.GetComponent<UIEventTrigger>();
    }
    
    public static Component GetComponent_UIEventTrigger(this GameObject obj)
    {
        return obj.GetComponent<UIEventTrigger>();
    }
    
    public static Component GetComponent_UIExtraData(this Transform tran)
    {
        return tran.GetComponent<UIExtraData>();
    }
    
    public static Component GetComponent_UIExtraData(this GameObject obj)
    {
        return obj.GetComponent<UIExtraData>();
    }
    
    public static int GetComponent_UIExtraSound(this Transform tran)
    {
        if (tran == null)
        {
            return 0;
        }
        var component = tran.GetComponent<UIExtraData>();
        return component != null ? component.soundId : 0;
    }
    
    public static int GetComponent_UIExtraSound(this GameObject obj)
    {
        if (obj == null)
        {
            return 0;
        }
        var component = obj.GetComponent<UIExtraData>();
        return component != null ? component.soundId : 0;
    }

    public static Component GetComponent_ParticleSystem(this Transform tran)
    {
        return tran.GetComponent<ParticleSystem>();
    }
    
    public static Component GetComponent_ParticleSystem(this GameObject obj)
    {
        return obj.GetComponent<ParticleSystem>();
    }

    /*public static Component GetComponent_CitySpaceManTrigger(this Transform tran)
    {
        return tran.GetComponent<CitySpaceManTrigger>();
    }

    public static Component GetComponent_CitySpaceManTrigger(this GameObject obj)
    {
        return obj.GetComponent<CitySpaceManTrigger>();
    }*/

    public static Component GetComponent_TouchObjectEventTrigger(this Transform tran)
    {
        return tran.GetComponent<TouchObjectEventTrigger>();
    }

    public static Component GetComponent_TouchObjectEventTrigger(this GameObject obj)
    {
        return obj.GetComponent<TouchObjectEventTrigger>();
    }
    
    public static Component GetComponent_SpriteMeshRenderer(this Transform tran)
    {
        return tran.GetComponent<SpriteMeshRenderer>();
    }
    
    public static Component GetComponent_SpriteMeshRenderer(this GameObject obj)
    {
        return obj.GetComponent<SpriteMeshRenderer>();
    }

    public static Component GetComponent_MeshRenderer(this Transform tran)
    {
        return tran.GetComponent<MeshRenderer>();
    }
    
    public static Component GetComponent_MeshRenderer(this GameObject obj)
    {
        return obj.GetComponent<MeshRenderer>();
    }
    
    // private static Dictionary<string, PlayableBinding> bindingDict = new Dictionary<string, PlayableBinding>();
    //动态修改Timeline的绑定节点
    public static void SetTimelineBind(this PlayableDirector director, string key, GameObject obj)
    {
        foreach (var bind in director.playableAsset.outputs)
        {Debug.Log($">>>streamName: {bind.streamName}");
            if (bind.streamName.Equals(key))
            {
                director.SetGenericBinding(bind.sourceObject, obj);
                break;
            }
        }
    }

    
    /******************** Animator ********************/
    //获取当前动画状态的时长，如果是同一帧刚播放，则下一帧获取才可以获得准确的时间
    //如果当前播放的不是目标动画，则时长返回-1
    public static float GetCurrentAnimatorStateLength(this Animator animator,string stateName)
    {
        AnimatorStateInfo info = animator.GetCurrentAnimatorStateInfo(0);
        float length = -1;
        if (info.IsName(stateName))
        {
            AnimatorClipInfo[] clipInfos = animator.GetCurrentAnimatorClipInfo(0);
            if (clipInfos.Length == 1)
            {
                AnimatorClipInfo clipInfo = clipInfos[0];
                length = clipInfo.clip.length;
                // Debug.LogError("current1,normalizedTime: "+info.normalizedTime+", speed:"+info.speed+", speedMultiplier:"+info.speedMultiplier);
            }
            else if(clipInfos.Length > 0)
            {
                length = info.length;
                // Debug.LogError("current2 ，normalizedTime: "+info.normalizedTime+", speed:"+info.speed+", speedMultiplier:"+info.speedMultiplier);
            }
            
        }
        else
        {
            //当前播放的状态不是需要，则看看下一个状态是不是
            info = animator.GetNextAnimatorStateInfo(0);
            if (info.IsName(stateName))
            {
                AnimatorClipInfo[] clipInfos = animator.GetNextAnimatorClipInfo(0);
                if (clipInfos.Length == 1)
                {
                    AnimatorClipInfo clipInfo = clipInfos[0];
                    length = clipInfo.clip.length;
                    // Debug.LogError("next1,normalizedTime: "+info.normalizedTime+", speed:"+info.speed+", speedMultiplier:"+info.speedMultiplier);
                }
                else if(clipInfos.Length > 0)
                {
                    length = info.length;
                    // Debug.LogError("next2,normalizedTime: "+info.normalizedTime+", speed:"+info.speed+", speedMultiplier:"+info.speedMultiplier);
                }
            }
        }
        return length;
    }

    public static float GetAnimationClipLength(this Animator animator, string name)
    {
        // 确保Animator组件和AnimatorController存在
        if (animator == null || animator.runtimeAnimatorController == null)
        {
            Debug.LogErrorFormat("Animator or AnimatorController is null. {0}.", name);
            return 0f;
        }
        
        AnimationClip[] clips = animator.runtimeAnimatorController.animationClips;
        for (int i = 0; i < clips.Length; ++i)
        {
            if (clips[i].name.Equals(name))
                return clips[i].length;
        }
        
        return 0.0f;
    }
    
    public static float GetAnimationClipLength(this Animator animator, int nameId)
    {
        var aniname = LuaStringLookupTable.Get(nameId);
        return animator.GetAnimationClipLength(aniname);
    }

    public class SortRaycastHit : IComparer<RaycastHit>
    {
        public int Compare(RaycastHit a, RaycastHit b)
        {
            if (a.distance <= b.distance)
            {
                return -1;
            }
            return 1;
        }
    }
    
    private static RaycastHit[] resultHits = new RaycastHit[128];
    private static SortRaycastHit sortRaycastHit = new SortRaycastHit();
    
    public static bool Raycast(this Transform transform, Transform targetTransform,bool ignoreRayPass = false)
    {
        if (transform == targetTransform)
        {
            return false;
        }
        Vector3 originPos = transform.position;
        originPos.y += 1.5f;
        Vector3 targetPos = targetTransform.position;
        targetPos.y += 1.5f;

        float dis = Vector3.Distance(originPos, targetPos);
        Ray ray = new Ray(originPos, targetPos - originPos);
        
        // 使用NonAlloc版本
        int count = Physics.RaycastNonAlloc(ray, resultHits, dis);
        if (count > 1)
        {
            Array.Sort(resultHits, 0, count, sortRaycastHit); // 将结果按照远近排序
        }

        // RaycastHit[] hits = Physics.RaycastAll(ray, dis);
        // Array.Sort(hits, HitComparison);
        
        bool isHit = false;
        //foreach (var hit in hits)
        for (int i=0;i<count;++i)
        {
            var hit = resultHits[i];
            if (hit.transform.Equals(targetTransform))
            {
                isHit = true;
                break;
            }
            if(ignoreRayPass || !hit.transform.CompareTag("RayPass"))
            {
                break;
            }
        }
        
#if UNITY_EDITOR
        if (isHit)
        {
            Debug.DrawRay(originPos, targetPos - originPos, Color.red);
        }
#endif
        
        return isHit;
    }

    public static bool ContainsPointOnXZPlane(this Bounds bounds, Vector3 point)
    {
        // 检查点的X和Z坐标是否在Bounds的最小和最大X、Z坐标之间
        return point.x >= bounds.min.x && point.x <= bounds.max.x &&
               point.z >= bounds.min.z && point.z <= bounds.max.z;
    }
    
    // 检查bounds1是否在XZ平面上完全包含bounds2（将Y轴视为0）
    public static bool FullyContainsOnXZPlaneIgnoringY(this Bounds bounds1, Bounds bounds2)
    {
        // 获取bounds2在XZ平面上的四个角点，并将Y轴视为0
        Vector2[] cornerPointsXZ = new Vector2[4];
        
        cornerPointsXZ[0] = new Vector2(bounds2.min.x, bounds2.min.z);
        cornerPointsXZ[1] = new Vector2(bounds2.max.x, bounds2.min.z);
        cornerPointsXZ[2] = new Vector2(bounds2.min.x, bounds2.max.z);
        cornerPointsXZ[3] = new Vector2(bounds2.max.x, bounds2.max.z);

        // 将bounds1的边界也投影到XZ平面
        Vector2 minPointXZ = new Vector2(bounds1.min.x, bounds1.min.z);
        Vector2 maxPointXZ = new Vector2(bounds1.max.x, bounds1.max.z);

        foreach (Vector2 pointXZ in cornerPointsXZ)
        {
            // 检查每个角点是否都在bounds1的XZ投影内
            if (pointXZ.x < minPointXZ.x || pointXZ.x > maxPointXZ.x ||
                pointXZ.y < minPointXZ.y || pointXZ.y > maxPointXZ.y)
            {
                return false; // 如果有任何一个角点不在投影的bounds1内，则返回false
            }
        }

        return true; // 所有角点都在投影的bounds1内，返回true
    }
    
    private static int HitComparison(RaycastHit a, RaycastHit b)
    {
        if (a.distance <= b.distance)
        {
            return -1;
        }
        return 1;
    }
    
    
    public static Vector3 MulVec3(this Quaternion q, Vector3 v)
    {
        return q * v;
    }

    public static bool GetDirByAgent(NavMeshAgent agent, float x, float y, float z, out float oX,
        out float oY, out float oZ)
    {
        oX = 0;
        oY = 0;
        oZ = 0;

        if (!agent.hasPath)
        {
            return false;
        }

        var corners = agent.path.corners;
        if (corners.Length <= 1)
        {
            return false;
        }

        var pos = new Vector3(x, y, z);
        var dir = Vector3.Normalize(corners[1] - pos);
        if (dir == Vector3.zero)
        {
            return false;
        }

        oX = dir.x;
        oY = dir.y;
        oZ = dir.z;

        return true;
    }

    public static T GetComponentInParentExt<T>(this Transform rt, bool includeSelf = true) where T : Component
    {
        var t = typeof(T);
        if (includeSelf)
        {
            return rt.GetComponentInParent(t) as T;
        }

        Component ret = null;
        Transform parent = rt.parent;
        while (parent != null)
        {
            ret = parent.GetComponent(t);
            if (ret != null)
            {
                break;
            }
            
            parent = parent.parent;
        }

        return ret as T;
    }

    
    public struct TransData
    {
        public Vector3 position;
        public Quaternion rotation;
        public Vector3 scale;
    }
    public static void CopyProperty(this GameObject o, GameObject t)
    {
        t.GetComponent<Animator>().enabled = false;
        t.transform.position = o.transform.position;
        Dictionary<string, TransData> allTrans = new Dictionary<string, TransData>();
        Transform[] allT = o.GetComponentsInChildren<Transform>();
        for (int i = 0; i < allT.Length; ++i)
        {
            TransData data = new TransData();
            data.position = allT[i].position;
            data.rotation = allT[i].rotation;
            data.scale = allT[i].localScale;
            allTrans[allT[i].name] = data;
        }

        Transform[] targets = t.GetComponentsInChildren<Transform>();
        StringBuilder sb = new StringBuilder(1024);
        for (int i = 0; i < targets.Length; ++i)
        {
            if (allTrans.TryGetValue(targets[i].name, out TransData data))
            {
                targets[i].position = data.position;
                targets[i].rotation = data.rotation;
                targets[i].localScale = data.scale;
                sb.AppendFormat("\n{0}", targets[i].name);
            }
        }

        Debug.Log($">>>change: {sb.ToString()}");
    }
    
    public static void SetCodeEffectLocalText(this TMPTeletypeComponent com, int dialogId, Action callback, int startIndex = 0,
        float speed = 0.1f)
    {
        //var str = LuaStringLookupTable.Get(strId);
        string str = GameEntry.Localization.GetString(dialogId, null);
        com.SetCodeEffectText(str, callback, startIndex, speed);
    }

}





