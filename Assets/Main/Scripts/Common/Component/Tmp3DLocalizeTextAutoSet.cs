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





