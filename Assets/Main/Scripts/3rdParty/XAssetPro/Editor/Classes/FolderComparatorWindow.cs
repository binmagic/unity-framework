using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;

public class FolderComparatorWindow : EditorWindow
{
    private string folderA = "";
    private string folderB = "";
    private int sizeDifferenceThreshold = 102400; // 默认100KB阈值
    private Vector2 scrollPosition;
    private List<string> mismatchedFiles = new List<string>();
    private string combinedResults = ""; // 存储组合文本的字符串


   [MenuItem("XASSET/Bundle文件夹变化比对", false, 500)]
    public static void ShowWindow()
    {
        FolderComparatorWindow window = GetWindow<FolderComparatorWindow>("文件夹比较工具");
        window.minSize = new Vector2(500, 300);
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("文件夹比较工具", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        // 输入框：文件夹 A
        EditorGUILayout.LabelField("文件夹 A", EditorStyles.miniBoldLabel);
        folderA = DragAndDropFolderField(folderA);

        // 输入框：文件夹 B
        EditorGUILayout.LabelField("文件夹 B", EditorStyles.miniBoldLabel);
        folderB = DragAndDropFolderField(folderB);

        EditorGUILayout.Space();

        // 输入阈值
        sizeDifferenceThreshold = EditorGUILayout.IntField("文件大小差异阈值 (字节)", sizeDifferenceThreshold);

        // 比较按钮
        if (GUILayout.Button("比较", GUILayout.Height(30)))
        {
            CompareFolders(folderA, folderB);
        }

        EditorGUILayout.Space();

        //显示结果
        if (!string.IsNullOrEmpty(combinedResults))
        {
              EditorGUILayout.LabelField("差异文件列表:", EditorStyles.boldLabel);
            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition, GUILayout.Height(500));
          EditorGUILayout.TextArea(combinedResults, EditorStyles.wordWrappedLabel);
             EditorGUILayout.EndScrollView();

        } else if (folderA != "" && folderB != "")
        {
            EditorGUILayout.LabelField("没有找到超过阈值的差异文件。", EditorStyles.miniBoldLabel);
        }
    }


     private string DragAndDropFolderField(string folderPath)
    {
        Rect dropArea = GUILayoutUtility.GetRect(0, 20, GUILayout.ExpandWidth(true));
        folderPath = EditorGUI.TextField(dropArea, folderPath);

        // 检测拖拽事件
        Event evt = Event.current;
        if (dropArea.Contains(evt.mousePosition))
        {
            if (evt.type == EventType.DragUpdated || evt.type == EventType.DragPerform)
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();
                    if (DragAndDrop.paths.Length > 0)
                    {
                        string draggedPath = DragAndDrop.paths[0];
                        if (Directory.Exists(draggedPath)) // 检查是否为文件夹
                        {
                            folderPath = draggedPath;
                            GUI.FocusControl(null);
                        }
                        else
                        {
                            EditorUtility.DisplayDialog("错误", "拖入的路径不是文件夹！", "确定");
                        }
                    }
                    evt.Use();
                }
            }
        }

        return folderPath;
    }
    private void CompareFolders(string pathA, string pathB)
    {
        mismatchedFiles.Clear();
        combinedResults = "";
        List<string> notExistFiles = new List<string>();
        List<string> aGreaterBFiles = new List<string>();
        List<string> aLessBFiles = new List<string>();
         const string separator = "-----------------------------------------------------------------";
       
        if (string.IsNullOrEmpty(pathA) || string.IsNullOrEmpty(pathB))
        {
            EditorUtility.DisplayDialog("错误", "请先选择两个文件夹路径！", "确定");
            return;
        }

        if (!Directory.Exists(pathA) || !Directory.Exists(pathB))
        {
            EditorUtility.DisplayDialog("错误", "其中一个文件夹路径不存在，请检查！", "确定");
            return;
        }
       
         DirectoryInfo dirA = new DirectoryInfo(pathA);
        DirectoryInfo dirB = new DirectoryInfo(pathB);

        FileInfo[] filesA = dirA.GetFiles();
        FileInfo[] filesB = dirB.GetFiles();

             Dictionary<string, long> fileSizesA = new Dictionary<string, long>();

        foreach (FileInfo file in filesA)
        {
            string key = GetFileNameWithoutMD5(file.Name);
            fileSizesA[key] = file.Length;
        }
        foreach (FileInfo fileB in filesB)
        {
           string keyB = GetFileNameWithoutMD5(fileB.Name);
              if (fileSizesA.ContainsKey(keyB))
              {
                 long sizeA = fileSizesA[keyB];
                 long sizeB = fileB.Length;

                if (Math.Abs(sizeA - sizeB) > sizeDifferenceThreshold)
                {
                     string sizeStringA = FormatSize(sizeA);
                    string sizeStringB = FormatSize(sizeB);
                    string sizeDiffString = FormatSize(Math.Abs(sizeA - sizeB));
                    
                    string comparison = sizeA > sizeB ? "A > B" : "A < B";
                    string result = $"文件: {fileB.Name}, {comparison} ({sizeDiffString}),  A ({sizeStringA})";

                     if(sizeA > sizeB)
                     {
                        aGreaterBFiles.Add(result);
                     }else{
                        aLessBFiles.Add(result);
                     }
                }

             }else
            {
                 string sizeStringB = FormatSize(fileB.Length);
                string result = $"文件: '{fileB.Name}' 在文件夹 A 中不存在,  B ({sizeStringB})";
                notExistFiles.Add(result);
            }
         }
         
		  if(aGreaterBFiles.Count > 0){
              mismatchedFiles.AddRange(aGreaterBFiles);
              if(aLessBFiles.Count > 0)
              {
                  mismatchedFiles.Add(separator);
                  mismatchedFiles.AddRange(aLessBFiles);
               }
               if(notExistFiles.Count > 0)
               {
                  mismatchedFiles.Add(separator);
                  mismatchedFiles.AddRange(notExistFiles);
                }

          }else if(aLessBFiles.Count > 0){
              mismatchedFiles.AddRange(aLessBFiles);
                if(notExistFiles.Count > 0)
               {
                  mismatchedFiles.Add(separator);
                   mismatchedFiles.AddRange(notExistFiles);
                }
          }else{
            mismatchedFiles.AddRange(notExistFiles);
          }


           combinedResults = string.Join("\n",mismatchedFiles);


           if (mismatchedFiles.Count == 0)
            {
                 Debug.Log("未发现超出阈值的差异文件");
            }
          Repaint();
    }

    private string GetFileNameWithoutMD5(string fileName)
    {
        string nameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);

         int lastUnderscoreIndex = nameWithoutExtension.LastIndexOf('_');
        if (lastUnderscoreIndex > 0)
        {
            return nameWithoutExtension.Substring(0, lastUnderscoreIndex) + ".bundle";
        }
        return fileName;
    }
      private string FormatSize(long bytes)
    {
        const int KB = 1024;
        if (bytes < KB)
        {
            return $"{bytes} B";
        }
        else
        {
            double sizeInKB = (double)bytes / KB;
           return $"{sizeInKB:F0} KB";
        }
    }
}
