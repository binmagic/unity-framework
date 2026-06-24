#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;

namespace VEngine.Editor
{
    [Serializable]
    public class GroupsEditor
    {
        private const int k_SearchHeight = 20;
        [SerializeField] private MultiColumnHeaderState multiColumnHeaderState;
        [SerializeField] private TreeViewState treeViewState;

        private AssetTreeView assetTree;

        [NonSerialized] private Texture2D cogIcon;

        private bool hierarchicalSearch;
        private SearchField searchField;

        [NonSerialized] private List<GUIStyle> searchStyles;
        internal int selected;

        private VerticalSplitter verticalSplitter;


        public Settings settings { get; private set; }

        private GUIStyle GetStyle(string styleName)
        {
            var s = GUI.skin.FindStyle(styleName);
            if (s == null)
            {
                s = EditorGUIUtility.GetBuiltinSkin(EditorSkin.Inspector).FindStyle(styleName);
                if (s == null)
                {
                    Logger.E("Missing built-in gui style " + styleName);
                    s = new GUIStyle();
                }
            }

            return s;
        }

        public void OnEnable()
        {
        }

        public void OnDisable()
        {
            settings.Save();
        }

        public bool OnGUI(Rect position)
        {
            if (settings == null)
            {
                settings = Settings.GetDefaultSettings();
            }

            if (settings.manifests.Count == 0)
            {
                GUILayout.Label("点击 Create 在设置中创建一个打包清单");
                if (GUILayout.Button("Create"))
                {
                    CreateManifest();
                }

                return false;
            }

            var inRectY = position.yMax;
            DrawTree(position, inRectY);
            DrawToolbar(new Rect(position.xMin, position.yMin, position.width, k_SearchHeight));
            return verticalSplitter.resizing;
        }

        private void DrawTree(Rect position, float inRectY)
        {
            var treeRect = new Rect(
                position.xMin,
                position.yMin + k_SearchHeight + 4,
                position.width,
                inRectY - k_SearchHeight - 4);
            if (assetTree == null)
            {
                if (treeViewState == null)
                {
                    treeViewState = new TreeViewState();
                }

                var headerState =
                    AssetTreeView.CreateDefaultMultiColumnHeaderState(); // multiColumnTreeViewRect.width);
                if (MultiColumnHeaderState.CanOverwriteSerializedFields(multiColumnHeaderState, headerState))
                {
                    MultiColumnHeaderState.OverwriteSerializedFields(multiColumnHeaderState, headerState);
                }

                multiColumnHeaderState = headerState;

                searchField = new SearchField();
                assetTree = new AssetTreeView(treeViewState, multiColumnHeaderState, this);
                assetTree.Reload();
            }

            if (verticalSplitter == null)
            {
                verticalSplitter = new VerticalSplitter
                {
                    percent = 0.8f
                };
            }

            verticalSplitter.OnGUI(position);
            assetTree.OnGUI(treeRect);
        }

