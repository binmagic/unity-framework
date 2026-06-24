//  ***
//  * Created by zhangliheng.
//  * DateTime: 2025/04/09 6:04 PM
//  * Description: get server list sig相关支持 key以非明文的方式存储，动态随机选择一种算法还原
//  ***/


using System.Text;
using UnityEngine;

public static class GSLSignatureHelper
{
    private static class KeyGenerator1 
    {
        private static readonly byte[] EncryptedKeyBytes = {
            0x09, 0x7F, 0x26, 0x1E, 0x18, 0x17, 0x1F, 0x17, 
            0x1B, 0x04, 0x66, 0x0E, 0x16, 0x0C, 0x11, 0x2B, 
            0x1A, 0x37, 0x1E, 0x1C, 0x3B, 0x1D, 0x3B, 0x10, 
            0x0B, 0x1E, 0x13, 0x18, 0x19, 0x24, 0x6B, 0x1B, 
            0x1A, 0x14, 0x60, 0x08, 0x1E, 0x62
        };
        private static readonly byte[] XorKey = Encoding.UTF8.GetBytes("XOR_KEY");

        public static string DecryptKey()
        {
            byte[] originalKeyBytes = new byte[EncryptedKeyBytes.Length];
            for (int i = 0; i < EncryptedKeyBytes.Length; i++)
            {
                originalKeyBytes[i] = (byte)(EncryptedKeyBytes[i] ^ XorKey[i % XorKey.Length]);
            }
            return Encoding.UTF8.GetString(originalKeyBytes);
        }

        public static byte[] EncryptKey(string originalKey)
        {
            byte[] originalKeyBytes = Encoding.UTF8.GetBytes(originalKey);
            byte[] encryptedBytes = new byte[originalKeyBytes.Length];

            for (int i = 0; i < originalKeyBytes.Length; i++)
            {
                encryptedBytes[i] = (byte)(originalKeyBytes[i] ^ XorKey[i % XorKey.Length]);
            }

            return encryptedBytes;
        }
    }
    private static class KeyGenerator2 
    {
        private static readonly byte[] EncryptedKeyBytes = {
            0x30, 0xF7, 0x02, 0x00, 0x70, 0x71, 0x91, 0x40, 
            0x11, 0xF0, 0xB6, 0xA0, 0x70, 0x41, 0xD1, 0x12, 
            0x71, 0x32, 0x01, 0x00, 0x03, 0xA0, 0x02, 0x30, 
            0x00, 0x01, 0x90, 0xA0, 0x40, 0x23, 0xB6, 0xB0, 
            0x50, 0x01, 0xD6, 0x51, 0xE0, 0xB7
        };
        
        private static readonly byte[] RotateKey = Encoding.UTF8.GetBytes("ROTATE_KEY");

        public static string DecryptKey()
        {
            byte[] originalKeyBytes = new byte[EncryptedKeyBytes.Length];
            
            for (int i = 0; i < EncryptedKeyBytes.Length; i++)
            {
                // 使用旋转和异或组合的加密方式
                byte rotated = (byte)((EncryptedKeyBytes[i] << 4) | (EncryptedKeyBytes[i] >> 4));
                originalKeyBytes[i] = (byte)(rotated ^ RotateKey[i % RotateKey.Length]);
            }
            
            return Encoding.UTF8.GetString(originalKeyBytes);
        }

        public static byte[] EncryptKey(string originalKey)
        {
            byte[] originalKeyBytes = Encoding.UTF8.GetBytes(originalKey);
            byte[] encryptedBytes = new byte[originalKeyBytes.Length];

            for (int i = 0; i < originalKeyBytes.Length; i++)
            {
                byte xored = (byte)(originalKeyBytes[i] ^ RotateKey[i % RotateKey.Length]);
                encryptedBytes[i] = (byte)((xored >> 4) | (xored << 4));
            }

            return encryptedBytes;
        }
    }
    private static class KeyGenerator3
    {
        private static readonly byte[] EncryptedKeyBytes = {
            0x7A, 0x55, 0x31, 0x6F, 0x22, 0x48, 0x5E, 0x3D, 
            0x1A, 0x6B, 0x41, 0x72, 0x50, 0x3C, 0x2E, 0x69, 
            0x11, 0x7D, 0x4B, 0x60, 0x33, 0x2A, 0x53, 0x46, 
            0x71, 0x27, 0x5B, 0x38, 0x44, 0x1C, 0x32, 0x7F, 
            0x4D, 0x55, 0x2C, 0x19, 0x61, 0x7A
        };

        private static readonly byte[] TransformKey = Encoding.UTF8.GetBytes("TRANSFORM_KEY");

        public static string DecryptKey()
        {
            byte[] originalKeyBytes = new byte[EncryptedKeyBytes.Length];

            for (int i = 0; i < EncryptedKeyBytes.Length; i++)
            {
                // 先执行减法，再进行位反转
                byte subtracted = (byte)(EncryptedKeyBytes[i] - TransformKey[i % TransformKey.Length]);
                originalKeyBytes[i] = (byte)~subtracted;
            }

            return Encoding.UTF8.GetString(originalKeyBytes);
        }

        public static byte[] EncryptKey(string originalKey)
        {
            byte[] originalKeyBytes = Encoding.UTF8.GetBytes(originalKey);
            byte[] encryptedBytes = new byte[originalKeyBytes.Length];

            for (int i = 0; i < originalKeyBytes.Length; i++)
            {
                // 先进行位反转，再执行加法
                byte inverted = (byte)~originalKeyBytes[i];
                encryptedBytes[i] = (byte)(inverted + TransformKey[i % TransformKey.Length]);
            }

            return encryptedBytes;
        }
    }

    
    public static string GetSigKey()
    {
        var t = Random.Range(1, 4); // 1-3的随机数
        string key;
        
        switch (t)
        {
            case 1:
                key = KeyGenerator1.DecryptKey();
                break;
            case 2:
                key = KeyGenerator2.DecryptKey();
                break;
            case 3:
                key = KeyGenerator3.DecryptKey();
                break;
            default:
                key = KeyGenerator1.DecryptKey();
                break;
        }
        
        return key;
    }
}
