/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour/MeshRenderer，依赖 DG.Tweening 的材质 DOFade 缓动
 * [OUTPUT]: 对外提供 FadeOut 组件，启用后延迟 delayTime 再在 duringTime 内将材质淡出，禁用时打断并复位透明度
 * [POS]: Common/Component 的网格淡出组件，与 DotweenFinish 同属 DOTween 系视觉组件，本组件面向 MeshRenderer 材质透明度
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

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





