using System;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Linq;
using System.Text;
//using TriangleNet;
using Debug = UnityEngine.Debug;

public static class XLuaMenu
{
    public const string LuaScriptPath = "Main/LuaScripts/";
    public const string LuaScriptExportPath = "Main/LuaTxt/";
    public const string LuaDataTablePath = "Main/DataTable/Lua/";
    public const string LuaDataTableExportPath = "Main/DataTable/LuaTxt/";

    public const string LuaScriptPath_Land = "Landscape/Main/LuaScripts/";
    public const string LuaScriptExportPath_Land = "Landscape/Main/LuaTxt/";


    public static void Lua2Txt(int type = -1)
    {
        Debug.LogFormat("Lua2Txt begin!!!");
        string luaPath, exportPath;
        string luaPath_land, exportPath_land;

        // 导出 Lua 脚本
        //        luaPath = Path.Combine(Application.dataPath, LuaScriptPath);
        //        exportPath = Path.Combine(Application.dataPath, LuaScriptExportPath);
        //        ExportLuaTxt(luaPath, exportPath);
        //
        //        // 导出 Lua 数据表
        //        luaPath = Path.Combine(Application.dataPath, LuaDataTablePath);
        //        exportPath = Path.Combine(Application.dataPath, LuaDataTableExportPath);
        //        ExportLuaTxt(luaPath, exportPath);

        try
        {
            AssetDatabase.StartAssetEditing();
            if (type == 1 || type == -1)
            {
                //在这个时候我们在使用luaC进行加密的时候,直接进行luaC的转换+文件位置的处理
                luaPath = Path.Combine(Application.dataPath, LuaScriptPath);
                exportPath = Path.Combine(Application.dataPath, LuaScriptExportPath);

                luaPath_land = Path.Combine(Application.dataPath, LuaScriptPath_Land);
                exportPath_land = Path.Combine(Application.dataPath, LuaScriptExportPath_Land);


                DoLuaAS(luaPath, exportPath);

                DoLuaAS(luaPath_land, exportPath_land);

                Debug.LogFormat("Lua2Txt : {0}", exportPath);
                Debug.LogFormat("Lua2Txt : {0}", exportPath_land);
            }

            if (type == 2 || type == -1)
            {
                luaPath = Path.Combine(Application.dataPath, LuaDataTablePath);
                exportPath = Path.Combine(Application.dataPath, LuaDataTableExportPath);
                DoLuaAS(luaPath, exportPath);

                Debug.LogFormat("Lua2Txt : {0}", exportPath);
            }

            //            EditorUtility.DisplayDialog("", "导出luac成功", "确定");
        }
        catch (Exception e)
        {
            Debug.LogFormat("Lua2Txt error!! {0}", e.Message);
            //            EditorUtility.DisplayDialog("", "导出luac失败", "确定");
            Console.WriteLine(e);
            throw;
        }
        finally
        {
            AssetDatabase.Refresh();
            AssetDatabase.StopAssetEditing();

            Debug.LogFormat("Lua2Txt end!!!");
        }


    }

