/**
 * [INPUT]: 依赖 UnityEngine 的 Time 与 IMGUI
 * [OUTPUT]: 对外提供 ShowFPS MonoBehaviour,按固定间隔统计并以 IMGUI 叠加显示实时帧率
 * [POS]: GFX/Console/Base 的独立帧率显示组件,可脱离控制台单挂,是最轻量的性能可视化工具
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public class ShowFPS : MonoBehaviour
{
    private float updateInterval = 1F;
    private double lastInterval;
    private int frames = 0;
    private int fps;

    void Start() 
    {
        lastInterval = Time.realtimeSinceStartup;
        frames = 0;
    }
    void OnGUI() 
    {
        GUIStyle myStyle = new GUIStyle();
        myStyle.fontSize = 30;
        myStyle.normal.textColor = new Color(1, 0, 0,1);
        GUILayout.Label("FPS:"+fps, myStyle);
    }
    void Update() 
    {
        ++frames;
        float timeNow = Time.realtimeSinceStartup;
        if (timeNow > lastInterval + updateInterval) {
            fps = (int) (frames / (timeNow - lastInterval));
            frames = 0;
            lastInterval = timeNow;
        }
    }
}





