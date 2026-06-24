using System;
using System.Collections.Generic;
using System.IO;
using GameFramework;
using GameFramework.Localization;
using UnityEngine;

public class LocalizationManager
{
    struct DialogEntry
    {
        public string originDlg;
        public bool hasCRLF; // 是否有回车换行；初始都标记为true，扫描一次之后设置为false
    }
    
    // Dictionary也需要设置Capacity，具体参考：https://cc.davelozinski.com/c-sharp/c-sharp-is-it-faster-to-preallocate-dictionary-sizes
    // 同时这里用struct，理论上也会略好一些，具体参考：http://clarkkromenaker.com/post/csharp-structs/
    private readonly Dictionary<string, DialogEntry> m_Dictionary = new Dictionary<string, DialogEntry>(100);
    private readonly Dictionary<int, DialogEntry> m_IntDictionary = new Dictionary<int, DialogEntry>(5000);
    private Language m_Language;

    public bool IsInitDone { get; private set; }
    
    public bool IsInitSuccess { get; private set; }
    
    public LocalizationManager()
    {
    }

    public string GetDeviceLang()
    {
        string strLang = "";
        try
        {
            var systemLanguage = Application.systemLanguage;
            strLang = Enum.GetName(typeof(SystemLanguage), systemLanguage);
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
        return strLang;
    }

    public void Initialize(Language userLanguage)
    {
        if (userLanguage != Language.Unspecified)
        {
            m_Language = userLanguage;
        }
        else
        {
            m_Language = SystemLanguage;
        }

    }

    public void Uninitialize()
    {

    }

    public void LoadDictionary(string dictionaryName)
    {
        IsInitDone = false;
        IsInitSuccess = false;

        string languageName = IsSuported() ? Language.ToString() : "English";
        if (ApplicationLaunch.Instance.GetZipDataTable()._ConfigStatus == ConfigStatus.FinishUnzip)
        {
            string dictionaryAssetName =
                Application.persistentDataPath + string.Format("/ZipDocument/getnewlua/Localization/{0}/Dictionaries/{1}.txt", languageName, dictionaryName);
            Log.Info("LoadDictionary zip start {0}", dictionaryAssetName);
            if (File.Exists(dictionaryAssetName))
            {
                IsInitDone = true;
                IsInitSuccess = ParseTxtDictionary(File.ReadAllText(dictionaryAssetName));
            }
            else
            {
                dictionaryAssetName = Application.persistentDataPath + string.Format("/ZipDocument/getnewlua/Localization/English/Dictionaries/Dialog.txt");
                if (File.Exists(dictionaryAssetName))
                {
                    IsInitDone = true;
                    IsInitSuccess = ParseTxtDictionary(File.ReadAllText(dictionaryAssetName));
                }
                else
                {
                    IsInitDone = true;
                    IsInitSuccess = false;
                }
            }
        }
        else
        {
            string dictionaryAssetName = string.Format("Assets/Main/DataTable/Localization/{0}/Dictionaries/{1}.txt",
                languageName, dictionaryName);
            Log.Info("LoadDictionary start {0}", dictionaryAssetName);
            var dialogAsset = GameEntry.Resource.LoadAssetAsync(dictionaryAssetName, typeof(TextAsset));
            if (dialogAsset != null)
            {
                // 这里要提高一下优先级，防止先弹出UI时，多语言还没有加载完毕
                dialogAsset.SetPriority(10);
                dialogAsset.completed += (request) =>
                {
                    Log.Info("LoadDictionary completed {0}", dictionaryAssetName);
                    LoadDictionaryCallback(request.asset as TextAsset);
                    request.Release();
                };
            }
            else
            {
                Log.Info("LoadDictionary {0} not found, use DefaultDialog!", dictionaryAssetName);
                dialogAsset = GameEntry.Resource.LoadAssetAsync(GameDefines.DefaultDialog, typeof(TextAsset));
                if (dialogAsset != null)
                {
                    // 这里要提高一下优先级，防止先弹出UI时，多语言还没有加载完毕
                    dialogAsset.SetPriority(10);
                    dialogAsset.completed += (request) =>
                    {
                        Log.Info("LoadDictionary completed {0}", dictionaryAssetName);
                        LoadDictionaryCallback(request.asset as TextAsset);
                        request.Release();
                    };
                }
                else
                {
                    Log.Info("LoadDictionary DefaultDialog not found!");
                    IsInitDone = true;
                    IsInitSuccess = false;
                }
            }
        }

    }

    void LoadDictionaryCallback(TextAsset asset)
    {
        IsInitDone = true;
        IsInitSuccess = ParseTxtDictionary(asset.text);
    }

    /// <summary>
    /// 解析字典。
    /// </summary>
    /// <param name="text">要解析的字典文本。</param>
    /// <returns>是否解析字典成功。</returns>

    bool ParseTxtDictionary(string text)
    {
        if (string.IsNullOrEmpty(text))
        {
            return false;
        }
        m_Dictionary.Clear();
        m_IntDictionary.Clear();

        try
        {
            foreach (ReadOnlySpan<char> line in text.SplitLines())
            {
                if (line.Length <= 2 || line[0] == '#' || line[0] == '/')
                {
                    continue;
                }

                ReadOnlySpan<char> keySpan;
                ReadOnlySpan<char> valueSpan;
                if (line.Split_to_spanspan('=', out keySpan, out valueSpan) == false)
                {
                    continue;
                }

                keySpan = keySpan.Trim();
                valueSpan = valueSpan.Trim();

                // valueSpan 策划的意思是要支持空字符串。你难道不觉得这需求诡异吗？？？
                if (keySpan.IsEmpty)
                {
                    continue;
                }

//                string key = keySpan.ToString();
                string value = valueSpan.ToString();

// #if UNITY_EDITOR
//                 if (HasRawString(key))
//                 {
//                     Log.Error("Can not add raw string with key '{0}' which may be invalid or duplicate.", key);
//                 }
// #endif

                AddRawString(keySpan, value);
            }


            // 这个地方是用来检测上面代码是否正确的
#if false //UNITY_EDITOR

            Dictionary<string, string> checkDict = new Dictionary<string, string>();
            string[] rowTexts = SplitToLines(asset.text);
            for (int i = 0; i < rowTexts.Length; i++)
            {
                if (rowTexts[i].Length <= 0 || rowTexts[i][0] == '#')
                {
                    continue;
                }

                string[] splitLine = rowTexts[i].Split(ColumnSplit, 2, StringSplitOptions.None);
                if (splitLine.Length != ColumnCount)
                {
                    Log.Error("Can not parse dictionary '{0}'.", rowTexts[i]);
                    //return false;
                    continue;
                }

                string key = splitLine[0];
                string value = splitLine[1];
                if (string.IsNullOrEmpty(key))
                {
                    //Log.Warning("Invalid Key at line:" + i);
                    continue;
                }
                // if (!AddRawString(key, value))
                // {
                //     Log.Error("Can not add raw string with key '{0}' which may be invalid or duplicate.", key);
                //     //return false;
                //     continue;
                // }
                
                checkDict.Add(key, value ?? string.Empty);
            }
            
            if (m_Dictionary.Count != checkDict.Count)
            {
                Log.Error("ParseDictionary count not same (%d/%d)", m_Dictionary.Count, checkDict.Count);
            }
#endif
            return true;
        }
        catch (Exception exception)
        {
            Debug.LogErrorFormat("Can not parse dictionary '{0}' with exception '{1}'.", text,
                string.Format("{0}\n{1}", exception.Message, exception.StackTrace));
            return false;
        }
    }

    /// <summary>
    /// 支持语言列表。
    /// </summary>
    private List<Language> SuportedLanguages = new List<Language>() { Language.English };

    /// <summary>
    /// 获取或设置本地化语言。
    /// </summary>
    public Language Language
    {
        get
        {
            return m_Language;
        }
        set
        {
            if (value == Language.Unspecified)
            {
                Log.Error("Language is invalid.");
            }

            m_Language = value;
        }
    }

    /// <summary>
    /// 获取系统语言。当第一次启动游戏的时候，会根据系统的语言做默认的处理。。
    /// </summary>
    public static Language SystemLanguage
    {
        get
        {
            switch (Application.systemLanguage)
            {
                case UnityEngine.SystemLanguage.Afrikaans: return Language.Afrikaans;
                case UnityEngine.SystemLanguage.Arabic: return Language.Arabic;
                case UnityEngine.SystemLanguage.Basque: return Language.Basque;
                case UnityEngine.SystemLanguage.Belarusian: return Language.Belarusian;
                case UnityEngine.SystemLanguage.Bulgarian: return Language.Bulgarian;
                case UnityEngine.SystemLanguage.Catalan: return Language.Catalan;
                case UnityEngine.SystemLanguage.Chinese: return Language.ChineseSimplified;
                case UnityEngine.SystemLanguage.ChineseSimplified: return Language.ChineseSimplified;
                case UnityEngine.SystemLanguage.ChineseTraditional: return Language.ChineseTraditional;
                case UnityEngine.SystemLanguage.Czech: return Language.Czech;
                case UnityEngine.SystemLanguage.Danish: return Language.Danish;
                case UnityEngine.SystemLanguage.Dutch: return Language.Dutch;
                case UnityEngine.SystemLanguage.English: return Language.English;
                case UnityEngine.SystemLanguage.Estonian: return Language.Estonian;
                case UnityEngine.SystemLanguage.Faroese: return Language.Faroese;
                case UnityEngine.SystemLanguage.Finnish: return Language.Finnish;
                case UnityEngine.SystemLanguage.French: return Language.French;
                case UnityEngine.SystemLanguage.German: return Language.German;
                case UnityEngine.SystemLanguage.Greek: return Language.Greek;
                case UnityEngine.SystemLanguage.Hebrew: return Language.Hebrew;
                case UnityEngine.SystemLanguage.Hungarian: return Language.Hungarian;
                case UnityEngine.SystemLanguage.Icelandic: return Language.Icelandic;
                case UnityEngine.SystemLanguage.Indonesian: return Language.Indonesian;
                case UnityEngine.SystemLanguage.Italian: return Language.Italian;
                case UnityEngine.SystemLanguage.Japanese: return Language.Japanese;
                case UnityEngine.SystemLanguage.Korean: return Language.Korean;
                case UnityEngine.SystemLanguage.Latvian: return Language.Latvian;
                case UnityEngine.SystemLanguage.Lithuanian: return Language.Lithuanian;
                case UnityEngine.SystemLanguage.Norwegian: return Language.Norwegian;
                case UnityEngine.SystemLanguage.Polish: return Language.Polish;
                case UnityEngine.SystemLanguage.Portuguese: return Language.PortuguesePortugal;
                case UnityEngine.SystemLanguage.Romanian: return Language.Romanian;
                case UnityEngine.SystemLanguage.Russian: return Language.Russian;
                case UnityEngine.SystemLanguage.SerboCroatian: return Language.SerboCroatian;
                case UnityEngine.SystemLanguage.Slovak: return Language.Slovak;
                case UnityEngine.SystemLanguage.Slovenian: return Language.Slovenian;
                case UnityEngine.SystemLanguage.Spanish: return Language.Spanish;
                case UnityEngine.SystemLanguage.Swedish: return Language.Swedish;
                case UnityEngine.SystemLanguage.Thai: return Language.Thai;
                case UnityEngine.SystemLanguage.Turkish: return Language.Turkish;
                case UnityEngine.SystemLanguage.Ukrainian: return Language.Ukrainian;
                case UnityEngine.SystemLanguage.Unknown: return Language.Unspecified;
                case UnityEngine.SystemLanguage.Vietnamese: return Language.Vietnamese;
                default: return Language.Unspecified;
            }
        }
    }
    
    /// <summary>
    /// 当前语言是否支持
    /// </summary>
    /// <returns>是否支持。</returns>
    public bool IsSuported()
    {
        return SuportedLanguages.Contains(Language);
    }

    public void SetSuportedLanguages(List<int> langList)
    {
        SuportedLanguages.Clear();
        foreach (var i in langList)
        {
            SuportedLanguages.Add((Language)i);
        }
    }

    public string GetString(int key)
    {
        return GetString(key, null);
    }
    
    public string GetString(string key)
    {
        return GetString(key, null);
    }

    /// <summary>
    /// 根据字典主键获取字典内容字符串。
    /// </summary>
    /// <param name="key">字典主键。</param>
    /// <param name="args">字典参数。</param>
    /// <returns>要获取的字典内容字符串。</returns>
    public string GetString(string key, params object[] args)
    {
        if (string.IsNullOrEmpty(key))
        {
            Log.Error("Key is invalid. {0}", key);
#if UNITY_EDITOR
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.LuaTraceback();
            }
#endif
            
#if DEBUG
            return "Key is invalid";
#endif
            return string.Empty;
        }

        // 如果看起来这个就是一个int key的话，转成int
        if (key[0] >= '0' && key[0] <= '9')
        {
            int ikey = 0;
            if (int.TryParse(key, out ikey))
            {
                return GetString(ikey, args);
            }
        }

        DialogEntry entry;
        if (!m_Dictionary.TryGetValue(key, out entry))
        {
#if DEBUG
            return string.Format("<NoKey>{0}", key);
#endif
           // Log.Error(string.Format("<NoKey>{0}", key));
            return string.Empty;
        }

        // 每个词条缓式处理一遍
        if (entry.hasCRLF)
        {
            if (entry.originDlg.Contains("\\n"))
            {
                entry.originDlg = entry.originDlg.Replace("\\n", "\n");
                m_Dictionary[key] = entry;
            }

            entry.hasCRLF = false;
        }

        try
        {
            if (args != null && args.Length > 0)
            {
                string ret = string.Format(entry.originDlg, args);
                return ret;
            }
        }
        catch (Exception exception)
        {
#if UNITY_EDITOR
            Log.Error("string format error - {0}!", key);
#endif
        }

        return entry.originDlg;
    }
    
