using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

// 数字门 paraTable 字段的编解码/校验工具。
// 来源提示：区间表的分隔符约定（';' 分隔条目、'|' 分隔字段）参考内部旧版 barrel 项目
// ParkourBattle 的 string.string2array2d_i(para, ';', '|') 写法整理，尚未逐行核对源码，
// 详见 Docs/STG/STG 关卡系统技术架构设计.md 第零节来源提示。
// 实施前务必用旧仓库真实数据跑一遍编解码往返测试，确认分隔符/字段顺序与运行时解析一致。
public static class StgGateParaTableUtil
{
    public struct StepEntry
    {
        public float hpThreshold;
        public string effectId;
    }

    public struct CounterEntry
    {
        public float min;
        public float max;
        public string effectId;
    }

    public static List<StepEntry> DecodeStep(string paraTable)
    {
        var list = new List<StepEntry>();
        if (string.IsNullOrEmpty(paraTable)) return list;

        foreach (var entry in paraTable.Split(';'))
        {
            if (string.IsNullOrEmpty(entry)) continue;
            var fields = entry.Split('|');
            if (fields.Length < 2) continue;
            if (!float.TryParse(fields[0], NumberStyles.Float, CultureInfo.InvariantCulture, out float threshold)) continue;
            list.Add(new StepEntry { hpThreshold = threshold, effectId = fields[1] });
        }
        return list;
    }

    public static string EncodeStep(List<StepEntry> entries)
    {
        var sb = new StringBuilder();
        for (int i = 0; i < entries.Count; i++)
        {
            if (i > 0) sb.Append(';');
            sb.Append(entries[i].hpThreshold.ToString(CultureInfo.InvariantCulture));
            sb.Append('|');
            sb.Append(entries[i].effectId);
        }
        return sb.ToString();
    }

    public static List<CounterEntry> DecodeCounter(string paraTable)
    {
        var list = new List<CounterEntry>();
        if (string.IsNullOrEmpty(paraTable)) return list;

        foreach (var entry in paraTable.Split(';'))
        {
            if (string.IsNullOrEmpty(entry)) continue;
            var fields = entry.Split('|');
            if (fields.Length < 3) continue;
            if (!float.TryParse(fields[0], NumberStyles.Float, CultureInfo.InvariantCulture, out float min)) continue;
            if (!float.TryParse(fields[1], NumberStyles.Float, CultureInfo.InvariantCulture, out float max)) continue;
            list.Add(new CounterEntry { min = min, max = max, effectId = fields[2] });
        }
        return list;
    }

    public static string EncodeCounter(List<CounterEntry> entries)
    {
        var sb = new StringBuilder();
        for (int i = 0; i < entries.Count; i++)
        {
            if (i > 0) sb.Append(';');
            sb.Append(entries[i].min.ToString(CultureInfo.InvariantCulture));
            sb.Append('|');
            sb.Append(entries[i].max.ToString(CultureInfo.InvariantCulture));
            sb.Append('|');
            sb.Append(entries[i].effectId);
        }
        return sb.ToString();
    }

    // 检查区间表按 min 排序后是否连续无空洞（前一条 max 与下一条 min 相邻）
    // 返回 null 表示无问题；否则返回描述第一处问题的提示文本
    public static string CheckCounterContinuity(List<CounterEntry> entries)
    {
        if (entries.Count == 0) return "区间表为空，任何数值都不会触发效果";

        var sorted = entries.OrderBy(e => e.min).ToList();
        for (int i = 0; i < sorted.Count - 1; i++)
        {
            if (!Mathf_Approximately(sorted[i].max, sorted[i + 1].min))
            {
                return $"区间 [{sorted[i].min},{sorted[i].max}] 与 [{sorted[i + 1].min},{sorted[i + 1].max}] 之间存在空洞或重叠，数值落在空洞里不会触发任何效果";
            }
        }
        return null;
    }

    static bool Mathf_Approximately(float a, float b)
    {
        return System.Math.Abs(a - b) < 0.0001f;
    }
}
