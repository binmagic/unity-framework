using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using GameFramework;

// 一些字符串的扩展放到这里
// 主要目的是减少GC
/////////////////////////////////////////////////////////////////////
// 一些说明：在C#中，直接操作内存是不允许的，同时字符串是不可变的
// 从设计角度看，不操作内存也就意味着程序更加稳定，是没有问题的。
// 但是这样就会导致我们在处理文本数据的时候可能会产生大量的临时字符串，也就是GC
// C#在后续的版本中，提供了Span这种可以间接操作内存的方法，当然也会有很多限制。
// Unity本身是不支持Span的（因为其用的.Net版本较老），这里我通过NuGet引入了System.Memory.dll
// 使其支持了Span。同时提供了一些常用的0-GC接口。
// 目前C#的文献中，基本上优化相关的都会提到Span和MemoryPool。也见Span的重要性。
// 关于GC的优化，C#已经更新了GC算法，而Unity因为版权和il2cpp等原因，一直还在用古老的GC算法（Boehm–Demers–Weiser）
// 这个GC算法性能会有一些问题。所以在目前的Unity中（2020也没有更新GC算法），所以GC的优化还是有一些意义的。

[Unity.IL2CPP.CompilerServices.Il2CppSetOption(Unity.IL2CPP.CompilerServices.Option.NullChecks, false)]
[UnityEngine.Scripting.Preserve]
public static class StringExtensions
{
    public static int IndexOfAny_NewLine(this ReadOnlySpan<char> value)
    {
        for (int i = 0; i < value.Length; i++)
        {
            char c = value[i];

            if (c == '\r' || c == '\n')
            {
                return i;
            }
        }

        return -1;
    }
    
    // 从字符串中获取行
    public static LineSplitEnumerator SplitLines(this string str)
    {
        //因为 LineSplitEnumerator 是值类型，所以这里没有在堆上创建对象
        return new LineSplitEnumerator(str.AsSpan());
    }
    
    public static LineSplitEnumerator SplitLines(this ReadOnlySpan<char> str)
    {
        //因为 LineSplitEnumerator 是值类型，所以这里没有在堆上创建对象
        return new LineSplitEnumerator(str);
    }
    
    // 分段处理，主要用来处理a|b|c|d这种，通过foreach来遍历
    public static SegmentSplitEnumerator SplitSegments(this string str, char segment)
    {
        return new SegmentSplitEnumerator(str.AsSpan(), segment);
    }

    public static SegmentSplitEnumerator SplitSegments(this ReadOnlySpan<char> strSpan, char segment, bool removeEmpty = false)
    {
        return new SegmentSplitEnumerator(strSpan, segment);
    }
    
    // 从文本文件中获取行
    public static StreamSplitEnumerator SplitLines(this StreamReader sr)
    {
        char[] buffer = new char[4096];
        return new StreamSplitEnumerator(sr, buffer);
    }
    
    public static StreamSplitEnumerator SplitLines(this StreamReader sr, char[] contentBuffer)
    {
        return new StreamSplitEnumerator(sr, contentBuffer);
    }

    //必须是一个 ref 结构并且包含字段 ReadOnlySpan<char>
    public ref struct LineSplitEnumerator
    {
        private ReadOnlySpan<char> _str;

        public LineSplitEnumerator(ReadOnlySpan<char> str)
        {
            _str = str;
            Current = default;
        }

        //需要和 foreach 运算符兼容的方法
        public LineSplitEnumerator GetEnumerator() => this;

        public bool MoveNext()
        {
            var span = _str;
            if (span.Length == 0) // 已经达到字符串的末端
                return false;

            var index = span.IndexOfAny('\r', '\n');
            if (index == -1) // 这个字符串仅包含一行
            {
                _str = ReadOnlySpan<char>.Empty; // 剩下的字符串是空的
                Current = new LineSplitEntry(span, ReadOnlySpan<char>.Empty);
                return true;
            }

            if (index < span.Length - 1 && span[index] == '\r')
            {
                // 尝试处理当 \n 紧跟着 \r 的情况
                var next = span[index + 1];
                if (next == '\n')
                {
                    Current = new LineSplitEntry(span.Slice(0, index), span.Slice(index, 2));
                    _str = span.Slice(index + 2);
                    return true;
                }
            }

            Current = new LineSplitEntry(span.Slice(0, index), span.Slice(index, 1));
            _str = span.Slice(index + 1);
            return true;
        }

        public LineSplitEntry Current { get; private set; }
    }

