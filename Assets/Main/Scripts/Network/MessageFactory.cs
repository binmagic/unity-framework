using System;
using System.Collections.Generic;
using GameFramework;
using Sfs2X.Core;
using Sfs2X.Entities.Data;
using Sfs2X.Util;
using UnityEngine;

#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

public class MessageFactory
{
    private static MessageFactory _instance;

    public static MessageFactory Instance
    {
        get
        {
            if (null == _instance)
            {
                _instance = new MessageFactory();
            }

            return _instance;
        }
    }

    public Dictionary<string, BaseMessage> mHandlers;

    public void InitMessageHandlers()
    {
        /*
         目前类型就以下几种了
         
            [0] = {RuntimeType} "UserBindGaidMessage"
            [1] = {RuntimeType} "ChangePFdisplayName"
            [2] = {RuntimeType} "CheckDeviceChangeMessage"
            [3] = {RuntimeType} "CrossWorldMoveMessage"
            [4] = {RuntimeType} "FcmTokenMessage"
            [5] = {RuntimeType} "GetViewLevelWorldInfoMessage"
            [6] = {RuntimeType} "LoginCrossServerMessage"
            [7] = {RuntimeType} "LoginMessage"
            [8] = {RuntimeType} "PushRecordMessage"
            [9] = {RuntimeType} "PushWorldDesertUpdate"
            [10] = {RuntimeType} "PushWorldMarchMessage"
            [11] = {RuntimeType} "PushWorldMarchDelMessage"
            [12] = {RuntimeType} "PushWorldMarchRetrunMessage"
            [13] = {RuntimeType} "PushWorldBeMoveMessage"
            [14] = {RuntimeType} "PushWorldUserCrashMessage"
            [15] = {RuntimeType} "PushWorldMarchWorldGet"
            [16] = {RuntimeType} "WorldCrossServerMessage"
            [17] = {RuntimeType} "WorldLeaveCrossServerMessage"
            [18] = {RuntimeType} "WorldMarchFormationMessage"
            [19] = {RuntimeType} "WorldMarchFormationChangeMessage"
        
            */
        
        Log.Info("InitMessageHandlers begin");
        mHandlers = new Dictionary<string, BaseMessage>(20);
        // var types = AppDomain.CurrentDomain.GetAssemblies()
        //     .SelectMany(a => a.GetTypes().Where(t => t.BaseType == typeof(BaseMessage)))
        //     .ToArray();
        //
        // Log.Info("InitMessageHandlers types ok!");
        
        
        // 因为我们没有多少消息是留在C#中了，所以这里直接手写列表，省去遍历Assembles带来的时间和GC开销！
        Type[] types =
        {
            typeof(UserBindGaidMessage),
            typeof(ChangePFdisplayName),
            //typeof(CrossWorldMoveMessage),
            typeof(FcmTokenMessage),
            // typeof(GetViewLevelWorldInfoMessage),
            typeof(LoginMessage),
            typeof(PushRecordMessage),
            //typeof(PushWorldDesertUpdate),
            //typeof(PushWorldMarchMessage),
            //typeof(PushWorldMarchDelMessage),
            //typeof(PushWorldMarchRetrunMessage),
            // typeof(PushWorldBeMoveMessage),
            // typeof(PushWorldUserCrashMessage),
            // typeof(PushWorldMarchWorldGet),
            //typeof(WorldCrossServerMessage),
            //typeof(WorldLeaveCrossServerMessage),
            //typeof(WorldMarchFormationMessage),
            //typeof(WorldMarchFormationChangeMessage),
            //typeof(PushWorldBattleUpdateMessage),
            //typeof(PushPointInfoUpdate),
            //typeof(PushWorldBattleFinishMessage)
        };
        
        foreach (var t in types)
        {
            var obj = t.Assembly.CreateInstance(t.FullName);
            var messageHandler = obj as BaseMessage;
            if (!mHandlers.ContainsKey(messageHandler.GetMsgId()))
            {
                mHandlers.Add(messageHandler.GetMsgId(), messageHandler);
            }
            else
            {
                GameFramework.Log.Error(messageHandler.GetMsgId() + " has duplicated");
                //Log.Error(messageHandler.GetMsgId());
            }
        }
    }

