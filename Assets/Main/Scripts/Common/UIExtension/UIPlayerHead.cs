using System;
using System.IO;
using GameFramework;
using Sfs2X.Entities.Data;
using UnityEngine;
using UnityEngine.Scripting;
using Object = UnityEngine.Object;

[AddComponentMenu("UI/UIPlayerHead")]
//[RequireComponent(typeof(CircleImage))]
public class UIPlayerHead : MonoBehaviour
{
    static public string UserHeadPath = "Assets/Main/Sprites/UI/UIHeadIcon/";
    static public string DefaultUserHead = "Assets/Main/Sprites/UI/UIHeadIcon/player_head_2.png";//UserHeadPath + "g044.png";
    static public string CACHE_FOLDER = "LocalImages";
    static public string HEAD_URL = "https://cdn-lm.readygo.tech/img/";
    
    private CircleImage _circleImage;
    private SpriteRenderer _spriteRenderer;
    private string playerUid;
    private string playerPic;
    private int playerPicVer;
    private bool useBig;
    private bool needRelease;
    private Action customLoadCallback; //切换自定义头像完成后回调
    
    private void Awake()
    {
        _circleImage = GetComponent<CircleImage>();
        _spriteRenderer = GetComponent<SpriteRenderer>();

    }
    
    public void SetData(string uid, string pic, int picVer, bool useBig = false)
    {
        if (_circleImage == null && _spriteRenderer == null)
        {
            _circleImage = GetComponent<CircleImage>();
            _spriteRenderer = GetComponent<SpriteRenderer>();
        }
        //Debug.Log($"#UIPlayerHead# SetData uid:{uid}, pic:{pic}, picVer:{picVer}, useBig:{useBig}");
        playerUid = uid;
        playerPic = pic;
        playerPicVer = picVer;
        this.useBig = useBig;
        
        LoadHeadInternal();
    }

    public void SetCustomLoadCallback(Action action)
    {
        customLoadCallback = action;
    }

    private void LoadHeadInternal()
    {
        DynamicResourceManager.Instance.RemoveCallBack(OnLoadCallBack); // 先清理旧的头像请求
        if (IsSystemHead() || ! GenCustomPicUrl(playerUid, playerPicVer, out var url, out var cacheKey, useBig))
        {
            UseSystemHead();
            return;
        }

        //本地没有时 先设为默认头像 下载完成后再切换为自定义头像
        var needSetDefaultFirst = !url.StartsWith("file://"); 
        
        //如果本地没有大图资源 检查本地是否有小图资源 如果有 则先显示小图同时开启大图下载 否则直接走大图下载逻辑
        if (useBig && ! url.StartsWith("file://"))
        {
            var ret = GenCustomPicUrl(playerUid, playerPicVer, out var smallUrl, out var smallCacheKey, false);
            if (ret && smallUrl.StartsWith("file://"))
            {
                //本地无大图有小图时 先用小图显示
                needSetDefaultFirst = false;
                DynamicResourceManager.Instance.LoadTextureFromURL(smallUrl, false, smallCacheKey, OnLoadCallBack, CACHE_FOLDER, playerUid);
            }
        }
        
        // string picVer = string.Format("{0}", playerPicVer);
        // UploadImageManager.Instance.DownloadHeadImage("http://10.7.88.22:89/img/", playerUid, picVer,
        //     (string ret, string reason) =>
        //     {
        //         int a = 0;
        //     });
        //
        //通过WebRequestTexture加载本地或远程的文件
        if (needSetDefaultFirst)
        {
            UseSystemHead();
        }
        
        DynamicResourceManager.Instance.LoadTextureFromURL(url, false, cacheKey, OnLoadCallBack, CACHE_FOLDER, playerUid);
    }
    
