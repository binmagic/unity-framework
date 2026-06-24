using System.Collections;  
using System.Collections.Generic;  
using UnityEngine;  
using UnityEngine.UI;  
using GameFramework;  

public class KeyCodeListener :MonoBehaviour 
{
    private void Awake()  
    {
    }  
  
    private void Update()
    {
        OnCheck();
    }

    private void OnCheck()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            GameEntry.Event.Fire(EventId.OnKeyCodeEscape);
        }
    }
}





