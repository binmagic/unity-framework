/**
 * [INPUT]: 依赖 System.Reflection 反射访问 UnityEventBase 的私有调用列表(m_Calls/m_ExecutingCalls)
 * [OUTPUT]: 对外提供扩展方法 UnityEventBase.Clear(),彻底清空事件的持久与运行时监听器
 * [POS]: UIExtension 的事件工具扩展,弥补 UnityEvent 无法一次性清除所有(含代码添加)监听的缺口,常用于回收 UI 时防止回调泄漏
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Reflection;
using UnityEngine;
using UnityEngine.Events;

public static class UnityEventEx
{
    public static void Clear(this UnityEventBase ev)
    { 
        // ev.m_Calls.Clear()
        // ev.m_Calls.m_ExecutingCalls.Clear();

        var eventBaseType = typeof(UnityEventBase);
        var evType = ev.GetType();
        while (evType != eventBaseType && evType != null)
            evType = evType.BaseType;
        
        if (evType == eventBaseType)
        {
            var m_Calls = evType.GetField("m_Calls", BindingFlags.Instance | BindingFlags.NonPublic);
            if (m_Calls != null)
            {
                var m_CallsObj = m_Calls.GetValue(ev);
                
                MethodInfo Clear;
                Clear = m_CallsObj.GetType().GetMethod("Clear", BindingFlags.Instance | BindingFlags.Public);
                if (Clear != null)
                {
                    Clear.Invoke(m_CallsObj, null); 
                }
            
                var m_ExecutingCalls = m_CallsObj.GetType().GetField("m_ExecutingCalls", BindingFlags.Instance | BindingFlags.NonPublic);
                if (m_ExecutingCalls != null)
                {
                    var m_ExecutingCallsObj = m_ExecutingCalls.GetValue(m_CallsObj);
                    Clear = m_ExecutingCallsObj.GetType().GetMethod("Clear", BindingFlags.Instance | BindingFlags.Public);
                    if (Clear != null)
                    {
                        Clear.Invoke(m_ExecutingCallsObj, null);
                    }
                }
            }
        }
    }
/*
    public static void PrintCount(this UnityEventBase ev, string name)
    {
        var eventBaseType = typeof(UnityEventBase);
        var evType = ev.GetType();
        while (evType != eventBaseType && evType != null)
            evType = evType.BaseType;
        
        if (evType == eventBaseType)
        {
            var m_Calls = evType.GetField("m_Calls", BindingFlags.Instance | BindingFlags.NonPublic);
            if (m_Calls != null)
            {
                var m_CallsObj = m_Calls.GetValue(ev);
                
                PropertyInfo Count;
                Count = m_CallsObj.GetType().GetProperty("Count", BindingFlags.Instance | BindingFlags.Public);
                if (Count != null)
                {
                    if ((int) Count.GetValue(m_CallsObj) > 0)
                    {
                        Debug.LogError($"{name} m_Calls.Count {Count.GetValue(m_CallsObj)}"); 
                    }
                }
            
                var m_ExecutingCalls = m_CallsObj.GetType().GetField("m_ExecutingCalls", BindingFlags.Instance | BindingFlags.NonPublic);
                if (m_ExecutingCalls != null)
                {
                    var m_ExecutingCallsObj = m_ExecutingCalls.GetValue(m_CallsObj);
                    Count = m_ExecutingCallsObj.GetType().GetProperty("Count", BindingFlags.Instance | BindingFlags.Public);
                    if (Count != null)
                    {
                        if ((int) Count.GetValue(m_ExecutingCallsObj) > 0)
                        {
                            Debug.LogError($"{name} m_ExecutingCallsObj.Count {Count.GetValue(m_ExecutingCallsObj)}");
                        }
                    }
                }
            }
        }
    }

    public static void DumpButton()
    {
        var buttons = Resources.FindObjectsOfTypeAll<UnityEngine.UI.Button>();
        foreach (var i in buttons)
        {
            i.onClick.PrintCount(i.name);
        }
    }
    */
}