        private void DrawToolbar(Rect toolbarPos)
        {
            if (searchStyles == null)
            {
                searchStyles = new List<GUIStyle>
                {
                    GetStyle("ToolbarSeachTextFieldPopup"),
                    GetStyle("ToolbarSeachCancelButton"),
                    GetStyle("ToolbarSeachCancelButtonEmpty")
                };
            }

            GetStyle("ToolbarButton");
            if (cogIcon == null)
            {
                cogIcon = EditorGUIUtility.FindTexture("_Popup");
            }

            GUILayout.BeginArea(new Rect(0, 0, toolbarPos.width, k_SearchHeight));
            GUILayout.BeginHorizontal(EditorStyles.toolbar);
            {
                DrawManifests();
                DrawView();
                DrawRefresh();
                GUILayout.FlexibleSpace();
                DrawScriptPlayMode();
                DrawBuild();
                Constants.BuildSize.text = EditorUtility.FormatBytes(settings.manifests[selected].size);
                GUILayout.Label(Constants.BuildSize);

                GUILayout.Space(4);
                var searchRect = GUILayoutUtility.GetRect(0, toolbarPos.width * 0.6f, 16f, 16f, searchStyles[0],
                    GUILayout.MinWidth(65), GUILayout.MaxWidth(300));
                var popupPosition = searchRect;
                popupPosition.width = 20;

                if (Event.current.type == EventType.MouseDown && popupPosition.Contains(Event.current.mousePosition))
                {
                    var menu = new GenericMenu();
                    menu.AddItem(new GUIContent("Hierarchical Search"), hierarchicalSearch, OnClickHierarchicalSearch);
                    menu.DropDown(popupPosition);
                }
                else
                {
                    var baseSearch = hierarchicalSearch ? assetTree.customSearchString : assetTree.searchString;
                    var searchString = searchField.OnGUI(searchRect, baseSearch, searchStyles[0], searchStyles[1],
                        searchStyles[2]);
                    if (baseSearch != searchString)
                    {
                        assetTree?.Search(searchString);
                    }
                }
            }
            GUILayout.EndHorizontal();
            GUILayout.EndArea();
        }

        private void DrawScriptPlayMode()
        {
            Constants.RuntimeMode.text = "Script Play Mode - " + settings.scriptPlayMode;
            var rect = GUILayoutUtility.GetRect(Constants.RuntimeMode, EditorStyles.toolbarDropDown);
            if (EditorGUI.DropdownButton(rect, Constants.RuntimeMode, FocusType.Keyboard,
                EditorStyles.toolbarDropDown))
            {
                var menu = new GenericMenu();
                var names = Enum.GetNames(typeof(ScriptPlayMode));
                foreach (var name in names)
                {
                    var mode = (ScriptPlayMode) Enum.Parse(typeof(ScriptPlayMode), name);
                    menu.AddItem(new GUIContent(name), settings.scriptPlayMode == mode,
                        data => { settings.scriptPlayMode = mode; }, null);
                }

                menu.DropDown(rect);
            }
        }


        private void DrawRefresh()
        {
            if (GUILayout.Button(Constants.Refresh, EditorStyles.toolbarButton))
            {
                assetTree.Reload();
                assetTree.Repaint();
            }
        }

        private void OnClickHierarchicalSearch()
        {
            hierarchicalSearch = !hierarchicalSearch;
            assetTree.SwapSearchType();
            assetTree.Reload();
            assetTree.Repaint();
        }

        private void DrawBuild()
        {
            var rect = GUILayoutUtility.GetRect(Constants.Build, EditorStyles.toolbarDropDown);
            if (EditorGUI.DropdownButton(rect, Constants.Build, FocusType.Keyboard,
                EditorStyles.toolbarDropDown))
            {
                var menu = new GenericMenu();
                menu.AddItem(new GUIContent("Bundles"), false, data =>
                {
                    var manifest = settings.manifests[selected];
                    BuildScript.BuildBundle(manifest);
                    Reload();
                }, null);
                menu.AddSeparator("");
                menu.AddItem(Constants.BuildBundles, false, _ =>
                {
                    BuildScript.BuildBundles();
                    Reload();
                }, null);
                menu.AddSeparator("");
                menu.AddItem(Constants.BuildPlayer, false, _ => { BuildScript.BuildPlayer(); }, null);

                if (settings.playerGroups.Count > 0)
                {
                    for (var index = 0; index < settings.playerGroups.Count; index++)
                    {
                        var playerGroups = settings.playerGroups[index];
                        menu.AddItem(new GUIContent(Constants.BuildPlayer.text + " - " + playerGroups.name), false,
                            data =>
                            {
                                settings.buildPlayerGroupsIndex = (int) data;
                                settings.Save();
                                BuildScript.BuildPlayer();
                            },
                            index);
                    }
                }

                menu.AddSeparator("");
                menu.AddItem(Constants.BuildCopy, false, _ => { BuildScript.CopyToStreamingAssets(); }, null);
                menu.AddItem(Constants.BuildClear, false, _ =>
                {
                    BuildScript.Clear();
                    Reload();
                }, null);
                menu.DropDown(rect);
            }
        }

