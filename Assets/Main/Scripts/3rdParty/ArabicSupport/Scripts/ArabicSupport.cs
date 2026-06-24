using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

namespace ArabicSupport
{
    /// <summary>
    /// From https://github.com/Konash/arabic-support-unity/blob/master/Assets/ArabicSupport/Scripts/ArabicSupport.cs
    /// </summary>
    public class ArabicFixer
    {
        private static readonly Dictionary<Regex, Regex> mTagDic = new Dictionary<Regex, Regex>()
        {
            [new Regex(@"\[color[^\]]*\]")] = new Regex(@"\[/color\]"),
            [new Regex(@"\[image[^\]]*\]")] = new Regex(@"\[/image\]"),
            [new Regex(@"\[link[^\]]*\]")] = new Regex(@"\[/link\]"),
        };


        private static readonly ArabicLineFixer sLineFixer = new ArabicLineFixer();

        private static string FixInternal(string str)
        {
            var a = 0;
            var temp = Regex.Replace(str, "[ \\[ \\] \\^ \\-_*×――(^)（^）$%~!@#$…&%￥—+=<>《》!！??？:：•`·、。，；,.;\"‘’“”-]",
                "");
            if (string.IsNullOrEmpty(str)) //  || int.TryParse(temp, out a))
            {
                return str;
            }

            str = ReverseTag(str);
            if (str.Contains("\n"))
                str = str.Replace("\n", Environment.NewLine);

            if (str.Contains(Environment.NewLine))
            {
                string[] stringSeparators = new string[] {Environment.NewLine};
                string[] strSplit = str.Split(stringSeparators, StringSplitOptions.None);

                if (strSplit.Length == 0)
                    return sLineFixer.FixLine(str);
                else if (strSplit.Length == 1)
                    return sLineFixer.FixLine(str);
                else
                {
                    string outputString = sLineFixer.FixLine(strSplit[0]);
                    int iteration = 1;
                    if (strSplit.Length > 1)
                    {
                        while (iteration < strSplit.Length)
                        {
                            outputString += Environment.NewLine + sLineFixer.FixLine(strSplit[iteration]);
                            iteration++;
                        }
                    }

                    return outputString;
                }
            }
            else
            {
                return sLineFixer.FixLine(str);
            }
        }

        public static string ReverseTag(string input)
        {
            StringBuilder builder = new StringBuilder();
            Stack<Match> stack = new Stack<Match>(); // 塞前缀的match
            Queue<KeyValuePair<bool, Match>> queue = new Queue<KeyValuePair<bool, Match>>();
            List<KeyValuePair<bool, Match>> list = new List<KeyValuePair<bool, Match>>();
            foreach (var kv in mTagDic)
            {
                list.Clear();
                queue.Clear();
                stack.Clear();
                var keyMatchs = kv.Key.Matches(input);
                var valueMatchs = kv.Value.Matches(input);
                for (int i = 0; i < keyMatchs.Count; i++) list.Add(new KeyValuePair<bool, Match>(true, keyMatchs[i]));
                for (int i = 0; i < valueMatchs.Count; i++)
                    list.Add(new KeyValuePair<bool, Match>(false, valueMatchs[i]));
                list.Sort((kv1, kv2) => kv1.Value.Index - kv2.Value.Index);
                list.ForEach(o => queue.Enqueue(o));
                // 遍历匹配
                while (queue.Count > 0)
                {
                    var match = queue.Dequeue();
                    if (match.Key) // 前缀入栈
                    {
                        stack.Push(match.Value);
                    }
                    else if (stack.Count > 0) // 后缀的时候，如果有前缀，进行交换
                    {
                        var match1 = stack.Pop();
                        var match2 = match.Value;
                        builder.Clear();
                        builder.Append(input.Substring(0, match1.Index));
                        builder.Append(input.Substring(match2.Index, match2.Length));
                        int startIndex = match1.Index + match1.Length;
                        builder.Append(input.Substring(startIndex, match2.Index - startIndex));
                        builder.Append(input.Substring(match1.Index, match1.Length));
                        builder.Append(input.Substring(match2.Index + match2.Length));
                        input = builder.ToString();
                    }
                }

            }

            return input;
        }

        public static string Fix(string str)
        {
            try
            {
                return FixInternal(str);
            }
            catch (Exception ex)
            {
                Debug.LogError($"ArabicFixer:Fix:{ex}");
            }

            return str;
        }
    }
}





