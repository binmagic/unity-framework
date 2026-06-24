using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
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

// Lua数据库对外暴露接口
// 主要就是一个执行SQL语句然后返回结果集
// 其实这个处理放到C里更方便，和Lua进行对接开销也小。但是目前没这个机制，先如此
public class LuaDatabaseManager
{
    public static void InitDataBase(string dbFileName, Action<bool> callback)
    {
        DatabaseManager.Instance.Release();
        DatabaseManager.Instance.Initialize(dbFileName,
            (bool s) =>
            {
                callback(s);
            });
    }
    
    public static void UninitDatabase()
    {
        DatabaseManager.Instance.Release();
    }

    private static LuaTable DBExecResult2LuaTable(DBExecResult r)
    {
        LuaTable luaTable = GameEntry.Lua.Env.NewTable();
        luaTable.SetInt("error", r.error);
        luaTable.SetString("errormsg", r.errormsg);
        luaTable.SetString("errorsql", r.errorsql);
        luaTable.SetInt("change_rows", r.change_rows);
        luaTable.SetInt("col_count", r.col_count);

        if (r.cols != null)
        {
            LuaTable col_table = GameEntry.Lua.Env.NewTable();
            for (int i = 0; i < r.cols.Length; ++i)
            {
                LuaTable t = GameEntry.Lua.Env.NewTable();
                t.SetString("name", r.cols[i].name);
                t.SetInt("type", r.cols[i].type);

                col_table.SetTable(i + 1, t);
            }
            luaTable.SetTable("cols", col_table);
        }
        else
        {
            // 这个错误一般是发生在第一次进入游戏的时候，sqlite尚无表格
            Log.Info("no cols ?? error: {0}, sql: {1}", r.errormsg??"", r.errorsql??"");
        }

        if (r.values != null)
        {
            LuaTable v_table = GameEntry.Lua.Env.NewTable();
            for (int i = 0; i < r.values.Count; ++i)
            {
                var row = r.values[i];
                LuaTable line = GameEntry.Lua.Env.NewTable();

                for (int j = 0; j < row.Length; ++j)
                {
                    switch (row[j].type)
                    {
                        case 1:
                            line.SetLong(j + 1, row[j].lv);
                            break;
                        case 2:
                            line.SetDouble(j + 1, row[j].fv);
                            break;
                        case 5:
                            line.Set(j + 1, (object) null);
                            break; // push nil
                        default:
                            line.SetString(j + 1, row[j].sv);
                            break;
                    }
                }

                v_table.SetTable(i + 1, line);
            }

            luaTable.SetTable("values", v_table);
        }
        else
        {
            Log.Error("no values ????");
        }

        return luaTable;
    }
    
    
    // 将用户传过来的数据转换为ROW
    static int ValueTableToRow(List<DBAnyValue> row, string format, int stack)
    {
        var L = GameEntry.Lua.Env.L;
        int type_len = string.IsNullOrEmpty(format) ? 0 : format.Length;
        int top = LuaAPI.lua_gettop(L);
        int count = 0;
        
        // if (LuaAPI.lua_istable(L, stack))
        // {
        //     int a = 0;
        // }

        // 最大就处理100列，不可能超过100列
        int i = 1;
        for (; i < 100; ++i)
        {
            LuaAPI.lua_pushnumber(L, i);
            LuaAPI.lua_rawget(L, stack);
            
            if (LuaAPI.lua_isnil(L, -1))
            {
                 break;
            }

            // 先尝试用用户指定的类型
            int this_type = -1;
            if (i < type_len) {
                char ttt = format[i-1];
                switch (ttt) {
                case 's': this_type = 3; break;
                case 'd': this_type = 2; break; // SQLITE_FLOAT; 
                case 'i': this_type = 1; break; // SQLITE_INTEGER;
                }
            }

            // 使用lua测算类型
            if (this_type == -1)
            {
                LuaTypes type = LuaAPI.lua_type(L, -1);
                if (type == LuaTypes.LUA_TNUMBER) {
                    if (LuaAPI.lua_isinteger(L, -1))
                    {
                        this_type = 1;// SQLITE_INTEGER;
                    }
                    else 
                    {
                        this_type = 2;// SQLITE_FLOAT;
                    }
                }
                // 除了整数其他都默认字符串了，包括blob，目前我们其实没有blob
                else {
                    this_type = 3;
                }
            }

            DBAnyValue value = new DBAnyValue();

            // SQLITE_INTEGER;
            if (this_type == 1) {
                value.lv = LuaAPI.xlua_tointeger(L, -1);
                value.type = 1;
            }
            // SQLITE_FLOAT;
            else if (this_type == 2) {
                value.fv = LuaAPI.lua_tonumber(L, -1);
                value.type = 2;
            }
            else {
                string tt = LuaAPI.lua_tostring(L, -1);
                value.sv = tt??"";
                value.type = 3;
            }
            
            row.Add(value);

            LuaAPI.lua_pop(L, 1);
        }

        // 设置列的数量，因为lua从1开始，这里需要处理-1
        count = (i - 1);
        
        LuaAPI.lua_settop(L, top);

        return count;
    }