    public void DispatchResponse(BaseEvent e)
    {
        ExtensionEvent ee = e as ExtensionEvent;
        if (ee != null)
        {
            DispatchResponse(ee.cmd, ee.rawData as ByteArray);
            // 这个地方的rawData其实可以使用pool系统，但是分配在底层（HandleNewPacket），同时跨越了线程，暂时就这样吧，手动置null
            ee.rawData = null;
        }
        else
        {
            string cmd = (string) e.Params["cmd"];
            var rawData = e.Params["rawData"] as ByteArray;
            DispatchResponse(cmd, rawData);
        }
    }

    // 消息统一分发处理
    public void DispatchResponse(string cmd, ByteArray rawData)
    {
        try
        {
            if (mHandlers.ContainsKey(cmd))
            {
                var sfs = SFSObject.NewFromBinaryData(rawData);
                var so = sfs.GetSFSObject("p").GetSFSObject("p");
                if (so.ContainsKey("_id"))
                {
                    int fuId = so.GetInt("_id");
                    int serverTime = so.TryGetInt("_time");
                    GameEntry.Network.getFutureManager().onServerMsgCome(fuId, serverTime);
                }
                
                if (CommonUtils.IsDebug())
                {
//#if __LOG
                    if (cmd.Equals("world.get.new"))
                    {
                        Log.Info($"<color=green>#message# [res] <{cmd}> |</color>");
                    }
                    else if(!cmd.Equals("survival.pve.heartbeat"))
                    {
                        var s = so.ToJson();
                        Log.Info($"<color=green>#message# [res] <{cmd}> |</color> {s}");
                    }
//#endif
                }
                
                mHandlers[cmd].Handle(so);
            }
            // 1.C#中没有的消息协议，放在lua中处理，比如新增的协议
            // 2.暂时不将所有协议全部放在lua中，后续可能使用pb代替
            // 3.C#中的协议有变化时，尝试使用Hotfix修复
            else
            {
                var l = GameEntry.Lua.Env.L;
                int oldTop = LuaAPI.lua_gettop(l);
                //针对lua handle的消息 直接将buff传到native中解析
                var ret = XLua.LuaDLL.Lua.BinToStackTable(l, rawData.GetRawBytes(), rawData.DataLength);
                if (ret == 0)
                {
                    throw new Exception("BinToStackTable Native Error [1]!");
                }
                
                // 相当于lua里面；目前栈顶是个table。
                // 下面代码相当于：
                // local t = XLua.LuaDLL.Lua.BinToStackTable() -- 这里返回一个lua table
                //  GameEntry.Lua.DispatchResponse(cmd, t.p.p); -- 连续取t.p.p
                bool is_ok = false;
                if (LuaAPI.lua_istable(l, oldTop + 1))
                {
                    var stackTable1 = new LuaStackTable(l, oldTop + 1);
                    var index1 = stackTable1.GetTableIndex("p");
                    if (index1 != 0)
                    {
                        var stackTable2 = new LuaStackTable(l, index1);
                        var index2 = stackTable2.GetTableIndex("p");
                        if (index2 != 0)
                        {
                            var stackTable3 = new LuaStackTable(l, index2);
                            GameEntry.Lua.DispatchResponse(cmd, stackTable3);
                            is_ok = true;
                        }
                    }
                }

                if (is_ok == false)
                {
                    Debug.LogErrorFormat("BIGBUG!!! {0} error!", cmd);
                }

                LuaAPI.lua_settop(l, oldTop);
                
            }
        }
        catch (System.Exception excep)
        {
            Log.Error("process msg {0} error, {1}", cmd, excep);
        }

    }
    
}





