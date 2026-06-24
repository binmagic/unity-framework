using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using AOT;
using UnityEngine;
using UnityEngine.Profiling;

// 一些从C导出的接口访问；
// 可以无视这个类名字，类名字应该叫CFuncUtils

public class CFuncUtils
{
#if (UNITY_IPHONE || UNITY_TVOS || UNITY_WEBGL || UNITY_SWITCH) && !UNITY_EDITOR
        const string LUADLL = "__Internal";
#else
    const string LUADLL = "xlua";
#endif
    
    private static readonly Dictionary<long, string> _showNames = new Dictionary<long, string>(32);
    
    public delegate void BeginSample(IntPtr pointer);
    public delegate void EndSample();

    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern void InitProfileDelegate(BeginSample begin, EndSample end);
    
    
    [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
    public static extern long WriteBufferToFile(string filename, IntPtr buff, long size);

    public static void InitUnityProfile_xLuaDll()
    {
        InitProfileDelegate(Unity_BeginSample, Unity_EndProfile);
    }

    // 这个pointer表示从C传过来的字符串，注意必须是一个常量指针，否则统计会有点问题
    [MonoPInvokeCallback(typeof(BeginSample))]
    public static void Unity_BeginSample(IntPtr pointer)
    {
        long l = pointer.ToInt64();
        if (_showNames.TryGetValue(l, out string name))
        {
            Profiler.BeginSample(name);
            return;
        }
        
        string message = Marshal.PtrToStringAnsi(pointer);
        _showNames[l] = message;
        Profiler.BeginSample(message);
    }
    
    [MonoPInvokeCallback(typeof(EndSample))]
    public static void Unity_EndProfile()
    {
        Profiler.EndSample();
    }
    
}





