using System;
using System.IO;
using System.Security.Cryptography;
using Sfs2X.Bitswarm;
using Sfs2X.Util;
/*
namespace Sfs2X.Core
{
  public class DefaultPacketEncrypter : IPacketEncrypter
  {
    private BitSwarmClient bitSwarm;

    public DefaultPacketEncrypter(BitSwarmClient bitSwarm)
    {
      this.bitSwarm = bitSwarm;
    }

    public void Encrypt(ByteArray data)
    {
      CryptoKey cryptoKey = bitSwarm.CryptoKey;
      byte[] array;
      int dataLen;
      using (RijndaelManaged rijndaelManaged = new RijndaelManaged())
      {
        rijndaelManaged.Key = cryptoKey.Key.GetBytes();
        rijndaelManaged.IV = cryptoKey.IV.GetBytes();
        ICryptoTransform encryptor = rijndaelManaged.CreateEncryptor(rijndaelManaged.Key, rijndaelManaged.IV);
        using (MemoryStream memoryStream = new MemoryStream())
        {
          using (CryptoStream cryptoStream = new CryptoStream(memoryStream, encryptor, CryptoStreamMode.Write))
          {
            cryptoStream.Write(data.GetRawBytes(), 0, data.DataLength);
            cryptoStream.FlushFinalBlock();
          }

          array = memoryStream.ToArray();
          dataLen = array.Length;
        }
      }

      data.WriteBytes(array, 0, dataLen);
    }

    public void Decrypt(ByteArray data)
    {
      CryptoKey cryptoKey = bitSwarm.CryptoKey;
      byte[] array;
      int dataLen;
      using (RijndaelManaged rijndaelManaged = new RijndaelManaged())
      {
        rijndaelManaged.Key = cryptoKey.Key.GetBytes();
        rijndaelManaged.IV = cryptoKey.IV.GetBytes();
        ICryptoTransform decryptor = rijndaelManaged.CreateDecryptor(rijndaelManaged.Key, rijndaelManaged.IV);
        using (MemoryStream memoryStream = new MemoryStream())
        {
          using (CryptoStream cryptoStream = new CryptoStream(memoryStream, decryptor, CryptoStreamMode.Write))
          {
            cryptoStream.Write(data.GetRawBytes(), 0, data.DataLength);
            cryptoStream.FlushFinalBlock();
          }
          
          array = memoryStream.ToArray();
          dataLen = array.Length;
        }
      }
      
      data.WriteBytes(array, 0, dataLen);
    }
  }
}
*/