    public static void LuaScripts2LuaTxt()
    {
        string luaPath, exportPath;

        try
        {
            AssetDatabase.StartAssetEditing();
            luaPath = Path.Combine(Application.dataPath, LuaScriptPath);
            exportPath = Path.Combine(Application.dataPath, LuaScriptExportPath);
            DoLuaAS(luaPath, exportPath);

            luaPath = Path.Combine(Application.dataPath, LuaScriptPath_Land);
            exportPath = Path.Combine(Application.dataPath, LuaScriptExportPath_Land);
            DoLuaAS(luaPath, exportPath);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
        finally
        {
            AssetDatabase.Refresh();
            AssetDatabase.StopAssetEditing();
        }
    }

    public static void DataTable2LuaTxt()
    {
        string luaPath, exportPath;

        try
        {
            AssetDatabase.StartAssetEditing();
            luaPath = Path.Combine(Application.dataPath, LuaDataTablePath);
            exportPath = Path.Combine(Application.dataPath, LuaDataTableExportPath);
            DoLuaAS(luaPath, exportPath);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
        finally
        {
            AssetDatabase.Refresh();
            AssetDatabase.StopAssetEditing();
        }
    }

    public static void DoDataTable(string tablePath1, string exportPath1)
    {
        string luaPath, exportPath;

        luaPath = Path.Combine(Application.dataPath, tablePath1);
        exportPath = Path.Combine(Application.dataPath, exportPath1);

        var files = Directory.GetFiles(luaPath, "*.lua", SearchOption.AllDirectories);
        Directory.CreateDirectory(luaPath);

        // 1. 删除目标文件夹的所有的bytes目标文件
        // 2. 把lua生成txt文件
        // 3. 删除目标文件夹的多余的meta文件
        var txtfiles = Directory.GetFiles(exportPath, "*.bytes", SearchOption.AllDirectories);
        foreach (var file in txtfiles)
        {
            File.Delete(file);
        }

        UnityEditor.EditorUtility.DisplayProgressBar("", $"copy lua begin ... ", 0);

        for (int i = 0; i < files.Length; i++)
        {
            var srcfile = files[i];
            var destName = srcfile.Replace(luaPath, "")
                //.Replace("/", ".")
                //.Replace("\\", ".")
                .Replace(".lua", ".bytes");

            var destPath = exportPath + destName;
            var dir = Path.GetDirectoryName(destPath);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

#if UNITY_EDITOR
            if (i % 100 == 0)
            {
                UnityEditor.EditorUtility.DisplayProgressBar($"luac ... ({i}/{files.Length}) ", srcfile, i * 1f / files.Length);
            }
#endif

            File.Copy(srcfile, destPath);
        }

        UnityEditor.EditorUtility.DisplayProgressBar("", $"luac end ... ", 0);
        UnityEditor.EditorUtility.ClearProgressBar();

        // 删除多余的meta
        var files2 = Directory.GetFiles(exportPath, "*.meta", SearchOption.AllDirectories);
        foreach (var file in files2)
        {
            string luafile = file.Remove(file.IndexOf(".meta"));
            if (!File.Exists(luafile) && !Directory.Exists(luafile))
            {
                File.Delete(file);
            }
        }


        AssetDatabase.Refresh();
        return;
    }

    // 直接把原始目录的.lua 拷贝过去变成 目标目录的 .bytes
    public static void CopyDataTable2LuaTxt()
    {
        DoDataTable(LuaDataTablePath, LuaDataTableExportPath);
    }

    static void DoLuaAS(string luaPath, string exportPath)
    {
        if (!Directory.Exists(luaPath))
        {
            Debug.LogError("Lua 路径不存在！");
            return;
        }
        // if (Directory.Exists(exportPath))
        // {
        //     Directory.Delete(exportPath, true);
        //     AssetDatabase.DeleteAsset(exportPath.Substring(exportPath.IndexOf("Assets") + "Assets".Length));
        //     AssetDatabase.Refresh();
        // }

        EncodeLua2Bytes(luaPath, exportPath);
    }

    static void ExportLuaTxt(string luaPath, string exportPath)
    {
        if (!Directory.Exists(luaPath))
        {
            Debug.LogError("Lua 路径不存在！");
            return;
        }

        if (Directory.Exists(exportPath))
        {
            Directory.Delete(exportPath, true);
            AssetDatabase.DeleteAsset(exportPath.Substring(exportPath.IndexOf("Assets") + "Assets".Length));
            AssetDatabase.Refresh();
        }

        var files = Directory.GetFiles(luaPath, "*.lua", SearchOption.AllDirectories);
        foreach (var i in files)
        {
            var destName = i.Replace(luaPath, "")
                .Replace("/", ".")
                .Replace("\\", ".")
                .Replace(".lua", ".txt");

            var destPath = exportPath + destName;
            CopyFile(i, destPath);
        }
        AssetDatabase.Refresh();
    }

    static void CopyFile(string fileFrom, string fileTo)
    {
        var dir = Path.GetDirectoryName(fileTo);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        File.Copy(fileFrom, fileTo, true);
    }

    static void EncodeLua2Bytes(string oldFilePath, string newFilePath)
    {
        var files = Directory.GetFiles(oldFilePath, "*.lua", SearchOption.AllDirectories);
#if UNITY_EDITOR_WIN
        string luaCPath = Application.dataPath.Replace("Assets", "") + "Tools/LuaC/luac.exe";
#elif UNITY_EDITOR_OSX
        string luaCPath = Application.dataPath.Replace("Assets", "") + "Tools/LuaC/luac";
#endif

        Directory.CreateDirectory(newFilePath);
        //File.WriteAllText(newFilePath + "placeholder","");
        var compileErrors = new StringBuilder();

        // 1. 删除目标文件夹的所有的bytes目标文件
        // 2. 把lua生成txt文件
        // 3. 删除目标文件夹的多余的meta文件
        var txtfiles = Directory.GetFiles(newFilePath, "*.bytes", SearchOption.AllDirectories);
        foreach (var file in txtfiles)
        {
            File.Delete(file);
        }

        UnityEditor.EditorUtility.DisplayProgressBar("", $"luac begin ... ", 0);
        var cmdString = new StringBuilder();
        for (int i = 0; i < files.Length; i++)
        {
            var srcfile = files[i];
            var destName = srcfile.Replace(oldFilePath, "")
                //.Replace("/", ".")
                //.Replace("\\", ".")
                .Replace(".lua", ".bytes");

            var destPath = newFilePath + destName;
            var dir = Path.GetDirectoryName(destPath);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            cmdString.AppendFormat($"{luaCPath} -o '{destPath}' '{srcfile}'; ");

            //100个执行一次, 指令参数长度最大32699字符，100个是一个舒适值
            if ((i % 100 == 0 && i / 100 > 0) || i == files.Length - 1 ||
                cmdString.Length > 30000)
            {
#if UNITY_EDITOR
                UnityEditor.EditorUtility.DisplayProgressBar($"luac ... ({i}/{files.Length}) ", srcfile,
                    i * 1f / files.Length);
#endif

                ProcessStartInfo info = new ProcessStartInfo();
#if UNITY_EDITOR_OSX
                info.FileName = "/bin/bash";
#elif UNITY_EDITOR_WIN
                    info.FileName = "powershell";
#endif
                // info.FileName = luaCPath;
#if UNITY_EDITOR_OSX
                info.Arguments = $"-c \'{cmdString.ToString()}\'";
#elif UNITY_EDITOR_WIN
                    info.Arguments = $"{cmdString.ToString()}";
#endif
                info.UseShellExecute = false;
                info.CreateNoWindow = true;
                info.RedirectStandardOutput = true;
                info.RedirectStandardError = true;
                Process process = Process.Start(info);
                process.WaitForExit();
                var errOutput = process.StandardError.ReadToEnd();
                if (errOutput.Length > 0)
                {
                    var errMsg =
                        $"lua complie error: \n stderr:{errOutput}";
                    compileErrors.AppendLine(errMsg);
                    Debug.LogError(errMsg);
                }

                process.Dispose();
                cmdString.Clear();
            }
        }

        UnityEditor.EditorUtility.DisplayProgressBar("", $"luac end ... ", 0);
        UnityEditor.EditorUtility.ClearProgressBar();

        // 删除多余的meta
        var files2 = Directory.GetFiles(newFilePath, "*.meta", SearchOption.AllDirectories);
        foreach (var file in files2)
        {
            string luafile = file.Remove(file.IndexOf(".meta"));
            if (!File.Exists(luafile) && !Directory.Exists(luafile))
            {
                File.Delete(file);
            }
        }
        if (compileErrors.Length > 0)
        {
            throw new Exception(compileErrors.ToString());
        }

        AssetDatabase.Refresh();


    }

}



