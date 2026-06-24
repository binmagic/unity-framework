using System.Text;

namespace Sfs2X.Core
{
  public struct PacketHeader
  {
    private int expectedLength;
    private bool binary;
    private bool compressed;
    private bool encrypted;
    private bool bigSized;

    public int ExpectedLength
    {
      get => expectedLength;
      set => expectedLength = value;
    }

    public bool Encrypted
    {
      get => encrypted;
      set => encrypted = value;
    }

    public bool Compressed
    {
      get => compressed;
      set => compressed = value;
    }

    public bool Binary
    {
      get => binary;
      set => binary = value;
    }

    public bool BigSized
    {
      get => bigSized;
      set => bigSized = value;
    }

    public PacketHeader(bool encrypted, bool compressed, bool bigSized)
    {
      this.compressed = compressed;
      binary = true;
      expectedLength = -1;
      this.encrypted = encrypted;
      this.bigSized = bigSized;
    }

    public static PacketHeader FromBinary(int headerByte)
    {
      return new PacketHeader((headerByte & 64) > 0, (headerByte & 32) > 0, (headerByte & 8) > 0);
    }

    public byte Encode()
    {
      byte num = 0;
      if (binary)
        num |= 128;
      if (Encrypted)
        num |= 64;
      if (Compressed)
        num |= 32;
      if (bigSized)
        num |= 8;
      return num;
    }

    public override string ToString()
    {
      StringBuilder stringBuilder = new StringBuilder();
      stringBuilder.Append("---------------------------------------------\n");
      stringBuilder.Append("Binary:  \t" + binary + "\n");
      stringBuilder.Append("Compressed:\t" + compressed + "\n");
      stringBuilder.Append("Encrypted:\t" + encrypted + "\n");
      stringBuilder.Append("BigSized:\t" + bigSized + "\n");
      stringBuilder.Append("---------------------------------------------\n");
      return stringBuilder.ToString();
    }
  }
}





