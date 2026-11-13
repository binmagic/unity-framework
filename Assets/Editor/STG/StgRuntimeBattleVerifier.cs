using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

// Editor-only controller. The Lua harness observes real updates and restores test overrides.
[InitializeOnLoad]
public static class StgRuntimeBattleVerifier
{
    const string P = "STG.RuntimeVerify.";
    public const string ReportRelativePath = "Captures/stg_runtime_verify_report.txt";
    static double s_LastPoll;
    static string Root => Path.GetDirectoryName(Application.dataPath);
    public static bool IsPending => SessionState.GetBool(P + "Pending", false);
    public static string Status => SessionState.GetString(P + "Status", "尚未执行实战验证");
    public static int ChoiceIndex
    {
        get => Mathf.Clamp(SessionState.GetInt(P + "ChoiceIndex", 1), 1, 3);
        set => SessionState.SetInt(P + "ChoiceIndex", Mathf.Clamp(value, 1, 3));
    }
    public static int RouteSide
    {
        get => Mathf.Clamp(SessionState.GetInt(P + "RouteSide", 0), 0, 2);
        set => SessionState.SetInt(P + "RouteSide", Mathf.Clamp(value, 0, 2));
    }

    static StgRuntimeBattleVerifier()
    {
        EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
        AssemblyReloadEvents.beforeAssemblyReload += BeforeReload;
        EditorApplication.update += Update;
        Application.logMessageReceived += OnLog;
    }

    public static string GetLaunchProblem(string path, string levelId)
    {
        int id;
        if (!int.TryParse(levelId, out id) || id <= 0 || id.ToString() != levelId)
            return "实战验证需要正整数关卡 ID（例如 1001）。";
        string expected = Path.Combine(Application.dataPath, "Resources/STG/Levels", levelId + ".json");
        if (string.IsNullOrEmpty(path) || !string.Equals(Path.GetFullPath(path), Path.GetFullPath(expected), StringComparison.OrdinalIgnoreCase))
            return "文件必须为 Assets/Resources/STG/Levels/" + levelId + ".json，文件名须与关卡 ID 一致。";
        if (!File.Exists(path)) return "关卡 JSON 尚未保存。";
        if (!File.Exists(Path.Combine(Root, "Tools/verify_stg_level_playthrough.lua")))
            return "缺少 Tools/verify_stg_level_playthrough.lua。";
        if (EditorApplication.isPlayingOrWillChangePlaymode || IsPending) return "请先停止当前 Play Mode 或等待验证完成。";
        var model = StgLevelJsonIO.LoadFromFile(path);
        if (model.levelId != levelId) return "已保存的 JSON 内关卡 ID 与文件名不一致。";
        if (ValidationPanel.RunValidation(model).Any(i => i.Severity == ValidationPanel.Severity.Error))
            return "关卡有错误级别问题，请先在⑧校验与统计中修复后实战验证。";
        if (UnityEngine.SceneManagement.SceneManager.GetActiveScene().path != "Assets/launcher.unity")
            return "请先打开 Assets/launcher.unity 启动场景。";
        return null;
    }

    public static void Start(string levelId) =>
        Start(Path.Combine(Application.dataPath, "Resources/STG/Levels", levelId + ".json"), levelId);

    public static bool Start(string path, string levelId)
    {
        try
        {
            string problem = GetLaunchProblem(path, levelId);
            if (problem != null) { SetStatus(problem); Debug.LogWarning("[STG验证] " + problem); return false; }
            if (StgPreviewRuntime.IsPlaying) StgPreviewRuntime.Stop();
            AssetDatabase.ImportAsset("Assets/Resources/STG/Levels/" + levelId + ".json", ImportAssetOptions.ForceSynchronousImport | ImportAssetOptions.ForceUpdate);
            Directory.CreateDirectory(Path.Combine(Root, "Captures"));
            SessionState.SetString(P + "Expected", File.ReadAllText(path));
            File.WriteAllText(Path.Combine(Root, "Captures/stg_runtime_verify_config.json"), SessionState.GetString(P + "Expected", ""));
            SessionState.SetString(P + "Level", levelId);
            SessionState.SetInt(P + "RunChoiceIndex", ChoiceIndex);
            SessionState.SetInt(P + "RunRouteSide", RouteSide);
            SessionState.SetString(P + "Script", File.ReadAllText(Path.Combine(Root, "Tools/verify_stg_level_playthrough.lua")));
            SessionState.SetBool(P + "Pending", true);
            SessionState.SetBool(P + "Started", false);
            SessionState.SetBool(P + "Opening", false);
            SessionState.SetInt(P + "Errors", 0);
            SessionState.SetString(P + "ErrorDetail", "");
            SetStatus("等待游戏启动…");
            EditorApplication.isPlaying = true;
            return true;
        }
        catch (Exception e) { Finish("error", e.ToString()); return false; }
    }

