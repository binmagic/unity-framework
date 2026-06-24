using UnityEngine;
using System.Collections;

public class GPUSkinningAnimation : ScriptableObject
{
    public string guid = null;
    public string name = null;
    public GPUSkinningBone[] bones = null;
    public int rootBoneIndex = 0;
    public GPUSkinningClip[] clips = null;
    public Bounds bounds;
    public int textureWidth = 0;
    public int textureHeight = 0;

    public GPUSkinningBone GetBoneByTransform(Transform transform)
    {
        int numBones = bones.Length;
        for(int i = 0; i < numBones; ++i)
        {
            if(bones[i].transform == transform)
            {
                return bones[i];
            }
        }
        return null;
    }
    
    public int GetBoneIndex(GPUSkinningBone bone)
    {
        return System.Array.IndexOf(bones, bone);
    }
}





