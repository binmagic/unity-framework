using System.Collections.Generic;
using UnityEngine;

public static class AutoReverseImageNameList
{
    public static HashSet<string> AutoReverseImageName = new HashSet<string>();
    public static HashSet<string> DontAutoReverseRawImageName = new HashSet<string>();
    private static VEngine.Asset dataListAsset1;
    private static VEngine.Asset dataListAsset2;

    public static void Init()
    {
        if (dataListAsset1 == null || dataListAsset2 == null)
        {
            Load();
        }
    }
    private static void Load()
    {
        if(GameEntry.Resource != null)
        {
            dataListAsset1 = GameEntry.Resource.LoadAssetAsync(
                "Assets/Main/Prefabs/UI/Arabic/ArabicMirrorAutoReverseImageList.asset",
                typeof(ArabicMirrorAutoReverseImageListData));
            dataListAsset1.completed += delegate
            {
                AutoReverseImageName.Clear();
                var list = dataListAsset1.Get<ArabicMirrorAutoReverseImageListData>();
                foreach (var name in list.reverseImageList)
                {
                    AutoReverseImageName.Add(name);
                }

                dataListAsset1.Release();
            };            
            
            dataListAsset2 = GameEntry.Resource.LoadAssetAsync(
                "Assets/Main/Prefabs/UI/Arabic/ArabicMirrorDontAutoReverseRawImageList.asset",
                typeof(ArabicMirrorAutoReverseImageListData));
            dataListAsset2.completed += delegate
            {
                DontAutoReverseRawImageName.Clear();
                var list = dataListAsset2.Get<ArabicMirrorAutoReverseImageListData>();
                foreach (var name in list.reverseImageList)
                {
                    DontAutoReverseRawImageName.Add(name);
                }

                dataListAsset2.Release();
            };
        }
    }

    public static bool IsAutoReverseImage(string name)
    {
        if (dataListAsset1 == null)
        {
            Load();
            return false;
        }

        return AutoReverseImageName.Contains(name);
    }    
    
    public static bool IsDontAutoReverseRawImage(string name)
    {
        if (dataListAsset2 == null)
        {
            Load();
            return false;
        }

        return DontAutoReverseRawImageName.Contains(name);
    }

}





