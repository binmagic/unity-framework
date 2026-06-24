using UnityEngine;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

#if UNITY_EDITOR
using System;
using UnityEditor;
#endif

[ExecuteInEditMode]
public class GPUSkinningSampler : MonoBehaviour 
{
#if UNITY_EDITOR
    [HideInInspector]
    [SerializeField]
	public string animName = null;

    [HideInInspector]
    [System.NonSerialized]
	public AnimationClip animClip = null;

    [HideInInspector]
    [SerializeField]
    public AnimationClip[] animClips = null;

    [HideInInspector]
    [SerializeField]
    public GPUSkinningWrapMode[] wrapModes = null;

    [HideInInspector]
    [SerializeField]
    public int[] fpsList = null;

    [HideInInspector]
    [SerializeField]
    public string[] nameList = null;
    
    [HideInInspector]
    [System.NonSerialized]
    public int samplingClipIndex = -1;

    [HideInInspector]
    [SerializeField]
	public Transform rootBoneTransform = null;

    [HideInInspector]
    [SerializeField]
    public GPUSkinningAnimation anim = null;

    [HideInInspector]
	[System.NonSerialized]
	public bool isSampling = false;

	private Animator animator = null;
    private RuntimeAnimatorController runtimeAnimatorController = null;

	private SkinnedMeshRenderer[] smrArr = null;

	private GPUSkinningAnimation gpuSkinningAnimation = null;

    private GPUSkinningClip gpuSkinningClip = null;

	[HideInInspector]
	[System.NonSerialized]
	public int samplingTotalFrams = 0;

	[HideInInspector]
	[System.NonSerialized]
	public int samplingFrameIndex = 0;

	public const string TEMP_SAVED_ANIM_PATH = "GPUSkinning_Temp_Save_Anim_Path";

    public void BeginSample()
    {
        samplingClipIndex = 0;
    }

    public void EndSample()
    {
        samplingClipIndex = -1;

        CreateAnimationAssets();
    }

    public bool IsSamplingProgress()
    {
        return samplingClipIndex != -1;
    }

    public void StartSample()
	{
        if (isSampling)
        {
            return;
        }

        if (string.IsNullOrEmpty(animName.Trim()))
        {
            ShowDialog("Animation name is empty.");
            return;
        }

        if (rootBoneTransform == null)
        {
            ShowDialog("Please set Root Bone.");
            return;
        }

        if (animClips == null || animClips.Length == 0)
        {
            ShowDialog("Please set Anim Clips.");
            return;
        }

        animClip = animClips[samplingClipIndex];
        if (animClip == null)
		{
            isSampling = false;
			return;
		}

        int numFrames = (int)(GetClipFPS(animClip, samplingClipIndex) * animClip.length + 1);
        if(numFrames == 0)
        {
            isSampling = false;
            return;
        }

		smrArr = GetComponentsInChildren<SkinnedMeshRenderer>();
		if(smrArr == null || smrArr.Length == 0)
		{
			ShowDialog("Cannot find SkinnedMeshRenderer.");
			return;
		}
		if(smrArr.Any(a => a.sharedMesh == null))
		{
			ShowDialog("Cannot find SkinnedMeshRenderer.mesh.");
			return;
		}

		samplingFrameIndex = 0;

		if (anim == null)
		{
			gpuSkinningAnimation = ScriptableObject.CreateInstance<GPUSkinningAnimation>();
			gpuSkinningAnimation.guid = System.Guid.NewGuid().ToString();
			gpuSkinningAnimation.name = animName;
			anim = gpuSkinningAnimation;
		}
		else
		{
			gpuSkinningAnimation = anim;
			gpuSkinningAnimation.name = animName;
		}

        List<Transform> bones = new List<Transform>();
        List<Matrix4x4> bindposes = new List<Matrix4x4>();
        for (int i = 0; i < smrArr.Length; i++)
        {
	        var smr = smrArr[i];
	        var mesh = smr.sharedMesh;
	        for (int j = 0; j < smr.bones.Length; j++)
	        {
		        if (!bones.Contains(smr.bones[j]))
		        {
			        bones.Add(smr.bones[j]);
			        bindposes.Add(mesh.bindposes[j]);
		        }
	        }
        }
        
		List<GPUSkinningBone> bones_result = new List<GPUSkinningBone>();
		CollectBones(bones_result, bones.ToArray(), bindposes.ToArray(), null, rootBoneTransform, 0);
        GPUSkinningBone[] newBones = bones_result.ToArray();
        GenerateBonesGUID(newBones);
        gpuSkinningAnimation.bones = newBones;
        gpuSkinningAnimation.rootBoneIndex = 0;
        

        int numClips = gpuSkinningAnimation.clips == null ? 0 : gpuSkinningAnimation.clips.Length;
        int overrideClipIndex = -1;
        for (int i = 0; i < numClips; ++i)
        {
            if (gpuSkinningAnimation.clips[i].animationClipName == animClip.name)
            {
                overrideClipIndex = i;
                break;
            }
        }

        gpuSkinningClip = new GPUSkinningClip();
        gpuSkinningClip.name = nameList[samplingClipIndex];
        gpuSkinningClip.animationClipName = animClip.name;
        gpuSkinningClip.fps = GetClipFPS(animClip, samplingClipIndex);
        gpuSkinningClip.length = animClip.length;
        gpuSkinningClip.wrapMode = animClip.isLooping ? GPUSkinningWrapMode.Loop : GPUSkinningWrapMode.Once;
        gpuSkinningClip.frames = new GPUSkinningFrame[numFrames];

        if(gpuSkinningAnimation.clips == null)
        {
            gpuSkinningAnimation.clips = new GPUSkinningClip[] { gpuSkinningClip };
        }
        else
        {
            if (overrideClipIndex == -1)
            {
                List<GPUSkinningClip> clips = new List<GPUSkinningClip>(gpuSkinningAnimation.clips);
                clips.Add(gpuSkinningClip);
                gpuSkinningAnimation.clips = clips.ToArray();
            }
            else
            {
                gpuSkinningAnimation.clips[overrideClipIndex] = gpuSkinningClip;
            }
        }

        SetCurrentAnimationClip();
        PrepareRecordAnimator();

        isSampling = true;
    }

