using System.Collections.Generic;
using System.Globalization;
using System.Text;

// STG 编辑器专用的极简 JSON 读写实现，不依赖 LitJson。
//
// 起因：Assembly-CSharp-Editor 同时能看到两份 LitJson.JsonType（源码版 Assets/Main/Scripts/3rdParty/LitJson
// 编译进 Assembly-CSharp，微信小游戏插件又带了一份 LitJson.dll），导致 CS0433 类型歧义（错误信息：
// "The type 'JsonType' exists in both 'Assembly-CSharp' and 'LitJson'"）。extern alias 能解决这类歧义，
// 但需要修改 Unity 自动生成的 .csproj（每次项目同步会被重新生成，改动无法持久化），不是稳妥方案；
// 修改微信插件 DLL 的平台导入设置属于全项目共享配置，影响范围超出 STG 编辑器工具本身，风险过高。
// 因此 STG 编辑器工具改为自带一个不进入 LitJson 命名空间的极简 JSON 实现，只覆盖本工具实际用到的
// 能力子集：对象/数组/字符串/数字(int/double)/布尔的读写、序列化为紧凑 JSON 文本、从文本解析。
//
// 这是对《STG 关卡编辑器设计.md》"C# 侧沿用 LitJson"表述的一处偏离，该文档已同步更新说明本偏离原因。
public class StgJsonValue
{
    public enum Kind { Null, Object, Array, String, Int, Double, Boolean }

    public Kind ValueKind { get; private set; } = Kind.Null;

    Dictionary<string, StgJsonValue> m_Object;
    List<string> m_Keys; // 保持插入顺序，避免每次导出字段顺序漂移
    List<StgJsonValue> m_Array;
    string m_String;
    int m_Int;
    double m_Double;
    bool m_Bool;

    public bool IsArray => ValueKind == Kind.Array;
    public bool IsObject => ValueKind == Kind.Object;
    public bool IsInt => ValueKind == Kind.Int;
    public bool IsDouble => ValueKind == Kind.Double;
    public bool IsString => ValueKind == Kind.String;
    public bool IsBoolean => ValueKind == Kind.Boolean;

    public static StgJsonValue NewObject()
    {
        var v = new StgJsonValue { ValueKind = Kind.Object, m_Object = new Dictionary<string, StgJsonValue>(), m_Keys = new List<string>() };
        return v;
    }

    public static StgJsonValue NewArray()
    {
        return new StgJsonValue { ValueKind = Kind.Array, m_Array = new List<StgJsonValue>() };
    }

    // ---------- 隐式转换：标量赋值直接写 j["key"] = 5 / "abc" / true / 1.5f ----------

    public static implicit operator StgJsonValue(string v) => v == null ? new StgJsonValue() : new StgJsonValue { ValueKind = Kind.String, m_String = v };
    public static implicit operator StgJsonValue(int v) => new StgJsonValue { ValueKind = Kind.Int, m_Int = v };
    public static implicit operator StgJsonValue(float v) => new StgJsonValue { ValueKind = Kind.Double, m_Double = v };
    public static implicit operator StgJsonValue(double v) => new StgJsonValue { ValueKind = Kind.Double, m_Double = v };
    public static implicit operator StgJsonValue(bool v) => new StgJsonValue { ValueKind = Kind.Boolean, m_Bool = v };

    public static explicit operator int(StgJsonValue v) => v.ValueKind == Kind.Int ? v.m_Int : (int)v.m_Double;
    public static explicit operator double(StgJsonValue v) => v.ValueKind == Kind.Double ? v.m_Double : v.m_Int;
    public static explicit operator float(StgJsonValue v) => (float)(double)v;
    public static explicit operator bool(StgJsonValue v) => v.m_Bool;
    public static explicit operator string(StgJsonValue v) => v?.ValueKind == Kind.String ? v.m_String : null;

    // ---------- 对象字段索引器 ----------

    public StgJsonValue this[string key]
    {
        get
        {
            EnsureObject();
            return m_Object.TryGetValue(key, out var v) ? v : null;
        }
        set
        {
            EnsureObject();
            if (!m_Object.ContainsKey(key)) m_Keys.Add(key);
            m_Object[key] = value ?? new StgJsonValue();
        }
    }

    public bool ContainsKey(string key)
    {
        return ValueKind == Kind.Object && m_Object.ContainsKey(key);
    }

    void EnsureObject()
    {
        if (ValueKind == Kind.Null)
        {
            ValueKind = Kind.Object;
            m_Object = new Dictionary<string, StgJsonValue>();
            m_Keys = new List<string>();
        }
    }

    // ---------- 数组 ----------

    public int Count => ValueKind == Kind.Array ? m_Array.Count : 0;

    public StgJsonValue this[int index]
    {
        get => m_Array[index];
        set => m_Array[index] = value;
    }

    public void Add(StgJsonValue item)
    {
        EnsureArray();
        m_Array.Add(item ?? new StgJsonValue());
    }

    void EnsureArray()
    {
        if (ValueKind == Kind.Null)
        {
            ValueKind = Kind.Array;
            m_Array = new List<StgJsonValue>();
        }
    }

    // ---------- 序列化 ----------

    public string ToJsonString()
    {
        var sb = new StringBuilder();
        Write(sb);
        return sb.ToString();
    }

