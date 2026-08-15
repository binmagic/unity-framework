/**
 * [INPUT]: 依赖 UnityEngine.Input 轮询按键,依赖 GameEntry.Event 广播 EventId.OnKeyCodeEscape
 * [OUTPUT]: 对外提供 KeyCodeListener 组件(监听 Esc/返回键并转为全局事件)
 * [POS]: UI 层的物理返回键适配器,把 Android 返回/Esc 键统一收敛为事件供 Lua UI 层响应关闭窗口
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
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