        private void DrawView()
        {
            var rect = GUILayoutUtility.GetRect(Constants.View, EditorStyles.toolbarDropDown);
            if (EditorGUI.DropdownButton(rect, Constants.View, FocusType.Keyboard,
                EditorStyles.toolbarDropDown))
            {
                var menu = new GenericMenu();
                menu.AddItem(new GUIContent("Settings"), false, _ =>
                    {
                        var target = Settings.GetDefaultSettings();
                        EditorUtility.PingWithSelected(target);
                    },
                    null);
                menu.AddItem(new GUIContent("Manifest"), false,
                    _ => { EditorUtility.PingWithSelected(settings.manifests[selected]); },
                    null);
                menu.AddItem(new GUIContent("Build Path"), false, _ => { MenuItems.ViewBuildPath(); }, null);
                menu.AddItem(new GUIContent("Download Path"), false, _ => { MenuItems.ViewDownloadPath(); },
                    null);
                menu.DropDown(rect);
            }
        }

        private void DrawManifests()
        {
            var content = new GUIContent(settings.manifests[selected].name);
            var rect = GUILayoutUtility.GetRect(content, EditorStyles.toolbarDropDown, GUILayout.MinWidth(128));
            if (EditorGUI.DropdownButton(rect, content, FocusType.Passive, EditorStyles.toolbarDropDown))
            {
                var menu = new GenericMenu();
                for (var index = 0; index < settings.manifests.Count; index++)
                {
                    var manifest = settings.manifests[index];
                    if (manifest == null)
                    {
                        continue;
                    }

                    menu.AddItem(new GUIContent(manifest.name), selected == index, data =>
                    {
                        var newIndex = (int) data;
                        if (selected != newIndex)
                        {
                            selected = newIndex;
                            Reload();
                        }
                    }, index);
                }

                menu.AddSeparator("");
                menu.AddItem(new GUIContent("Create New..."), false, data => { CreateManifest(); }, null);
                menu.DropDown(rect);
            }
        }

        private void CreateManifest()
        {
            var path = UnityEditor.EditorUtility.SaveFilePanel("创建清单", $"{Settings.dataPath}", "New Manifest", "asset");
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            selected = settings.AddManifest(FileUtil.GetProjectRelativePath(path));
            Reload();
        }

        public void Reload()
        {
            if (assetTree != null)
            {
                assetTree.Reload();
                assetTree.Repaint();
            }
        }

        public static class Constants
        {
            public static readonly GUIContent RuntimeMode =
                new GUIContent("Runtime Mode",
                    "编辑器运行模式，主要包含: 1.Simulation 可以跳过打包快速运行；2.Preload 需要打包，但是不触发更新；3.Incremental 需要打包会触发更新，资源要复制到 StreamingAssets");


            public static readonly GUIContent View = new GUIContent("View", "打包资源的输出目录，点击下拉框，可以对改目录进行打开，复制，清理操作");

            public static readonly GUIContent BuildCopy = new GUIContent("Copy To StreamingAssets",
                "复制 Build Path 目录的资源到工程下的 Assets/StreamingAssets 下");

            public static readonly GUIContent BuildClear = new GUIContent("Clear", "清空 Build Path 目录");
            public static readonly GUIContent Build = new GUIContent("Build", "打包");
            public static readonly GUIContent BuildBundles = new GUIContent("All Bundles", "构建资源，并生成对应的 AssetBundles");
            public static readonly GUIContent BuildPlayer = new GUIContent("Player", "构建播放器");
            public static readonly GUIContent Refresh = new GUIContent("Refresh", "刷新树状视图");
            public static readonly GUIContent BuildSize = new GUIContent(string.Empty, "打包后的 Bundles 的大小");
        }
    }
}
#endif



