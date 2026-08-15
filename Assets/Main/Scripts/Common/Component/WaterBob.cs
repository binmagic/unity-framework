/**
 * [INPUT]: 依赖 UnityEngine 的 Transform/Time/Mathf/Random
 * [OUTPUT]: 对外提供 WaterBob 组件，暴露 height/period 控制上下浮动幅度与周期
 * [POS]: Common/Component 的漂浮动画体，在 FixedUpdate 中以正弦函数让对象绕初始位置上下起伏，用随机相位偏移错开多个实例的节奏
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;

public class WaterBob : MonoBehaviour
{
    [SerializeField]
    float height = 0.1f;

    [SerializeField]
    float period = 1;

    private Vector3 initialPosition;
    private float offset;
    private Transform tran;

    private void Awake()
    {
        tran = transform;
        initialPosition = transform.position;

        offset = 1 - (Random.value * 2);
    }

    private void FixedUpdate()
    {
        tran.position = initialPosition - Vector3.up * Mathf.Sin((Time.time + offset) * period) * height;
    }
}





