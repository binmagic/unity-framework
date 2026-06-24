using System;
using System.Text;
using GameFramework;
using UnityEngine;
using XLua;

#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif


//
// 这个是Lua使用mono的基类
// 这个类写的比较复杂，原因是直接使用了LUAAPI防止额外的GC
// 

public class LuaMonoBase : MonoBehaviour
{
    public string para1;
    public string para2;
    public GameObject object1;
    public GameObject object2;

    [Serializable]
    public class Objects
    {
        public string name;
        public GameObject value;
    }

    [Serializable]
    public class Values
    {
        public string name;
        public string value;
    }

    // 数据列表
    public Values[] _values;
    
    // 物件列表
    public Objects[] _objects;
    
    // lua文件的名称；里面必须return 一个正确的lua table
    public string _luaPath;
    
    // 无效的引用
    protected readonly static int LUA_REFNIL = -1;
    
    // 关联的表
    protected int _luaTableReference = LUA_REFNIL;
    
    // 简单处理一下优化，这个作为static全局的，因为我们没有并发
    private static char[] globalBuf = new char[256];
    private static StringBuilder globalSB = new StringBuilder(256);

        
    // 处理lua字节加载
    private void MakeLuaBytes(out byte[] bytes, out int bytes_len)
    {
        if (string.IsNullOrEmpty(_luaPath))
        {
            bytes = null;
            bytes_len = 0;
            return;
        }
        
        globalSB.Clear();
        globalSB.Append("local t = require '");
        globalSB.Append(_luaPath);
        globalSB.Append("' \nreturn t");
        
        globalSB.CopyTo(0, globalBuf, 0, globalSB.Length);

        int pos = globalSB.Length;
        if (pos > InternalGlobals.strBuff.Length)
        {
            bytes = Encoding.UTF8.GetBytes(globalBuf, 0, pos);
            bytes_len = bytes.Length;
        }
        else
        {
            bytes_len = Encoding.UTF8.GetBytes(globalBuf, 0, pos, InternalGlobals.strBuff, 0);
            bytes = InternalGlobals.strBuff;
        }
        
        return;
    }

    private void CallLuaFunc<T>(int funcref, int para_count, T para)
    {
        if (funcref == LUA_REFNIL)
        {
            return;
        }

        if (GameEntry.Lua == null || GameEntry.Lua.Env == null)
        {
            Log.Info("CallLuaFunc lua not ready!");
            return;
        }
        
        var Env = GameEntry.Lua.Env; 
        var L = Env.L;
        var translator = Env.translator;
        int oldTop = LuaAPI.lua_gettop(L);

        int top;
        try
        {
            int errFunc = LuaAPI.load_error_func(L, Env.errorFuncRef);
            LuaAPI.lua_getref(L, funcref);

            top = LuaAPI.lua_gettop(L);
            
            // 必须要压入自己；即LuaTable作为self
            LuaAPI.lua_getref(L, _luaTableReference); 
            
            top = LuaAPI.lua_gettop(L);

            // 我们一般情况就只有一个参数
            if (para_count > 0)
            {
                translator.PushAny(L, para);
                para_count = 2;
            }
            else
            {
                para_count = 1;
            }

            top = LuaAPI.lua_gettop(L);
            
            int error = LuaAPI.lua_pcall(L, para_count, -1, errFunc);
            if (error != 0)
                Env.ThrowExceptionFromError(oldTop);

            LuaAPI.lua_remove(L, errFunc);
        }
        catch (Exception e)
        {
            Log.Error("CallLuaFunc error!\n{0}", e.Message);
        }
        finally
        {
            LuaAPI.lua_settop(L, oldTop);
        }

    }

    protected int GetFunction(string funcName)
    {
        if (GameEntry.Lua == null || GameEntry.Lua.Env == null)
        {
            Log.Info("lua not ready!");
            return LUA_REFNIL;
        }

        if (_luaTableReference == LUA_REFNIL)
        {
            Log.Info("lua table not ready!");
            return LUA_REFNIL;
        }
        
        var L = GameEntry.Lua.Env.L;
        var translator = GameEntry.Lua.Env.translator;
        int funcref = LUA_REFNIL;
        int oldTop = LuaAPI.lua_gettop(L);
        try
        {
            LuaTypes t;
            // 压入table
            LuaAPI.lua_getref(L, _luaTableReference);
            
            funcref = GetFunctionInternal(funcName);

        }
        catch (Exception e)
        {
            Log.Error("GetFunctions error - {0}", funcName);
        }
        finally
        {
            LuaAPI.lua_settop(L, oldTop);
        }

        return funcref;
    }
    
    // 内部获取相应名称的函数
    private int GetFunctionInternal(string funcName)
    {
        var L = GameEntry.Lua.Env.L;
        var translator = GameEntry.Lua.Env.translator;
        int oldTop = LuaAPI.lua_gettop(L);
        int funcref = LUA_REFNIL;
        
        // 此时table 已经压栈了，所以这里直接取。然后恢复栈即可
        translator.PushByType(L, funcName);
        LuaTypes t = LuaAPI.lua_type(L, -1);
        
        // 不知道为什么不能使用LuaAPI.lua_rawget(L, -2);
        // 这里使用作者写的这个函数，，但是明显效率低
        LuaAPI.xlua_pgettable(L, -2);
            
        t = LuaAPI.lua_type(L, -1);
        if (t == LuaTypes.LUA_TFUNCTION)
        {
            funcref = LuaAPI.luaL_ref(L, LuaIndexes.LUA_REGISTRYINDEX);
        }
        else if (t == LuaTypes.LUA_TNIL)
        {
            // 这个一般表示LUA没有实现这个函数，这里什么都取不到
            //Log.Info("GetFunctions - Not found lua function : {0}", funcName);
        }
        else
        {
            Log.Error("GetFunctions error! not a function! {0}", funcName);
        }
        
        LuaAPI.lua_settop(L, oldTop);
        return funcref;
    }

