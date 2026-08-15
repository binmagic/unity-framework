/**
 * [INPUT]: 依赖 UnityEngine 的 ScriptableObject 作资产载体，编辑器下依赖 UnityEditor.EditorUtility.SetDirty 落盘
 * [OUTPUT]: 对外提供 WorldTerrainUVScaleScriptableObject 资产，持有地形 UV 数组、低配 UV 缩放与光照方向数据
 * [POS]: GEgineRunTime 命名空间下 Common/Component 的地形 UV 配置资产，为世界地形着色提供可序列化的 UV/光照参数，编辑器侧 Save 写脏，运行时只读消费
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

namespace GEgineRunTime
{
	public class WorldTerrainUVScaleScriptableObject : ScriptableObject
	{
		public float[] uvs = new float[16];
		public float lowUVScale = 100;
		public Vector4 LightDir = Vector4.one;
#if UNITY_EDITOR
		public void Save()
		{
			EditorUtility.SetDirty(this);
		}
#endif
	}
}





