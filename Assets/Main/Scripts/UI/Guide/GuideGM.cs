/**
 * [INPUT]: 依赖 Odin Inspector 生成编辑器按钮,依赖 GameEntry.Lua 调用 DataCenter.GuideManager/SU_EventSystem 的 Lua 方法
 * [OUTPUT]: 对外提供 GuideGM 编辑器调试组件(在 Inspector 中一键触发指定引导 ID 与事件 ID)
 * [POS]: Guide 模块的引导调试入口,是 C# 侧薄壳、真正引导逻辑在 Lua DataCenter.GuideManager,仅供开发期手动驱动引导流程
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
#if UNITY_EDITOR
using Sirenix.OdinInspector;
#endif

public class GuideGM : MonoBehaviour
{
    
    // [Title("引导部分:")]
#if UNITY_EDITOR    
    [HorizontalGroup("引导")]
    [LabelText("引导ID:")]
#endif
    public int _guideId;
    
#if UNITY_EDITOR
    [HorizontalGroup("引导")]
    [Button("执行引导",ButtonSizes.Medium)]
#endif
    private void SetGuideId()
    {
        GameEntry.Lua.Call("DataCenter.GuideManager:SetCurGuideId", _guideId);
        GameEntry.Lua.Call("DataCenter.GuideManager:DoGuide");
    }

    
    // [Space(30)]
    // [Title("")]
#if UNITY_EDITOR
    [HorizontalGroup("事件")]
    [LabelText("事件ID")]
#endif
    public int eventId;

#if UNITY_EDITOR
    [HorizontalGroup("事件")]
    [Button("执行事件", ButtonSizes.Medium)]
#endif
    private void DoEventId()
    {
        GameEntry.Lua.Call("DataCenter.SU_EventSystem:DoEventGM", eventId);
    }

}





