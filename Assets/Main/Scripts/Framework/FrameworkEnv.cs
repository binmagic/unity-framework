//------------------------------------------------------------
// 框架环境信息：框架根节点名 + 常用节点路径的唯一来源
// 由 ApplicationLaunch 在实例化框架 prefab 后写入 RootName，
// 其它使用方只读，不再直接依赖 ApplicationLaunch。
//------------------------------------------------------------

public static class FrameworkEnv
{
    // 框架根节点名（= 实例化后的框架 GameObject 名 = prefab 文件名）
    public static string RootName = "GameFramework";

    // 常用节点路径（集中拼接，改结构只动这里）
    public static string UIRoot => RootName + "/UI";
    public static string UIContainerPath => RootName + "/UI/UIContainer";
    public static string UICameraPath => RootName + "/UI/UICamera";
    public static string BlurCameraPath => RootName + "/UI/BlurCamera";
    public static string GfxProfilerBgPath => RootName + "/UI/UIContainer/GfxProfilerBg";
    public static string MainCameraPath => RootName + "/JustForShake/Main Camera";
}
