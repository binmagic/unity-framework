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
// LuaTable是创建在注册表里面的一个table
// 当我们频繁在c#和lua之间传输数据的时候，使用LuaTable会略耗。
// 这里我们提供一个基于LuaStack的table，这种table相对是轻量级的，同时也是0-GC的。
// 这种table保存在LUA 栈上，所以不能做成成员变量缓存。
//

public struct LuaStackTable
{
    private int oldTop;
    private RealStatePtr L;
    // 大部分，我们处理的时候，都是可以设置成-3的。
    // 同时因为我们是一直操作栈，所以所有的操作都应该是在栈的上面。
    private int index_;
    
    // narr -> array元素的空间;; nrec -> 非array元素的空间
    public LuaStackTable(RealStatePtr L1, int narr, int nrec)
    {
        //创建table
        L = L1;
        oldTop = LuaAPI.lua_gettop(L);

        //LuaAPI.lua_newtable(L);
        LuaAPI.lua_createtable(L, narr, nrec);
        index_ = LuaAPI.lua_gettop(L);
    }
    
    // 用来绑定栈上已经有的table，方便操作；注意执行完要手动Reset一下。
    public LuaStackTable(RealStatePtr L1, int stack_index)
    {
        L = L1;
        oldTop = LuaAPI.lua_gettop(L);
        index_ = stack_index;
    }

    public void SetInt(string key, int value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetInt(int key, int value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetLong(string key, long value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushint64(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetLong(int key, long value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushint64(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetDouble(string key, double value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushnumber(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetDouble(int key, double value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushnumber(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetString(string key, string value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushstring(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetString(int key, string value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushstring(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetBool(string key, bool value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushboolean(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetBool(int key, bool value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushboolean(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetULong(string key, ulong value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushuint64(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetULong(int key, ulong value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushuint64(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetByte(string key, int value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetByte(int key, int value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetShort(string key, short value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetShort(int key, short value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.xlua_pushinteger(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetFloat(string key, float value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushnumber(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetFloat(int key, float value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushnumber(L, value);
        LuaAPI.lua_rawset(L, index_);
    }


    public void SetBytes(string key, byte[] value)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_pushstring(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetBytes(int key, byte[] value)
    {
        LuaAPI.xlua_pushinteger(L, key);
        LuaAPI.lua_pushstring(L, value);
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetStackTable(string key, LuaStackTable t)
    {
        LuaAPI.lua_rawset(L, index_);
    }

    public void SetStackTable(int key, LuaStackTable t)
    {
        LuaAPI.lua_rawset(L, index_);
    }

    public void push()
    {
        //LuaAPI.lua_pushvalue(L, oldTop + 1);
        LuaAPI.lua_pushvalue(L, index_);
    }
    
    // 弹出
    public void pop()
    {
        if (index_ > 0)
        {
            LuaAPI.lua_remove(L, index_);
            index_ = 0;
        }
    }
    
    int GetInt(string key)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_rawget(L, index_);

        int ret = 0;
        if (LuaAPI.lua_isinteger(L, -1)) {
            ret = LuaAPI.xlua_tointeger(L, -1);
        }
        return ret;
    }

    float GetFloat(string key)
    {
        float ret = 0;

        return ret;
    }

    string GetString(string key)
    {
        return "";
    }
    
    // 获取table之后，栈上会残留一个table，这个需要手动弹出
    public int GetTableIndex(string key)
    {
        LuaAPI.lua_pushstring(L, key);
        LuaAPI.lua_rawget(L, index_);

        if (LuaAPI.lua_istable(L, -1)) {
            int top = LuaAPI.lua_gettop(L);
            return top;
        }

        return 0;
    }
}