    static void OnPlayModeStateChanged(PlayModeStateChange state)
    {
        if (state == PlayModeStateChange.EnteredEditMode && SessionState.GetBool(P + "Closing", false))
        {
            SessionState.SetBool(P + "Closing", false);
            int errors = SessionState.GetInt(P + "TeardownErrors", 0);
            File.AppendAllText(Path.Combine(Root, ReportRelativePath), "\n[Play Mode teardown]\nteardownConsoleErrors=" + errors
                + "\nteardownFirstError=" + SessionState.GetString(P + "TeardownDetail", "") + "\n");
            if (errors > 0) SetStatus(Status + " · 退出阶段另有 " + errors + " 条错误日志，见报告");
        }
        if (!IsPending) return;
        if (state == PlayModeStateChange.EnteredPlayMode)
            SessionState.SetFloat(P + "Deadline", (float)EditorApplication.timeSinceStartup + 90f);
        else if (state == PlayModeStateChange.ExitingPlayMode)
            Finish("cancelled", "用户停止 Play Mode，验证未完成。", false);
    }

    static void BeforeReload()
    {
        if (IsPending && EditorApplication.isPlaying)
            Finish("interrupted", "验证期间脚本重新编译，已中止；请重新验证。", false);
    }

    static void OnLog(string condition, string stack, LogType type)
    {
        if (type != LogType.Error && type != LogType.Exception && type != LogType.Assert) return;
        if (SessionState.GetBool(P + "Closing", false))
        {
            SessionState.SetInt(P + "TeardownErrors", SessionState.GetInt(P + "TeardownErrors", 0) + 1);
            if (SessionState.GetString(P + "TeardownDetail", "").Length == 0)
                SessionState.SetString(P + "TeardownDetail", condition);
            return;
        }
        if (!IsPending) return;
        SessionState.SetInt(P + "Errors", SessionState.GetInt(P + "Errors", 0) + 1);
        if (SessionState.GetString(P + "ErrorDetail", "").Length == 0)
            SessionState.SetString(P + "ErrorDetail", condition + "\n" + stack);
    }

