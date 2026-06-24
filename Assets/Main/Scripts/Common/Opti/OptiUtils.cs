using System.Collections.Generic;
using UnityEngine;

// 这个文件中放一些具体的优化函数
// 这些函数是全局的，不属于某个类。属于某个类的放到UnityExtension中

[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
[UnityEngine.Scripting.Preserve]
public static class OptiUtils
{
    public static float Vector3_Angle(float fx, float fy, float fz, float tx, float ty, float tz)
    {
        Vector3 from = new Vector3(fx, fy, fz);
        Vector3 to = new Vector3(tx, ty, tz);
        return Vector3.Angle(from.normalized, to.normalized);
    }

    // 这个计算较多，在lua中性能总体有限；这个放到C#中处理
    public static void Vector3_MoveTowards(float current_x, float current_y, float current_z,
        float target_x, float target_y, float target_z, float maxDistanceDelta,
        out float x, out float y, out float z)
    {
        Vector3 current = new Vector3(current_x, current_y, current_z);
        Vector3 target = new Vector3(target_x, target_y, target_z);

        Vector3 ret = Vector3.MoveTowards(current, target, maxDistanceDelta);
        x = ret.x;
        y = ret.y;
        z = ret.z;
        return;
    }
    
    // 启动/禁止 某个节点下所有子节点的组件（调用有点频繁，所以处理一下）
    private static List<TrailRenderer> trailList = new List<TrailRenderer>(8);
    public static void EnableAllChildren_TrailRenderer(Transform transform, bool includeInactive, bool enable)
    {
        trailList.Clear();
        transform.GetComponentsInChildren(includeInactive, trailList);
        for (int i = 0; i < trailList.Count; ++i)
        {
            if (enable == false)
            {
                trailList[i].Clear();
            }
            trailList[i].enabled = enable;
        }
    }
    
    
}