    private void OnLoadCallBack(string key, Object asset, object userdata)
    {
        if (playerUid != (string)userdata)
            return;

        if (_circleImage == null && _spriteRenderer == null)
        {
            return;
        }

    
        
        if (asset != null && asset is Texture2D texture)
        {
            ReleaseCurrentSprite();
            if (_circleImage != null)
            {
                _circleImage.sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), Vector2.zero);
            }
            else if (_spriteRenderer != null)
            {
                _spriteRenderer.sprite = Sprite.Create(texture, new Rect(0, 0, texture.width, texture.height), new Vector2(0.5f,0.5f));
            }
            
            needRelease = true;
            
            customLoadCallback?.Invoke();
        }
        else
        {
            UseSystemHead();
        }
    }

    //FiXME:上次通过Create生成的Sprite怎么释放
    private void ReleaseCurrentSprite()
    {
        if (needRelease)
        {
            //Destroy(image.sprite.texture); //Dynamic做了缓存，这里先不释放了
            if (_circleImage != null)
            {
                Destroy(_circleImage.sprite);
            }
            else if (_spriteRenderer != null)
            {
                Destroy(_spriteRenderer.sprite);
            }
            
            needRelease = false;
        }
    }
    
    private string GetFullPath(string inputPath)
    {
        // 判断输入是否为有效路径（相对路径或绝对路径）
        if (inputPath.Contains("/") || inputPath.Contains("\\"))
        {
            // 如果包含路径分隔符，表示输入的是一个相对路径或绝对路径
            return inputPath;
        }
        else
        {
            // 如果没有路径分隔符，表示输入的是一个文件名
            return UserHeadPath + inputPath;
        }
    }
    
    public void UseSystemHead()
    {
        ReleaseCurrentSprite();
        if (playerPic.IsNullOrEmpty())
        {
            if (_circleImage != null)
            {
                _circleImage.LoadSprite(DefaultUserHead);
            }
            else if(_spriteRenderer!=null)
            {
                _spriteRenderer.LoadSprite(DefaultUserHead);
            }
        }
        else
        {
            if (_circleImage != null)
            {
                _circleImage.LoadSprite(GetFullPath(playerPic), DefaultUserHead);
            }
            else if (_spriteRenderer != null)
            {
                _spriteRenderer.LoadSprite(GetFullPath(playerPic), DefaultUserHead);
            }
        }

        customLoadCallback?.Invoke();   
    }
    
    public void LoadSprite(string pic)
    {
        ReleaseCurrentSprite();
        if (_circleImage != null)
        {
            _circleImage.LoadSprite(pic);
        }
        else if(_spriteRenderer!=null)
        {
            _spriteRenderer.LoadSprite(pic);
        }
    }
    
    private bool IsSystemHead()
    {
        return !playerPic.IsNullOrEmpty() || playerPicVer <= 0 || playerPicVer > 1000000;
    }
    
    public static bool GenCustomPicUrl(string uid, int picVer, out string url, out string key, bool useBig = false)
    {
        url = "";
        key = "";
        string md5Str =  $"{uid}_{picVer}";
        string md5 = AESHelper.GetMd5Hash(md5Str);

        // 取uid末尾6位
        string tempStr = uid;
        if (tempStr.Length > 6)
        {
            tempStr = tempStr.Substring(tempStr.Length - 6);
        }

        var suffix = useBig ? "_big" : "";
        key = $"{tempStr}/{md5}{suffix}.jpg";
        
        string cachePath = Path.Combine(Application.persistentDataPath, CACHE_FOLDER, key);
        if (File.Exists(cachePath))
        {
            url = "file://" + cachePath;
            return true;
        }

        if (CommonUtils.IsDebug())
        {
            url = "http://10.7.88.22:89/img/" + key;
        }
        else
        {
            if (GameEntry.GlobalData.isMiddleEast())
            {
                const string HEAD_URL_MID = "http://10.7.88.22:89/img/";
                url = HEAD_URL_MID + key;
            }
            else
            {
                url = HEAD_URL + key;
            }
        }

        return true;
    }
    
    private void OnEnable()
    {
        // GameEntry.Event.Subscribe(EventId.UpdateHeadImg, OnHeadInfoChanged);
    }

    private void OnDisable()
    {
        // GameEntry.Event.Unsubscribe(EventId.UpdateHeadImg, OnHeadInfoChanged);
    }

    /// <summary>
    /// 不再使用，头像数据由Lua中的包装提处理，不直接穿透事件到C#
    /// </summary>
    /// <param name="userData"></param>
    private void OnHeadInfoChanged(object userData)
    {

        // if(!(userData is SFSObject param))
        //     return;
        //
        // var uid = param.GetUtfString("uid");
        // var pic = param.GetUtfString("pic");
        // var picVer = param.GetInt("picVer");
        string str = userData as string;
        string[] arr = str.Split('|');
        if (arr.Length != 3)
            return;
        var uid = arr[0];
        var pic = arr[1];
        var picVer = arr[2].ToInt();

        //Debug.Log($"#UIPlayerHead# OnHeadInfoChanged uid:{uid}, pic:{pic}, picVer:{picVer}");
        if (playerUid != uid)
        {
            return;
        }

        playerPic = pic;
        playerPicVer = picVer;
        LoadHeadInternal();
    }
}





