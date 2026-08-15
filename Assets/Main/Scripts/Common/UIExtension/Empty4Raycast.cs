/**
 * [INPUT]: 依赖 UnityEngine.UI 的 MaskableGraphic 与 VertexHelper
 * [OUTPUT]: 对外提供 Empty4Raycast 组件，一个不产生任何顶点、只保留射线响应能力的空图形
 * [POS]: UIExtension 的零绘制点击区域组件，用作透明可点击热区，替代挂 Image 撑起 Raycast 带来的额外 DrawCall
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;
using System.Collections;

namespace UnityEngine.UI
{
    [RequireComponent(typeof(CanvasRenderer))]
	public class Empty4Raycast : MaskableGraphic
	{
		protected Empty4Raycast()
		{
			useLegacyMeshGeneration = false;
		}

		protected override void OnPopulateMesh(VertexHelper vh)
		{
			vh.Clear();
		}
	}
}





