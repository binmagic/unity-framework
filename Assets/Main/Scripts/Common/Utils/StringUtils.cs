using System.Security.Cryptography;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

[Extension.IL2CPP.CompilerServices.Il2CppEagerStaticClassConstructionAttribute]
[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
public static class StringUtils
{
    // 数字变字符串的缓存数组
    static private string[] s_num_string = new string[]{
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
        "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
        "30", "31", "32", "33", "34", "35", "36", "37", "38", "39",
        "40", "41", "42", "43", "44", "45", "46", "47", "48", "49",
        "50", "51", "52", "53", "54", "55", "56", "57", "58", "59",
        "60", "61", "62", "63", "64", "65", "66", "67", "68", "69",
        "70", "71", "72", "73", "74", "75", "76", "77", "78", "79",
        "80", "81", "82", "83", "84", "85", "86", "87", "88", "89",
        "90", "91", "92", "93", "94", "95", "96", "97", "98", "99",
        "100",
    };
    
    static private Dictionary<int, string> intValueToString = new Dictionary<int, string>(1000);
    
    static private string[] s_roman_level = new string[]{
        "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
        "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX",
        "XXI", "XXII", "XXIII", "XXIV", "XXV", "XXVI", "XXVII", "XXVIII", "XXIX", "XXX"
    };
    
    public static bool IsNullOrEmpty(this string str)
    {
        return string.IsNullOrEmpty(str);
    }
    
    public static bool IsInt(this string value)
    {
        return Regex.IsMatch(value, @"^[+-]?\d*$");
    }

    public static string FixNewLine(this string str)
    {
        return str.Replace("\\n", "\n");
    }
    
    // 数字变字符串，缓存版
    public static string IntToString(int variable)
    {
        if (variable >= 0 && variable < s_num_string.Length)
        {
            return s_num_string[variable];
        }

        if (variable == -1)
        {
            return "-1";
        }
        
        if (!intValueToString.TryGetValue(variable, out var result))
        {
            result = variable.ToString();
            if (intValueToString.Count < 4000)
            {
                intValueToString.Add(variable, result);
            }
        }
        return result;
    }
    
    public static string GetMD5(string msg)
    {
        return AESHelper.GetMd5Hash(msg);
        // MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        // byte[] data = System.Text.Encoding.UTF8.GetBytes(msg);
        // byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
        // md5.Clear();
        //
        // string destString = "";
        // for (int i = 0; i < md5Data.Length; i++)
        // {
        //     destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
        // }
        // destString = destString.PadLeft(32, '0');
        // return destString;
    }

    public static string GetFileNameNoExtension(this string path, char separator = '.')
    {
        if (path.IsNullOrEmpty())
        {
            return "";
        }
        return path.Substring(0, path.LastIndexOf(separator));
    }
    public static string GetFileName(this string path, char separator = '/')
    {
        if (path.IsNullOrEmpty())
        {
            return "";
        }
        return path.Substring(path.LastIndexOf(separator) + 1);
    }
    //千位分隔符
    public static string GetFormattedSeperatorNum(int value)
    {
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }
        
        unit = unit + value.ToString("N0");
        return unit;
    }
    public static string GetFormattedSeperatorNum(long value)
    {
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }
        unit = unit + value.ToString("N0");
        return unit;
    }
    public static string GetFormattedSeperatorNum(string value)
    {
        //小数点和百分值不做分隔
        if (value.Contains(".") || value.Contains("%"))
        {
            return value;
        }
        return value.ToLong().ToString("N0");
    }

    public static string GetFormattedInt(int value)
    {
        //string unit = "";
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }
        var kVal = (float)value / 1000f;
        var mVal = (float)value / 1000000f;
        if (mVal >= 1f)
        {
            return unit +mVal.ToString("F1") + "M";
        }
        if (kVal >= 1f)
        {
            return unit + kVal.ToString("F1") + "K";
        }
        return unit + value.ToString("");
    }
     
    public static string GetFormattedLong(long value)
    {
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }
        var kVal = (float)value / 1000f;
        var mVal = (float)value / 1000000f;
        if (mVal >= 1f)
        {
            return unit + mVal.ToString("F1") + "M";
        }
        if (kVal >= 1f)
        {
            return unit + kVal.ToString("F1") + "K";
        }
        return unit + value.ToString("");
    }

    public static string GetFormattedStr(double value)
    {
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }
        var kVal = value / 1000f;
        var mVal = value / 1000000f;
        var gVal = value / 1000000000f;
        if(gVal >= 1f)
        {
            return unit+ gVal.ToString("F1") + "G";
        }
        if (mVal >= 1f)
        {
            return unit+ mVal.ToString("F1") + "M";
        }
        if (kVal >= 1f)
        {
            return unit+ kVal.ToString("F1") + "K";
        }
        return unit+ value.ToString("");
    }

    public static string GetFormattedPercentStr(double value)
    {
        string unit = "";
        if (value < 0)
        {
            value = -value;
            unit = "-";
        }

        return unit + value.ToString("P");
    }
    /// <summary>
    /// 生成随机字符串
    /// </summary>
    /// <param name="_charCount">生成的字符数</param>
    /// <returns></returns>
    private static int rep = 0;
    public static string GenerateRandomStr(int _codeCount)
    {
        string str = string.Empty;
        long num2 = DateTime.Now.Ticks + rep;
        rep++;
        Random random = new Random(((int)(((ulong)num2) & 0xffffffffL)) | ((int)(num2 >> rep)));
        for (int i = 0; i < _codeCount; i++)
        {
            int num = random.Next();
            str = str + ((char)(0x30 + ((ushort)(num % 10)))).ToString();
        }
        return str;
    }

    public static string FormatDBString(string str)
    {
        return "'" + str + "'";
    }

    public static string ConvertToRomanFromInt(int lv)
    {
        if (lv < 1 || lv > 30)
            return "";
        else
            return s_roman_level[lv - 1];

    }

    public static string FormatPassedTime(double passed)
    {
        string strRet = "";
        int secondsPerMinute = 60;
        int secondsPerHour = 3600;
        int secondsPerDay = secondsPerHour * 24;

        int tmp = 0;
        if (passed >= secondsPerDay)
        {
            tmp = (int)(passed / secondsPerDay);
            strRet += tmp.ToString();
            strRet += GameEntry.Localization.GetString("100167"); //day
        }
        else if (passed >= secondsPerHour)
        {
            tmp = (int)(passed / secondsPerHour);
            strRet += tmp.ToString();
            strRet += GameEntry.Localization.GetString("100166"); //hour
        }
        else if (passed >= secondsPerMinute)
        {
            tmp = (int)(passed / secondsPerMinute);
            strRet += tmp.ToString();
            strRet += GameEntry.Localization.GetString("100165"); //minute
        }
        else
        {
            strRet += "1";
            strRet += GameEntry.Localization.GetString("100165"); //minute
        }

        strRet += " ";
        strRet += GameEntry.Localization.GetString("100168"); // ago

        return strRet;
    }

    public static void SplitString(string str, char key, ref List<string> list)
    {
        list = str.Split(key).ToList();
    }

    public static string[] SplitString(string str, char key)
    {
        return str.Split(key);
    }

    public static string GetTimerString(long l)
    {
        return GameEntry.Timer.SecondsToSecondString(l, ":");
    }

    public static string FormatStringMaxLength(string str, int maxLen = 18)
    {
        int strLen = str.Length;
        if (strLen > maxLen)
        {
            return str.Substring(0, maxLen);
        }
        return str;
    }

    /// <summary>
    /// string to section 逗号分段
    /// </summary>
    /// <returns>The s.</returns>
    /// <param name="rawStr">Raw string.</param>
    public static string S2Sec(string rawStr)
    {
        if (rawStr == null || rawStr == "")
            return "";

        if (rawStr.Length <= 3)
            return rawStr;

        string retStr = rawStr;
        int curPos = rawStr.Length;
        while (curPos > 3)
        {
            curPos -= 3;
            retStr = retStr.Insert(curPos, ",");
        }

        return retStr;
    }

    /// <summary>
    /// string to section 逗号分段
    /// </summary>
    /// <returns>The s.</returns>
    /// <param name="rawNum">Raw int.</param>
    public static string S2Sec(int rawNum)
    {
        return S2Sec(rawNum.ToString());
    }

    public static int TryParseInt(string str)
    {
        if (string.IsNullOrEmpty(str))
        {
            return 0;
        }
        else
        {
            int ret = 0;
            int.TryParse(str, out ret);
            return ret;
            // return int.Parse(str);
        }
    }

    public static int GetLengthByChar(this string sourceStr)
    {
        var strLen = Regex.Replace(sourceStr, "[\u4e00-\u9fa5]", "aa", RegexOptions.IgnoreCase).Length;
        return strLen;
    } 

    public static string SubstringEx(this string sourceStr, int len)
    {
        if (sourceStr.IsNullOrEmpty())
        {
            return sourceStr;
        }
        
        var sourceStrCharLen = sourceStr.GetLengthByChar();
        if (sourceStrCharLen <= len)
        {
            return sourceStr;
        }
        
        
        var returnStr = string.Empty;
        var m = Convert.ToInt32(Math.Floor(Convert.ToDouble(len / 2)));
        for (var i = m; i <= sourceStr.Length; i++)
        {
            var s = sourceStr.Substring(0, i);
            var l = s.GetLengthByChar();
            if (l >= len)
            {
                returnStr = s + (l < sourceStrCharLen ? "..." : "");
                break;
            }
        }

        return returnStr;
    } 
    
    // You can use Convert.ToHexString starting with .NET 5.
    // There's also a method for the reverse operation: Convert.FromHexString.
    public static string ByteArrayToString(byte[] ba)
    {
        StringBuilder hex = new StringBuilder(ba.Length * 2);
        foreach (byte b in ba)
        {
            //hex.Append(b.ToString("x2"));
            hex.AppendFormat("{0:x2}", b);
        }

        return hex.ToString();
    }
}