    public readonly ref struct LineSplitEntry
    {
        public LineSplitEntry(ReadOnlySpan<char> line, ReadOnlySpan<char> separator)
        {
            Line = line;
            Separator = separator;
        }

        public ReadOnlySpan<char> Line { get; }
        public ReadOnlySpan<char> Separator { get; }

        // This method allow to deconstruct the type, so you can write any of the following code
        // foreach (var entry in str.SplitLines()) { _ = entry.Line; }
        // foreach (var (line, endOfLine) in str.SplitLines()) { _ = line; }
        // https://docs.microsoft.com/en-us/dotnet/csharp/deconstruct#deconstructing-user-defined-types
        public void Deconstruct(out ReadOnlySpan<char> line, out ReadOnlySpan<char> separator)
        {
            line = Line;
            separator = Separator;
        }

        // This method allow to implicitly cast the type into a ReadOnlySpan<char>, so you can write the following code
        // foreach (ReadOnlySpan<char> entry in str.SplitLines())
        public static implicit operator ReadOnlySpan<char>(LineSplitEntry entry) => entry.Line;
    }

    //必须是一个 ref 结构并且包含字段 ReadOnlySpan<char>
    public ref struct SegmentSplitEnumerator
    {
        private ReadOnlySpan<char> _str;
        char _seg;
        bool ShouldRemoveEmptyEntries;

        public SegmentSplitEnumerator(ReadOnlySpan<char> str, char segment, bool removeEmpty = false)
        {
            _str = str;
            _seg = segment;
            ShouldRemoveEmptyEntries = removeEmpty;
            Current = default;
        }

        //需要和 foreach 运算符兼容的方法
        public SegmentSplitEnumerator GetEnumerator() => this;

        // 参考代码
        // https://github.com/bbartels/coreclr/blob/master/src/System.Private.CoreLib/shared/System/MemoryExtensions.Split.cs
        public bool MoveNext()
        {
            var span = _str;
            if (span.Length == 0) // 已经达到字符串的末端
                return false;

            do
            {
                int index = span.IndexOf(_seg);
                if (index < 0)
                {
                    _str = ReadOnlySpan<char>.Empty; 
                    Current = new LineSplitEntry(span, ReadOnlySpan<char>.Empty);

                    // 剩下的字符串是空的，就直接返回false，这段就不算了
                    // 否则返回true，这段也返给用户
                    return !(ShouldRemoveEmptyEntries && Current.Line.IsEmpty);
                }

                Current = new LineSplitEntry(span.Slice(0, index), span.Slice(index, 1));
                _str = span.Slice(index + 1);

                // 如果设置了跳过空，那么如果本段是空，那么就跳过
            } while (Current.Line.IsEmpty && ShouldRemoveEmptyEntries);

            return true;
        }

        public LineSplitEntry Current { get; private set; }
    }
    
