/**
 * [INPUT]: 依赖 TMPro 的 TextMeshProUGUI 文本渲染，依赖 GameEntry.Localization 取提示词，依赖 Unity 协程与 Mathf.Lerp
 * [OUTPUT]: 对外提供 NumberRoller 组件及 StartRoll 接口，驱动数字从 0 滚动到目标值
 * [POS]: UIExtension 的数值动画节点，用协程做定时插值的一次性数字增长动效，OnDisable 时中止协程防泄漏
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using TMPro;
using UnityEngine;

public class NumberRoller : MonoBehaviour
{
    public TextMeshProUGUI numberText;
    //public NewTMPText numberText;
    public int targetNumber = 100;
    public float duration = 2f;

    static string TipsPreWord;

    private Coroutine countingCoroutine;

    public void StartRoll(int new_targetNumber,float new_duration)
    {
        TipsPreWord = GameEntry.Localization.GetString(799118);
        targetNumber = new_targetNumber;
        duration = new_duration;
        countingCoroutine = StartCoroutine(CountToNumber(targetNumber, duration));
    }

    private void OnDisable()
    {
        if(countingCoroutine != null)
        {
            // �ڽ���ʱֹͣЭ��
            StopCoroutine(countingCoroutine);
        }
    }

    IEnumerator CountToNumber(int target, float duration)
    {
        float elapsedTime = 0;
        int currentNumber = 0;

        while (elapsedTime < duration)
        {
            currentNumber = (int)Mathf.Lerp(0, target, (elapsedTime / duration));
            if (currentNumber >= 0)
            {
                numberText.text = "+ " + currentNumber.ToString();
            }
            else
            {
                numberText.text = currentNumber.ToString();
            }

            //numberText.text = "+ " + currentNumber.ToString();  //string.Format(TipsPreWord, currentNumber);
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // Ensure the final number is exactly the target
        if (target >= 0)
        {
            numberText.text = "+ " + target.ToString();
        }
        else
        {
            numberText.text = target.ToString();
        }
        //numberText.text = "+ "+target.ToString(); //string.Format(TipsPreWord, target);
    }
}