    void Write(StringBuilder sb)
    {
        switch (ValueKind)
        {
            case Kind.Null:
                sb.Append("null");
                break;
            case Kind.Object:
                sb.Append('{');
                for (int i = 0; i < m_Keys.Count; i++)
                {
                    if (i > 0) sb.Append(',');
                    WriteString(sb, m_Keys[i]);
                    sb.Append(':');
                    m_Object[m_Keys[i]].Write(sb);
                }
                sb.Append('}');
                break;
            case Kind.Array:
                sb.Append('[');
                for (int i = 0; i < m_Array.Count; i++)
                {
                    if (i > 0) sb.Append(',');
                    m_Array[i].Write(sb);
                }
                sb.Append(']');
                break;
            case Kind.String:
                WriteString(sb, m_String);
                break;
            case Kind.Int:
                sb.Append(m_Int.ToString(CultureInfo.InvariantCulture));
                break;
            case Kind.Double:
                sb.Append(m_Double.ToString("R", CultureInfo.InvariantCulture));
                break;
            case Kind.Boolean:
                sb.Append(m_Bool ? "true" : "false");
                break;
        }
    }

    static void WriteString(StringBuilder sb, string s)
    {
        sb.Append('"');
        if (s != null)
        {
            foreach (char c in s)
            {
                switch (c)
                {
                    case '"': sb.Append("\\\""); break;
                    case '\\': sb.Append("\\\\"); break;
                    case '\n': sb.Append("\\n"); break;
                    case '\r': sb.Append("\\r"); break;
                    case '\t': sb.Append("\\t"); break;
                    default:
                        if (c < 0x20) sb.Append("\\u").Append(((int)c).ToString("x4"));
                        else sb.Append(c);
                        break;
                }
            }
        }
        sb.Append('"');
    }

    // ---------- 解析 ----------

    public static StgJsonValue Parse(string text)
    {
        int pos = 0;
        SkipWhitespace(text, ref pos);
        var value = ParseValue(text, ref pos);
        return value;
    }

    static StgJsonValue ParseValue(string text, ref int pos)
    {
        SkipWhitespace(text, ref pos);
        char c = text[pos];
        switch (c)
        {
            case '{': return ParseObject(text, ref pos);
            case '[': return ParseArray(text, ref pos);
            case '"': return new StgJsonValue { ValueKind = Kind.String, m_String = ParseString(text, ref pos) };
            case 't':
                pos += 4; // true
                return new StgJsonValue { ValueKind = Kind.Boolean, m_Bool = true };
            case 'f':
                pos += 5; // false
                return new StgJsonValue { ValueKind = Kind.Boolean, m_Bool = false };
            case 'n':
                pos += 4; // null
                return new StgJsonValue { ValueKind = Kind.Null };
            default:
                return ParseNumber(text, ref pos);
        }
    }

    static StgJsonValue ParseObject(string text, ref int pos)
    {
        var result = NewObject();
        pos++; // {
        SkipWhitespace(text, ref pos);
        if (text[pos] == '}') { pos++; return result; }

        while (true)
        {
            SkipWhitespace(text, ref pos);
            string key = ParseString(text, ref pos);
            SkipWhitespace(text, ref pos);
            pos++; // :
            var value = ParseValue(text, ref pos);
            result[key] = value;
            SkipWhitespace(text, ref pos);
            if (text[pos] == ',') { pos++; continue; }
            if (text[pos] == '}') { pos++; break; }
        }
        return result;
    }

    static StgJsonValue ParseArray(string text, ref int pos)
    {
        var result = NewArray();
        pos++; // [
        SkipWhitespace(text, ref pos);
        if (text[pos] == ']') { pos++; return result; }

        while (true)
        {
            var value = ParseValue(text, ref pos);
            result.Add(value);
            SkipWhitespace(text, ref pos);
            if (text[pos] == ',') { pos++; continue; }
            if (text[pos] == ']') { pos++; break; }
        }
        return result;
    }

    static string ParseString(string text, ref int pos)
    {
        pos++; // 起始 "
        var sb = new StringBuilder();
        while (text[pos] != '"')
        {
            char c = text[pos];
            if (c == '\\')
            {
                pos++;
                char esc = text[pos];
                switch (esc)
                {
                    case '"': sb.Append('"'); break;
                    case '\\': sb.Append('\\'); break;
                    case '/': sb.Append('/'); break;
                    case 'n': sb.Append('\n'); break;
                    case 'r': sb.Append('\r'); break;
                    case 't': sb.Append('\t'); break;
                    case 'b': sb.Append('\b'); break;
                    case 'f': sb.Append('\f'); break;
                    case 'u':
                        string hex = text.Substring(pos + 1, 4);
                        sb.Append((char)int.Parse(hex, NumberStyles.HexNumber, CultureInfo.InvariantCulture));
                        pos += 4;
                        break;
                }
                pos++;
            }
            else
            {
                sb.Append(c);
                pos++;
            }
        }
        pos++; // 结束 "
        return sb.ToString();
    }

    static StgJsonValue ParseNumber(string text, ref int pos)
    {
        int start = pos;
        bool isDouble = false;
        if (text[pos] == '-' || text[pos] == '+') pos++;
        while (pos < text.Length && (char.IsDigit(text[pos]) || text[pos] == '.' || text[pos] == 'e' || text[pos] == 'E' || text[pos] == '+' || text[pos] == '-'))
        {
            if (text[pos] == '.' || text[pos] == 'e' || text[pos] == 'E') isDouble = true;
            pos++;
        }
        string numStr = text.Substring(start, pos - start);
        if (isDouble)
        {
            return new StgJsonValue { ValueKind = Kind.Double, m_Double = double.Parse(numStr, CultureInfo.InvariantCulture) };
        }
        return new StgJsonValue { ValueKind = Kind.Int, m_Int = int.Parse(numStr, CultureInfo.InvariantCulture) };
    }

    static void SkipWhitespace(string text, ref int pos)
    {
        while (pos < text.Length && (text[pos] == ' ' || text[pos] == '\t' || text[pos] == '\n' || text[pos] == '\r'))
        {
            pos++;
        }
    }
}
