using System;
using System.Text;
using System.Security.Cryptography;
using System.IO;
using UnityEngine;
using Random = UnityEngine.Random;

class AESHelper
{
    public static string Encrypt(string countent, string Key)
    {
        AesEncryptor pAes = new AesEncryptor(Key);
        string ciphertext = pAes.EncryptString(countent);
    
        pAes.Dispose();
        pAes = null;
    
        return ciphertext;
    }
    
    public static string Decrypt(string ciphertext, string Key)
    {
        AesEncryptor pAes = new AesEncryptor(Key);
        string countent = pAes.DecryptString(ciphertext);
    
        pAes.Dispose();
        pAes = null;
    
        return countent;
    }

    public static string GetMd5Hash(string input)
    {
        MD5 md5Hash = MD5.Create();

        // Convert the input string to a byte array and compute the hash.
        byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

        // Create a new Stringbuilder to collect the bytes
        // and create a string.
        StringBuilder sBuilder = new StringBuilder();

        // Loop through each byte of the hashed data 
        // and format each one as a hexadecimal string.
        for (int i = 0; i < data.Length; i++)
        {
            sBuilder.Append(data[i].ToString("x2"));
        }

        // Return the hexadecimal string.
        return sBuilder.ToString();
    }
    
    public static string GenerateGSLSig(string uuid, long timestamp)
    {
        string key = GSLSignatureHelper.GetSigKey();
        string signatureString = $"{uuid}{timestamp}@{key}";
        string hash = GetMd5Hash(signatureString);
        return hash;
    }
}