    private int GetClipFPS(AnimationClip clip, int clipIndex)
    {
        return fpsList[clipIndex] == 0 ? (int)clip.frameRate : fpsList[clipIndex];
    }

    private string GetClipName(int clipIndex)
    {
	    return nameList[clipIndex];
    }

    private void GenerateBonesGUID(GPUSkinningBone[] bones)
    {
        int numBones = bones == null ? 0 : bones.Length;
        for(int i = 0; i < numBones; ++i)
        {
            string boneHierarchyPath = GPUSkinningUtil.BoneHierarchyPath(bones, i);
            string guid = GPUSkinningUtil.MD5(boneHierarchyPath);
            bones[i].guid = guid;
        }
    }

    private void PrepareRecordAnimator()
    {
        if (animator != null)
        {
            int numFrames = (int)(gpuSkinningClip.fps * gpuSkinningClip.length);

            animator.Rebind();
            animator.recorderStartTime = 0;
            animator.StartRecording(numFrames);
            for (int i = 0; i <= numFrames; ++i)
            {
                animator.Update(1.0f / gpuSkinningClip.fps);
            }
            animator.StopRecording();
            animator.StartPlayback();
        }
    }

    private void SetCurrentAnimationClip()
    {
	    AnimatorOverrideController animatorOverrideController = new AnimatorOverrideController();
	    AnimationClip[] clips = runtimeAnimatorController.animationClips;
	    AnimationClipPair[] pairs = new AnimationClipPair[clips.Length];
	    for (int i = 0; i < clips.Length; ++i)
	    {
		    AnimationClipPair pair = new AnimationClipPair();
		    pairs[i] = pair;
		    pair.originalClip = clips[i];
		    pair.overrideClip = animClip;
	    }
	    animatorOverrideController.runtimeAnimatorController = runtimeAnimatorController;
	    animatorOverrideController.clips = pairs;
	    animator.runtimeAnimatorController = animatorOverrideController;
    }

