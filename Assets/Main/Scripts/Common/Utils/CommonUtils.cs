using System;
using GameFramework;
using UnityEngine;
using UnityEngine.UI;
using XLua;
using Random = UnityEngine.Random;
using System.IO;
using System.Reflection;
using Unity.Collections.LowLevel.Unsafe;
using UnityEngine.AI;
using UnityEngine.EventSystems;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Profiling;
using UnityEngine.Rendering.Universal;

[Hotfix]
public class CommonUtils
{
    public static int GetUnityMode()
    {
#if UNITY_EDITOR
        return 1;
#else
        return 2;
#endif
    }


    public static bool Is<T>(object o)
    {
        return o is T;
    }


    public static void OpenURL(string url)
    {
        //借助一下
        // var a = FowSystem2.mRevealers;
        GameEntry.Sdk.OpenUrl(url);
    }

    public static void OpenAppReview(string url)
    {
        //借助一下
        // var a = FowSystem2.mRevealers;
        GameEntry.Sdk.OpenAppReview(url);
    }

    public static bool IsDebug()
    {
        bool isDebug = false;

#if DEBUG
        isDebug = true;
#endif

#if UNITY_EDITOR
        // 如果编辑器模式下，看一下用户是否设置成连接线上模式了
        int v = PlayerPrefs.GetInt("Editor_ConnectOnline", 0);
        if (v == 1)
        {
            return false;
        }
#endif

        return isDebug;
    }

    public static bool IsEditor()
    {
#if UNITY_EDITOR
        return true;
#endif

        return false;
    }

    public static bool IsWriteLog()
    {
        int writeLogLevel = Log.GetWriteLogLevel();
        return writeLogLevel > 0;
    }

    // 生成一个uuid，提供给LUA使用
    public static string GenerateUUID()
    {
        return System.Guid.NewGuid().ToString();
    }

    // 获取当前毫秒，提供给LUA使用
    public long GetCurrentTime()
    {
        return DateTimeOffset.Now.ToUnixTimeMilliseconds();
    }

    private static ScriptableRendererData _scriptableRendererData;

    public static void ToggleBlendDepth(bool b)
    {
        if (_scriptableRendererData == null)
        {
            var pipeline = QualitySettings.renderPipeline as UniversalRenderPipelineAsset;
            if (pipeline != null)
            {
                FieldInfo propertyInfo = pipeline.GetType()
                    .GetField("m_RendererDataList", BindingFlags.Instance | BindingFlags.NonPublic);
                _scriptableRendererData = ((ScriptableRendererData[])propertyInfo?.GetValue(pipeline))?[0];
            }
        }

        if (_scriptableRendererData != null)
        {
            foreach (var feature in _scriptableRendererData.rendererFeatures)
            {
                if (feature != null && feature.name.Equals("Blend"))
                {
                    var rendererObjects = (RenderObjects)feature;
                    rendererObjects.settings.overrideDepthState = b;
                }
            }

            _scriptableRendererData.SetDirty();
        }
    }

    public static bool FindPathByNavMesh(NavMeshPath navMeshPath, Vector3 startPos, Vector3 dstPos,
        float sampleDistance = 6)
    {
        navMeshPath.ClearCorners();
        var ret1 = NavMesh.SamplePosition(dstPos, out var sampleHit, sampleDistance, NavMesh.AllAreas);
        if (!ret1)
        {
            return false;
        }

        var ret2 = NavMesh.CalculatePath(startPos, sampleHit.position, NavMesh.AllAreas, navMeshPath);
        if (ret2 && navMeshPath.status == NavMeshPathStatus.PathComplete)
        {
            return true;
        }

        return false;
    }


    /// <summary>
    ///     检查是否为覆盖安装：如果覆盖安装，删除cache/Builtin，cache/DownLoad，files/AssetBundles文件夹
    /// </summary>
    public static bool CheckIsOverridePackage()
    {
        var isOverride = false;
        var needCheckStr = "";
#if UNITY_IOS
        needCheckStr = GameEntry.Sdk.Version;
#else
        needCheckStr = GameEntry.Sdk.Version + ";" + GameEntry.Sdk.VersionCode;
#endif
        Log.Debug("cur version{0}", needCheckStr);
        var path = Application.persistentDataPath + "/CheckVersion.txt";
        if (File.Exists(path))
        {
            Log.Debug("already have CheckVersion.txt");
            var versionStr = File.ReadAllText(path);
            Log.Debug("file version{0}", versionStr);
            if (versionStr.Contains(needCheckStr) == false)
            {
                isOverride = true;
            }
        }
        else
        {
            isOverride = true;
        }

        return isOverride;
    }

