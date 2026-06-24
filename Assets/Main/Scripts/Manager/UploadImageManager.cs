using System;
using System.IO;
using UnityEngine;
using GameKit.Base;
using GameFramework;
using UnityEngine.Networking;

public class UploadImageManager
{
    #region 单例
    private static UploadImageManager _instance;
    public static UploadImageManager Instance
    {
        get
        {
            if (null == _instance)
            {
                _instance = new UploadImageManager();
            }

            return _instance;
        }
    }

    public static void Purge()
    {
        _instance = null;

    }


    #endregion

    // 保存一个最后一次上传的参数。
    // 因为异步，同时理论上每次只会发起一次，所以这里暂时不考虑重叠问题
    private string param_uid_;
    private int param_picVer_;
    private Action<string, string> param_callback_;
    
    public static string PHOTO_UPLOAD_URL_DEBUG = "http://10.7.88.22:85/upload_img.php";
    public static string PHOTO_UPLOAD_URL_ONLINE = "http://upload-img-lm.metapoint.club/upload_img.php";

    private static string PHOTO_UPLOAD_URL
    {
        get
        {
            if (CommonUtils.IsDebug())
            {
                return PHOTO_UPLOAD_URL_DEBUG;
            }
            else
            {
                return PHOTO_UPLOAD_URL_ONLINE;
            }
        }
    }
    
    private UploadImageManager()
    {
        GameFramework.Log.Info("初始化UploadImageManager ~");
    }

    // 上传头像照片起始入口，从LUA端发起
    public void OnUploadImage(int code, string uid, int picVer, Action<string, string> action)
    {
        param_uid_ = uid;
        param_picVer_ = picVer;
        param_callback_ = action;
     
        GameEntry.GlobalData.isUploadPic = true;
        
#if UNITY_EDITOR
        string urlPath = UnityEditor.EditorUtility.OpenFilePanel("Select a Picture", Application.dataPath, "");
        OnImagePathOk(urlPath);
#else
        GameEntry.Sdk.OnUploadPhoto(uid, code, picVer);
#endif
    }
    
    // 图片选择完毕
    public void OnImagePathOk(string filePath)
    {
        GameEntry.GlobalData.isUploadPic = false;
        if (param_callback_ == null)
        {
            return;
        }
        
        if(string.IsNullOrEmpty(filePath))
        {
            param_callback_("false", "no file");
            return;
        }
        
        Debug.Log($"#UploadImageManager# GetHeadImgBack filePath:{filePath}");
        
        // GameEntry.Lua.CallLuaFunc("WebUtil", "UploadHead", filePath);

        int picVer = param_picVer_ % 1000000;
        string str_picVer = string.Format("{0}", picVer + 1);
        UploadHeadImage(PHOTO_UPLOAD_URL, param_uid_, str_picVer, filePath, param_callback_);

        return;
    }
    
