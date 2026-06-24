using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ScrollLoopText : MonoBehaviour
{
    public Text txt;
    public List<Text> scrollTxt;
    public float offset = 40;
    public float speed = -30;

    public RectTransform scrollEndPos;
    private Vector2 endPos;

    public void CheckCanRun()
    {
        RectTransform rect = txt.GetComponent<RectTransform>();
        RectTransform rect1 = txt.transform.parent.GetComponent<RectTransform>();
        //Debug.LogErrorFormat("rect.sizeDelta.x={0},rect.sizeDelta.x={1},rect1.x={2}", txt.preferredWidth, rect.sizeDelta.x, rect1.sizeDelta.x);
        txt.gameObject.SetActive(true);
        if (txt.preferredWidth >= rect1.sizeDelta.x - 2)
        {
            gameObject.SetActive(true);
            txt.gameObject.SetActive(false);
            scrollTxt[0].text = txt.text;
            scrollTxt[0].color = txt.color;
            scrollTxt[1].text = txt.text;
            scrollTxt[1].color = txt.color;
            scrollTxt[2].text = txt.text;
            scrollTxt[2].color = txt.color;

            scrollTxt[0].rectTransform.anchoredPosition = txt.rectTransform.anchoredPosition;
            float x = rect.anchoredPosition.x + txt.preferredWidth + offset;

            Vector2 scrollEndPosX = rect.anchoredPosition;
            scrollEndPosX.x -= txt.preferredWidth + offset;// + offset;
            scrollEndPos.anchoredPosition = scrollEndPosX;


            Text txt1 = scrollTxt[1];
            Vector2 v2 = rect.anchoredPosition;
            v2.x = x;
            txt1.rectTransform.anchoredPosition = v2;

            txt1 = scrollTxt[2];
            v2 = rect.anchoredPosition;
            x += txt.preferredWidth + offset;
            v2.x = x;
            endPos = txt1.rectTransform.anchoredPosition = v2;
        }
        else
        {
            gameObject.SetActive(false);
        }
    }

    private void Update()
    {
        foreach (var item in scrollTxt)
        {
            Vector2 v2 = item.rectTransform.anchoredPosition;
            v2.x += Time.deltaTime * speed;
            item.rectTransform.anchoredPosition = v2;
            if (v2.x <= scrollEndPos.anchoredPosition.x)
            {
                item.rectTransform.anchoredPosition = endPos;
            }
        }
    }
}