    /// <summary>
    /// 根据字典主键获取字典内容字符串。
    /// </summary>
    /// <param name="key">字典主键。</param>
    /// <param name="args">字典参数。</param>
    /// <returns>要获取的字典内容字符串。</returns>
    public string GetString(int key, params object[] args)
    {
        if (key <= 0)
        {
            Log.Error("Key is invalid. {0}", key);
            
#if UNITY_EDITOR
            if (GameEntry.Lua != null)
            {
                GameEntry.Lua.LuaTraceback();
            }
#endif
            
#if DEBUG
            return "Key is invalid";
#endif
            return string.Empty;
        }

        DialogEntry entry;
        if (!m_IntDictionary.TryGetValue(key, out entry))
        {
#if DEBUG
            return string.Format("<NoKey>{0}", key);
#endif
            //Log.Error(string.Format("<NoKey>{0}", key));
            return string.Empty;
        }

        // 每个词条缓式处理一遍
        if (entry.hasCRLF)
        {
            if (entry.originDlg.Contains("\\n"))
            {
                entry.originDlg = entry.originDlg.Replace("\\n", "\n");
                m_IntDictionary[key] = entry;
            }

            entry.hasCRLF = false;
        }

        try
        {
            if (args != null && args.Length > 0)
            {
                string ret = string.Format(entry.originDlg, args);
                return ret;
            }
        }
        catch (Exception exception)
        {
#if UNITY_EDITOR
            Log.Error("string format error2 - {0}!", key);
#endif
        }

        return entry.originDlg;
    }
 
