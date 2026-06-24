using System;
using System.Text;

public class AesEncryptor {
    private AES m_pEncryptor;

    public AesEncryptor(byte[] key)
    {
        m_pEncryptor = new AES(key);
    }

    public AesEncryptor(string AESkey)
    {
        byte[] _AESkey = Encoding.Default.GetBytes(AESkey);
        byte[] key = new byte[17];
        int i;
        for (i = 0; i < 16; i++)
        {
            if (i < AESkey.Length)
            {
                key[i] = _AESkey[i];
            }
            else
            {
                key[i] = (byte)'0';
            }
        }
        key[i] = (byte)'\0';

        m_pEncryptor = new AES(key);
    }

    public void Dispose()
    {
        m_pEncryptor = null;
    }

    public string EncryptString(string strInfor)
    {
        int nLength = strInfor.Length;
        int spaceLength = 16 - (nLength % 16);

        byte[] pBuffer = new byte[nLength + spaceLength];
        pBuffer[nLength + spaceLength - 1] = (byte)'\0';
        Array.Copy(Encoding.UTF8.GetBytes(strInfor), pBuffer, nLength);

        m_pEncryptor.Cipher(ref pBuffer);
        string ret = Convert.ToBase64String(pBuffer);

        return ret;
    }

    public string DecryptString(string strMessage)
    {
        int nLength = strMessage.Length / 2;
        byte[] pBuffer = new byte[nLength];
        Hex2Byte(strMessage, strMessage.Length, ref pBuffer);

        m_pEncryptor.InvCipher(ref pBuffer);
        string retBuffer = Encoding.UTF8.GetString(pBuffer);

        return retBuffer;
    }

    public void Byte2Hex(byte[] src, int len, ref string dest)
    {
        for (int i = 0; i < len; ++i)
        {
            dest = dest.Substring(0, i * 2) + string.Format("{0:X2}", src[i]);
        }
    }
    public void Hex2Byte(string src, int len, ref byte[] dest)
    {
        char[] _src = src.ToCharArray();
        int length = len / 2;
        for (int i = 0; i < length; ++i)
        {
            dest[i] = (byte)(Char2Int(_src[i * 2]) * 16 + Char2Int(_src[i * 2 + 1]));
        }
    }

    public int Char2Int(char c)
    {
        if ('0' <= c && c <= '9')
        {
            return (c - '0');
        }
        else if ('a' <= c && c <= 'f')
        {
            return (c - 'a' + 10);
        }
        else if ('A' <= c && c <= 'F')
        {
            return (c - 'A' + 10);
        }
        return -1;
    }

}





