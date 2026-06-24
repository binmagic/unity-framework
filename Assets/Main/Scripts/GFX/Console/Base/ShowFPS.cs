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





