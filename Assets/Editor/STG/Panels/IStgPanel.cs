using UnityEngine.UIElements;

// 九个面板的统一接口，主窗口按此接口切换 Tab 内容
public interface IStgPanel
{
    string TabTitle { get; }
    VisualElement Root { get; }

    // 面板首次创建或关卡数据整体替换（New/Open）后调用，用于重建视图
    void Rebuild();
}
