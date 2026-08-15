/**
 * [INPUT]: 依赖 UnityEngine 的 MonoBehaviour 承载 Inspector 配置
 * [OUTPUT]: 对外提供 ForceArabicBiHorizontalLayout 标记组件(IsReverseHorizontalLayout 意图开关)
 * [POS]: Arabic 模块的布局方向覆盖标记,ArabicMirror 处理 BidirectionalHorizontalLayoutGroup 时读取它,以强制指定该容器是否随 RTL 反向
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine;
public class ForceArabicBiHorizontalLayout : MonoBehaviour
{
    public bool IsReverseHorizontalLayout = false;
}





