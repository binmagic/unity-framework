/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 承载 Inspector 数据
 * [OUTPUT]: 对外提供 UIExtraData 组件(在 UI 节点上附加声音 ID 与两个扩展整型)
 * [POS]: UI 层的节点附加数据载体,当前主要供点击音效查表使用,是挂在 UI 元件上的纯数据标记
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// UI上附加的扩展数据，目前只有声音处理

public class UIExtraData : MonoBehaviour
{
    public int soundId;
    public int extra1;
    public int extra2;
}





