using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

[CustomEditor(typeof(GPUSkinningSampler))]
public class GPUSkinningSamplerEditor : Editor 
{
	private GPUSkinningAnimation anim = null;
    private bool guiEnabled = false;

    public override void OnInspectorGUI ()
	{
		GPUSkinningSampler sampler = target as GPUSkinningSampler;
		if(sampler == null)
		{
			return;
		}
        
        OnGUI_Sampler(sampler);
	}

    private void OnGUI_Sampler(GPUSkinningSampler sampler)
    {
        guiEnabled = !Application.isPlaying;

        BeginBox();
        {
            GUI.enabled = guiEnabled;
            {
                GUI.enabled = guiEnabled;
                EditorGUILayout.PropertyField(serializedObject.FindProperty("animName"), new GUIContent("Animation Name"));
                EditorGUILayout.PropertyField(serializedObject.FindProperty("rootBoneTransform"), new GUIContent("Root Bone"));
                
                GUI.enabled = false;
                EditorGUILayout.Space();
                EditorGUILayout.BeginHorizontal();
                {
                    EditorGUILayout.PropertyField(serializedObject.FindProperty("anim"), new GUIContent("GPUSkinningAnimation"));
                }
                EditorGUILayout.EndHorizontal();
                
                OnGUI_AnimClips(sampler);
            }
            GUI.enabled = true;

            if (GUILayout.Button("Step1: Play Scene"))
            {
                EditorApplication.isPlaying = true;
            }

            if (Application.isPlaying)
            {
                if (GUILayout.Button("Step2: Start Sample"))
                {
                    LockInspector(true);
                    sampler.BeginSample();
                    sampler.StartSample();
                }
            }
        }
        EndBox();
        serializedObject.ApplyModifiedProperties();
    }

    private SerializedProperty animClips_array_size_sp = null;
    //private SerializedProperty wrapModes_array_size_sp = null;
    private SerializedProperty fpsList_array_size_sp = null;
    private SerializedProperty nameList_array_size_sp = null;
    private List<SerializedProperty> animClips_item_sp = null;
    //private List<SerializedProperty> wrapModes_item_sp = null;
    private List<SerializedProperty> fpsList_item_sp = null;
    private List<SerializedProperty> nameList_item_sp = null;
    
