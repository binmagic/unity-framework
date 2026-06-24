using System;
using System.Buffers;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using UnityEngine;
using GameFramework;
using GameKit.Base;
using Sfs2X.Entities.Data;
using UnityEngine.Networking;
using UnityGameFramework.Runtime;

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
public static class PostEventLog
{
    public static class Defines
    {
        public const string LAUNCH = "APP_LAUNCH";
        public const string RES_OK = "APP_RESOK";
        public const string APP_QUIT = "APP_QUIT";
        public const string APP_PAUSE = "APP_PAUSE";
        public const string APP_RESUME = "APP_RESUME";

        public const string CHECK_VERSION_START = "CHECK_VERSION_START";
        public const string CHECK_VERSION_SUCCESS = "CHECK_VERSION_SUCCESS";
        public const string CHECK_VERSION_FAILED = "CHECK_VERSION_FAILED";
        public const string CHECK_VERSION_TIMEOUT = "CHECK_VERSION_TIMEOUT";
        public const string CHECK_VERSION_ONUPDATE = "CHECK_VERSION_ONUPDATE";

        public const string DOWNLOAD_MANIFEST_START = "DOWNLOAD_MANIFEST_START";
        public const string DOWNLOAD_MANIFEST_SUCCESS = "DOWNLOAD_MANIFEST_SUCCESS";
        public const string DOWNLOAD_MANIFEST_FAILED = "DOWNLOAD_MANIFEST_FAILED";
        public const string DOWNLOAD_MANIFEST_TIMEOUT = "DOWNLOAD_MANIFEST_TIMEOUT";
        
        public const string DOWNLOAD_START = "DOWNLOAD_START";
        public const string DOWNLOAD_FINISH = "DOWNLOAD_FINISH";
        public const string DOWNLOAD_FAILED = "DOWNLOAD_FAILED";
        
        public const string START_CONNECT = "START_CONNECT";
        public const string CONNECT_TIME_OUT = "CONNECT_TIME_OUT";
        public const string GET_SERVERLIST = "GET_SERVERLIST";
        public const string SERVERLIST_TIME_OUT = "SERVERLIST_TIME_OUT";
        public const string SERVERLIST_FAILED = "SERVERLIST_FAILED";
        public const string LONG_TIME_NOT_PUSH_INIT = "LONG_TIME_NOT_PUSH_INIT";

        public const string LOGIN_START = "LOGIN_START";
        public const string LOGIN_FINISH = "LOGIN_FINISH";
        public const string LOGIN_COMPLETE = "LOGIN_COMPLETE";
        public const string LOGIN_FAILED = "LOGIN_FAILED";
        public const string SERVER_STATUS = "SERVER_STATUS";
        public const string PUSH_INIT_RECV = "PUSH_INIT_RECV";
        public const string LOGIN_PARSE_ERROR = "LOGIN_PARSE_ERROR";
        public const string DISCONNECT_RETRY = "DISCONNECT_RETRY";
        public const string SOCKET_ERROR = "SOCKET_ERROR";
        public const string DNS_SUCESS = "DNS_SUCESS";
        public const string SOCKET_SHUTDOWN = "SOCKET_SHUTDOWN";

        public const string LOW_MEMORY = "LOW_MEMORY";
    }
  
    // 参数及字典缓存优化
    private static string[] pN = new string[] { "param0", "param1", "param2", "param3" };
    private static Dictionary<string, string> pairs = new Dictionary<string, string>();
    private static StringBuilder sb = new StringBuilder();

    private static PostEventThread postEventThread = new PostEventThread();
    public static bool hasInit = false;
    private static Dictionary<string, int> actionCountMap = new Dictionary<string, int>();

    public static bool isGpTest = false;

    private static string posteventId = "";
    
    // 设置成非const，方便在LUA中进行动态切换
//    public static string POSTURL = "http://analyse-lm.readygo.tech/ballevent.php";
    //public static string POSTURL = "http://analyse-lm.metapoint.club/ballevent.php";
    public static string POSTURL = "https://analyse-lm.florereapps.com/ballevent.php";
    
