using System;
using System.Collections.Generic;
using System.IO;
using System.Linq.Expressions;
using GameFramework;
using GameKit.Base;
using SQLite4Unity3d;
using UnityEngine;

public class DatabaseManager : MonoBehaviour
{
    private static DatabaseManager _instance;
    private static readonly object _lock = new object();

    public static DatabaseManager Instance
    {
        get
        {
            // Double-Checked Locking
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = FindObjectOfType<DatabaseManager>();

                        if (FindObjectsOfType<DatabaseManager>().Length > 1)
                        {
                            return _instance;
                        }

                        if (_instance == null)
                        {
                            GameObject singleton = new GameObject("(Singleton) " + typeof(DatabaseManager));
                            _instance = singleton.AddComponent<DatabaseManager>();

                            DontDestroyOnLoad(singleton);
                        }
                    }
                }
            }

            return _instance;
        }
    }

    private System.Action<bool> OnInitCallback;

    public void Initialize(string databaseFile, System.Action<bool> callback)
    {
        OnInitCallback = callback;

        string dstPath = Path.Combine(Application.persistentDataPath, databaseFile);

        if (!File.Exists(dstPath))
        {
            Log.Debug("Copy {0} form streaming assets path to persistent data path", databaseFile);

            string srcPath = Path.Combine(Application.streamingAssetsPath, databaseFile);

#if !UNITY_ANDROID || UNITY_EDITOR
            srcPath = "file://" + srcPath;
#endif

            WebRequestManager.Instance.Get(srcPath, (request, hasErr, userdata) =>
            {
                if (!hasErr)
                {
                    if (request.isDone)
                    {
                        File.WriteAllBytes(dstPath, request.downloadHandler.data);
                        InitDatabase(dstPath);
                    }
                }
                else
                {
                    Log.Error(request.error);
                }
            });
        }
        else
        {
            InitDatabase(dstPath);
        }
    }

    public void Release()
    {
        try
        {
            taskQueue.Clear();
            if (thread != null)
            {
                thread.Stop();
                thread = null;
            }

            if (dbConnection != null)
            {
                dbConnection.Close();
                dbConnection = null;
            }

            OnInitCallback = null;
        }
        catch (Exception e)
        {
            Log.Error("dbmanager release error", e.Message);
        }
    }

    private QueuedThread thread;
    private SQLiteConnection dbConnection;
    private Queue<DatabaseActionTask> taskQueue = new Queue<DatabaseActionTask>();

    private bool isInited;

    void InitDatabase(string path)
    {
        Log.Info("InitDatabase : {0}", path);
        
        dbConnection = new SQLiteConnection(path, SQLiteOpenFlags.ReadWrite | SQLiteOpenFlags.Create);

        if (dbConnection != null)
        {
            thread = new QueuedThread("DatabaseThread");
            thread.Start();

            isInited = true;
        }

        OnInitCallback?.Invoke(isInited);
    }

    private void Update()
    {
        UpdateTask();
    }

    public void UpdateTask()
    {
        if (thread == null)
            return;

        if (taskQueue.Count > 0)
        {
            if (taskQueue.Peek().Processed)
            {
                try
                {
                    taskQueue.Dequeue().CallBack();
                }
                catch (Exception e)
                {
                    Log.Error(e.Message);
                }
            }
        }
    }

    public void Execute2(string cmdStr, Action<DBExecResult> callback = null)
    {
        if (!isInited)
        {
            callback?.Invoke(null);
            return;
        }

        ExecuteTask2 task = new ExecuteTask2(dbConnection, cmdStr, callback);

        thread.AddTask(task);
        taskQueue.Enqueue(task);
    }

    public void ExecuteSTMT(string sqlstmt, List<List<DBAnyValue>> values, Action<DBExecResult> callback = null)
    {
        if (!isInited)
        {
            callback?.Invoke(null);
            return;
        }

        ExecuteStmtTask task = new ExecuteStmtTask(dbConnection, sqlstmt, values, callback);

        thread.AddTask(task);
        taskQueue.Enqueue(task);
    }
    
    // 执行多条SQL语句
    public void ExecuteMulti(List<string> cmdStr, Action<List<DBExecResult>> callback = null)
    {
        if (!isInited)
        {
            callback?.Invoke(null);
            return;
        }

        MultiExecuteTask task = new MultiExecuteTask(dbConnection, cmdStr, callback);

        thread.AddTask(task);
        taskQueue.Enqueue(task);
    }
    
    public static string GetPrimaryKeyValue<T>(T obj, SQLiteConnection dbConnection)
    {
        var mapping = dbConnection.GetMapping<T>();
        var property = obj.GetType().GetProperty(mapping.PK.PropertyName);
        if (property == null)
            return string.Empty;
        return property.GetValue(obj) as string;
    }
}

