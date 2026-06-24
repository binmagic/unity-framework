using System;
using System.Text;
using Sfs2X.Exceptions;
using Sfs2X.Util;

namespace Sfs2X.Protocol.Serialization
{
  public class DefaultObjectDumpFormatter
  {
    public static readonly char TOKEN_INDENT_OPEN = '{';
    public static readonly char TOKEN_INDENT_CLOSE = '}';
    public static readonly char TOKEN_DIVIDER = ';';
    public static readonly char NEW_LINE = '\n';
    public static readonly char TAB = '\t';
    public static readonly char DOT = '.';
    public static readonly int HEX_BYTES_PER_LINE = 16;
    public static int MAX_DUMP_LENGTH = 1024;

    public static string PrettyPrintDump(string rawDump)
    {
      StringBuilder stringBuilder1 = new StringBuilder();
      int howMany = 0;
      for (int index = 0; index < rawDump.Length; ++index)
      {
        char ch = rawDump[index];
        char newLine;
        if (ch == TOKEN_INDENT_OPEN)
        {
          ++howMany;
          StringBuilder stringBuilder2 = stringBuilder1;
          newLine = NEW_LINE;
          string str = newLine + GetFormatTabs(howMany);
          stringBuilder2.Append(str);
        }
        else if (ch == TOKEN_INDENT_CLOSE)
        {
          --howMany;
          if (howMany < 0)
            throw new SFSError("DumpFormatter: the indentPos is negative. TOKENS ARE NOT BALANCED!");
          StringBuilder stringBuilder2 = stringBuilder1;
          newLine = NEW_LINE;
          string str = newLine + GetFormatTabs(howMany);
          stringBuilder2.Append(str);
        }
        else if (ch == TOKEN_DIVIDER)
        {
          StringBuilder stringBuilder2 = stringBuilder1;
          newLine = NEW_LINE;
          string str = newLine + GetFormatTabs(howMany);
          stringBuilder2.Append(str);
        }
        else
          stringBuilder1.Append(ch);
      }
      if ((uint) howMany > 0U)
        throw new SFSError("DumpFormatter: the indentPos is not == 0. TOKENS ARE NOT BALANCED!");
      return stringBuilder1.ToString();
    }

    private static string GetFormatTabs(int howMany)
    {
      return StrFill(TAB, howMany);
    }

    private static string StrFill(char ch, int howMany)
    {
      StringBuilder stringBuilder = new StringBuilder();
      for (int index = 0; index < howMany; ++index)
        stringBuilder.Append(ch);
      return stringBuilder.ToString();
    }

    public static string HexDump(ByteArray ba)
    {
      return HexDump(ba, HEX_BYTES_PER_LINE);
    }

    public static string HexDump(ByteArray ba, int bytesPerLine)
    {
      StringBuilder stringBuilder1 = new StringBuilder();
      stringBuilder1.Append("Binary Size: " + ba.DataLength + NEW_LINE);
      if (ba.DataLength > MAX_DUMP_LENGTH)
      {
        stringBuilder1.Append("** Data larger than max dump size of " + MAX_DUMP_LENGTH + ". Data not displayed");
        return stringBuilder1.ToString();
      }
      StringBuilder stringBuilder2 = new StringBuilder();
      StringBuilder stringBuilder3 = new StringBuilder();
      int index1 = 0;
      int num1 = 0;
      do
      {
        //byte num2 = ba.Bytes[index1];
        byte num2 = ba.GetByte(index1);
        string str1 = string.Format("{0:x2}", num2);
        if (str1.Length == 1)
          str1 = "0" + str1;
        stringBuilder2.Append(str1 + " ");
        char ch1 = num2 < (byte) 33 || num2 > (byte) 126 ? DOT : Convert.ToChar(num2);
        stringBuilder3.Append(ch1);
        if (++num1 == bytesPerLine)
        {
          num1 = 0;
          StringBuilder stringBuilder4 = stringBuilder1;
          string str2 = stringBuilder2.ToString();
          char ch2 = TAB;
          string str3 = ch2.ToString();
          string str4 = stringBuilder3.ToString();
          ch2 = NEW_LINE;
          string str5 = ch2.ToString();
          string str6 = str2 + str3 + str4 + str5;
          stringBuilder4.Append(str6);
          stringBuilder2 = new StringBuilder();
          stringBuilder3 = new StringBuilder();
        }
      }
      while (++index1 < ba.DataLength);
      if ((uint) num1 > 0U)
      {
        for (int index2 = bytesPerLine - num1; index2 > 0; --index2)
        {
          stringBuilder2.Append("   ");
          stringBuilder3.Append(" ");
        }
        stringBuilder1.Append(stringBuilder2 + TAB.ToString() + stringBuilder3 + NEW_LINE);
      }
      return stringBuilder1.ToString();
    }
  }
}





