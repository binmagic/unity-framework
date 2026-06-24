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