    // 文件流的行分割器，读取文件用
    public ref struct StreamSplitEnumerator
    {
        private StreamReader _sr;
        private char[] _buffer;
        private ReadOnlySpan<char> _str;    // 指向有效的char[]数组位置

        public StreamSplitEnumerator(StreamReader sr, char[] contentBuffer)
        {
            _sr = sr;
            _buffer = contentBuffer;
            _str = new ReadOnlySpan<char>(_buffer, 0, 0);
            Current = default;
        }

        //需要和 foreach 运算符兼容的方法
        public StreamSplitEnumerator GetEnumerator() => this;

        public bool MoveNext()
        {
            var span = _str;
            var index = span.IndexOfAny('\r', '\n');
            if (index == -1) // 此时需要读取文件
            {
                if (prepareBuffer() == false)
                {
                    return false;
                }

                span = _str;
                index = span.IndexOfAny('\r', '\n');
                if (index == -1)
                {
                    _str = ReadOnlySpan<char>.Empty; // 剩下的字符串是空的
                    Current = new LineSplitEntry(span, ReadOnlySpan<char>.Empty);
                    return true;
                }
            }

            if (index < span.Length - 1 && span[index] == '\r')
            {
                // 尝试处理当 \n 紧跟着 \r 的情况
                var next = span[index + 1];
                if (next == '\n')
                {
                    Current = new LineSplitEntry(span.Slice(0, index), span.Slice(index, 2));
                    _str = span.Slice(index + 2);
                    return true;
                }
            }

            Current = new LineSplitEntry(span.Slice(0, index), span.Slice(index, 1));
            _str = span.Slice(index + 1);
            
            return true;
        }

        // 每次准备一个缓冲
        private bool prepareBuffer()
        {
            if (_sr.EndOfStream)
            {
                return false;
            }

            int remain_length = 0;
            if (!_str.IsEmpty)
            {
                remain_length = _str.Length;
                int copyOffset = _buffer.Length - remain_length;
                if (copyOffset < 0)
                {
                    Log.Error("Line to long or buffer to small!!!!");
                    return false;
                }
                
                Array.Copy(_buffer, copyOffset, _buffer, 0, remain_length);
                
                // 把剩余的一点缓冲copy到buffer中，注意，如果某行特别长的话，这样处理会有问题
                // 但是这种情况我们暂时先不考虑
                if (remain_length >= _buffer.Length / 2)
                {
                    Log.Error("Line to long or buffer to small 2!!!");
                }
            }
            
            int read = _sr.ReadBlock(_buffer, remain_length, _buffer.Length - remain_length);
            
            // 剩余内存清空
            int this_length = read + remain_length;
            if (this_length < _buffer.Length)
            {
                Array.Clear(_buffer, this_length, _buffer.Length - this_length);
            }
            
            _str = new ReadOnlySpan<char>(_buffer, 0, this_length);

            if (read + remain_length > _buffer.Length)
            {
                Log.Error("out of buffer !!!");
            }

            return true;
        }

        public LineSplitEntry Current { get; private set; }
    }

    // 字符串切成2段
    // str = 要切的字符串
    public static bool Split_to_spanspan(this string str, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2)
    {
        ReadOnlySpan<char> span = str.AsSpan();
        return span.Split_to_spanspan(ch, out span1, out span2);
    }
    
    // str = 要切的字符串
    public static bool Split_to_spanspan(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2)
    {
        if (span.IsEmpty)
        {
            span1 = ReadOnlySpan<char>.Empty;
            span2 = ReadOnlySpan<char>.Empty;
            return false;
        }
        
        // 直接切割字符
        int indexOfFirst = span.IndexOf(ch);
        if (indexOfFirst < 0)
        {
            span1 = span;
            span2 = ReadOnlySpan<char>.Empty;
            return false;
        }

        // 通过分片来进行
        span1 = span.Slice(0, indexOfFirst);
        span2 = span.Slice(indexOfFirst + 1);

        return true;
    }
    
    public static bool Split_to_spans(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2, out ReadOnlySpan<char> span3)
    {
        bool ret;
        ReadOnlySpan<char> remain;
        Split_to_spanspan(span, ch, out span1, out remain);
        ret = Split_to_spanspan(remain, ch, out span2, out span3);

        return ret;
    }