    /// <summary>
    /// 是否存在字典。
    /// </summary>
    /// <param name="key">字典主键。</param>
    /// <returns>是否存在字典。</returns>
    private bool HasRawString(string key)
    {
        if (string.IsNullOrEmpty(key))
        {
            throw new Exception("Key is invalid.");
        }

        return m_Dictionary.ContainsKey(key);
    }
    
    private bool HasRawString(int key)
    {
        return m_IntDictionary.ContainsKey(key);
    }

    private bool AddRawString(ReadOnlySpan<char> key, string value)
    {
        DialogEntry entry = new DialogEntry();
        entry.originDlg = value;
        entry.hasCRLF = true;
        
        // 表示是一个数字
        if (key[0] >= '0' && key[0] <= '9')
        {
            int iKey = key.ToInt();
            
#if UNITY_EDITOR
            string s1 = key.ToString();
            string s2 = iKey.ToString();
            if (s1 != s2)
            {
                Log.Error("Language Key : {0} - not supported!", s1);
            }
#endif
            
            if (HasRawString(iKey))
            {
                return false;
            }

            m_IntDictionary[iKey] = entry;
        }
        else
        {
            string sKey = key.ToString();
            
            if (HasRawString(sKey))
            {
                return false;
            }

            m_Dictionary[sKey] = entry;
        }
        
        return true;
    }
    
