/**
 * [INPUT]: 依赖 GameEntry.Resource 异步加载 ArabicMirrorAutoReverseImageListData 配置资源
 * [OUTPUT]: 对外提供 AutoReverseImageNameList 静态查询表(IsAutoReverseImage/IsDontAutoReverseRawImage)
 * [POS]: Arabic 模块的镜像白/黑名单数据源,为 ArabicMirror 判定某张图片是否应自动翻转提供依据
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





