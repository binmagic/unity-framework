using UnityEngine;

public class AutoDisable : MonoBehaviour
{
    public float time = 1f;

    private float _timer = 0f;

    void OnEnable()
    {
        _timer = 0f;
    }
    
    void Update()
    {
        _timer += Time.deltaTime;
        if (_timer >= time)
        {
            gameObject.SetActive(false);
        }
    }
}





