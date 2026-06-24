using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class FadeOut : MonoBehaviour
{
    [SerializeField]
    public float delayTime=0.5f;
    [SerializeField]
    public float duringTime=0.5f;
    private MeshRenderer meshRender;
    private void Awake()
    {
        meshRender = GetComponentInChildren<MeshRenderer>();
    }
    private void OnDisable()
    {
        if(IsInvoking("DoFadeOut"))
        {
            CancelInvoke("DoFadeOut");
        }
        meshRender.material.DOKill();
        meshRender.material.DOFade(1, 0);
    }
    private void OnEnable()
    {
        Invoke("DoFadeOut", delayTime);
    }
    void DoFadeOut()
    {
        meshRender.material.DOFade(0, duringTime);
    }

}





