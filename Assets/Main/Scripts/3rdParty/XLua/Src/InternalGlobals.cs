/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using System;
using System.Collections.Generic;
using System.Reflection;
using System.Linq;
using System.Threading;

namespace XLua
{
    [Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
    [UnityEngine.Scripting.Preserve]
    internal partial class InternalGlobals
    {
#if !THREAD_SAFE && !HOTFIX_ENABLE
        internal static byte[] strBuff = new byte[256];
#endif

        internal delegate bool TryArrayGet(Type type, RealStatePtr L, ObjectTranslator translator, object obj, int index);
        internal delegate bool TryArraySet(Type type, RealStatePtr L, ObjectTranslator translator, object obj, int array_idx, int obj_idx);
        internal static volatile TryArrayGet genTryArrayGetPtr = null;
        internal static volatile TryArraySet genTryArraySetPtr = null;

        internal static volatile ObjectTranslatorPool objectTranslatorPool = new ObjectTranslatorPool();

        internal static volatile int LUA_REGISTRYINDEX = -10000;

        internal static volatile Dictionary<string, string> supportOp = new Dictionary<string, string>()
        {
            { "op_Addition", "__add" },
            { "op_Subtraction", "__sub" },
            { "op_Multiply", "__mul" },
            { "op_Division", "__div" },
            { "op_Equality", "__eq" },
            { "op_UnaryNegation", "__unm" },
            { "op_LessThan", "__lt" },
            { "op_LessThanOrEqual", "__le" },
            { "op_Modulus", "__mod" },
            { "op_BitwiseAnd", "__band" },
            { "op_BitwiseOr", "__bor" },
            { "op_ExclusiveOr", "__bxor" },
            { "op_OnesComplement", "__bnot" },
            { "op_LeftShift", "__shl" },
            { "op_RightShift", "__shr" },
        };

        internal static volatile Dictionary<Type, IEnumerable<MethodInfo>> extensionMethodMap = null;

#if GEN_CODE_MINIMIZE
        internal static volatile LuaDLL.CSharpWrapperCaller CSharpWrapperCallerPtr = new LuaDLL.CSharpWrapperCaller(StaticLuaCallbacks.CSharpWrapperCallerImpl);
#endif

        internal static volatile LuaCSFunction LazyReflectionWrap = new LuaCSFunction(Utils.LazyReflectionCall);
        internal static Type delegate_birdge_type;
        // -1: not initialized yet, 0: initialized without gencode, 1: initialized with gencode
        private static volatile int initState = -1;
        internal static bool Gen_Flag
        {
            get
            {
                Init();
                return initState == 1;
            }
        }

        internal static Delegate ConvertDelegate(Delegate sourceDelegate, Type targetType)
        {
            return Delegate.CreateDelegate(targetType, sourceDelegate.Target, sourceDelegate.Method);
        }

        internal static void Init()
        {
            if (Interlocked.CompareExchange(ref initState, 0, -1) != -1)
            {
                return;
            }
            
            // 因为XLUA的作者设计思路是，如果你没有编辑GenConfig，或者没有生成任何Wrap文件，xlua一样可以通过反射工作
            // 所以在设计上，类的Wrap文件和xlua的内核文件是分离的，内核是通过反射的方式初始化初始化wrap的（代码如下）
            // 但是如果在Unity上开启了Medium裁剪，Unity无法找到Wrap模块的关联，会把XLua.DelegateBridge_Wrap裁掉，导致反射不到。
            // 所以这里需要对XLua.DelegateBridge_Wrap进行裁剪保留。
            // AppDomain.CurrentDomain.GetAssemblies() 这个GC很大吧？？？

#if UNITY_EDITOR
            delegate_birdge_type = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                select assembly.GetType("XLua.DelegateBridge_Wrap")).FirstOrDefault(x => x != null);
            var InternalGlobals_Gen = (from assembly in AppDomain.CurrentDomain.GetAssemblies()
                select assembly.GetType("XLua.InternalGlobals_Gen")).FirstOrDefault(x => x != null);
#else
            delegate_birdge_type = typeof(XLua.DelegateBridge_Wrap);
            var InternalGlobals_Gen = typeof(XLua.InternalGlobals_Gen);
#endif
            if (delegate_birdge_type == null || InternalGlobals_Gen == null)
            {
                UnityEngine.Debug.Log("delegate_birdge_type == null || InternalGlobals_Gen == null");
                return;
            }

            //UnityEngine.Debug.Log("InternalGlobals:Init()");
            
            Interlocked.Exchange(ref initState, 1);
            
#if UNITY_EDITOR
            var Init = InternalGlobals_Gen.GetMethod("Init", BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
            var parameters = new object[] {null, null, null};
            Init.Invoke(null, parameters);
            extensionMethodMap = parameters[0] as Dictionary<Type, IEnumerable<MethodInfo>>;
            genTryArrayGetPtr = ConvertDelegate(parameters[1] as Delegate, typeof(TryArrayGet)) as TryArrayGet;
            genTryArraySetPtr = ConvertDelegate(parameters[2] as Delegate, typeof(TryArraySet)) as TryArraySet;
#else
            XLua.InternalGlobals_Gen.TryArrayGet TryArrayGet1 = null;
            XLua.InternalGlobals_Gen.TryArraySet TryArraySet1 = null;
            XLua.InternalGlobals_Gen.Init(out extensionMethodMap, out TryArrayGet1, out TryArraySet1);
            genTryArrayGetPtr = ConvertDelegate(TryArrayGet1 as Delegate, typeof(TryArrayGet)) as TryArrayGet;
            genTryArraySetPtr = ConvertDelegate(TryArraySet1 as Delegate, typeof(TryArraySet)) as TryArraySet;
#endif
        }
    }

}





