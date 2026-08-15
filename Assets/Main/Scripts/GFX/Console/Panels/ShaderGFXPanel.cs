/**
 * [INPUT]: 继承 BaseGFXPanel,依赖 UnityEngine.Shader 的 globalMaximumLOD 等全局态
 * [OUTPUT]: 对外提供 ShaderGFXPanel,运行时调节全局 ShaderLOD 与关键字以调试渲染档位
 * [POS]: GFX/Console/Panels 的 Shader 调试页,由 GFXConsole 装配,专管着色器 LOD 与 keyword 现场调参
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public class ShaderGFXPanel :BaseGFXPanel
{
    private string keywordName="";
    public ShaderGFXPanel() : base("Shader") { }

    public override void DrawGUI()
    { 
        GUILayout.Label($"ShaderLOD:{Shader.globalMaximumLOD}");
       GUILayout.BeginHorizontal();
       if (GUILayout.Button("601"))
       {
           Shader.globalMaximumLOD = 601;
       }
       if (GUILayout.Button("401"))
       {
           Shader.globalMaximumLOD = 401;
       }
       if (GUILayout.Button("201"))
       {
           Shader.globalMaximumLOD = 201;
       }
       GUILayout.EndHorizontal();
       
       GUILayout.Space(30);
      
       keywordName=DrawInputField("Shader关键字",  keywordName);
        GUILayout.Label($"{keywordName}开关 {Shader.IsKeywordEnabled(keywordName)}");
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("开"))
        {
            Shader.EnableKeyword(keywordName);
        }
        if (GUILayout.Button("关"))
        {
            Shader.DisableKeyword(keywordName);
        }
        GUILayout.EndHorizontal();
    }
}





