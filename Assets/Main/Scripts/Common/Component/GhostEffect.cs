using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GhostEffect : MonoBehaviour
{
    private static readonly int m_IdFresnelStrength = Shader.PropertyToID("_FresnelStrength");
    private static readonly int m_IdFresnelColorStrength = Shader.PropertyToID("_FresnelColorStrength");
    private static readonly int m_IdMainTexStrength = Shader.PropertyToID("_MainTexStrength");
    private static readonly int m_IdMainTex = Shader.PropertyToID("_MainTex");
    private static readonly int m_IdAlpha = Shader.PropertyToID("_Alpha");
    private static readonly int m_IdColor = Shader.PropertyToID("_Color");
    private static int m_DefaultLayer = -1;
    private static MaterialPropertyBlock m_MaterialPropertyBlock = null;

    public void Ghost()
    {
        CreateGhostEffectObject(Color.yellow, 1.2f, 0.5f,1f, 1.5f);

    }

    private struct MeshInfo
    {
        public Mesh mesh;
        public Matrix4x4 matrix;
        public bool isSharedMesh;
        public Material material;
    };

    private class GhostObject
    {
        public List<MeshInfo> meshInfoList = new List<MeshInfo>();
        public Color color;
        public float fresnelStrength;
        public float mainTexStrength;
        public float totalTime;
        public float remainingTime;
        public float originFresnelColorStrength;
        public float originAlpha;
        public float originMainTexStrength;

        public bool Update(Material material)
        {
            if (material == null)
            {
                return false;
            }
            remainingTime -= Time.deltaTime;
            float fresnelColorStrength = Mathf.Lerp(0, originFresnelColorStrength, remainingTime / totalTime);
            float alpha = Mathf.Lerp(0, originAlpha, remainingTime / totalTime);
            float mainTexStrength = Mathf.Lerp(0, originMainTexStrength, remainingTime / totalTime);

            m_MaterialPropertyBlock.Clear();
            m_MaterialPropertyBlock.SetFloat(m_IdFresnelStrength, fresnelStrength);
            m_MaterialPropertyBlock.SetFloat(m_IdFresnelColorStrength, fresnelColorStrength);
            m_MaterialPropertyBlock.SetFloat(m_IdAlpha, alpha);
            m_MaterialPropertyBlock.SetColor(m_IdColor, color);
            if(mainTexStrength > 0)
            {
                m_MaterialPropertyBlock.SetFloat(m_IdMainTexStrength, mainTexStrength);
            }

            for (int i = 0; i < meshInfoList.Count; ++i)
            {
                MeshInfo info = meshInfoList[i];
                if(mainTexStrength > 0 && info.material != null)
                {
                    Texture mainTex = info.material.GetTexture(m_IdMainTex);
                    if(mainTex != null)
                    {
                        m_MaterialPropertyBlock.SetTexture(m_IdMainTex, mainTex);
                    }
                }
                Graphics.DrawMesh(info.mesh, info.matrix, material, m_DefaultLayer, null, 0, m_MaterialPropertyBlock, false, false, false);
            }

            if (remainingTime <= 0)
            {
                return true;
            }

            return false;
        }
    };

    private List<GhostObject> m_GhostShadowList = new List<GhostObject>();

    private List<SkinnedMeshRenderer> m_SkinnedMeshRendererList = null;
    private List<SkinnedMeshRenderer> cachedSkinnedMeshRenderer
    {
        get
        {
            if(m_SkinnedMeshRendererList == null)
            {
                m_SkinnedMeshRendererList = new List<SkinnedMeshRenderer>();
                gameObject.GetComponentsInChildren(m_SkinnedMeshRendererList);
            }
            return m_SkinnedMeshRendererList;
        }
    }
    private List<MeshFilter> m_MeshFilterList = null;
    private List<MeshFilter> cachedMeshFilterList
    {
        get
        {
            if(m_MeshFilterList == null)
            {
                m_MeshFilterList = new List<MeshFilter>();
                gameObject.GetComponentsInChildren(m_MeshFilterList);
            }
            return m_MeshFilterList;
        }
    }

    private Material m_GhostMaterial = null;
    private Material ghostMaterial
    {
        get
        {
            if (m_GhostMaterial == null)
            {
                var shader = GameEntry.Shader.Find("Survival/Character_Ghost");
                if (shader == null)
                {
                    return null;
                }
                m_GhostMaterial = new Material(shader);
            }
            return m_GhostMaterial;
        }
    }

    #region UnityMethods
    private void OnEnable()
    {
        if (m_DefaultLayer == -1)
        {
            m_DefaultLayer = LayerMask.NameToLayer("Default");
        }
        if (m_MaterialPropertyBlock == null)
        {
            m_MaterialPropertyBlock = new MaterialPropertyBlock();
        }

        if(ghostMaterial == null)
        {
#if UNITY_EDITOR
            Debug.Log(string.Format("[GhostEffect](OnEnable) ghostMaterial is null:[{0}]", gameObject.name));
#endif
            this.enabled = false;
            return;
        }

    }

    private void OnDisable()
    {
        CleanUp();
    }

    private void Update()
    {
        for (int i = 0; i < m_GhostShadowList.Count;)
        {
            GhostObject obj = m_GhostShadowList[i];

            if (obj.Update(ghostMaterial))
            {
                m_GhostShadowList.RemoveAt(i);
                DestroyGhostShadowObj(obj);
            }
            else
            {
                ++i;
            }
        }
    }
    #endregion

    #region LocalMethods
    private void CleanUp()
    {
        for (int i = 0; i < m_GhostShadowList.Count; ++i)
        {
            DestroyGhostShadowObj(m_GhostShadowList[i]);
        }
        cachedSkinnedMeshRenderer.Clear();
        cachedMeshFilterList.Clear();
        m_GhostShadowList.Clear();
    }

    private void DestroyGhostShadowObj(GhostObject obj)
    {
        List<MeshInfo> meshInfoList = obj.meshInfoList;
        for (int i = 0; i < meshInfoList.Count; ++i)
        {
            if (!meshInfoList[i].isSharedMesh)
            {
                Destroy(meshInfoList[i].mesh);
            }
        }
    }
    #endregion

    #region API
    // Summary:
    //     ///
    //     Create a ghost images of the previous locations of the object.
    //     ///
    //
    // params:
    //   color:
    //     Ghost color.
    //
    //   fresnelStrength:
    //     Strength of fresnel.
    //
    //   fresnelColorStrength:
    //     Strength of color
    //     
    //   alpha:
    //     Ghost alpha.
    //
    //   fadeoutTime:
    //     Fadeout time of the ghost effect object
    //     
    //   mainTexStrength:
    //     Strength of the MainTexture, 0 to 1.
    public void CreateGhostEffectObject(Color color, float fresnelStrength, float fresnelColorStrength, float alpha, float fadeoutTime, float mainTexStrength = 0f)
    {
        GhostObject obj = new GhostObject();

        bool combineMesh = mainTexStrength <= 0;
        if (combineMesh)
        {
            List<CombineInstance> combines = new List<CombineInstance>();

            for (int i = 0; i < cachedSkinnedMeshRenderer.Count; i++)
            {
                SkinnedMeshRenderer renderer = cachedSkinnedMeshRenderer[i];
                if (renderer.sharedMesh == null)
                {
                    Debug.LogErrorFormat("[GhostEffect]CreateGhostShadowObj mesh null!");
                    continue;
                }
                Mesh mesh = new Mesh();
                renderer.BakeMesh(mesh);
                combines.Add(new CombineInstance()
                {
                    mesh = mesh,
                    transform = Matrix4x4.TRS(renderer.transform.position, renderer.transform.rotation, Vector3.one),
                    subMeshIndex = 0
                });
            }

            MeshInfo info = new MeshInfo();
            info.mesh = new Mesh();
            info.mesh.name = "Ghost";
            info.mesh.CombineMeshes(combines.ToArray(), true);
            info.matrix = Matrix4x4.identity;
            obj.meshInfoList.Add(info);

            for (int i = 0; i < combines.Count; ++i)
            {
                Destroy(combines[i].mesh);
            }
        }
        else
        {
            foreach (var mr in cachedSkinnedMeshRenderer)
            {
                MeshInfo info = new MeshInfo();
                info.mesh = new Mesh();
                mr.BakeMesh(info.mesh);
                info.matrix = Matrix4x4.TRS(mr.transform.position, mr.transform.rotation, Vector3.one);
                info.material = mr.sharedMaterial;
                obj.meshInfoList.Add(info);
            }
        }

        foreach (var mf in cachedMeshFilterList)
        {
            if (mf.sharedMesh == null)
            {
                continue;
            }
            MeshInfo info = new MeshInfo();
            info.mesh = mf.sharedMesh;
            info.isSharedMesh = true;
            info.matrix = mf.transform.localToWorldMatrix;
            obj.meshInfoList.Add(info);
        }

        obj.remainingTime = fadeoutTime;

        obj.totalTime = fadeoutTime;
        obj.color = color;
        obj.fresnelStrength = fresnelStrength;
        obj.originFresnelColorStrength = fresnelColorStrength;
        obj.originAlpha = alpha;
        obj.originMainTexStrength = mainTexStrength;
        m_GhostShadowList.Add(obj);
    }
    #endregion
}