    //是否区域是中国
    public static bool isApk = false;

    // 每种错误只报一遍吧，按照堆栈处理
    private static Dictionary<string, string> exceptionDict = new Dictionary<string, string>();

    private static int getActionCount(string action){
        if (actionCountMap.ContainsKey(action)){
            actionCountMap[action] += 1;
        } else {
            actionCountMap[action] = 1;
        }
        return actionCountMap[action];
    }

    public static void init(){
        if (!hasInit)
        {
            postEventThread.Start();
            // 第一次稍微等一下
            Thread.Sleep(10);
            hasInit = true;
            //posteventId = DateTimeOffset.Now.ToUnixTimeMilliseconds();
            posteventId = GetPostEventId();
            Log.Info("posteventId = {0}", posteventId);
            string package_name = GameEntry.Sdk.GetPackageName();
            
            // 如果是test结尾的话，就是gptest
            if (package_name.EndsWith("test"))
                isGpTest = true;
            // if (RegionInfo.CurrentRegion.TwoLetterISORegionName.Equals("CN"))
            //     isInChina = true;

            try
            {
                var targetVersion = GameEntry.Sdk.GetDataFromNative("PM_GetTargetSdkVersion", "");
                var _nversion = targetVersion.ToInt();
                if (_nversion <= 30)
                {
                    isApk = true;
                }
            }
            catch (Exception)
            {
                
            }
        }
    }

    // 这个使用唯一的posteventId
    private static string GetPostEventId()
    {
        string PostEventID = GameEntry.Setting.GetString("POSTEVENTID", "");
// #if UNITY_EDITOR
//         PostEventID = "";
// #endif
        
        if (PostEventID.IsNullOrEmpty())
        {
            PostEventID = System.Guid.NewGuid().ToString().Replace("-", "");
            GameEntry.Setting.SetString("POSTEVENTID", PostEventID);
        }
        
        return PostEventID;
    }

    public static void stop()
    {
        if (hasInit)
        {
            postEventThread.Stop();
            hasInit = false;
        }
    }

    // 直接发送表单数据
    public static void PostException(string action, string logString, string longText)
    {
        // 每个堆栈只上传一次吧，否则出错之后狂上传也不好。
        string outText;
        if (exceptionDict.TryGetValue(longText, out outText))
        {
            Log.Info("PostException but duplicate!!!");
#if FINAL_RELEASE
            return;
#endif
        }
        exceptionDict[longText] = logString;

        init();

        pairs.Clear();


        var arPool = ArrayPool<byte>.Shared;

        {
            byte[] buf = arPool.Rent(longText.Length * 3);
            try
            {
                int len = System.Text.Encoding.UTF8.GetBytes(longText, 0, longText.Length, buf, 0);
                string base64 = System.Convert.ToBase64String(buf, 0, len);
                pairs.Add("form", base64);
            }
            finally
            {
                arPool.Return(buf);
            }
        }

        {
            byte[] buf = arPool.Rent(logString.Length * 3);
            try
            {
                int len = System.Text.Encoding.UTF8.GetBytes(logString, 0, logString.Length, buf, 0);
                string base64 = System.Convert.ToBase64String(buf, 0, len);
                pairs.Add("keylog", base64);
            }
            finally
            {
                arPool.Return(buf);
            }
        }

        Record(action, pairs);
    }

    // 发送打点数据
    public static void Record(string action)
    {
        init();

        pairs.Clear();
        Record(action, pairs);
    }

    // 有一些比较频繁的打点也需要处理一下
    public static void Record(int actionId)
    {
        var action = LuaStringLookupTable.Get(actionId);
        Record(action);
    }

    // 发送打点数据
    public static void Record(string action, string param1)
    {
        init();

        pairs.Clear();
        pairs.Add(pN[0], param1);

        Record(action, pairs);
    }

    // 发送打点数据
    public static void Record(string action, string param1, string param2)
    {
        init();

        pairs.Clear();
        pairs.Add(pN[0], param1);
        pairs.Add(pN[1], param2);

        Record(action, pairs);
    }

