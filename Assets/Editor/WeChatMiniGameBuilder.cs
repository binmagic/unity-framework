#if UNITY_WEBGL || UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 微信小游戏构建后处理器
/// 将 Unity WebGL 构建输出转换为微信小游戏项目格式
/// </summary>
public class WeChatMiniGameBuilder
{
    private const string TEMPLATE_NAME = "WeChatMiniGame";

    /// <summary>
    /// 菜单: 构建 WebGL 并转换为微信小游戏格式
    /// </summary>
    [MenuItem("Build/Build WeChat Mini Game")]
    public static void BuildWeChatMiniGame()
    {
        string outputPath = EditorUtility.SaveFolderPanel("选择微信小游戏输出目录", "", "wechat_minigame");
        if (string.IsNullOrEmpty(outputPath))
            return;

        // Step 1: 构建 WebGL
        string webglOutput = Path.Combine(outputPath, "webgl_build");
        BuildWebGL(webglOutput);

        // Step 2: 转换为微信小游戏格式
        ConvertToMiniGame(webglOutput, outputPath);

        Debug.Log($"[WeChatMiniGame] 构建完成! 输出目录: {outputPath}");
        EditorUtility.DisplayDialog("构建完成", $"微信小游戏已输出到:\n{outputPath}", "确定");
    }

    private static void BuildWebGL(string outputPath)
    {
        if (Directory.Exists(outputPath))
            Directory.Delete(outputPath, true);

        var options = new BuildPlayerOptions
        {
            scenes = GetEnabledScenes(),
            locationPathName = outputPath,
            target = BuildTarget.WebGL,
            options = BuildOptions.None
        };

        var report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != UnityEditor.Build.Reporting.BuildResult.Succeeded)
        {
            Debug.LogError("[WeChatMiniGame] WebGL 构建失败!");
            return;
        }

        Debug.Log("[WeChatMiniGame] WebGL 构建成功");
    }

    private static void ConvertToMiniGame(string webglOutput, string miniGameOutput)
    {
        Debug.Log("[WeChatMiniGame] 开始转换为微信小游戏格式...");

        // 复制 WebGL 构建文件到微信小游戏目录
        string buildDir = Path.Combine(webglOutput, "Build");
        string templateDir = Path.Combine(webglOutput, "TemplateData");

        // 复制 Build 目录下的 .data, .framework.js, .wasm 文件
        if (Directory.Exists(buildDir))
        {
            string targetBuildDir = Path.Combine(miniGameOutput, "Build");
            CopyDirectory(buildDir, targetBuildDir);
        }

        // 复制 TemplateData
        if (Directory.Exists(templateDir))
        {
            string targetTemplateDir = Path.Combine(miniGameOutput, "TemplateData");
            CopyDirectory(templateDir, targetTemplateDir);
        }

        // 从模板复制 game.json 和 game.js
        string templatePath = Path.Combine(Application.dataPath, "WebGLTemplates", TEMPLATE_NAME);
        CopyFileIfExists(Path.Combine(templatePath, "game.json"), Path.Combine(miniGameOutput, "game.json"));
        CopyFileIfExists(Path.Combine(templatePath, "game.js"), Path.Combine(miniGameOutput, "game.js"));

        Debug.Log("[WeChatMiniGame] 转换完成");
    }

    private static string[] GetEnabledScenes()
    {
        var scenes = EditorBuildSettings.scenes;
        var enabledScenes = new System.Collections.Generic.List<string>();
        foreach (var scene in scenes)
        {
            if (scene.enabled)
                enabledScenes.Add(scene.path);
        }
        return enabledScenes.ToArray();
    }

    private static void CopyDirectory(string sourceDir, string targetDir)
    {
        if (!Directory.Exists(targetDir))
            Directory.CreateDirectory(targetDir);

        foreach (var file in Directory.GetFiles(sourceDir))
        {
            string targetFile = Path.Combine(targetDir, Path.GetFileName(file));
            File.Copy(file, targetFile, true);
        }

        foreach (var dir in Directory.GetDirectories(sourceDir))
        {
            string targetSubDir = Path.Combine(targetDir, Path.GetFileName(dir));
            CopyDirectory(dir, targetSubDir);
        }
    }

    private static void CopyFileIfExists(string source, string target)
    {
        if (File.Exists(source))
        {
            string targetDir = Path.GetDirectoryName(target);
            if (!Directory.Exists(targetDir))
                Directory.CreateDirectory(targetDir);
            File.Copy(source, target, true);
        }
    }
}
#endif
