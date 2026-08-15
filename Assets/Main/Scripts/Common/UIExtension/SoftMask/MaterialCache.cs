/**
 * [INPUT]: 依赖 UnityEngine 的 Material/Hash128 与运行期/编辑期销毁能力
 * [OUTPUT]: 对外提供 MaterialCache 静态缓存（Register/Unregister）与内部 MaterialEntry 计数条目
 * [POS]: SoftMask 的材质共享层，按 Hash128 对遮罩材质做引用计数复用与释放，避免重复实例化 Material，被 SoftMaskable 消费
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections.Generic;
using System;
using UnityEngine;

namespace UnityEngine.UI
{
    internal class MaterialEntry
    {
        public Material material;
        public int referenceCount;

        public void Release()
        {
            if (material)
            {
#if UNITY_EDITOR
                if (!Application.isPlaying)
                    UnityEngine.Object.DestroyImmediate(material, false);
                else
#endif
                    UnityEngine.Object.Destroy(material);
            }

            material = null;
        }
    }

    internal static class MaterialCache
    {
        static readonly Dictionary<Hash128, MaterialEntry> s_MaterialMap = new Dictionary<Hash128, MaterialEntry>();

#if UNITY_EDITOR
        [UnityEditor.InitializeOnLoadMethod]
        private static void ClearCache()
        {
            foreach (var entry in s_MaterialMap.Values)
            {
                entry.Release();
            }

            s_MaterialMap.Clear();
        }
#endif

        public static Material Register(Material material, Hash128 hash, Action<Material> onModify)
        {
            if (!hash.isValid) return null;

            MaterialEntry entry;
            if (!s_MaterialMap.TryGetValue(hash, out entry))
            {
                entry = new MaterialEntry()
                {
                    material = new Material(material)
                    {
                        hideFlags = HideFlags.HideAndDontSave,
                    },
                };

                onModify(entry.material);
                s_MaterialMap.Add(hash, entry);
            }

            entry.referenceCount++;
            //Debug.LogFormat("Register: {0}, {1} (Total: {2})", hash, entry.referenceCount, materialMap.Count);
            return entry.material;
        }

        public static void Unregister(Hash128 hash)
        {
            MaterialEntry entry;
            if (!hash.isValid || !s_MaterialMap.TryGetValue(hash, out entry)) return;
            //Debug.LogFormat("Unregister: {0}, {1}", hash, entry.referenceCount -1);

            if (--entry.referenceCount > 0) return;

            entry.Release();
            s_MaterialMap.Remove(hash);
            //Debug.LogFormat("Unregister: Release Emtry: {0}, {1} (Total: {2})", hash, entry.referenceCount, materialMap.Count);
        }
    }
}





