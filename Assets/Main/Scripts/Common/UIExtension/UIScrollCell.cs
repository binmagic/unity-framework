using UnityEngine;
using UnityEngine.UI;

public class UIScrollCell : MonoBehaviour
{
    public Text indexTxt;

    public void RefreshItem()
    {
        if (indexTxt)
        {
            int idx = 0;
            int.TryParse(name, out idx);
            indexTxt.text = idx.ToString();
        }
    }
}





