using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
public class DotweenFinish : MonoBehaviour
{
    private Vector3 localScale = Vector3.one;
    private DOTweenAnimation[] animations = null;
    private SpriteRenderer sp;
    private void Awake()
    {
        animations = GetComponents<DOTweenAnimation>();

        sp = GetComponent<SpriteRenderer>();
  
    }
    private void Start()
    {
        localScale = transform.localScale;
    }
    public void OnComplete()
    {
        for(int i=0;i<animations.Length;i++)
        {
            animations[i].DOPause();
        }
        transform.localScale = localScale;
        sp.color = new Color(1, 1, 1, 1);
        gameObject.SetActive(false);
    }
}