    private static Mesh CreateNewMesh(Mesh mesh, string meshName, Transform[] smrBones, GPUSkinningAnimation animation)
    {
	    if (mesh == null)
		    return null;
        Vector3[] normals = mesh.normals;
        Vector4[] tangents = mesh.tangents;
        Color[] colors = mesh.colors;
        Vector2[] uv = mesh.uv;
        Vector2[] uv2 = mesh.uv2;
        Vector2[] uv3 = mesh.uv3;
        
        Mesh newMesh = new Mesh();
        newMesh.name = meshName;
        newMesh.vertices = mesh.vertices;
        if (normals != null && normals.Length > 0) { newMesh.normals = normals; }
        if (tangents != null && tangents.Length > 0) { newMesh.tangents = tangents; }
        if (colors != null && colors.Length > 0) { newMesh.colors = colors; }
        if (uv != null && uv.Length > 0) { newMesh.uv = uv; }
        if (uv2 != null && uv2.Length > 0) { newMesh.uv2 = uv2; }
        if (uv3 != null && uv3.Length > 0) { newMesh.uv3 = uv3; }

        int numVertices = mesh.vertexCount;
        BoneWeight[] boneWeights = mesh.boneWeights;
        Vector4[] uv4 = new Vector4[numVertices];
		Vector4[] uv5 = new Vector4[numVertices];
        for(int i = 0; i < numVertices; ++i)
        {
            BoneWeight boneWeight = boneWeights[i];

			BoneWeightSortData[] weights = new BoneWeightSortData[4];
			weights[0] = new BoneWeightSortData(){ index=boneWeight.boneIndex0, weight=boneWeight.weight0 };
			weights[1] = new BoneWeightSortData(){ index=boneWeight.boneIndex1, weight=boneWeight.weight1 };
			weights[2] = new BoneWeightSortData(){ index=boneWeight.boneIndex2, weight=boneWeight.weight2 };
			weights[3] = new BoneWeightSortData(){ index=boneWeight.boneIndex3, weight=boneWeight.weight3 };
			System.Array.Sort(weights);

			GPUSkinningBone bone0 = animation.GetBoneByTransform(smrBones[weights[0].index]);
			GPUSkinningBone bone1 = animation.GetBoneByTransform(smrBones[weights[1].index]);
			GPUSkinningBone bone2 = animation.GetBoneByTransform(smrBones[weights[2].index]);
			GPUSkinningBone bone3 = animation.GetBoneByTransform(smrBones[weights[3].index]);

            Vector4 skinData_01 = new Vector4();
			skinData_01.x = animation.GetBoneIndex(bone0);
			skinData_01.y = weights[0].weight;
			skinData_01.z = animation.GetBoneIndex(bone1);
			skinData_01.w = weights[1].weight;
			uv4[i] = skinData_01;

			Vector4 skinData_23 = new Vector4();
			skinData_23.x = animation.GetBoneIndex(bone2);
			skinData_23.y = weights[2].weight;
			skinData_23.z = animation.GetBoneIndex(bone3);
			skinData_23.w = weights[3].weight;
			uv5[i] = skinData_23;
        }
        newMesh.SetUVs(3, new List<Vector4>(uv4));
		newMesh.SetUVs(4, new List<Vector4>(uv5));

        newMesh.triangles = mesh.triangles;
        newMesh.RecalculateBounds();
        return newMesh;
    }

	private class BoneWeightSortData : System.IComparable<BoneWeightSortData>
	{
		public int index = 0;

		public float weight = 0;

		public int CompareTo(BoneWeightSortData b)
		{
			return weight > b.weight ? -1 : 1;
		}
	}

	private void CollectBones(List<GPUSkinningBone> bones_result, Transform[] bones_smr, Matrix4x4[] bindposes, GPUSkinningBone parentBone, Transform currentBoneTransform, int currentBoneIndex)
	{
		GPUSkinningBone currentBone = new GPUSkinningBone();
		bones_result.Add(currentBone);

		int indexOfSmrBones = System.Array.IndexOf(bones_smr, currentBoneTransform);
		currentBone.transform = currentBoneTransform;
		currentBone.name = currentBone.transform.gameObject.name;
		currentBone.bindpose = indexOfSmrBones == -1 ? Matrix4x4.identity : bindposes[indexOfSmrBones];
		currentBone.parentBoneIndex = parentBone == null ? -1 : bones_result.IndexOf(parentBone);

		if(parentBone != null)
		{
			parentBone.childrenBonesIndices[currentBoneIndex] = bones_result.IndexOf(currentBone);
		}

		int numChildren = currentBone.transform.childCount;
		if(numChildren > 0)
		{
			currentBone.childrenBonesIndices = new int[numChildren];
			for(int i = 0; i < numChildren; ++i)
			{
				CollectBones(bones_result, bones_smr, bindposes, currentBone, currentBone.transform.GetChild(i) , i);
			}
		}
	}

