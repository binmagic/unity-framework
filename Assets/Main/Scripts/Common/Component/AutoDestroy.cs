using UnityEngine;

public class AutoDestroy : MonoBehaviour
{
    public float time = 1f;
    public InstanceRequest handle;
    public bool realDestroy = true;
    public bool removeSelf = false;

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
            if (handle != null)
            {
                if (realDestroy)
                {
                    handle.Destroy(false);
                }
                else
                {
                    if (removeSelf)
                    {
                        GameObject.Destroy(this);
                    }
                    handle.Destroy();
                }
                handle = null;
            }
            else
            {
                GameObject.Destroy(gameObject);
            }
        }
    }
}