    private int animClips_count = 0;
    private void OnGUI_AnimClips(GPUSkinningSampler sampler)
    {
        System.Action ResetItemSp = () =>
        {
            animClips_item_sp.Clear();
            //wrapModes_item_sp.Clear();
            fpsList_item_sp.Clear();
            nameList_item_sp.Clear();

            //wrapModes_array_size_sp.intValue = animClips_array_size_sp.intValue;
            fpsList_array_size_sp.intValue = animClips_array_size_sp.intValue;
            nameList_array_size_sp.intValue = animClips_array_size_sp.intValue;

            for (int i = 0; i < animClips_array_size_sp.intValue; i++)
            {
                animClips_item_sp.Add(serializedObject.FindProperty(string.Format("animClips.Array.data[{0}]", i)));
                //wrapModes_item_sp.Add(serializedObject.FindProperty(string.Format("wrapModes.Array.data[{0}]", i)));
                fpsList_item_sp.Add(serializedObject.FindProperty(string.Format("fpsList.Array.data[{0}]", i)));
                nameList_item_sp.Add(serializedObject.FindProperty(string.Format("nameList.Array.data[{0}]", i)));
            }

            animClips_count = animClips_item_sp.Count;
        };

        if (animClips_array_size_sp == null) animClips_array_size_sp = serializedObject.FindProperty("animClips.Array.size");
        //if (wrapModes_array_size_sp == null) wrapModes_array_size_sp = serializedObject.FindProperty("wrapModes.Array.size");
        if (fpsList_array_size_sp == null) fpsList_array_size_sp = serializedObject.FindProperty("fpsList.Array.size");
        if (nameList_array_size_sp == null) nameList_array_size_sp = serializedObject.FindProperty("nameList.Array.size");
        if(animClips_item_sp == null)
        {
            animClips_item_sp = new List<SerializedProperty>();
            //wrapModes_item_sp = new List<SerializedProperty>();
            fpsList_item_sp = new List<SerializedProperty>();
            nameList_item_sp = new List<SerializedProperty>();
            ResetItemSp();
        }

        BeginBox();
        {
            EditorGUILayout.PrefixLabel("Sample Clips");

            GUI.enabled = guiEnabled;
            int no = nameList_array_size_sp.intValue;
            int no1 = animClips_array_size_sp.intValue;
            //int no2 = wrapModes_array_size_sp.intValue;
            int no3 = fpsList_array_size_sp.intValue;

            EditorGUILayout.BeginHorizontal();
            {
                animClips_count = EditorGUILayout.IntField("Size", animClips_count);
                if (GUILayout.Button("Apply", GUILayout.Width(60)))
                {
                    if (animClips_count != no)
                    {
                        nameList_array_size_sp.intValue = animClips_count;
                    }
                    if (animClips_count != no1)
                    {
                        animClips_array_size_sp.intValue = animClips_count;
                    }
                    /*if (animClips_count != no2)
                    {
                        wrapModes_array_size_sp.intValue = animClips_count;
                    }*/
                    if (animClips_count != no3)
                    {
                        fpsList_array_size_sp.intValue = animClips_count;
                        ResetItemSp();
                    }
                    return;
                }
                if(GUILayout.Button("Reset", GUILayout.Width(60)))
                {
                    ResetItemSp();
                    GUI.FocusControl(string.Empty);
                    return;
                }
            }
            EditorGUILayout.EndHorizontal();
            GUI.enabled = true && guiEnabled;

            EditorGUILayout.BeginHorizontal();
            {
                for (int j = -1; j < 3; ++j)
                {
                    EditorGUILayout.BeginVertical();
                    {
                        EditorGUILayout.BeginHorizontal();
                        {
                            if(j == -1)
                            {
                                GUILayout.Label("   ");
                            }
                            if(j == 0)
                            {
                                GUILayout.Label("Name");
                            }
                            if(j == 1)
                            {
                                GUILayout.Label("Anim Clip");
                            }
                            /*if(j == 2)
                            {
                                GUILayout.Label("Wrap Mode");
                            }*/
                            if(j == 2)
                            {
                                GUILayout.Label("FPS");
                            }
                        }
                        EditorGUILayout.EndHorizontal();
                        for (int i = 0; i < no; i++)
                        {
                            var prop = nameList_item_sp[i];
                            var prop1 = animClips_item_sp[i];
                            //var prop2 = wrapModes_item_sp[i];
                            var prop2 = fpsList_item_sp[i];
                            if (prop != null)
                            {
                                GUI.enabled = guiEnabled;
                                if(j == -1)
                                {
                                    GUILayout.Label((i + 1) + ":    ");
                                }
                                if(j == 0)
                                {
                                    EditorGUILayout.PropertyField(prop, new GUIContent());
                                }
                                if(j == 1)
                                {
                                    EditorGUILayout.PropertyField(prop1, new GUIContent());
                                }
                                /*if (j == 2)
                                {
                                    EditorGUILayout.PropertyField(prop2, new GUIContent());
                                }*/
                                if(j == 2)
                                {
                                    EditorGUILayout.PropertyField(prop2, new GUIContent());
                                    prop2.intValue = Mathf.Clamp(prop2.intValue, 0, 60);
                                }
                                GUI.enabled = guiEnabled;
                            }
                        }
                    }
                    EditorGUILayout.EndVertical();
                }
            }
            EditorGUILayout.EndHorizontal();
        }
        EndBox();
    }

    private void ApplySamplerModification(GPUSkinningSampler sampler)
    {
        if(sampler != null)
        {
            EditorUtility.SetDirty(sampler);
            EditorUtility.SetDirty(sampler.gameObject);
            EditorSceneManager.SaveOpenScenes();
        }
    }

