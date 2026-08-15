//  Created by zhangliheng on 2024/06/11.
//  Copyright © 2022 com.aps.net. All rights reserved.

/**
 * [INPUT]: 依赖 UnityEngine.Scripting.Preserve 特性与被引用的 Unity 类型(如 LODGroup)
 * [OUTPUT]: 对外提供 ManualPreserve 占位类,通过持有字段强制 IL2CPP 代码裁剪时保留相关类型
 * [POS]: Application 的裁剪保护声明,防止仅 Lua/反射使用的类型被 link 剥离,是发布链路的防裁剪锚点
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using UnityEngine.Scripting;

[Preserve]
public class ManualPreserve
{
    public UnityEngine.LODGroup _lodGroup;
}