    private static void SetSthAboutTexture(GPUSkinningAnimation gpuSkinningAnim)
    {
        int numPixels = 0;

        GPUSkinningClip[] clips = gpuSkinningAnim.clips;
        int numClips = clips.Length;
        for (int clipIndex = 0; clipIndex < numClips; ++clipIndex)
        {
            GPUSkinningClip clip = clips[clipIndex];
            clip.pixelSegmentation = numPixels;

            GPUSkinningFrame[] frames = clip.frames;
            int numFrames = frames.Length;
            numPixels += gpuSkinningAnim.bones.Length * 3/*treat 3 pixels as a float3x4*/ * numFrames;
        }

        CalculateTextureSize(numPixels, out gpuSkinningAnim.textureWidth, out gpuSkinningAnim.textureHeight);
    }

    private static void CreateAnimation(string dir, GPUSkinningAnimation gpuSkinningAnimation)
    {
	    string savedAnimPath = dir + "/" + gpuSkinningAnimation.name + "_animation.asset";
	    SetSthAboutTexture(gpuSkinningAnimation);
	    EditorUtility.SetDirty(gpuSkinningAnimation);
	    if (!AssetDatabase.Contains(gpuSkinningAnimation))
		    AssetDatabase.CreateAsset(gpuSkinningAnimation, savedAnimPath);
	    WriteTempData(TEMP_SAVED_ANIM_PATH, savedAnimPath);
    }

    private static Mesh[] CreateMeshAsset(string dir, SkinnedMeshRenderer[] smrs, GPUSkinningAnimation animation)
    {
	    List<Mesh> meshList = new List<Mesh>();
	    for (int i = 0; i < smrs.Length; i++)
	    {
		    var smr = smrs[i];
		    Mesh newMesh = CreateNewMesh(smr.sharedMesh, animation.name + "_" + smr.name, smr.bones, animation);
		    string savedMeshPath = dir + "/" + animation.name + "_mesh_" + smr.name + ".asset";
		    AssetDatabase.CreateAsset(newMesh, savedMeshPath);
		    meshList.Add(newMesh);
	    }

	    return meshList.ToArray();
    }

    private static Texture2D CreateTextureMatrix(string dir, GPUSkinningAnimation gpuSkinningAnim)
    {
        Texture2D texture = new Texture2D(gpuSkinningAnim.textureWidth, gpuSkinningAnim.textureHeight, TextureFormat.RGBAHalf, false, true);
        texture.name = "TextureMatrix";
        texture.filterMode = FilterMode.Point;
        Color[] pixels = texture.GetPixels();
        int pixelIndex = 0;
        for (int clipIndex = 0; clipIndex < gpuSkinningAnim.clips.Length; ++clipIndex)
        {
            GPUSkinningClip clip = gpuSkinningAnim.clips[clipIndex];
            GPUSkinningFrame[] frames = clip.frames;
            int numFrames = frames.Length;
            for (int frameIndex = 0; frameIndex < numFrames; ++frameIndex)
            {
                GPUSkinningFrame frame = frames[frameIndex];
                Matrix4x4[] matrices = frame.matrices;
                int numMatrices = matrices.Length;
                for (int matrixIndex = 0; matrixIndex < numMatrices; ++matrixIndex)
                {
                    Matrix4x4 matrix = matrices[matrixIndex];
                    pixels[pixelIndex++] = new Color(matrix.m00, matrix.m01, matrix.m02, matrix.m03);
                    pixels[pixelIndex++] = new Color(matrix.m10, matrix.m11, matrix.m12, matrix.m13);
                    pixels[pixelIndex++] = new Color(matrix.m20, matrix.m21, matrix.m22, matrix.m23);
                }
            }
        }
        texture.SetPixels(pixels);
        texture.Apply();
        
        string savedPath = dir + "/" + gpuSkinningAnim.name + "_texture.asset";
        AssetDatabase.CreateAsset(texture, savedPath);

        return texture;
    }

