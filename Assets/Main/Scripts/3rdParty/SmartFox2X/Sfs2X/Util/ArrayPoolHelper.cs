using System.Buffers;

namespace Sfs2X.Util
{
    public static class ArrayPoolHelper
    {
        #region byte数组缓存池

        private static readonly ArrayPool<byte> ArrayPool_byte = ArrayPool<byte>.Create();
    
        public static byte[] SpawnByteArrayFromPool(int size)
        {
            return ArrayPool_byte.Rent(size);
        }

        public static void RecycleByteArrayToPool(byte[] array)
        {
            ArrayPool_byte.Return(array, true);
        }

        #endregion
    }
}