    public static bool Split_to_spans(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2, out ReadOnlySpan<char> span3, out ReadOnlySpan<char> span4)
    {
        bool ret;
        ReadOnlySpan<char> remain;
        Split_to_spanspan(span, ch, out span1, out remain);
        Split_to_spanspan(remain, ch, out span2, out remain);
        ret = Split_to_spanspan(remain, ch, out span3, out span4);

        return ret;
    }

    public static bool Split_to_spans(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2, out ReadOnlySpan<char> span3, out ReadOnlySpan<char> span4, out ReadOnlySpan<char> span5)
    {
        bool ret;
        ReadOnlySpan<char> remain;
        Split_to_spanspan(span, ch, out span1, out remain);
        Split_to_spanspan(remain, ch, out span2, out remain);
        Split_to_spanspan(remain, ch, out span3, out remain);
        ret = Split_to_spanspan(remain, ch, out span4, out span5);

        return ret;
    }
    
    public static bool Split_to_spans(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2, out ReadOnlySpan<char> span3, out ReadOnlySpan<char> span4, out ReadOnlySpan<char> span5, out ReadOnlySpan<char> span6)
    {
        bool ret;
        ReadOnlySpan<char> remain;
        Split_to_spanspan(span, ch, out span1, out remain);
        Split_to_spanspan(remain, ch, out span2, out remain);
        Split_to_spanspan(remain, ch, out span3, out remain);
        Split_to_spanspan(remain, ch, out span4, out remain);
        ret = Split_to_spanspan(remain, ch, out span5, out span6);

        return ret;
    }

    public static bool Split_to_spans(this ReadOnlySpan<char> span, char ch, out ReadOnlySpan<char> span1, out ReadOnlySpan<char> span2, out ReadOnlySpan<char> span3, out ReadOnlySpan<char> span4, out ReadOnlySpan<char> span5, out ReadOnlySpan<char> span6, out ReadOnlySpan<char> span7)
    {
        bool ret;
        ReadOnlySpan<char> remain;
        Split_to_spanspan(span, ch, out span1, out remain);
        Split_to_spanspan(remain, ch, out span2, out remain);
        Split_to_spanspan(remain, ch, out span3, out remain);
        Split_to_spanspan(remain, ch, out span4, out remain);
        Split_to_spanspan(remain, ch, out span5, out remain);
        ret = Split_to_spanspan(remain, ch, out span6, out span7);
        
        return ret;
    }
    
    // 字符串切成2段整数
    // str = 要切的字符串
    public static bool Split_to_ii(this string str, char ch, out int k, out int v)
    {
        ReadOnlySpan<char> span = str.AsSpan();
        return span.Split_to_ii(ch, out k, out v);
    }

    // 字符串切成2段整数
    // str = 要切的字符串
    public static bool Split_to_ii(this ReadOnlySpan<char> span, char ch, out int k, out int v)
    {
        // 直接切割字符
        int indexOfFirst = span.IndexOf(ch);
        if (indexOfFirst < 0)
        {
            k = span.ToInt();
            v = 0;
            return false;
        }

        // 通过分片来进行
        k = span.Slice(0, indexOfFirst).ToInt();
        v = span.Slice(indexOfFirst + 1).ToInt();

        return true;
    }

    // 系统没提供带偏移值得IndexOf，这里自己提供一个
    public static int IndexOf(this ReadOnlySpan<char> span, char value, int startIndex)
    {
        if (startIndex <= 0)
        {
            return span.IndexOf(value);
        }
        
        // 先切片再查找
        ReadOnlySpan<char> BeginSpan = span.Slice(startIndex);
        int pos = BeginSpan.IndexOf(value);
        if (pos < 0)
        {
            return pos;
        }

        return startIndex + pos;
    }
    
