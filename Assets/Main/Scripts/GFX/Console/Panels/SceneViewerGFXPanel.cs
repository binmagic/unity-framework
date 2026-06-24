using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class SceneViewerGFXPanel:BaseGFXPanel
{
    private Transform currTrm=null;
    
    private string currSceneName="";
    
    public SceneViewerGFXPanel() : base("场景查看") {}

    public override void DrawGUI()
    {
        if (currTrm == null)
        {
            DrawSceneList();
        }
        else
        {
            DrawTransformList();
        }
    }
    
    private void DrawSceneList()
    { 
        foreach (var scene in UnityEngine.SceneManagement.SceneManager.GetAllScenes())
        {
            GUILayout.Label("Scene:"+scene.name);
            foreach (var rootGO in scene.GetRootGameObjects())
            {
                if (GUILayout.Button($"{rootGO.name}"))
                {
                    currTrm = rootGO.transform;
                    currSceneName = scene.name;
                }
            }
            GUILayout.Space(20);
        }
    }

    private string tempSearchStr = "";
    private string targetSearchStr = "";
    private void DrawTransformList()
    {
        GUILayout.Label($"Scene:{currSceneName}");
        GUILayout.Label($"Path:{GetTrmPath(currTrm)}");
        
        GUILayout.Space(20);
        GUILayout.BeginHorizontal();
        GUILayout.Label("搜索:");
        tempSearchStr=GUILayout.TextField(tempSearchStr);
        if (GUILayout.Button("确定"))
        {
            targetSearchStr = tempSearchStr;
        }
        if (GUILayout.Button("清空"))
        {
            tempSearchStr = "";
            targetSearchStr = "";
        }
        GUILayout.EndHorizontal();
        GUILayout.Space(20);
        
        if (GUILayout.Button("上一级"))
        {
            if (currTrm.parent != null)
            {
                currTrm = currTrm.parent;
            }
            else
            {
                currTrm = null;
                currSceneName = "";
            }
            
            detailTrm = null;
        }

        if (currTrm != null)
        {
            if (currTrm.childCount == 0) //已经是叶子节点
            {
                GUILayout.Label(currTrm.name);
            }
            else //还有内容
            {
                foreach (Transform trm in currTrm)
                {
                    if (trm.name.Contains(targetSearchStr))
                    {
                        DrawTransform(trm);
                    }
                }
            }
        }
    }

    private Transform detailTrm;
    private void DrawTransform(Transform trm)
    {
        GUILayout.BeginHorizontal();
        if (GUILayout.Button(trm.name))
        {
            currTrm = trm;
            detailTrm = null;

            tempSearchStr = "";
            targetSearchStr = "";
        }

        if (GUILayout.Button($"显隐:{trm.gameObject.activeSelf}"))
        {
            trm.gameObject.SetActive(!trm.gameObject.activeSelf);
        }
        
        //详情
        if (trm.GetComponent<MeshRenderer>() != null )
        {
            if (GUILayout.Button("M.."))
            {
                detailTrm = trm;
            }
        }else if (trm.GetComponent<SkinnedMeshRenderer>() != null)
        {
            if (GUILayout.Button("SM.."))
            {
                detailTrm = trm;
            }
        }else
        {
            if (GUILayout.Button("..."))
            {
                detailTrm = trm;
            }
        }
        
        GUILayout.EndHorizontal();
        
        if (detailTrm == trm)
        {
            DrawDetail();
        }
    } 
    
    //打印贴图用的创建出的go,最终要销毁
    private List<GameObject> tempDebugGameObjectList = new List<GameObject>();
    private void DrawDetail()
    {
        //MeshRenderer
        Renderer mr = detailTrm.GetComponent<MeshRenderer>();
        if (mr == null)
        {
            mr = detailTrm.GetComponent<SkinnedMeshRenderer>();
        }
        if (mr != null)
        {
            foreach (var mat in mr.sharedMaterials)
            {
                GUILayout.Label(" Mat:"+mat.name);
                if (mat.shader != null)
                {
                    GUILayout.Label(" Shader:" + mat.shader.name);
                }
            }
        }
        
        //抬高
        GUILayout.BeginHorizontal();
        GUILayout.Space(20);
        if (GUILayout.Button("升高 1"))
        {
            detailTrm.Translate(Vector3.up);
        }
        if (GUILayout.Button("降低1"))
        {
            detailTrm.Translate(Vector3.down);
        }
       
        if (GUILayout.Button("旋转45"))
        {
            detailTrm.Rotate(Vector3.up,45);
        }
       
        GUILayout.EndHorizontal();
        
        GUILayout.BeginHorizontal();
        GUILayout.Space(20);
        if (GUILayout.Button("升高0.1"))
        {
            detailTrm.Translate(Vector3.up*0.1f);
        }
        if (GUILayout.Button("降低0.1"))
        {
            detailTrm.Translate(Vector3.down*0.1f);
        }
        GUILayout.EndHorizontal();
       
        GUILayout.BeginHorizontal();
        GUILayout.Space(20);
        if (GUILayout.Button("打印贴图(仅Tex2D)"))
        {
           this.DumpOneMaterialAllTextures(mr,detailTrm);
        }

        if (GUILayout.Button("清理GO"))
        {
            foreach (var tempGO in tempDebugGameObjectList)
            {
                GameObject.Destroy(tempGO);
            }
            tempDebugGameObjectList.Clear();
        }

        GUILayout.EndHorizontal();
    }
    
    //把一个mat的全体材质球都打印出来
    
    private void DumpOneMaterialAllTextures(Renderer renderer,Transform trm)
    {
        foreach (var mat in renderer.sharedMaterials)
        {
            var texList = GetAllTexturesOfMaterial(mat);
            if (texList != null)
            {
                int idx = 0;
                foreach (var tex in texList)
                {
                    var cubeGO=GameObject.CreatePrimitive(PrimitiveType.Cube);
                    cubeGO.transform.position = trm.position + Vector3.right * (1+idx)*3+Vector3.up*4;
                    cubeGO.transform.localScale=Vector3.one*2;
                    
                    cubeGO.GetComponent<MeshRenderer>().material.mainTexture = tex;
                    idx++;
                    
                    tempDebugGameObjectList.Add(cubeGO);
                }
            }
            else
            {
                Debug.Log("贴图为空");
            }
        }
    }

    private List<Texture> GetAllTexturesOfMaterial(Material mat)
    {
        var texList = new List<Texture>();
        var shader = mat.shader;
        if (shader == null)
        {
            return null;
        }

        var pNames=mat.GetTexturePropertyNames();

        foreach (var pName in pNames)
        {
            var tex=mat.GetTexture(pName);
            
            if (tex is Texture2D)
            {
                texList.Add(tex);
            }
        }
        return texList;
    }
    
    private string GetTrmPath(Transform trm)
    {
        var list = new List<string>();
        list.Append(trm.name);

        while (trm.parent != null)
        {
            trm = trm.parent;
            list.Add(trm.name);
        }

        list.Reverse();
        
        return string.Join("/",list.ToArray());
    }
}





