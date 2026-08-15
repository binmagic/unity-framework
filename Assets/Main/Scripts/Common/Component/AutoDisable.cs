/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 与 Time.deltaTime 计时
 * [OUTPUT]: 对外提供 AutoDisable 组件，每次启用后按 time 到期自动 SetActive(false)
 * [POS]: Common/Component 的自动禁用组件，是 AutoDestroy 的轻量兄弟——只隐藏不销毁，适合复用型 GameObject
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

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