#region Thread Tasks

abstract class DatabaseActionTask : IQueuedThreadTask
{
    protected SQLiteConnection dbConnection;

    public volatile bool Processed;

    protected internal DatabaseActionTask(SQLiteConnection dbConnection)
    {
        this.dbConnection = dbConnection;
    }

    public virtual void Process()
    {
        Processed = true;
    }

    protected internal abstract void CallBack();
}

/// <summary>
/// 执行相应的SQL语句
/// </summary>
public struct DBAnyValue
{
    public int type;
    public string sv;
    public long lv;
    public double fv;
    public bool is_null;
}

public struct DBColumn
{
    public string name;
    public int type;
}

public class DBExecResult
{
    public int error;	// 错误
    public string errormsg;
    public string errorsql;    // 如果没有错误的时候，此为null
    public int change_rows;	// 修改的行数
    public long last_insertid;    // 最后插入的自增长id
    public int col_count;	// 列数
    public DBColumn[] cols;	// 列名
    public List<DBAnyValue[]> values;
}

class ExeHelper
{
    static IntPtr NegativePointer = new IntPtr (-1);
    
    // 执行一条sql语句
    static public DBExecResult ExecSql(SQLiteConnection dbConnection, string sql)
    {
        DBExecResult ret = new DBExecResult();
        ret.values = new List<DBAnyValue[]>(20);
        
        ret.error = -1;
        ret.change_rows = -1;
        ret.last_insertid = -1;

        var r = SQLite3.Result.Error;
        IntPtr handle__ = dbConnection.Handle;
        
        lock (dbConnection.SyncObject)
        {
            var stmt = IntPtr.Zero;
            try
            {
                stmt = SQLite3.Prepare2(handle__, sql);

                int col_count = SQLite3.ColumnCount(stmt);
                ret.col_count = col_count;
                ret.cols = new DBColumn[col_count];
                for (int i = 0; i < col_count; ++i)
                {
                    ret.cols[i].name = SQLite3.ColumnName16(stmt, i);
                    // ret.cols[i].type = (int)SQLite3.ColumnType(stmt, i);
                }

                while (SQLite3.Result.Row == (r = SQLite3.Step(stmt)))
                {
                    DBAnyValue[] line = new DBAnyValue[col_count];
                    for (int i = 0; i < col_count; i++)
                    {
                        var colType = SQLite3.ColumnType(stmt, i);
                        line[i].type = (int) SQLite3.ColumnType(stmt, i);

                        switch (colType)
                        {
                            case SQLite3.ColType.Null:
                                line[i].is_null = true;
                                break;

                            case SQLite3.ColType.Integer:
                                line[i].lv = SQLite3.ColumnInt64(stmt, i);
                                break;

                            case SQLite3.ColType.Float:
                                line[i].fv = SQLite3.ColumnDouble(stmt, i);
                                break;

                            default:
                                line[i].sv = SQLite3.ColumnString(stmt, i);
                                break;
                        }
                    }

                    ret.values.Add(line);
                }

                if (r != SQLite3.Result.Done)
                {
                    string msg = SQLite3.GetErrmsg(handle__);
                    ret.errormsg = msg;
                    ret.errorsql = sql;
                }
                else
                {
                    // 成功处理直接设置error = 0
                    int rowsAffected = SQLite3.Changes(handle__);
                    ret.error = 0;
                    ret.change_rows = rowsAffected;
                    ret.last_insertid = SQLite3.LastInsertRowid(handle__);
                }
            }
            catch (Exception exception)
            {
                ret.errormsg = exception.Message;
                ret.errorsql = sql;
            }
            finally
            {
                if (stmt != IntPtr.Zero) {
                    SQLite3.Finalize(stmt);
                }
            }
        }
			
        // // 结果处理
        // if (r != SQLite3.Result.Done) 
        // {
        //     if (r == SQLite3.Result.Error)
        //     {
        //         string msg = SQLite3.GetErrmsg(handle__);
        //         ret.errormsg = msg;
        //         ret.errorsql = sql;
        //     }
        //     else if (r == SQLite3.Result.Constraint)    // 约束出错
        //     {
        //         ret.errorsql = sql;
        //         if (SQLite3.ExtendedErrCode(handle__) == SQLite3.ExtendedResult.ConstraintNotNull)
        //         {
        //             ret.errormsg = SQLite3.GetErrmsg(handle__);
        //         }
        //         else
        //         {
        //             ret.errormsg = "SQLite3.Result.Constraint";
        //         }
        //     }
        // }

        return ret;
    }
    
    
    // 这个主要是做输入
    static public DBExecResult ExecStmt(SQLiteConnection dbConnection, string sql, List<List<DBAnyValue>> values)
    {
        DBExecResult ret = new DBExecResult();
        ret.values = new List<DBAnyValue[]>(20);
        
        ret.error = -1;
        ret.change_rows = -1;
        ret.last_insertid = -1;

        var r = SQLite3.Result.Error;
        IntPtr handle__ = dbConnection.Handle;

        lock (dbConnection.SyncObject)
        {
            var stmt = IntPtr.Zero;
            try
            {
                stmt = SQLite3.Prepare2(handle__, sql);
                
                // 压入绑定的值
                if (values != null)
                {
                    for (int ii = 0; ii < values.Count; ++ii)
                    {
                        List<DBAnyValue> this_row = values[ii];
                        for (int j = 0; j < this_row.Count; ++j)
                        {
                            DBAnyValue this_value = this_row[j];
                            int bind_ret;
                            int bi = j + 1; // bind index，索引要从1开始

                            SQLite3.ColType type = (SQLite3.ColType) this_value.type;
                            switch (type)
                            {
                                case SQLite3.ColType.Integer: //SQLITE_INTEGER:
                                    bind_ret = SQLite3.BindInt64(stmt, bi, this_value.lv);
                                    break;

                                case SQLite3.ColType.Float: //SQLITE_FLOAT:
                                    bind_ret = SQLite3.BindDouble(stmt, bi, this_value.fv);
                                    break;

                                case SQLite3.ColType.Text: //SQLITE3_TEXT:
                                    bind_ret = SQLite3.BindText(stmt, bi, this_value.sv, -1, NegativePointer);
                                    break;

                                default:
                                    bind_ret = SQLite3.BindNull(stmt, bi);
                                    break;
                            }
                        }
                    }
                    
                    // 处理及获取返回值 
                    while (SQLite3.Result.Row == (r = SQLite3.Step(stmt)))
                    {
                        // 第一次的时候，赋值处理；一般来说不太可能有两行值带有同样的返回处理
                        if (ret.col_count <= 0)
                        {
                            int col_count = SQLite3.ColumnCount(stmt);
                            ret.col_count = col_count;
                            ret.cols = new DBColumn[col_count];
                            for (int i = 0; i < col_count; ++i)
                            {
                                ret.cols[i].name = SQLite3.ColumnName16(stmt, i);
                                // ret.cols[i].type = (int)SQLite3.ColumnType(stmt, i);
                            }
                        }

                        DBAnyValue[] line = new DBAnyValue[ret.col_count];
                        for (int i = 0; i < ret.col_count; i++)
                        {
                            var colType = SQLite3.ColumnType(stmt, i);
                            line[i].type = (int) SQLite3.ColumnType(stmt, i);

                            switch (colType)
                            {
                                case SQLite3.ColType.Null:
                                    line[i].is_null = true;
                                    break;

                                case SQLite3.ColType.Integer:
                                    line[i].lv = SQLite3.ColumnInt64(stmt, i);
                                    break;

                                case SQLite3.ColType.Float:
                                    line[i].fv = SQLite3.ColumnDouble(stmt, i);
                                    break;

                                default:
                                    line[i].sv = SQLite3.ColumnString(stmt, i);
                                    break;
                            }
                        }

                        ret.values.Add(line);
                    }

                    if (r == SQLite3.Result.Busy)
                    {
                        int a = 0;
                        Log.Error(" == RUN SQL BUSY : {1}", sql); 
                    }

                    // 成功处理直接设置error = 0
                    int rowsAffected = SQLite3.Changes(handle__);
                    ret.error = 0;
                    ret.change_rows = rowsAffected;
                    ret.last_insertid = SQLite3.LastInsertRowid(handle__);
                }
            }
            catch
            {
                Log.Error(" exception : {0}", sql);
            }
            finally
            {
                // 结果处理
                if (r != SQLite3.Result.Done) 
                {
                    if (r == SQLite3.Result.Error)
                    {
                        string msg = SQLite3.GetErrmsg(handle__);
                        ret.errormsg = msg;
                        ret.errorsql = sql;
                    }
                    else if (r == SQLite3.Result.Constraint)    // 约束出错
                    {
                        ret.errorsql = sql;
                        if (SQLite3.ExtendedErrCode(handle__) == SQLite3.ExtendedResult.ConstraintNotNull)
                        {
                            ret.errormsg = SQLite3.GetErrmsg(handle__);
                        }
                        else
                        {
                            ret.errormsg = "SQLite3.Result.Constraint";
                        }
                    }
                }
                
                if (stmt != IntPtr.Zero)
                {
                    SQLite3.Reset(stmt);
                    SQLite3.Finalize(stmt);
                }
            }
        }



        return ret;
    }
}

