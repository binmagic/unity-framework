/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 与 Transform.Rotate
 * [OUTPUT]: 对外提供 ObjectRandRotation 组件，按 Inspector 配置的三轴权重与 speed 逐帧世界空间旋转自身
 * [POS]: Common/Component 的持续自旋组件，最轻量的展示型行为，常用于道具/图标的循环旋转
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectRandRotation : MonoBehaviour
{
    public float axisX = 1;
    public float axisY = 1;  
    public float axisZ = 1;   
    public float speed = 1;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.Rotate(new Vector3(axisY, axisX, axisZ) * speed, Space.World);

    }
}





