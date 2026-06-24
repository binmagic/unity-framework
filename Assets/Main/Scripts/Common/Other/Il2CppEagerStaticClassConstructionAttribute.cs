using System;

namespace Extension.IL2CPP.CompilerServices
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, Inherited = false, AllowMultiple = false)]
    public class Il2CppEagerStaticClassConstructionAttribute : Attribute
    {
    }
}





