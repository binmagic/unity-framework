[System.Serializable]
public class GPUSkinningClip
{
    public string name = null;
    
    public string animationClipName;
    
    public float length = 0.0f;

    public int fps = 0;

    public GPUSkinningWrapMode wrapMode = GPUSkinningWrapMode.Once;

    public GPUSkinningFrame[] frames = null;

    public int pixelSegmentation = 0;
}