    static void Update()
    {
        if (!IsPending || !EditorApplication.isPlaying || EditorApplication.isCompiling) return;
        if (EditorApplication.timeSinceStartup - s_LastPoll < 0.4) return;
        s_LastPoll = EditorApplication.timeSinceStartup;
        try
        {
            if (EditorApplication.timeSinceStartup > SessionState.GetFloat(P + "Deadline", float.MaxValue))
            { Finish("timeout", "游戏启动或战斗验证超时。请查看日志及报告。"); return; }
            if (GameEntry.Lua == null || GameEntry.Lua.Env == null) return;
            var env = GameEntry.Lua.Env;
            if (!SessionState.GetBool(P + "Started", false))
            {
                var ready = env.DoString(@"
if not UIManager or not UIWindowNames or not DataCenter or not DataCenter.PlaneBattleDataManager
    or not DataCenter.HeroDataManager or not LocalController or not TableName then return 'waiting' end
local ui=UIManager:GetInstance()
if not UILayer or not ui.layers or not ui.layers[UILayer.Normal.Name] then return 'waiting' end
local w=ui:GetWindow(UIWindowNames.UIPlaneBattle)
return w and w.View and w.View.playerPlaneGo and w.View.formationPanel and 'ready' or 'open'
", "STG.VerifyReady");
                string state = Text(ready, 0);
                if (state == "waiting") return;
                if (state == "open")
                {
                    if (!SessionState.GetBool(P + "Opening", false))
                    {
                        env.DoString("UIManager:GetInstance():OpenWindow(UIWindowNames.UIPlaneBattle, {anim=false})");
                        SessionState.SetBool(P + "Opening", true);
                    }
                    return;
                }
                string level = SessionState.GetString(P + "Level", "1001");
                string expected = SessionState.GetString(P + "Expected", "");
                string source = SessionState.GetString(P + "Script", "");
                env.DoString("local run=function(...)\n" + source + "\nend\nreturn run(" + level + "," + Quote(expected) + "," + Quote(Path.Combine(Root, "Captures").Replace('\\', '/')) + "," + SessionState.GetInt(P + "RunChoiceIndex", 1) + "," + SessionState.GetInt(P + "RunRouteSide", 0) + ")", "STG.VerifyStart");
                SessionState.SetBool(P + "Started", true);
                var model = StgLevelJsonIO.FromJson(StgJsonValue.Parse(expected));
                SessionState.SetFloat(P + "Deadline", (float)EditorApplication.timeSinceStartup + Mathf.Max(180f, model.timeline.duration * 3 + 60));
                SetStatus("实战验证中 · 关卡 " + level);
                return;
            }

            var values = env.DoString(@"
local r=STGPlaythrough
assert(r,'验证记录丢失')
return tostring(r.running), r.reason or '', r:Describe(), r.time or 0
", "STG.VerifyPoll");
            if (Text(values, 0) == "true") { SetStatus("实战验证中 · " + Text(values, 3) + " 秒"); return; }
            Finish(Text(values, 1), Text(values, 2));
        }
        catch (Exception e) { Finish("error", e.ToString()); }
    }

    static string Text(object[] values, int index) => values != null && index < values.Length && values[index] != null ? values[index].ToString() : "";
    static string Quote(string value) => "\"" + value.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    static void SetStatus(string value) => SessionState.SetString(P + "Status", value);

    static void Finish(string reason, string detail, bool stopPlay = true)
    {
        // Clear pending first so ExitingPlayMode cannot overwrite a completed report as cancellation.
        SessionState.SetBool(P + "Pending", false);
        try
        {
            if (EditorApplication.isPlaying && GameEntry.Lua != null && GameEntry.Lua.Env != null)
                GameEntry.Lua.Env.DoString("if STGPlaythrough and STGPlaythrough.running then STGPlaythrough:Stop('cancelled') end");
        }
        catch (Exception e) { detail += "\ncleanupError=" + e.Message; }
        int errors = SessionState.GetInt(P + "Errors", 0);
        bool pass = reason == "passed" && errors == 0;
        string report = "status=" + (pass ? "PASS" : "INCOMPLETE_OR_FAILED") + "\nlevel=" + SessionState.GetString(P + "Level", "")
            + "\nreason=" + reason + "\nconsoleErrors=" + errors + "\ncheckedAtUtc=" + DateTime.UtcNow.ToString("O")
            + "\n说明：真实帧更新，模拟拖动，路线门选侧=" + SessionState.GetInt(P + "RunRouteSide", 0) + "（0自动/1左/2右），三选一选择第 " + SessionState.GetInt(P + "RunChoiceIndex", 1) + " 项（无收益时改选可用项）；屏蔽金币/通关存档写入。\n"
            + detail + "\n" + SessionState.GetString(P + "ErrorDetail", "");
        Directory.CreateDirectory(Path.Combine(Root, "Captures"));
        File.WriteAllText(Path.Combine(Root, ReportRelativePath), report);
        SetStatus((pass ? "验证通过" : "验证未通过/未完成") + " · 报告：" + ReportRelativePath);
        Debug.Log("[STG验证] " + Status);
        if (EditorApplication.isPlaying)
        {
            SessionState.SetBool(P + "Closing", true);
            SessionState.SetInt(P + "TeardownErrors", 0);
            SessionState.SetString(P + "TeardownDetail", "");
            if (stopPlay) EditorApplication.isPlaying = false;
        }
    }
}

