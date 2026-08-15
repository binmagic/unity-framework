/**
 * [INPUT]: 依赖 UnityEngine 的 ScriptableObject 与 AnimationCurve 序列化能力
 * [OUTPUT]: 对外提供 UIButtonCurve 配置资产,承载按钮按下/其他态的缓动曲线、时长与目标缩放
 * [POS]: UIExtension 的按钮动效数据源,与消费它的按钮交互组件解耦,把动效参数外置为可配置资产
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "UIButtonCurve", menuName = "ScriptableObjects/UIButtonCurve", order = 0)]
public class UIButtonCurve : ScriptableObject
{
    [SerializeField] public AnimationCurve m_PressedCurve = null;
    
    [SerializeField]
    public float m_DoPressedTime = 0.1f;
    
    [SerializeField]
    public Vector3 m_PressedScale = new Vector3(0.7f, 0.7f, 0.7f);

    [SerializeField] public AnimationCurve m_OtherCurve = null;
    
    [SerializeField]
    public float m_DoOtherTime = 0.1f;
    
}