    private static Material[] CreateMaterial(string dir, SkinnedMeshRenderer[] smrArr, Texture2D texMatrix, GPUSkinningAnimation animation)
    {
	    var smrMats = new List<Material>();
	    for (int i = 0; i < smrArr.Length; i++)
	    {
		    var mat = smrArr[i].sharedMaterial;

		    var j = Array.FindIndex(smrArr, a => a.sharedMaterial == mat);
		    if (i == j)
		    {
			    var gpuSkinMat = new Material(mat);
			    gpuSkinMat.SetTexture(GPUSkinningAnimator.PropertyID_Matrix, texMatrix);
			    gpuSkinMat.SetVector(GPUSkinningAnimator.PropertyID_TextureSize, new Vector4(animation.textureWidth, animation.textureHeight, animation.bones.Length * 3));
			    gpuSkinMat.SetFloat(GPUSkinningAnimator.PropertyID_GPUSkin, 1);
			    gpuSkinMat.EnableKeyword("GPU_SKIN");
			    gpuSkinMat.enableInstancing = true;
			    smrMats.Add(gpuSkinMat);
			    
			    string savedPath = dir + "/" + animation.name + "_material_" + mat.name + ".mat";
			    AssetDatabase.CreateAsset(gpuSkinMat, savedPath);
		    }
		    else
		    {
			    smrMats.Add(smrMats[j]);
		    }
	    }

	    return smrMats.ToArray();
    }

    private static void CreatePrefab(string dir, SkinnedMeshRenderer[] smrs, Mesh[] meshArr, Material[] matArr, GPUSkinningAnimation animation)
    {
	    var go = new GameObject(animation.name, typeof(GPUSkinningAnimator));
	    var serializedObject = new SerializedObject(go.GetComponent<GPUSkinningAnimator>());
	    var propAnim = serializedObject.FindProperty("anim");
	    propAnim.objectReferenceValue = animation;
	    serializedObject.ApplyModifiedProperties();
	    
	    for (int i = 0; i < smrs.Length; i++)
	    {
		    var smr = smrs[i];
		    var meshGo = new GameObject(smr.name, typeof(MeshFilter), typeof(MeshRenderer));
		    meshGo.transform.SetParent(go.transform);
		    meshGo.GetComponent<MeshFilter>().sharedMesh = meshArr[i];
		    meshGo.GetComponent<MeshRenderer>().sharedMaterial = matArr[i];
	    }

	    if (smrs.Length > 0)
	    {
		    var rootBone = smrs[0].rootBone;
		    var rootGo = new GameObject(rootBone.name);
		    rootGo.transform.SetParent(go.transform);
		    rootGo.transform.localPosition = rootBone.localPosition;
		    rootGo.transform.localRotation = rootBone.localRotation;
		    rootGo.transform.localScale = rootBone.localScale;
	    }

	    PrefabUtility.SaveAsPrefabAsset(go, dir + "/" + animation.name + "_prefab.prefab");
    }

    private static void CalculateTextureSize(int numPixels, out int texWidth, out int texHeight)
    {
        texWidth = 1;
        texHeight = 1;
        while (true)
        {
            if (texWidth * texHeight >= numPixels) break;
            texWidth *= 2;
            if (texWidth * texHeight >= numPixels) break;
            texHeight *= 2;
        }
    }

    private void InitTransform()
    {
        transform.parent = null;
        transform.position = Vector3.zero;
        transform.eulerAngles = Vector3.zero;
    }

    private void Awake()
	{
		animator = GetComponent<Animator>();
        if (animator == null)
        {
            DestroyImmediate(this);
            ShowDialog("Cannot find Animator Component");
            return;
        }

        if (animator.runtimeAnimatorController == null)
        {
            DestroyImmediate(this);
            ShowDialog("Missing RuntimeAnimatorController");
            return;
        }

        if (animator.runtimeAnimatorController is AnimatorOverrideController)
        {
            DestroyImmediate(this);
            ShowDialog("RuntimeAnimatorController could not be a AnimatorOverrideController");
            return;
        }

        runtimeAnimatorController = animator.runtimeAnimatorController;
        animator.cullingMode = AnimatorCullingMode.AlwaysAnimate;
    }

