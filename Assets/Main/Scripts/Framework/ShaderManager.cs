using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using GameFramework;
using UnityEngine;
using VEngine;

/// <summary>
/// 这个是shader的管理器,目的是为了将shader打bundle
/// 因为目前shader其实是随意存放的,暂时先设置两个bundle存放,后续再指定规则,
/// </summary>
public class ShaderManager
{
    //shadername和shader的映射
    public Dictionary<string, Shader> m_kvNameToShader = new Dictionary<string, Shader>(128);
    //默认
    private Shader m_defaultShader;
    private int m_loadCnt = 0;
    private string[] SHADER_BUNDLE = new[]
    {
        "shader_all",
    };

    private List<Asset> m_bundleList = new List<Asset>(2);

    public bool IsInitDone()
    {
#if UNITY_EDITOR
        return true;
#endif
        return m_loadCnt >= SHADER_BUNDLE.Length;
    }

    public Shader Find(string shaderName)
    {
#if UNITY_EDITOR
        return Shader.Find(shaderName);
#endif
        if (ApplicationLaunch.Instance.m_kvNameToShader.TryGetValue(shaderName, out Shader shader))
        {
            return shader;
        }

        return shader;
    }

    public void DumpCurBundle()
    {
        Debug.Log("****在shaderManager前加载的bundle");
        VEngine.Bundle.DebugOutputCache();
    }

    public void Initialize(Action callback)
    {
#if UNITY_EDITOR
        return;
#endif
        Shutdown();
        m_loadCnt = 0;
        m_defaultShader = Shader.Find("Survival/Standard");
        for (int index = 0; index < SHADER_BUNDLE.Length; ++index)
        {
            string shader_bundle = "";
            VEngine.Versions.VisitBundles(delegate(string s)
            {
                if (s.Contains(SHADER_BUNDLE[index]))
                {
                    shader_bundle = s;
                    return false;
                }
                return true;
            });
            DumpCurBundle();
            var req = GameEntry.Resource.LoadAllAssetsAsync(shader_bundle, asset =>
            {
                AllBundledAsset allBundledAsset = asset as AllBundledAsset;
                if (allBundledAsset == null)
                {
                    Debug.LogError("AllBundledAsset is null!");
                    return;
                }

                var allAssets = allBundledAsset.assets;
                ShaderVariantCollection svc=null;
                if (allAssets != null)
                {
                    for (int i = 0; i < allAssets.Length; ++i)
                    {
                        try
                        {
                            var _asset = allAssets[i];
                            if (_asset is ShaderVariantCollection)
                            {
                                svc = (ShaderVariantCollection) _asset;
                                // (_asset as ShaderVariantCollection).WarmUp();
                            }
                            else if (_asset is Shader)
                            {
                                var _shaderAsset = _asset as Shader;
                                ApplicationLaunch.Instance.m_kvNameToShader[_shaderAsset.name] = _shaderAsset;
                            }
                        }
                        catch (Exception e)
                        {
                            Debug.LogErrorFormat("allAssets process exception! {0}", e.Message);
                        }
                    }
                }
                else
                {
                    Debug.LogError("allAssets is null!");
                }

                if(svc!=null&&!svc.isWarmedUp)
                {
                    svc.WarmUp();
                }
                // asset.Release();
                m_loadCnt++;
                
#if !FINAL_RELEASE
                Dump();
#endif
            });
            m_bundleList.Add(req);
        }
    }

    public void Shutdown()
    {
        ApplicationLaunch.Instance.m_kvNameToShader.Clear();
        for (int i = 0; i < m_bundleList.Count; ++i)
        {
            m_bundleList[i].Release();
        }
        m_bundleList.Clear();
        m_loadCnt = 0;

        Log.Info("ShaderManager - Shutdown!");
    }
    
    public void Dump()
    {
        Log.Info("ShaderManager - dump all shaders!");
        foreach (var entry in ApplicationLaunch.Instance.m_kvNameToShader)
        {
            Log.Info("  {0}", entry.Key);
        }
    }
}





