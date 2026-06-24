namespace Sfs2X.Util
{
  public class CryptoKey
  {
    private ByteArray iv;
    private ByteArray key;

    public CryptoKey(ByteArray iv, ByteArray key)
    {
      this.iv = iv;
      this.key = key;
    }

    public ByteArray IV => iv;

    public ByteArray Key => key;
  }
}





