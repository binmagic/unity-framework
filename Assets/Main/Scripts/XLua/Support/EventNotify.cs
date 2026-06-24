using Sfs2X.Entities.Data;
using Sfs2X.Util;
using UnityGameFramework.Runtime;
using XLua;

//
// 导出Lua调用接口
//

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
public static class EventNotify
{
    public static void Fire(EventId eventId)
    {
        GameEntry.Event.Fire(eventId);
    }
    
    public static void FireLong(EventId eventId, long userData)
    {
        GameEntry.Event.Fire(eventId, userData);
    }

    public static void FireBool(EventId eventId, bool userData)
    {
        GameEntry.Event.Fire(eventId, userData);
    }

    public static void FireString(EventId eventId, string userData)
    {
        GameEntry.Event.Fire(eventId, userData);
    }

    public static void FireLuaTable(EventId eventId, LuaTable userData)
    {
        GameEntry.Event.Fire(eventId, userData);
    }

    // 接口相对比较耗，为啥要用他呢
    // public static void FireSFSObject(EventId eventId, byte[] sfsObjBinary)
    // {
    //     GameEntry.Event.Fire(eventId, SFSObject.NewFromBinaryData(new ByteArray(sfsObjBinary, 0, sfsObjBinary.Length)));
    // }
}





