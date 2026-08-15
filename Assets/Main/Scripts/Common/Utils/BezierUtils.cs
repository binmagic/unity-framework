/**
 * [INPUT]: 依赖 UnityEngine 的 Vector3 向量运算
 * [OUTPUT]: 对外提供 BezierUtils 静态工具,以固定分段数生成二次贝塞尔路径点数组
 * [POS]: Common/Utils 的曲线采样快捷入口,复用静态缓冲区避免 GC,与 Bezier(可配置三次曲线)分层
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public static class BezierUtils
{
    private static int SEGMENT_COUNT = 20;
    private static Vector3[] _paths = new Vector3[SEGMENT_COUNT];
    
    public static Vector3[] Bezier2Path( Vector3 startPos, Vector3 controlPos, Vector3 endPos)
    {
        for (int i = 1; i <= SEGMENT_COUNT; i++)
        {
            float t = i / (float)SEGMENT_COUNT;
            Vector3 pixel = CalculateCubicBezierPointfor2C(t, startPos, controlPos, endPos);

            _paths[i - 1] = pixel;

        }

        return _paths;
    }

    static Vector3 CalculateCubicBezierPointfor2C(float t, Vector3 p0, Vector3 p1, Vector3 p2)
    {
        //B(t) = (1-t)(1-t)P0+ 2 (1-t) tP1 + ttP2,   0 <= t <= 1 
        float u = 1 - t;
        float tt = t * t;
        float uu = u * u;

        Vector3 p = uu * p0;
        p += 2 * u * t * p1;
        p += tt * p2;
        return p;
    }
    
}





