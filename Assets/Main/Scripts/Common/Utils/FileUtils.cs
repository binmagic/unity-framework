using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using XLua;

public static class FileUtils
{
    public static bool ExistDirectory(string path)
    {
        return Directory.Exists(path);
    }

    public static bool ExistFile(string path)
    {
        return File.Exists(path);
    }
    
    public static bool Copy(string srcPath, string dstPath, bool overwrite = true)
    {
        try
        {
            File.Copy(srcPath, dstPath, overwrite);
            return true;
        }
        catch (Exception e)
        {
            return false;
        }
    }

    public static void DeleteDirectoryIfExists(string path, bool recursive = true)
    {
        if (Directory.Exists(path))
            Directory.Delete(path, recursive);
    }

    public static void DeleteFileIfExists(string path)
    {
        if (File.Exists(path))
            File.Delete(path);
    }

    public static void CreateFileDirectoryIfNotExists(string path)
    {
        string directory = Path.GetDirectoryName(path);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
            Directory.CreateDirectory(directory);
    }

    public static FileStream CreateFile(string path)
    {
        DeleteFileIfExists(path);
        CreateFileDirectoryIfNotExists(path);
        return File.Create(path);
    }

    public static StreamWriter CreateText(string path)
    {
        DeleteFileIfExists(path);
        CreateFileDirectoryIfNotExists(path);
        return File.CreateText(path);
    }

    public static void WriteFile(string path, byte[] bytedata, bool overwrite = true)
    {
        Debug.Assert(bytedata != null);
        CreateFileDirectoryIfNotExists(path);

        if (overwrite && File.Exists(path))
            File.Delete(path);

        File.WriteAllBytes(path, bytedata);
    }

    public static void CopyFile(string srcPath, string dstPath, bool overwrite = true)
    {
        if (File.Exists(srcPath))
        {
            CreateFileDirectoryIfNotExists(dstPath);
            File.Copy(srcPath, dstPath, overwrite);
        }
        else
        {
            Debug.LogErrorFormat("File not exsits: {0}", srcPath);
        }
    }

    public static long GetFileSize(string path)
    {
        using (FileStream fs = File.OpenRead(path))
        {
            return fs.Length;
        }
    }
    
    public static void CopyFilesRecursively(string sourcePath, string targetPath)
    {
        //Now Create all of the directories
        foreach (string dirPath in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
        {
            Directory.CreateDirectory(dirPath.Replace(sourcePath, targetPath));
        }

        //Copy all the files & Replaces any files with the same name
        foreach (string newPath in Directory.GetFiles(sourcePath, "*.*", SearchOption.AllDirectories))
        {
            File.Copy(newPath, newPath.Replace(sourcePath, targetPath), true);
        }
    }
}





