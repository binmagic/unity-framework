/**
 * [INPUT]: 依赖 UnityEngine 的 ScriptableObject 序列化能力
 * [OUTPUT]: 对外提供 ArabicMirrorAutoReverseImageListData 资产类(承载图片名字符串数组)
 * [POS]: Arabic 模块的镜像名单资产载体,是 AutoReverseImageNameList 加载的磁盘配置形态
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
[CreateAssetMenu(fileName = "ArabicMirrorAutoReverseImageList", menuName = "ScriptableObjects/ArabicMirrorAutoReverseImageList", order = 0)]
public class ArabicMirrorAutoReverseImageListData : ScriptableObject
{
    public string[] reverseImageList; 
}