    // 将用户传过来的数据转换为ROW
    static int ValueTableToRows(List<List<DBAnyValue>> rows, string format, int stack)
    {
        var L = GameEntry.Lua.Env.L;
        int type_len = string.IsNullOrEmpty(format) ? 0 : format.Length;
        int top = LuaAPI.lua_gettop(L);
        int count = 0;
        
        if (!LuaAPI.lua_istable(L, stack)) {
            return 0;
        }

        // 将用户传入的bind数据table的第一个元素放到栈上看一下
        // 如果是第一个元素是table的话，表示是一个多行数据
        // 否则就是一个单行数据
        bool multidatas = false;
        
        LuaAPI.lua_pushnumber(L, 1);
        LuaAPI.lua_rawget(L, stack);
        top = LuaAPI.lua_gettop(L);

        if (LuaAPI.lua_istable(L, -1)) {
            multidatas = true;
        }
        LuaAPI.lua_pop(L, 1);
        top = LuaAPI.lua_gettop(L);

        // 看看是不是嵌套table了
        if (multidatas)
        {
            int i = 1;
            for (; i < 1001; ++i)
            {
                top = LuaAPI.lua_gettop(L);
                
                LuaAPI.lua_pushnumber(L, i);
                LuaAPI.lua_rawget(L, stack);
                // lua_rawgeti(L, stack, i);
                if (LuaAPI.lua_isnil(L, -1)) {
                    break;
                }

                top = LuaAPI.lua_gettop(L);
                List<DBAnyValue> value = new List<DBAnyValue>();
                ValueTableToRow(value, format, top);
                rows.Add(value);

                LuaAPI.lua_pop(L, 1);
            }

            count = i-1;
        }
        else
        {
            // 单行数据处理
            List<DBAnyValue> v = new List<DBAnyValue>(4);
            count = ValueTableToRow(v, format, stack);
            rows.Add(v);
        }

        LuaAPI.lua_settop(L, top);
        return count;
    }
    

    
    public static void ExecuteMultiSQL(List<string> cmdStr, Action<LuaTable> callback = null)
    {
        DatabaseManager.Instance.ExecuteMulti(cmdStr, (List<DBExecResult> ret) =>
        {
            if (ret == null) {
                callback(null);
                return;
            }
            
            LuaTable all = GameEntry.Lua.Env.NewTable();

            for (int index = 0; index < ret.Count; ++index)
            {
                LuaTable v_table = DBExecResult2LuaTable(ret[index]);
                all.Set(index + 1, v_table);
            }

            callback(all);

            all.Dispose();
        });
    }

    // 因为这个参数2是一个比较复杂的参数，所以这里我们自己处理解析一下
    // 另外try catch在外层会有包装。这里要注意，千万不要操作错误，否则可能导致C代码崩溃
    public static void ExecuteSTMT()
    {
        int t = 0;

        if (GameEntry.Lua == null)
        {
            return;
        }

        var L = GameEntry.Lua.Env.L;
        if ((int)L == 0)
        {
            return;
        }
        
        int top = LuaAPI.lua_gettop(L);
        ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
        
        int gen_param_count = LuaAPI.lua_gettop(L);
        if (gen_param_count != 4)
        {
            return;
        }

        string sqlstmt = LuaAPI.lua_tostring(L, 1);
        string format = LuaAPI.lua_tostring(L, 3);
        System.Action<LuaTable> _callback = null;

        if (gen_param_count >= 4)
        {
            _callback = translator.GetDelegate<System.Action<LuaTable>>(L, 4);
        }

        List<List<DBAnyValue>> rows = null;
        if (LuaAPI.lua_istable(L, 2))
        {
            rows = new List<List<DBAnyValue>>();
            ValueTableToRows(rows, format, 2);
        }
        
        LuaAPI.lua_settop(L, top);

        DatabaseManager.Instance.ExecuteSTMT(sqlstmt, rows, (DBExecResult ret) =>
        {
            if (_callback == null)
            {
                return;
            }
            
            if (ret == null) {
                _callback(null);
                return;
            }
            
            LuaTable v_table = DBExecResult2LuaTable(ret);
            _callback(v_table);
            v_table.Dispose();
        });
            
    }
    
    public static void ExecuteSQL(string cmdStr, Action<LuaTable> callback = null)
    {
        DatabaseManager.Instance.Execute2(cmdStr, (DBExecResult ret) =>
        {
            if (ret == null) {
                callback(null);
                return;
            }
            
            LuaTable v_table = DBExecResult2LuaTable(ret);
            callback(v_table);
            v_table.Dispose();
        });
    }
}