    // 将span解析成int[]
    // 一般情况下，removeEmpty都需要设置为true；否则出现空字符串的话将用defInt=0填充。
    // 注意：末尾多个分隔符的话不会影响结果；譬如"1,2,3"和"1,2,3,"解析出来结果一样
    public static int[] Split_to_IntArray(this ReadOnlySpan<char> str, char ch, bool removeEmpty = true, int defInt = 0)
    {
        try
        {
            // 最大支持8192个分段，为什么会有需求超过这个最大值？？
            Span<int> ints = stackalloc int[8192];
            int c = 0;

            int begin_pos = 0;

            do
            {
                int index = str.IndexOf(ch, begin_pos);
                if (index < 0)
                {
                    // 到结尾了
                    // Log.Error("found end!");
                    index = str.Length;
                }

                ReadOnlySpan<char> temp = str.Slice(begin_pos, index - begin_pos);
                temp.Trim();

                // string s = temp.ToString();
                // Log.Error("s = {0}", s);

                if (!temp.IsEmpty)
                {
                    ints[c++] = temp.ToInt();
                }
                else if (removeEmpty == false)
                {
                    ints[c++] = defInt;
                }
                
                // 判断一下防止越界
                if (c >= 8192)
                {
#if UNITY_EDITOR
                    Log.Error("max count for Split_to_IntArray!!!!!");
#endif
                    break;
                }
                

                begin_pos = index + 1;
            } while (begin_pos < str.Length);

            // Log.Error("split ok!");

            int[] r = new int[c];
            for (int i = 0; i < c; ++i)
            {
                r[i] = ints[i];
            }

            return r;
        }
        catch(System.Exception e) 
        {
            // 如果解析失败了，使用老的解析方法
#if UNITY_EDITOR
            Log.Error("SUPER big bug!!! Split_to_IntArray exception!!!!!!");
#endif
            var items = str.ToString().Split(new[] {ch}, StringSplitOptions.RemoveEmptyEntries);
            if (items.Length > 0)
            {
                return Array.ConvertAll(items, int.Parse);
            }
        }
        
        return new int[0];
    }
    
    
    // 同样是切分字符串，支持1-2|3-4这样
    public static int[] Split_to_IntArrayEx(this ReadOnlySpan<char> str, char ch, bool removeEmpty = true, int defInt = 0)
    {
        try
        {
            Span<int> ints = stackalloc int[8192*4];
            int c = 0;
            
            foreach (ReadOnlySpan<char> seg in str.SplitSegments('|'))
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
                    if (seg.Split_to_ii('-', out a, out b))
                    {
                        for (int i = a; i <= b; ++i)
                        {
                            ints[c++] = i;
                        }
                    }
                    else
                    {
#if UNITY_EDITOR
                        Log.Error("Split_to_IntArrayEx string format error!!!!!!");
#endif
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
        catch(System.Exception e) 
        {
            // 如果解析失败了，使用老的解析方法
#if UNITY_EDITOR
            Log.Error("SUPER big bug!!! Split_to_IntArrayEx exception!!!!!!");
#endif
            var items = str.ToString().Split(new[] {ch}, StringSplitOptions.RemoveEmptyEntries);
            if (items.Length > 0)
            {
                return Array.ConvertAll(items, int.Parse);
            }
        }
        
        return new int[0];
    }
}


// https://stackoverflow.com/questions/6771917/why-cant-i-preallocate-a-hashsett
public static class HashSetExtensions
{
    private static class HashSetDelegateHolder<T>
    {
        private const BindingFlags Flags = BindingFlags.Instance | BindingFlags.NonPublic;
        public static MethodInfo InitializeMethod { get; } = typeof(HashSet<T>).GetMethod("Initialize", Flags);
    }

    public static void SetCapacity<T>(this HashSet<T> hs, int capacity)
    {
        HashSetDelegateHolder<T>.InitializeMethod.Invoke(hs, new object[] { capacity });
    }

    public static HashSet<T> GetHashSet<T>(int capacity)
    {
        var hashSet = new HashSet<T>();
        hashSet.SetCapacity(capacity);
        return hashSet;
    }
}





