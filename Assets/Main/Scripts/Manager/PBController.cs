using System.Collections.Generic;
using GameFramework;
using UnityEngine;
using VEngine;
using XLua;

public class PBController
{
    private List<string> pbFiles = new List<string>(10);

    public bool IsInitDone { get; private set; }
    public bool IsInitSuccess { get; private set; }
    public int loadSuccessCount { get; private set; }
    public int preloadCount { get; private set; }
    
    private List<VEngine.Asset> preloadRequest = new List<VEngine.Asset>();
    private List<Asset> loadRequest = new List<VEngine.Asset>();
    public void Reload()
    {
        IsInitDone = false;
        IsInitSuccess = true;
        loadSuccessCount = 0;
        var pbTable = GameEntry.Lua.Env.Global.GetInPath<LuaTable>("PBController.ProtoConfig");
        int index = 1;
        string pbfilename = "";
        pbFiles.Clear();
        do
        {
            pbfilename = pbTable.Get<string>(index++);
            if (!pbfilename.IsNullOrEmpty())
                pbFiles.Add(pbfilename);
                
        } while (!pbfilename.IsNullOrEmpty());
        
        loadRequest.ForEach(i=>i.Release());
        loadRequest.Clear();
        preloadCount = 0;
        preloadRequest.ForEach(i => i.Release());
        preloadRequest.Clear();
        foreach (var path in pbFiles)
        {
            var req = GameEntry.Resource.LoadAssetAsync(path, typeof(TextAsset));
            loadRequest.Add(req);
            req.completed += delegate(VEngine.Asset request)
            {
                if (!request.isError)
                {
                    OnLoadAssets(request);
                }
                else
                {
                    var errorStr = $"LoadTable error {request.pathOrURL} {request.error}";
                    GameEntry.Lua.Call("CSharpCallLuaInterface.SendErrorMessageToServer",errorStr);
                    Log.Error(errorStr);
                }
                
                preloadCount++;
                if (preloadCount == pbFiles.Count)
                {
                    IsInitDone = true;
                    IsInitSuccess = preloadRequest.TrueForAll(i => !i.isError);
                    loadRequest.ForEach(i=>i.Release());
                    loadRequest.Clear();
                    preloadRequest.ForEach(i => i.Release());
                    preloadRequest.Clear();
                }
            };
        }

        // XLua.LuaDLL.Lua.pbn_global_clear();
    }

    private void OnLoadAssets(VEngine.Asset request)
    { 
        byte[] bytes = ((TextAsset)request.asset).bytes ;
        var loadSuccess = XLua.LuaDLL.Lua.Load_luaUtil(GameEntry.Lua.Env.L, bytes, bytes.Length);
        // var loadPbNodeSuccess = XLua.LuaDLL.Lua.pbn_loadPbSchemeBinary(bytes, bytes.Length);
        if (loadSuccess > 0)
        {
            loadSuccessCount++;
        }

        // Debug.Log($"PbNode Load {request.asset.name}, {loadPbNodeSuccess}");
        //通过lua加载
//        GameEntry.Lua.LuaLoadPb(bytes);
    }

}





