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