	private void Update()
	{
		if(!isSampling)
		{
			return;
		}

        int totalFrams = (int)(gpuSkinningClip.length * gpuSkinningClip.fps);
		samplingTotalFrams = totalFrams;

        if (samplingFrameIndex > totalFrams)
        {
            if(animator != null)
            {
                animator.StopPlayback();
            }

            isSampling = false;
            return;
        }
        
        float time = gpuSkinningClip.length * ((float)samplingFrameIndex / totalFrams);
        GPUSkinningFrame frame = new GPUSkinningFrame();
        gpuSkinningClip.frames[samplingFrameIndex] = frame;
        frame.matrices = new Matrix4x4[gpuSkinningAnimation.bones.Length];

        animator.playbackTime = time;
        animator.Update(0);
        
        StartCoroutine(SamplingCoroutine(frame, totalFrams));
    }

    private IEnumerator SamplingCoroutine(GPUSkinningFrame frame, int totalFrames)
    {
		yield return new WaitForEndOfFrame();

        GPUSkinningBone[] bones = gpuSkinningAnimation.bones;
        int numBones = bones.Length;
        for(int i = 0; i < numBones; ++i)
        {
            GPUSkinningBone currentBone = bones[i];
            frame.matrices[i] = currentBone.bindpose;
            do
            {
                Matrix4x4 mat = Matrix4x4.TRS(currentBone.transform.localPosition, currentBone.transform.localRotation, currentBone.transform.localScale);
                frame.matrices[i] = mat * frame.matrices[i];
                if (currentBone.parentBoneIndex == -1)
                {
                    break;
                }
                else
                {
                    currentBone = bones[currentBone.parentBoneIndex];
                }
            }
            while (true);
        }

        ++samplingFrameIndex;
    }
    

    private void CreateAnimationAssets()
    {
	    string savePath = null;
	    if (!AssetDatabase.Contains(gpuSkinningAnimation))
	    {
		    savePath = EditorUtility.SaveFolderPanel("GPUSkinning Sampler Save", GetUserPreferDir(), "");
	    }
	    else
	    {
		    string animPath = AssetDatabase.GetAssetPath(gpuSkinningAnimation);
		    savePath = new FileInfo(animPath).Directory.FullName.Replace('\\', '/');
	    }

	    if(!string.IsNullOrEmpty(savePath))
	    {
		    if(!savePath.Contains(Application.dataPath.Replace('\\', '/')))
		    {
			    ShowDialog("Must select a directory in the project's Asset folder.");
		    }
		    else
		    {
			    SaveUserPreferDir(savePath);

			    string dir = "Assets" + savePath.Substring(Application.dataPath.Length);

			    CreateAnimation(dir, gpuSkinningAnimation);
			    var texMatrix = CreateTextureMatrix(dir, gpuSkinningAnimation);
			    var meshArr = CreateMeshAsset(dir, smrArr, gpuSkinningAnimation);
			    var matArr = CreateMaterial(dir, smrArr, texMatrix, gpuSkinningAnimation);
			    CreatePrefab(dir, smrArr, meshArr, matArr, gpuSkinningAnimation);

			    AssetDatabase.Refresh();
			    AssetDatabase.SaveAssets();
		    }
	    }
    }

    public static void ShowDialog(string msg)
	{
		EditorUtility.DisplayDialog("GPUSkinning", msg, "OK");
	}

	private void SaveUserPreferDir(string dirPath)
	{
		PlayerPrefs.SetString("GPUSkinning_UserPreferDir", dirPath);
	}

	private string GetUserPreferDir()
	{
		return PlayerPrefs.GetString("GPUSkinning_UserPreferDir", Application.dataPath);
	}

    public static void WriteTempData(string key, string value)
    {
        PlayerPrefs.SetString(key, value);
    }

    public static string ReadTempData(string key)
    {
        return PlayerPrefs.GetString(key, string.Empty);
    }

    public static void DeleteTempData(string key)
    {
        PlayerPrefs.DeleteKey(key);
    }
#endif
}





