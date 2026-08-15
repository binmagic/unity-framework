/**
 * [INPUT]: 依赖同物体的 NewText 文本组件，经 GameEntry.Localization.GetString 按 dialogId 取本地化文案
 * [OUTPUT]: 对外提供 LocalizeTextAutoSet 组件的 Refresh 方法，启用时自动把本地化文案写入 NewText
 * [POS]: Common/Component 的文本本地化挂件，[RequireComponent(NewText)] 强绑文本组件，是 UI 与框架本地化模块之间的声明式桥接
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;


[RequireComponent(typeof(NewText)), DisallowMultipleComponent]
public class LocalizeTextAutoSet : MonoBehaviour
{
    public string dialogId;
    private NewText _newText;
    private void Awake()
    {
        _newText = GetComponent<NewText>();
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





