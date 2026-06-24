using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;
public class GaussianBlur : MonoBehaviour
{
    private Texture myTexture;
    public Material mat;
    private RenderTexture buffer0, buffer1, buffer2;
    private RawImage rawImage;
    public float blurRaius = 1;
    public int blurTimes = 1;
    public int downloadTimes = 6;
    private int width, heigh;
    private bool capter = false;
    private void Start()
    {
        rawImage = GetComponent<RawImage>();

    }
    public void Blur()
    {
        if (rawImage == null)
        {
            rawImage = GetComponent<RawImage>();
        }
        if (rawImage == null)
        {
            return;
        }
        myTexture = rawImage.texture;
        if (myTexture == null)
        {
            Debug.LogError("û���ҵ����");
            return;
        }
        width = myTexture.width / downloadTimes;
        heigh = myTexture.height / downloadTimes;
        buffer0 = new RenderTexture(width, heigh, 0, RenderTextureFormat.ARGB32);
        Graphics.Blit(myTexture, buffer0);
        for (int i = 0; i < blurTimes; i++)
        {
            mat.SetFloat("_BlurSize", 1 + i * blurRaius);
            buffer1 = new RenderTexture(width, heigh, 0, RenderTextureFormat.ARGB32);
            Graphics.Blit(buffer0, buffer1, mat,0);
            ReleaseRT(buffer0);
            buffer0 = buffer1;
            buffer1 = new RenderTexture(width, heigh, 0, RenderTextureFormat.ARGB32);
            Graphics.Blit(buffer0, buffer1, mat, 1);
            ReleaseRT(buffer0);
            buffer0 = buffer1;
        }

        rawImage.texture = buffer0;
      
       // RenderTexture.ReleaseTemporary(buffer1);
    }
    private void ReleaseRT(RenderTexture rt)
    {
        if (rt != null)
        {
            rt.Release();
            rt = null;

        }
    }



    private void OnDisable()
    {
        ReleaseRT(buffer0);
        ReleaseRT(buffer1);
    }

}





