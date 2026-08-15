/**
 * [INPUT]: 依赖 UnityEngine 的 IMGUI 绘制
 * [OUTPUT]: 对外提供 BaseGFXPanel 面板基类,定义面板名与 Init/DrawGUI 生命周期钩子
 * [POS]: GFX/Console/Base 的面板抽象,所有 Panels/ 下的调试页签均继承它,是调试台的插件契约
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

/// <summary>
/// GFX控制台的一个选项
/// </summary>
public class BaseGFXPanel
{
    public string name { get; private set; }

    public BaseGFXPanel(string p_name)
    {
        name = p_name;
    }

    public virtual void Init()
    {
        
    }

    public virtual  void DrawGUI()
    {
        
    }

    protected float DrawSlider(string label, float v, float min, float max)
    {
        float resultValue;
       
        GUILayout.Label(label+":"+v);
        resultValue = GUILayout.HorizontalSlider(v, min, max);
       
        return resultValue;
    }

    protected string DrawInputField(string label,  string inputTex)
    {
        GUILayout.BeginHorizontal();
        GUILayout.Label(label);
        string result = GUILayout.TextField(inputTex);
        GUILayout.EndHorizontal();
        return result;

    }
}





