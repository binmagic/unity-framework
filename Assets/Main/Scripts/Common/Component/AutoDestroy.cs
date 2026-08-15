/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour/Time；依赖资源系统的 InstanceRequest 句柄以归还对象池实例
 * [OUTPUT]: 对外提供 AutoDestroy 组件，按 time 到期后销毁自身或经 handle 归还实例
 * [POS]: Common/Component 的自动回收组件，是 AutoDisable 的销毁版兄弟——AutoDisable 仅禁用，本组件真销毁并对接对象池回收
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

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