class ExecuteTask2 : DatabaseActionTask 
{
    private Action<DBExecResult> callback;
    private string sql;
    private DBExecResult sql_result;

    public ExecuteTask2(SQLiteConnection dbConnection, string cmd, Action<DBExecResult> callback = null) : base(dbConnection)
    {
        this.sql = cmd;
        this.callback = callback;
    }
    
    public override void Process()
    {
        sql_result = ExeHelper.ExecSql(dbConnection, sql);
        base.Process();
    }
    
    protected internal override void CallBack()
    {
        callback?.Invoke(sql_result);
    }
}


class ExecuteStmtTask : DatabaseActionTask 
{
    private Action<DBExecResult> callback;
    private string sql;
    private DBExecResult sql_result;
    private List<List<DBAnyValue>> values;

    public ExecuteStmtTask(SQLiteConnection dbConnection, string cmd, List<List<DBAnyValue>> values, Action<DBExecResult> callback = null) : base(dbConnection)
    {
        this.sql = cmd;
        this.values = values;
        this.callback = callback;
    }
    
    public override void Process()
    {
        sql_result = ExeHelper.ExecStmt(dbConnection, sql, values);
        base.Process();
    }
    
    protected internal override void CallBack()
    {
        callback?.Invoke(sql_result);
    }
}


// 多个sql执行
class MultiExecuteTask : DatabaseActionTask
{
    private Action<List<DBExecResult>> callback;
    private List<string> sqls;
    private List<DBExecResult> sql_results;

    public MultiExecuteTask(SQLiteConnection dbConnection, List<string> cmd, Action<List<DBExecResult>> callback = null) :
        base(dbConnection)
    {
        this.sqls = cmd;
        this.callback = callback;
    }
    
    public override void Process()
    {
        this.sql_results = new List<DBExecResult>(sqls.Count);
        for (int i = 0; i < sqls.Count; ++i)
        {
            var r = ExeHelper.ExecSql(dbConnection, sqls[i]);
            // Log.Error(" == RUN SQL [{0}] : {1}", r.error, sqls[i]);
                
            sql_results.Add(r);
        }

        base.Process();
    }
    
    protected internal override void CallBack()
    {
        callback?.Invoke(sql_results);
    }
}


#endregion





