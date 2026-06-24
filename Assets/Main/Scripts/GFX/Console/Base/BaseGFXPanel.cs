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