    private void UpdateHandler()
    {
        GPUSkinningSampler sampler = target as GPUSkinningSampler;

        if (EditorApplication.isCompiling)
        {
            if (Selection.activeGameObject == sampler.gameObject)
            {
                Selection.activeGameObject = null;
                return; 
            }
        }

        if(!sampler.isSampling && sampler.IsSamplingProgress())
        {
            if (++sampler.samplingClipIndex < sampler.animClips.Length)
            {
                sampler.StartSample();
            }
            else
            {
                sampler.EndSample();
                EditorApplication.isPlaying = false;
                EditorUtility.ClearProgressBar();
                LockInspector(false);
            }
        }
        
        if (sampler.isSampling)
        {
            string msg = sampler.animClip.name + "(" + (sampler.samplingClipIndex + 1) + "/" + sampler.animClips.Length +")";
            EditorUtility.DisplayProgressBar("Sampling, DONOT stop playing", msg, (float)(sampler.samplingFrameIndex + 1) / sampler.samplingTotalFrams);
        }
    }

    private void LockInspector(bool isLocked)
    {
        System.Type type = Assembly.GetAssembly(typeof(Editor)).GetType("UnityEditor.InspectorWindow");
        FieldInfo field = type.GetField("m_AllInspectors", BindingFlags.Static | BindingFlags.NonPublic);
        System.Collections.ArrayList windows = new System.Collections.ArrayList(field.GetValue(null) as System.Collections.ICollection);
        foreach (var window in windows)
        {
            PropertyInfo property = type.GetProperty("isLocked");
            property.SetValue(window, isLocked, null);
        }
    }

    private void GetLastGUIRect(ref Rect rect)
    {
        Rect guiRect = GUILayoutUtility.GetLastRect();
        if (guiRect.x != 0)
        {
            rect = guiRect;
        }
    }

    private void Awake()
    {
        EditorApplication.update += UpdateHandler;

        if (!Application.isPlaying)
        {
            Object obj = AssetDatabase.LoadMainAssetAtPath(GPUSkinningSampler.ReadTempData(GPUSkinningSampler.TEMP_SAVED_ANIM_PATH));
            if (obj != null && obj is GPUSkinningAnimation)
            {
                serializedObject.FindProperty("anim").objectReferenceValue = obj;
            }

            serializedObject.ApplyModifiedProperties();

            GPUSkinningSampler.DeleteTempData(GPUSkinningSampler.TEMP_SAVED_ANIM_PATH);
        }
    }

    private bool GetEditorPrefsBool(string key, bool defaultValue)
    {
        return EditorPrefs.GetBool("GPUSkinningSamplerEditorPrefs_" + key, defaultValue);
    }

    private void SetEditorPrefsBool(string key, bool value)
    {
        EditorPrefs.SetBool("GPUSkinningSamplerEditorPrefs_" + key, value);
    }

	private void OnDestroy()
    {
        EditorApplication.update -= UpdateHandler;
        EditorUtility.ClearProgressBar();
	}

	private void BeginBox()
	{
		EditorGUILayout.BeginVertical(GUI.skin.GetStyle("Box"));
		EditorGUILayout.Space();
	}

	private void EndBox()
	{
		EditorGUILayout.Space();
		EditorGUILayout.EndVertical();
	}
    /*
    [MenuItem("Tools/SkinBones")]
    static void SkinBones()
    {
        var go = Selection.activeGameObject;
        var smr = go.GetComponent<SkinnedMeshRenderer>();
        var builder = new StringBuilder();
        foreach (var b in smr.bones)
        {
            builder.AppendLine(b.name);
        }
        Debug.Log($"bones {smr.bones.Length} bindposes {smr.sharedMesh.bindposes.Length}");
        Debug.Log(builder.ToString());
    }
    */

    private int lastIndentLevel = 0;
    private void BeginIndentLevel(int indentLevel)
    {
        lastIndentLevel = EditorGUI.indentLevel;
        EditorGUI.indentLevel = indentLevel;
    }

    private void EndIndentLevel()
    {
        EditorGUI.indentLevel = lastIndentLevel;
    }
}