    public static void DeleteCache()
    {
        Log.Info("DeleteCache!");
        try
        {
            var assetBundlesPath = $"{Application.persistentDataPath}/{VEngine.Utility.buildPath}";
            if (Directory.Exists(assetBundlesPath))
            {
                Log.Debug("delete{0}", assetBundlesPath);
                Directory.Delete(assetBundlesPath, true);
            }

            var builtinPath = $"{Application.temporaryCachePath}/Builtin";
            if (Directory.Exists(builtinPath))
            {
                Directory.Delete(builtinPath, true);
                Log.Debug("delete{0}", builtinPath);
            }

            var downloadPath = $"{Application.temporaryCachePath}/Download";
            if (Directory.Exists(downloadPath))
            {
                Directory.Delete(downloadPath, true);
                Log.Debug("delete{0}", downloadPath);
            }
        }
        catch (Exception ex)
        {
            // Log the exception details
            Log.Error("An error occurred while deleting cache: {0}", ex.Message);
        }
    }

    public static void WriteVersion()
    {
        var path = Application.persistentDataPath + "/CheckVersion.txt";
        var needCheckStr = "";
#if UNITY_IOS
        needCheckStr = GameEntry.Sdk.Version;
#else
        needCheckStr = GameEntry.Sdk.Version + ";" + GameEntry.Sdk.VersionCode;
#endif
        File.WriteAllText(path, needCheckStr);
        Log.Debug("write{0}", needCheckStr);
    }

    public static bool IS_FINAL_RELEASE()
    {
#if FINAL_RELEASE
        return true;
#else
        return false;
#endif
    }

    public static void Execute_beginDrag(GameObject obj, BaseEventData eventData)
    {
        ExecuteEvents.Execute(obj, eventData, ExecuteEvents.beginDragHandler);
    }

    public static void Execute_drag(GameObject obj, BaseEventData eventData)
    {
        ExecuteEvents.Execute(obj, eventData, ExecuteEvents.dragHandler);
    }

    public static void Execute_endDrag(GameObject obj, BaseEventData eventData)
    {
        ExecuteEvents.Execute(obj, eventData, ExecuteEvents.endDragHandler);
    }

    public static void BeginSample(int id)
    {
        var tag = LuaStringLookupTable.Get(id);
        Profiler.BeginSample(tag);
    }

    public static void EndSample()
    {
        Profiler.EndSample();
    }

    // 把request直接写入文件
    public static long TextAssetRequestSaveToFile(VEngine.Asset request, string filepath)
    {
        var txtAsset = request.asset as TextAsset;
        if (txtAsset == null)
        {
            return 0;
        }

        try
        {
            if (!GameEntry.GameBase.UsePtrForLua)
            {
                byte[] bytes = txtAsset.bytes;
                FileUtils.WriteFile(filepath, bytes);
                return txtAsset.dataSize;
            }

            // 直接使用C写入byte的方式
            var nativeArray = txtAsset.GetData<byte>();
            long ret = 0;

            unsafe
            {
                IntPtr data = (IntPtr)nativeArray.GetUnsafeReadOnlyPtr();
                ret = CFuncUtils.WriteBufferToFile(filepath, data, txtAsset.dataSize);
            }

            return ret;
        }
        catch (Exception excep)
        {
            return 0;
        }
    }

    // 获取一个按钮上的音效
    public static int GetButtonSoundEffect(GameObject obj)
    {
        var component = obj.GetComponent<UIExtraData>();
        if (component != null)
        {
            return component.soundId;
        }

        return 0;
    }

    // 清除gameObject上的TouchObjectEventTrigger的lua绑定
    public static int ClearTouchObjectEventTrigger(GameObject gameObject)
    {
        if (gameObject == null)
        {
            Debug.LogError("ClearTouchObjectEventTrigger null!");
            return -1;
        }

        var touchEvent = gameObject.GetComponentInChildren<TouchObjectEventTrigger>();
        if (touchEvent != null)
        {
            touchEvent.ClearAction();
            return 1;
        }

        return 0;
    }

    public static int ClearTouchObjectEventTrigger(Transform tf)
    {
        return ClearTouchObjectEventTrigger(tf.gameObject);
    }

    //先临时加个函数 上传下部分error日志
    public static void LogErrorWithPost(string str)
    {
#if UNITY_EDITOR
        if (GameEntry.Lua != null)
        {
            GameEntry.Lua.LuaTraceback();
        }
#endif
        Debug.LogError(str);
        PostEventLog.LogToFeishu(str, 1);
    }

}