    protected void ReleaseLuaTable()
    {
        if (_luaTableReference != LUA_REFNIL)
        {
            if (GameEntry.Lua == null || GameEntry.Lua.Env == null)
            {
                Log.Info("ReleaseLuaTable Lua not ready!");
                return;
            }
        
            var Env = GameEntry.Lua.Env;
            var _L = Env.L;
            
            LuaAPI.lua_unref(_L, _luaTableReference);
            _luaTableReference = LUA_REFNIL;
        }
    }
    
    // 这里主要还是因为GC原因，不想因为用户使用了LuaMono，从而造成额外的负担
    protected int GetLuaTable(byte[] bytes, int bytes_len)
    {
        if (GameEntry.Lua == null || GameEntry.Lua.Env == null)
        {
            Log.Info("GetLuaTable Lua not ready!");
            return LUA_REFNIL;
        }
        
        var Env = GameEntry.Lua.Env;
        var _L = Env.L;
        LuaTypes type;

        int oldTop = LuaAPI.lua_gettop(_L);
        int luaref = LUA_REFNIL;
        
        try
        {
            int errFunc = LuaAPI.load_error_func(_L, Env.errorFuncRef);
            if (LuaAPI.xluaL_loadbuffer(_L, bytes, bytes_len, "") == 0)
            {
                if (LuaAPI.lua_pcall(_L, 0, -1, errFunc) == 0)
                {
                    LuaAPI.lua_remove(_L, errFunc);
                }
                else
                {
                    Env.ThrowExceptionFromError(oldTop);
                }
            }
            else
            {
                Env.ThrowExceptionFromError(oldTop);
            }
            
            // 这里top - oldTop应该只是个1才对
            int top = LuaAPI.lua_gettop(_L);

            // 确保返回值是一个lua table，然后把这个lua table放进注册表
            type = LuaAPI.lua_type(_L, oldTop + 1);
            type = LuaAPI.lua_type(_L, -1);
            if (type == LuaTypes.LUA_TTABLE)
            {
                //luaref = LuaAPI.luaL_ref(_L, LuaIndexes.LUA_REGISTRYINDEX);
                luaref = LuaAPI.luaL_ref(_L);
            }
            else
            {
                Log.Error("Top value not a table!  {0}", type);    
            }
        }
        catch (Exception)
        {
            Log.Error("GetLuaTable error!");
        }
        finally
        {
            LuaAPI.lua_settop(_L, oldTop);
        }
        
        return luaref;
    }
    
    // 给table设置值
    protected void Set<TKey, TValue>(int luaref, TKey key, TValue value)
    {
        var Env = GameEntry.Lua.Env;
        var L = Env.L;
        int oldTop = LuaAPI.lua_gettop(L);
        
        try
        {
            var translator = Env.translator;

            LuaAPI.lua_getref(L, luaref);
            translator.PushByType(L, key);
            translator.PushByType(L, value);

            if (0 != LuaAPI.xlua_psettable(L, -3))
            {
                Env.ThrowExceptionFromError(oldTop);
            }
        }
        catch (Exception)
        {
            Log.Error("Set error!");
        }
        finally
        {
            LuaAPI.lua_settop(L, oldTop);
        }
    }

    protected void UnRef(ref int funcref)
    {
        var Env = GameEntry.Lua.Env;
        var L = Env.L;
        
        if (funcref > 0) 
        {
            LuaAPI.lua_unref(L, funcref);
            funcref = LUA_REFNIL;
        }
    }

    protected void Init()
    {
        // 生成require lua 表
        // 下面这段代码等于于这段：
        // string s = string.Format("local t = require '{0}'\n return t", _luaPath);
        // object[] t = GameEntry.Lua.Env.DoString(s);
        // LuaTable lt = t[0] as LuaTable;

        
        MakeLuaBytes(out byte[] bytes, out int bytes_len);
        if (bytes_len <= 0)
        {
            // 尚未绑定脚本就不做其他处理了
            return;
        }
        
        // 获取返回值的引用
        _luaTableReference = GetLuaTable(bytes, bytes_len);
        if (_luaTableReference == LUA_REFNIL)
        {
            Log.Error("LuaMonoBehaviour Awake error : {0}", _luaPath??"");
            return;
        }
            
        Set(_luaTableReference, "Mono", this);
        Set(_luaTableReference, "gameObject", this.gameObject);
    }

    // 上面函数获取了lua table的ref，这里将其清空
    protected void Uninit()
    {
        object1 = null;
        object2 = null;
        ReleaseLuaTable();
    }

    // 函数调用
    protected void CallLuaFunc(string funcname, ref int funcref)
    {
        if (funcref == 0)
        {
            funcref = GetFunction(funcname);
        }
        CallLuaFunc(funcref, 0, (object)null);
    }
    
    protected void CallLuaFunc<T>(string funcname, int funcref, T para)
    {
        if (funcref == 0)
        {
            funcref = GetFunction(funcname);
        }
        CallLuaFunc(funcref, 1, para);
    }

    public LuaTable GetLuaTable()
    {
        var Env = GameEntry.Lua.Env;
        return new LuaTable(this._luaTableReference, Env);
    }
}





