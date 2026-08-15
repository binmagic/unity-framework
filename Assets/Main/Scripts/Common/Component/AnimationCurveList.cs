/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 与 AnimationCurve
 * [OUTPUT]: 对外提供 AnimationCurveList 组件，挂载后在 Inspector 暴露一条可配置动画曲线
 * [POS]: Common/Component 的曲线数据挂载点，作为纯数据容器供其他脚本 GetComponent 读取缓动曲线，自身无逻辑
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationCurveList : MonoBehaviour
{
    public AnimationCurve animationCurve1;
}





