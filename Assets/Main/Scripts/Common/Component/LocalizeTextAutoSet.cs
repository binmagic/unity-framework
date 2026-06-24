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





