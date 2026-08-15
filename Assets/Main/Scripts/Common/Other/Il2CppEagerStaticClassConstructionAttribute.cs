/**
 * [INPUT]: 依赖 System.Attribute 基类
 * [OUTPUT]: 对外提供 Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute 特性
 * [POS]: Common/Other 的 IL2CPP 编译提示特性,标注类做急切静态构造以规避运行时惰性初始化开销,被 Utils/Log 等热点类广泛标注
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System;

namespace Extension.IL2CPP.CompilerServices
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, Inherited = false, AllowMultiple = false)]
    public class Il2CppEagerStaticClassConstructionAttribute : Attribute
    {
    }
}





