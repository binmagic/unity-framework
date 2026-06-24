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





