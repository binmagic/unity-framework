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