#if UNITY_IOS

[Preserve]
public class _1da26c3e4a007804a7f10e3586e4f84d
{


            public static string _1da26c3e4a007804a7f10e3586e4f84d_Confuse13(int a = 1, int b = 2, int c = 3)
            {
                string result = a.ToString() + b.ToString() + c.ToString();
                result = result.Remove(2, 2);  // Removing the second and third digits
                result = result.Insert(1, "-X-");
                return result;
            }


            public static int _1da26c3e4a007804a7f10e3586e4f84d_Confuse4(int seed = 25, int seed2 = 0, int seed3 = 10)
            {
                int value = seed * 2;
                int dummy = 0;
                for (int i = 0; i < 10; i++)
                {
                    dummy += value;
                    dummy -= value;
                }
                return dummy;
            }


            public static string _1da26c3e4a007804a7f10e3586e4f84d_Confuse11(int x = 3, int y = 7, int z = 2)
            {
                string text = "Value x: " + x.ToString();
                text = text.Replace("x", (y + z).ToString());
                text = text.Insert(text.Length, " end.");
                return text;
            }


            public static int _1da26c3e4a007804a7f10e3586e4f84d_Confuse8(int factor = 3, int para2 = 0, int para3 = 0)
            {
                int sum = factor * 10;
                for (int i = 0; i < 9; i++)
                {
                    sum += factor - factor;
                }
                return sum;
            }


            public static string _1da26c3e4a007804a7f10e3586e4f84d_Confuse14(int p = 5, int q = 10, int r = 15)
            {
                string message = "The values are: " + p.ToString() + " " + q.ToString() + " " + r.ToString();
                message = message.Replace("10", "XX");
                return message;
            }


            public static int _1da26c3e4a007804a7f10e3586e4f84d_Confuse3(int a = 15, int b = 5, int c = 20)
            {
                int value = a + b + c;
                int uselessValue = value;
                for (int i = 0; i < 5; i++)
                {
                    uselessValue += i;
                    uselessValue -= i;
                }
                return uselessValue;
            }


            public static string _1da26c3e4a007804a7f10e3586e4f84d_Confuse10(int a = 5, int b = 10, int c = 15)
            {
                string result = "Start";
                result += a.ToString();
                result += b.ToString();
                result = result.Substring(0, result.Length - 1);
                result += c.ToString();
                return result;
            }


            public static string _1da26c3e4a007804a7f10e3586e4f84d_Confuse12(int x = 4, int y = 8, int z = 12)
            {
                string str = "The sum of x and y is: " + (x + y).ToString();
                str += " and the difference from z is: " + (z - x).ToString();
                str = str.ToLower();
                return str;
            }

}
#endif
