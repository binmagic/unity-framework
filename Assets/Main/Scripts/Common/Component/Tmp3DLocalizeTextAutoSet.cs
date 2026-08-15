/**
 * [INPUT]: 依赖 NewTMP3DText 的 3D 文本渲染组件，依赖 GameEntry.Localization.GetString 按 id 取本地化文案
 * [OUTPUT]: 对外提供 Tmp3DLocalizeTextAutoSet 组件与 Refresh，按 dialogId 自动填充 3D 文本
 * [POS]: Common/Component 的 3D 文本本地化桥接器，启用时把配置的 dialogId 解析成当前语言文案写入 NewTMP3DText，是场景内 3D 文字接入 GameEntry 本地化系统的挂点
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;


[RequireComponent(typeof(NewTMP3DText)), DisallowMultipleComponent]
public class Tmp3DLocalizeTextAutoSet : MonoBehaviour
{
    public string dialogId;
    private NewTMP3DText _newText;
    private void Awake()
    {
        _newText = GetComponent<NewTMP3DText>();
    }

    private void OnEnable()
    {
        Refresh();
    }
    
    public void Refresh()
    {
        if (!string.IsNullOrEmpty(dialogId.Trim()) && _newText != null)
        {
            var str = GameEntry.Localization.GetString(dialogId.Trim());
            _newText.text = str;
        }
        else
        {
            _newText.text = string.Empty;
        }
    }
}