    // 发送打点数据
    public static void Record(string action, params string[] args)
    {
        init();

        pairs.Clear();

        // 0~3使用快速优化处理
        int c = Math.Min(args.Length, pN.Length);
        for (int i=0;i<c;++i)
        {
            pairs.Add(pN[i], args[i]);
        }
        for (int i=c;i<args.Length;++i)
        {
            pairs.Add("param" + i, args[i]);
        }

        Record(action, pairs);
    }

    // 发送打点数据，携带一个参数数组
    private static void Record(string action, Dictionary<string, string> dictionary = null)
    {
        // 有些错误只报一次
        int action_count = getActionCount(action);
        if (action_count > 1)
        {
            if (action == Defines.LOW_MEMORY)
            {
                return;
            }
        }

        if (action.Length > 32)
        {
            Debug.LogWarningFormat("key is too long! {0}", action);
        }
        
        // 
        var setting = GameEntry.Setting;
        var device = GameEntry.Device;
        var globalData = GameEntry.GlobalData;
        try
        {
            // 格式化具体的值
            sb.Clear();
            sb.Append("action=").Append(action);
            sb.Append("&posteventId=").Append(posteventId);
            
            sb.AppendFormat("&actioncount={0}", action_count);
            sb.AppendFormat("&timestamp={0}", DateTimeOffset.Now.ToUnixTimeMilliseconds());

            if (setting != null)
            {
                sb.Append("&uid=").Append(setting.GetPublicString(GameDefines.SettingKeys.GAME_UID, ""));
                sb.Append("&zone=").Append(setting.GetPublicString(GameDefines.SettingKeys.SERVER_ZONE, ""));
            }

            sb.Append("&deviceId=").Append(device.GetDeviceUid());
            sb.Append("&net=").Append(device.GetNetworkTypeDesc());
            
            // 打点的时候把这几个版本都加上
            sb.Append("&version=").Append(GameEntry.Sdk.Version);
            sb.Append("&buildcode=").Append(GameEntry.Sdk.VersionCode);
            if (GameEntry.Resource != null)
            {
                sb.Append("&resver=").Append(GameEntry.Resource.GetResVersion());
            }

            sb.Append("&country=").Append(globalData.fromCountry);
            sb.Append("&platform=").Append(string.IsNullOrEmpty(globalData.analyticID) ? "" : globalData.analyticID);
            
            sb.Append("&line=").Append(GameEntry.Network.getCurLine());

            if (dictionary != null)
            {
                foreach (var p in dictionary)
                {
                    string k = p.Key;
                    string v = p.Value ?? "";
                    
                    // param1要特殊处理一下，因为有可能有各种转义等字符串
                    v = v.Replace("\n", "\\n");
                    if (k == "param1")
                    {
                        v = string.Format("[[[{0}]]]", v);
                    }

                    sb.Append("&").Append(k).Append("=").Append(v);
                }
            }

            // debug版本，就不处理了，只写一个LOG
            string postData = sb.ToString();
            if (CommonUtils.IsDebug())
            {
                Log.Info("[PostEventLog] {0}", postData);
                return;
            }

            postEventThread.AddTask(new PostEventThreadTask(postData));
        }
        catch (Exception e)
        {
            Log.Error("record log {0} error", action);
        }
    }

    public static Dictionary<int, bool> _logCache = new Dictionary<int, bool>();

    public static void LogToServer(string value, int flag=0)
    {
        if (value.IsNullOrEmpty())
            return;
        if (GameEntry.GlobalData != null && GameEntry.GlobalData.fromCountry == "CN")
            return;
        
        //value = value.Replace("\n", "\\n");
        //var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(value);
        //value = System.Convert.ToBase64String(plainTextBytes);
        
        //string value_new = string.Format("ERROR|{0}|{1}|@@@", flag, value);
        if (flag == 1)
        {
            PostEventLog.Record("ERROR", value);
        }
        else
        {
            PostEventLog.Record("ERR_LOG", value);    
        }
    }

