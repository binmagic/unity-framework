using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace VEngine
{
    /// <summary>
    ///     字符串扩张类，封装了常用的字符串转换函数
    /// </summary>
    public static class StringExtensions
    {
        /// <summary>
        /// </summary>
        /// <param name="s"></param>
        /// <param name="split"></param>
        /// <returns></returns>
        public static int[] IntArrayValue(this string s, string split = ",")
        {
            var items = s.Split(new[]
            {
                split
            }, StringSplitOptions.RemoveEmptyEntries);
            if (items.Length > 0)
            {
                return Array.ConvertAll(items, int.Parse);
            }

            return new int[0];
        }

        /// <summary>
        ///     将输入的字符串 s 转换成 ulong 数值
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static ulong ULongValue(this string s)
        {
            ulong.TryParse(s, out var value);
            return value;
        }

        /// <summary>
        ///     将输入的字符串 s 转换成 int 数值
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static int IntValue(this string s)
        {
            int.TryParse(s, out var value);
            return value;
        }

        /// <summary>
        ///     将输入的字符串 s 转换成 int 数值
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static byte ByteValue(this string s)
        {
            byte.TryParse(s, out var value);
            return value;
        }

        /// <summary>
        ///     将输入的字符串 s 转换成 uint 数值
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static uint UIntValue(this string s)
        {
            uint.TryParse(s, out var value);
            return value;
        }

        /// <summary>
        ///     将制定的 array 转换成用 separator 连接字符串输出
        /// </summary>
        /// <param name="separator"></param>
        /// <param name="array"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public static string Join<T>(string separator, T[] array)
        {
            var value = new string[array.Length];
            for (var index = 0; index < array.Length; index++)
            {
                var a = array[index];
                value[index] = a.ToString();
            }

            return string.Join(separator, value);
        }
        
        //public static 
        public static int[] SplitStringToIntArray(string s)
        {
            Span<int> ints = stackalloc int[8192*4];
            int c = 0;
            foreach (ReadOnlySpan<char> seg in s.SplitSegments('|'))
            {
                int pos = seg.IndexOf('-');
                if (pos < 0)
                {
                    ints[c++] = seg.ToInt();
                }
                else
                {
                    int a = -1;
                    int b = -1;
                    seg.Split_to_ii('-', out a, out b);

                    for (int i = a; i <= b; ++i)
                    {
                        ints[c++] = i;
                    }
                }
            }

            int[] r = new int[c];
            for (int i = 0; i < c; ++i)
            {
                r[i] = ints[i];
            }
            
            return r;
        }
        
        // int[] to string
        public static string IntArrayToString(int[] ar)
        {
            if (ar.Length <= 2)
            {
                return Join("|", ar);
            }
            
            Array.Sort(ar);
            
            var sb = new StringBuilder();

            int prev_i = -1; 
            for (int i = 0; i < ar.Length; ++i)
            {
                if (prev_i == -1)
                {
                    prev_i = i;
                    continue;
                }

                // 表示当前项和上一个没有连着，就把之前的进行字符串pack
                if (ar[i] - ar[i - 1] != 1)
                {
                    if (sb.Length > 0)
                    {
                        sb.Append("|");
                    }

                    if (i - prev_i > 1)
                    {
                        sb.AppendFormat("{0}-{1}", ar[prev_i], ar[i - 1]);
                    }
                    else
                    {
                        sb.AppendFormat("{0}", ar[prev_i]);
                    }

                    prev_i = i;
                }
            }

            if (prev_i != -1)
            {
                int max_i = ar.Length;
                
                if (sb.Length > 0)
                {
                    sb.Append("|");
                }

                if (max_i - prev_i > 1)
                {
                    sb.AppendFormat("{0}-{1}", ar[prev_i], ar[max_i - 1]);
                }
                else
                {
                    sb.AppendFormat("{0}", ar[prev_i]);
                }
            }
            
            string s = sb.ToString();

            int[] ttt = SplitStringToIntArray(s);
            
            bool isEqual = Enumerable.SequenceEqual(ar, ttt);
            if (isEqual)
            {
                int a = 0;
            }
            else
            {
                int b = 0;
            }
            

            return s;
        }
    }
}