    // 上传头像
    // 先写到这里吧。因为目前直接使用 UnityWebRequest，没几行代码，所以不用单独去归类了
    public void UploadHeadImage(string uri, string uid, string photo_seq, string filePath, Action<string, string> cb)
    {
        Debug.Log("#UploadHeadImage# step in UploadHeadImage!");
        // 每一个post请求对应一个cb吧，不用公共的了
        if (cb == null)
        {
            Debug.LogError("#UploadHeadImage#  no callback??? error!!");
            return;
        }

        //设置开始上传标记
        GameEntry.Lua.Call("CSharpCallLuaInterface.OnUploadPicStart");
        
        if (File.Exists(filePath) == false)
        {
            Debug.LogError("#UploadHeadImage# file not found??? error!!");
            cb("false", "");

            return;
        }
        
        byte[] photoByte = File.ReadAllBytes(filePath);
        if (photoByte.Length < 16)
        {
            Debug.LogError("#UploadHeadImage# file is wrong??? error!!");
            cb("false", "");
            
            return;
        }

        string kvstr = "x645rGA7rnG5yOZkGijddata0commandNameuser/UploadPhotoparams0" + "gameuid" + uid + "photo_seq" + photo_seq;
        string strAuthKey = AESHelper.GetMd5Hash(kvstr);
        
        string format = 
@"{{
    ""data"":[{{
        ""commandName"":""user/UploadPhoto"",
        ""params"":[{{
            ""photo_seq"":""{0}"",
            ""gameuid"":""{1}"",
        }}]
    }}],
    ""authkey"":""{2}""
}}";

        string ext = "";
        int pos = filePath.LastIndexOf('.');
        if (pos != -1)
        {
            ext = filePath.Substring(pos + 1);
        }
        
        string filename = Path.GetFileName(filePath);
        string mimeType = "image/" + ext;
        
        string v = string.Format(format, photo_seq, uid, strAuthKey);

        // 添加MultipartForm，json和binary!
        WWWForm form = new WWWForm();
        form.AddField("UploadPhoto", v);
        form.AddField("uid", uid);
        form.AddField("pvr", photo_seq);
        form.AddBinaryData("file", photoByte, filename, mimeType);
        
        Debug.Log($"#UploadHeadImage#  Start Web Post! byteLen:{photoByte.Length}");

        WebRequestManager.Instance.Post(uri, form,
            (UnityWebRequest request, bool hasErr, object userdata) =>
            {
                // post每帧都会调用，所以这里要处理一下
                if (request.isDone == false)
                {
                    return;
                }
                
                bool b = true;
                if (hasErr || request.responseCode < 200 || request.responseCode >= 300)
                {
                    b = false;
                }
                
                string retdata = request.downloadHandler.text;
                
                Debug.Log($"#UploadHeadImage# Web ret:{b}, rspCode:{request.responseCode}, Error:{request.error}, Res:{retdata}");
                
                cb(b ? "true" : "false", retdata);
            }, 0, 30);
    }

    // 获取头像路径，和uid及picVer都有关系
    public static string GetHeadPath(string uid, string picVer)
    {
        // https:/域名/$file_folder/$file_name
        //     file_folder = substr($useruid, -6);
        // 15:33
        //     $seq=$data['picVer'];
        //     $file_name = md5($useruid . '_' . $seq) .'.jpg'
        // http://10.7.88.22:89/img/000001/b7ad5f28ad2634404c5686791c79258e.jpg

        string file_folder = uid.Substring(uid.Length-6, 6);
        string file_name = AESHelper.GetMd5Hash(uid + "_" + picVer) + ".jpg";

        return file_folder + "/" + file_name;
    }
    
    // 下载头像
    // 首先下载到文件，然后使用的时候用户从文件中读取byte[]，然后加载
    public void DownloadHeadImage(string uri, string uid, string picVer, Action<string, string> cb)
    {
        // 每一个post请求对应一个cb吧，不用公共的了
        if (cb == null)
        {
            Log.Error("RequestTranslate no callback??? error!!");
            return;
        }

        string headPath = GetHeadPath(uid, picVer);
        
        // {0} = uri
        // {1} = 如果uri最后是/的话，就不处理，如果不是/，加一个/
        // {2} = head path
        string full_uri = string.Format("{0}{1}{2}", uri, uri.EndsWith("/") ? "" : "/", headPath);
        string local_image = string.Format("{0}/LocalImage/{1}", Application.persistentDataPath, headPath);
        
        string path = Path.GetDirectoryName(local_image);
        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);
        
        Debug.Log($"full_uri:{full_uri}");
        // full_uri = "http://10.7.88.22:89/img/000001/b7ad5f28ad2634404c5686791c79258e.jpg";
        
        // 直接将文件下载到指定目录
        WebRequestManager.Instance.DownFile(full_uri, local_image,(request, hasErr, userdata) =>
        {
            bool b = true;
            if (hasErr || request.isDone != true)
            {
                b = false;
            }
            
            cb(b ? "true" : "false", "");
        });

        return;
    }

}





