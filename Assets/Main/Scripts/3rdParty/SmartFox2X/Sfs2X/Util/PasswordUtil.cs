using System.Security.Cryptography;
using System.Text;

namespace Sfs2X.Util
{
  public class PasswordUtil
  {
    public static string MD5Password(string pass)
    {
      StringBuilder stringBuilder = new StringBuilder(string.Empty);
      foreach (byte num in new MD5CryptoServiceProvider().ComputeHash(Encoding.Default.GetBytes(pass)))
        stringBuilder.Append(num.ToString("x2"));
      return stringBuilder.ToString();
    }
  }
}