    //获取语言名称
    public string GetLanguageName()
    {
        switch (Language)
        {
            case Language.ChineseSimplified:
                return "zh_CN";
            case Language.ChineseTraditional:
                return "zh_TW";
            case Language.English:
                return "en";
            case Language.PortuguesePortugal:
                return "pt";
            case Language.Turkish:
                return "tr";
            case Language.French:
                return "fr";
            case Language.Norwegian:
                return "no";
            case Language.Korean:
                return "ko";
            case Language.Japanese:
                return "ja";
            case Language.Dutch:
                return "nl";
            case Language.Italian:
                return "it";
            case Language.German:
                return "de";
            case Language.Spanish:
                return "es";
            case Language.Russian:
                return "ru";
            case Language.Arabic:
                return "ar";
            case Language.Persian:
                return "fa"; // 波斯语的 ISO 639-1 代码是 "fa"
            case Language.Thai:
                return "th";
            case Language.Afrikaans:
                return "af";
            case Language.Albanian:
                return "sq";
            case Language.Basque:
                return "eu";
            case Language.Belarusian:
                return "be";
            case Language.Bulgarian:
                return "bg";
            case Language.Catalan:
                return "ca";
            case Language.Croatian:
                return "hr";
            case Language.Czech:
                return "cs";
            case Language.Danish:
                return "da";
            case Language.Estonian:
                return "et";
            case Language.Faroese:
                return "fo";
            case Language.Finnish:
                return "fi";
            case Language.Georgian:
                return "ka";
            case Language.Greek:
                return "el";
            case Language.Hebrew:
                return "he";
            case Language.Hungarian:
                return "hu";
            case Language.Icelandic:
                return "is";
            case Language.Indonesian:
                return "id";
            case Language.Latvian:
                return "lv";
            case Language.Lithuanian:
                return "lt";
            case Language.Macedonian:
                return "mk";
            case Language.Malayalam:
                return "ml";
            case Language.Polish:
                return "pl";
            case Language.PortugueseBrazil:
                return "pt_BR";
            case Language.Romanian:
                return "ro";
            case Language.SerboCroatian:
                return "sh";
            case Language.SerbianCyrillic:
                return "sr_Cyrl";
            case Language.SerbianLatin:
                return "sr_Latn";
            case Language.Slovak:
                return "sk";
            case Language.Slovenian:
                return "sl";
            case Language.Swedish:
                return "sv";
            case Language.Ukrainian:
                return "uk";
            case Language.Vietnamese:
                return "vi";
          
            case Language.Unspecified:
            default:
                return "en";
        }
    }
    

    public int GetLanguage()
    {
        return (int) Language;
    }
    
    public void SetLanguage(int language)
    {
        Language = (Language)language;
        GameEntry.Setting.UserLanguage = Language;
    }

    //通过当前使用语言来获取对应字体
    public Font GetFontByLanguage()
    {
        return null; 
    }

}





