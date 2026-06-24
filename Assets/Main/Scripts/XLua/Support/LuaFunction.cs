#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using System;
using System.Collections.Generic;
using GameFramework;
using UnityEngine;


/// 以后所有的LuaFunction扩展都写到这里
/// 主要是为了扩展xlua的不足和各种方便处理函数的问题

namespace XLua
{
    public partial class LuaFunction : LuaBase
    {
        public Delegate Cast(Type delType)
        {
            if (!delType.IsSubclassOf(typeof(Delegate)))
            {
                throw new InvalidOperationException(delType.Name + " is not a delegate type");
            }
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnv.luaEnvLock)
            {
#endif
                var L = luaEnv.L;
                var translator = luaEnv.translator;
                push(L);
                Delegate ret = (Delegate)translator.GetObject(L, -1, delType);
                LuaAPI.lua_pop(luaEnv.L, 1);
                return ret;
#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
        }
    }
    
    // 关于DCBuilding的压入扩展
    ////////////////////////////////////////////////////////////////////////////
    // 因为这种情况比较特殊，需要返回多个值。
    // 如果把多个值当成一个表返回的话确实可以处理，但是效率略低，由于此函数调用频繁，所以这里特殊处理一下。
    // 另外xlua自己的多值返回代码，会有gc，毕竟函数调用形式多变，做成统一接口肯定要有所浪费。
    // 所以这里暂时不用，自己封装一个
    //////////////////////////////////////////////////////////////////////////

    public partial class LuaFunction : LuaBase
    {
        public LuaBuildData CallReturnBuildingData(long uuid, int itemId)
        {
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnv.luaEnvLock)
            {
#endif
            int nArgs = 0;
            var L = luaEnv.L;
            int oldTop = LuaAPI.lua_gettop(L);
            nArgs = oldTop;

            int errFunc = LuaAPI.load_error_func(L, luaEnv.errorFuncRef);
            LuaAPI.lua_getref(L, luaReference);

            // 这里做个区分
            // 如果lua version >= 5.3的话，Int64和integer没区别。否则In64会有开销。
            if (uuid != 0)
            {
                LuaAPI.lua_pushint64(L, uuid);
            }
            else
            {
                LuaAPI.xlua_pushinteger(L, itemId);
            }

            int error = LuaAPI.lua_pcall(L, 1, -1, errFunc);
            if (error != 0)
            {
                Log.Error("CallReturnBuildingData call error!!! --- {0}", uuid);
                LuaAPI.lua_settop(L, oldTop);
                return null;
            }

            LuaAPI.lua_remove(L, errFunc);

            // 目前固定8个参数，要修改就修改这里
            int top = LuaAPI.lua_gettop(L);
            if ((top - nArgs) != 7)
            {
                if (top > 0)
                {
                    Log.Debug("CallReturnBuildingData return count error!!! --- {0}", uuid);
                }

                LuaAPI.lua_settop(L, oldTop);
                return null;
            }
            
            // return buildData.uuid,buildData.pointId,buildData.state,buildData.itemId,buildData.level,buildData.connect
            // 直接从栈顶取，比较严谨一些；因为有可能会有lua->c#->lua的情况，此时栈上会有第一次lua压栈的数据（因为尚未返回栈还没有展开）
            long _uid = LuaAPI.lua_toint64(L, -7);
            long _updateTime = LuaAPI.lua_toint64(L, -6);
            int _point = LuaAPI.xlua_tointeger(L, -5);
            int _tempState = LuaAPI.xlua_tointeger(L, -4);
            int _itemId = LuaAPI.xlua_tointeger(L, -3);
            int _lv = LuaAPI.xlua_tointeger(L, -2);
            int _tempConnect = LuaAPI.xlua_tointeger(L, -1);
            
            LuaAPI.lua_settop(L,oldTop);
            
            LuaBuildData gen_ret = new LuaBuildData(_uid, _updateTime,_point, _tempState, _itemId, _lv, _tempConnect);
            return gen_ret;
            
#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
        }
    }
    
    
    // 这里对压入消息做一个函数的特化
    public partial class LuaFunction : LuaBase
    {
        public void CallForPushTable(string cmd, LuaTable table)
        {
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnv.luaEnvLock)
            {
#endif
            int nArgs = 0;
            var L = luaEnv.L;
            int oldTop = LuaAPI.lua_gettop(L);

            int errFunc = LuaAPI.load_error_func(L, luaEnv.errorFuncRef);
            
            // dispatchNetMessage 这个LUA函数
            LuaAPI.lua_getref(L, luaReference);
            
            // 压入消息的命令
            LuaAPI.lua_pushstring(L, cmd);

            // 压入luastack table
            table.push(L);

            int error = LuaAPI.lua_pcall(L, 2, 0, errFunc);
            if (error != 0)
            {
                Log.Error("CallForPushTable error {0}, cmd{1}!!!", error, cmd);
                LuaAPI.lua_settop(L, oldTop);
                return;
            }

            // LuaAPI.lua_remove(L, errFunc);
            LuaAPI.lua_settop(L,oldTop);
            
#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
        }
        
        // 调用LUA的函数： GameMain.Protocal(cmd, table)
        public void CallForPushTable(string cmd, LuaStackTable table)
        {
#if THREAD_SAFE || HOTFIX_ENABLE
            lock (luaEnv.luaEnvLock)
            {
#endif
            int nArgs = 0;
            var L = luaEnv.L;
            int oldTop = LuaAPI.lua_gettop(L);
            
// #if UNITY_EDITOR
//             if (LuaAPI.lua_istable(L, oldTop) == false)
//             {
//                 Debug.LogError("oldtop not a LuaStackTable!!!");
//             }
// #endif
//             // 出栈的时候顺便把lua stack table出栈了。
//             // 因为lua stack table是手动压栈的
//             oldTop -= 1; // 这个最底下是LuaStackTable

            int errFunc = LuaAPI.load_error_func(L, luaEnv.errorFuncRef);
            
            // dispatchNetMessage 这个LUA函数
            LuaAPI.lua_getref(L, luaReference);
            
            // 压入消息的命令
            LuaAPI.lua_pushstring(L, cmd);

            // 压入luastack table
            table.push();

            int error = LuaAPI.lua_pcall(L, 2, 0, errFunc);
            if (error != 0)
            {
                Log.Error("CallForPushTable error {0}, cmd{1}!!!", error, cmd);
                LuaAPI.lua_settop(L, oldTop);
                return;
            }

            // LuaAPI.lua_remove(L, errFunc);
            LuaAPI.lua_settop(L,oldTop);
            
#if THREAD_SAFE || HOTFIX_ENABLE
            }
#endif
        }
    }

}