    public static void SendToFeishuMessage(string value)
    {
        var _lang = GameEntry.Localization.GetLanguageName();
        var zoneId = GameEntry.Device.GetTimeZoneId();
        if (!_lang.Equals("zh_CN") || !zoneId.Equals("Asia/Shanghai"))
        {
            return;
        }

        try
        {
            //增加版本号的描述
            string model = SystemInfo.deviceModel;
            string name = SystemInfo.deviceName;
            string osname = SystemInfo.operatingSystem;
            var setting = GameEntry.Setting;
            var gameUid = setting.GetPublicString(GameDefines.SettingKeys.GAME_UID, "\"\"");
            var packageName = GameEntry.Sdk.GetPackageName();
            string value_new = String.Format("{0} Code:{1} Device:{2}({3})\n package: {4} \n UID: {5} \n msg:{6}", 
                name, 
                GameEntry.Sdk.VersionCode, 
                model, 
                osname,
                packageName,
                gameUid, 
                value);
            
            SFSObject base_data = new SFSObject();
            base_data.PutUtfString("msg_type", "text");
            SFSObject sub_data = new SFSObject();
            sub_data.PutUtfString("text", value_new);
            base_data.PutUtfString("content", sub_data.ToJson());
            string value1 = base_data.ToJson();
            
            string url = "https://open.feishu.cn/open-apis/bot/v2/hook/b1fd809b-cb9e-40b1-9bc2-efb3f8a6caf9";

            UnityWebRequest request = new UnityWebRequest(url, "POST");
            request.SetRequestHeader("User-Agent",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36");
            byte[] bodyRaw = Encoding.UTF8.GetBytes(value1); // 将JSON数据转换成字节数组
            request.uploadHandler = (UploadHandler)new UploadHandlerRaw(bodyRaw);
            request.downloadHandler = (DownloadHandler)new DownloadHandlerBuffer();
            request.SetRequestHeader("Content-Type", "application/json");
            request.SendWebRequest();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

    // 0表示普通log，1表示程序错误
    public static void LogToFeishu(string value, int flag = 0)
    {
        try
        {
#if UNITY_EDITOR
            return;
#endif
            // 如果有重复的，就报一次
            int hashCode = value.GetHashCode();
            if (_logCache.ContainsKey(hashCode))
                return;
            _logCache[hashCode] = true;
            
#if FINAL_RELEASE
            if (isGpTest || isApk)
                SendToFeishuMessage(value);
            else
            {
                LogToServer(value, flag);
            }
#else
            SendToFeishuMessage(value);
#endif
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }

}

class PostEventThreadTask
{
    private object requestLock = new object();
    private WebRequest webrequest;
    private ManualResetEvent allDone;
    private byte[] content;
    private int contentLen;
    private string uri;
    public string param;
    
    public PostEventThreadTask(string para)
    {
        param = para;
        allDone = new ManualResetEvent(false);
        webrequest = null;
    }

    public void Abort()
    {
        try
        {
            lock (requestLock)
            {
                if (webrequest != null)
                {
                    webrequest.Abort();
                    webrequest = null;
                }
            }
        }
        catch (Exception e)
        {
            Log.Info("Abort excep " + e.Message);
        }
        finally
        {
            allDone.Set();
        }
    }

    public void BeginProcess(byte[] buffer)
    {
        try
        {
            if (string.IsNullOrEmpty(param))
            {
                allDone.Set();
                return;
            }
            
            content = buffer;
            contentLen = Encoding.UTF8.GetBytes(param, 0, param.Length, content, 0);
            
            uri = PostEventLog.POSTURL;

            var request = (HttpWebRequest)WebRequest.Create(uri);
            request.Timeout = 15000;
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            request.ContentLength = contentLen;
            request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36";

            request.BeginGetRequestStream(GetRequestStreamCallback, this);
                
            lock (requestLock)
            {
                webrequest = request;
            }
        }
        catch (Exception e)
        {
            allDone.Set();
            Log.Info("Process excep " + e.Message);
        }
    }

    public void WaitProcessDone()
    {
        try
        {
            allDone.WaitOne();
        }
        catch (Exception e)
        {
            Log.Debug("WaitProcessDone excep " + e.Message);            
        }
    }

    private static void GetRequestStreamCallback(IAsyncResult asynchronousResult)
    {
        //Log.Debug("GetRequestStreamCallback");
        WebRequest request;
        Stream postStream = null;
        PostEventThreadTask task = null;
        try
        {
            task = (PostEventThreadTask) asynchronousResult.AsyncState;

            lock (task.requestLock)
            {
                request = task.webrequest;
            }
            postStream = request.EndGetRequestStream(asynchronousResult);
            postStream.Write(task.content, 0, task.contentLen);
            postStream.Flush();
            
            request.BeginGetResponse(GetResponseCallback, task);
        }
        catch (Exception e)
        {
            if (task != null)
            {
                task.allDone.Set();
            }
            //Log.Info("GetRequestStreamCallback excep " + e.Message);
        }
        finally
        {
            if (postStream != null)
            {
                postStream.Close();
            }
            //Log.Debug("GetRequestStreamCallback finally");
        }
    }

    private static void GetResponseCallback(IAsyncResult asynchronousResult)
    {
        //Log.Debug("GetResponseCallback");
        WebRequest request;
        WebResponse response = null;
        PostEventThreadTask task = null;
        try
        {
            task = (PostEventThreadTask) asynchronousResult.AsyncState;
            
            lock (task.requestLock)
            {
                request = task.webrequest;
            }
            response = request.EndGetResponse(asynchronousResult);
            //using (var respStream = response.GetResponseStream())
            //using (StreamReader reader = new StreamReader(respStream))
            //{
            //    Log.Debug("GetResponseStream " + reader.ReadToEnd());
            //}
        }
        catch (Exception e)
        {
            Debug.LogFormat("GetResponseCallback excep {0}", e.Message);
        }
        finally
        {
            if (response != null)
            {
                response.Close();
            }
            Log.Debug("[>>>>>>> PostEventLog]{0}?{1}", task.uri, task.param);
            task.allDone.Set();
        }
    }
}


// 后台发送线程
class PostEventThread
{
    private Thread thread;
    private AutoResetEvent wakeupEvent = new AutoResetEvent(false);
    private volatile bool stop;
    private Queue<PostEventThreadTask> tasks = new Queue<PostEventThreadTask>(10);
    private volatile PostEventThreadTask currentTask;

    // 这个buffer主要用来防止GC
    private byte[] buffer = new byte[8192*2];

    public void Start()
    {
        stop = false;
        thread = new Thread(ThreadProc) {IsBackground = true};
        thread.SetThreadName("PostEventThread");
        thread.Start();
    }

    public void Stop()
    {
        try
        {
            stop = true;
            Wakeup();

            if (currentTask != null)
            {
                currentTask.Abort();
            }

            if (thread != null)
            {
                thread.Join();
                thread = null;
            }
            tasks.Clear();
        }
        catch (Exception e)
        {
            Log.Error("Stop exception " + e.Message);
        }
    }

    public void AddTask(PostEventThreadTask task)
    {
        lock (tasks)
        {
            tasks.Enqueue(task);
        }

        Wakeup();
    }

    private void Sleep()
    {
        wakeupEvent.WaitOne();
    }

    private void Wakeup()
    {
        wakeupEvent.Set();
    }

    private void ThreadProc()
    {
        while (!stop)
        {
            currentTask = null;
            
            lock (tasks)
            {
                if (tasks.Count > 0)
                {
                    currentTask = tasks.Dequeue();
                }
            }

            if (currentTask != null)
            {
                try
                {
                    currentTask.BeginProcess(buffer);
                    if (stop)
                    {
                        currentTask.Abort();
                        break;
                    }
                    currentTask.WaitProcessDone();
                }
                catch (Exception e)
                {
                    Log.Info("post thread excep", e);
                }
            }
            else
            {
                Sleep();
            }
        }
        //Log.Debug("post ThreadProc end");
    }
}





