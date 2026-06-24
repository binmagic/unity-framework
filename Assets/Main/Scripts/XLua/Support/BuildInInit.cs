using System.Collections.Generic;

namespace XLua.LuaDLL
{
    using System.Runtime.InteropServices;

    public partial class Lua
    {
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_rapidjson(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadRapidJson(System.IntPtr L)
        {
            return luaopen_rapidjson(L);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_lpeg(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLpeg(System.IntPtr L)
        {
            return luaopen_lpeg(L);
        }

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_pb(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLuaProfobuf(System.IntPtr L)
        {
            return luaopen_pb(L);
        }

        // [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        // public static extern int luaopen_ffi(System.IntPtr L);
        //
        // [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        // public static int LoadFFI(System.IntPtr L)
        // {
        //     return luaopen_ffi(L);
        // }
        
        
        /// 测试
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int loadPbSchemeBinary(System.IntPtr L, byte[] pointer, int length);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int StackTopToBin(System.IntPtr L, byte[] buffer, int length);

        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern System.IntPtr GetStackTopBufLen(System.IntPtr L, out System.IntPtr length);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int CopyAndFreeStackTopBuf(System.IntPtr L, System.IntPtr baBytes, byte[] buffer, int length);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int BinToStackTable(System.IntPtr L, byte[] buffer, int length);
        
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int ZLibCompressBound(int level);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int ZLibCompress(byte[] src, int srcLen, byte[] dst, int dstLen, int level);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int ZLibUnCompress(byte[] src, int srcLen, byte[] dst, int dstLen);

        // 将数据写入到文件内，filePath必须是可写入路径；注意缓冲是System.IntPtr，不是byte[]
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int WriteBufferToFile(string filePath, System.IntPtr buffer, int bufLen);
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaL_traceback(System.IntPtr L, System.IntPtr L1, byte[] msg, int level);
        
        public static string Traceback(System.IntPtr L)
        {
            int top = lua_gettop(L);
            luaL_traceback(L, L, null, 1);
            string s = "";
            System.IntPtr str = lua_tolstring(L, -1, out System.IntPtr strlen);
            if (str != System.IntPtr.Zero)
            {
                s = Marshal.PtrToStringAnsi(str, strlen.ToInt32());
            }
            lua_settop(L, top);
            return s;
        }
        
        private delegate void UnityLogger(int logLevel, System.IntPtr pointer);
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        private static extern void RegisterUnityLogger(UnityLogger logger);

        public static void RegisterUnityLogger()
        {
            RegisterUnityLogger(Unity_Log);
        }
        
        private static readonly Dictionary<long, string> StrCache = new Dictionary<long, string>(32);
        [MonoPInvokeCallback(typeof(UnityLogger))]
        private static void Unity_Log(int logLevel, System.IntPtr pointer)
        {
            // var pValue = pointer.ToInt64();
            // if (!StrCache.TryGetValue(pValue, out var message))
            // {
            //     message = Marshal.PtrToStringAnsi(pointer);
            //     StrCache[pValue] = message;
            // }
// #if FINAL_RELEASE
//             return;
// #endif
            string message = Marshal.PtrToStringAnsi(pointer);

            if (logLevel == 0)
            {
                UnityEngine.Debug.Log(message);
            }
            else
            {
                UnityEngine.Debug.LogError(message);
            }
        }
        
        
        
        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int Load_luaUtil(System.IntPtr L, byte[] pointer, int length)
        {
            return loadPbSchemeBinary(L, pointer, length);
        }
        
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_split(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadStringExt(System.IntPtr L)
        {
            return luaopen_split(L);
        }
        
        
        //本地库
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_native(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLuaCNativeCode(System.IntPtr L)
        {
            return luaopen_native(L);
        }
        
        
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_mpack(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLuaMPackCode(System.IntPtr L)
        {
            return luaopen_mpack(L);
        }

#if UNITY_IOS
#else
        /// test code no ios static link library

        /// <summary>
        /// 在PBN环境下导入proto.bytes
        /// </summary>
        /// <param name="pointer"></param>
        /// <param name="length"></param>
        /// <returns></returns>
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int pbn_loadPbSchemeBinary(byte[] pointer, int length);

        /// <summary>
        /// PBN环境下解析ud数据
        /// </summary>
        /// <param name="L"></param>
        /// <returns></returns>
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int pbn_ud_parse(System.IntPtr L);

        /// <summary>
        /// 清理pb_node缓存, Be carefull
        /// </summary>
        /// <returns></returns>
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int pbn_global_clear();

        /// <summary>
        /// 直接解析，返回pb_tree_t指针
        /// </summary>
        /// <param name="data"></param>
        /// <param name="d_size"></param>
        /// <param name="type"></param>
        /// <param name="t_size"></param>
        /// <returns></returns>
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern System.IntPtr pbn_decode(byte[] data, int d_size, string type, int t_size);

        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_pbnode(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLuaPbNode(System.IntPtr L)
        {
            return luaopen_pbnode(L);
        }

#endif

    }
}





