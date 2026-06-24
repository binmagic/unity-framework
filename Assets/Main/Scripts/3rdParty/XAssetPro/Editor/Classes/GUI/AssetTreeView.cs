#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEditor.IMGUI.Controls;
using UnityEngine;
using Object = UnityEngine.Object;
using Random = UnityEngine.Random;

namespace VEngine.Editor
{
    public sealed class AssetTreeViewItem : TreeViewItem
    {
        public readonly Texture2D assetIcon;

        internal AssetTreeViewItem(Group a, int depth = 0) : base(
            a != null ? a.name.GetHashCode() : Random.Range(int.MinValue, int.MaxValue),
            depth, a != null ? a.name : "failed")
        {
            group = a;
        }

        public AssetTreeViewItem(Asset a, int depth) : base(
            a?.path.GetHashCode() ?? Random.Range(int.MinValue, int.MaxValue),
            depth, a != null ? a.path : "failed")
        {
            asset = a;
            if (a != null)
            {
                assetIcon = AssetDatabase.GetCachedIcon(a.path) as Texture2D;
            }
        }

        public bool IsGroup => group != null;

        public Asset asset { get; set; }
        public Group group { get; set; }
        public bool isRenaming { get; set; }
    }

    public class AssetTreeView : TreeView
    {
        private readonly Dictionary<string, ulong> buildSize = new Dictionary<string, ulong>();
        private readonly GroupsEditor editor;

        private readonly Dictionary<AssetTreeViewItem, bool>
            searchedEntries = new Dictionary<AssetTreeViewItem, bool>();

        private readonly ColumnID[] sortOptions =
        {
            ColumnID.Path, ColumnID.Size, ColumnID.Type, ColumnID.Label, ColumnID.Bundle, ColumnID.Dirty
        };

        private Dictionary<string, AssetBuild> buildAssets = new Dictionary<string, AssetBuild>();

        private Dictionary<string, BundleBuild> buildBundles = new Dictionary<string, BundleBuild>();
        private Dictionary<string, GroupBuild> buildGroups = new Dictionary<string, GroupBuild>();

        internal string customSearchString = string.Empty;
        private string firstSelectedGroup;
        private GUIStyle labelStyle;


        private Manifest manifest;

        private Dictionary<string, Asset> pathWithAssets = new Dictionary<string, Asset>();

        internal AssetTreeView(TreeViewState state, MultiColumnHeaderState headerState,
            GroupsEditor groupEditor) : base(state,
            new MultiColumnHeader(headerState))
        {
            showBorder = true;
            editor = groupEditor;
            columnIndexForTreeFoldouts = 0;
            multiColumnHeader.sortingChanged += OnSortingChanged;
        }

        internal static MultiColumnHeaderState CreateDefaultMultiColumnHeaderState()
        {
            return new MultiColumnHeaderState(GetColumns());
        }

        private static MultiColumnHeaderState.Column[] GetColumns()
        {
            var retVal = new[]
            {
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(@"Group \ Path"),
                    minWidth = 200,
                    width = 300,
                    headerTextAlignment = TextAlignment.Left,
                    canSort = true,
                    autoResize = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Size", "带依赖的大小"),
                    minWidth = 64,
                    width = 72,
                    maxWidth = 96,
                    headerTextAlignment = TextAlignment.Left,
                    canSort = false,
                    autoResize = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent(EditorGUIUtility.FindTexture("FilterByType"), "Asset type"),
                    minWidth = 20,
                    width = 20,
                    maxWidth = 20,
                    headerTextAlignment = TextAlignment.Left,
                    canSort = false,
                    autoResize = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Label"),
                    minWidth = 140,
                    width = 160,
                    headerTextAlignment = TextAlignment.Left,
                    autoResize = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Bundle(Size)", "AssetBundle 的名字和大小。"),
                    minWidth = 140,
                    width = 160,
                    headerTextAlignment = TextAlignment.Left,
                    autoResize = true
                },
                new MultiColumnHeaderState.Column
                {
                    headerContent = new GUIContent("Dirty", "资源的 meta 或者 自身 是否有修改。"),
                    minWidth = 140,
                    width = 200,
                    canSort = true,
                    headerTextAlignment = TextAlignment.Left,
                    autoResize = true
                }
            };
            return retVal;
        }

        public override void OnGUI(Rect rect)
        {
            base.OnGUI(rect);
            if (Event.current.type == EventType.MouseDown && Event.current.button == 0 &&
                rect.Contains(Event.current.mousePosition))
            {
                SetSelection(new int[0], TreeViewSelectionOptions.FireSelectionChanged);
            }
        }

        protected override void BeforeRowsGUI()
        {
            base.BeforeRowsGUI();

            switch (Event.current.type)
            {
                case EventType.Repaint:
                {
                    var rows = GetRows();
                    if (rows.Count > 0)
                    {
                        GetFirstAndLastVisibleRows(out var first, out var last);
                        for (var rowId = first; rowId <= last; rowId++)
                        {
                            var aeI = (AssetTreeViewItem) rows[rowId];
                            if (aeI?.asset != null)
                            {
                                DefaultStyles.backgroundEven.Draw(GetRowRect(rowId), false, false, false, false);
                            }
                        }
                    }

                    break;
                }
            }
        }

        protected override IList<TreeViewItem> BuildRows(TreeViewItem root)
        {
            if (!string.IsNullOrEmpty(customSearchString))
            {
                SortChildren(root);
                return Search(base.BuildRows(root));
            }

            SortChildren(root);
            return base.BuildRows(root);
        }

        protected internal IList<TreeViewItem> Search(IList<TreeViewItem> rows)
        {
            if (rows == null)
            {
                return new List<TreeViewItem>();
            }

            searchedEntries.Clear();
            return rows.OfType<AssetTreeViewItem>()
                .Where(row => SearchHierarchical(row, customSearchString))
                .Cast<TreeViewItem>()
                .ToList();
        }

        protected override void SelectionChanged(IList<int> selectedIds)
        {
            if (selectedIds.Count == 1)
            {
                var item = FindItemInVisibleRows(selectedIds[0]);
                if (item != null && item.group != null)
                {
                    firstSelectedGroup = item.group.name;
                }
            }

            base.SelectionChanged(selectedIds);

            var selectedObjects = new Object[selectedIds.Count];
            for (var i = 0; i < selectedIds.Count; i++)
            {
                var item = FindItemInVisibleRows(selectedIds[i]);
                if (item != null)
                {
                    if (item.group != null)
                    {
                        selectedObjects[i] = item.group;
                    }
                    else if (item.asset != null)
                    {
                        selectedObjects[i] = item.asset.target;
                    }
                }
            }

            // Make last selected group the first object in the array
            if (selectedObjects.Length > 1)
            {
                if (selectedObjects[0].name == firstSelectedGroup)
                {
                    var temp = selectedObjects[0];
                    selectedObjects[0] = selectedObjects[selectedIds.Count - 1];
                    selectedObjects[selectedIds.Count - 1] = temp;
                }
            }

            Selection.objects = selectedObjects; // change selection
        }

        protected bool SearchHierarchical(TreeViewItem item, string search)
        {
            var aeItem = (AssetTreeViewItem) item;
            if (aeItem == null || search == null)
            {
                return false;
            }

            if (searchedEntries.ContainsKey(aeItem))
            {
                return searchedEntries[aeItem];
            }

            var isMatching = DoesItemMatchSearch(aeItem, search) || IsInMatchingGroup(aeItem);
            searchedEntries.Add(aeItem, isMatching);

            if ((!isMatching || aeItem.IsGroup) && aeItem.children != null)
            {
                foreach (var c in aeItem.children)
                {
                    if (SearchHierarchical(c, search))
                    {
                        return true;
                    }
                }
            }

            return isMatching;
        }

        protected override bool DoesItemMatchSearch(TreeViewItem item, string search)
        {
            if (string.IsNullOrEmpty(search))
            {
                return true;
            }

            var aeItem = (AssetTreeViewItem) item;
            if (aeItem == null)
            {
                return false;
            }

            //check if item matches.
            if (aeItem.displayName.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }

            if (aeItem.asset != null &&
                aeItem.asset.path.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return true;
            }

            return false;
        }


        private bool IsInMatchingGroup(AssetTreeViewItem aeItem)
        {
            var current = aeItem;
            while (current != null && !current.IsGroup)
            {
                current = current.parent as AssetTreeViewItem;
            }

            return current != null && current.IsGroup && searchedEntries.ContainsKey(current) &&
                   searchedEntries[current];
        }

        public ulong GetBundleSize(string bundle)
        {
            if (string.IsNullOrEmpty(bundle))
            {
                return 0;
            }

            if (buildBundles.TryGetValue(bundle, out var value))
            {
                return value.size;
            }

            return 0;
        }

        public ulong GetAssetSize(Asset asset)
        {
            string path = asset.path;
            if (!buildSize.TryGetValue(path, out var size))
            {
                if (!buildAssets.TryGetValue(path, out var value))
                {
                    string bundle = asset.PackWithBundleMode();
                    ulong bundle_size = GetBundleSize(bundle);
                    if (bundle_size > 0)
                    {
                        return bundle_size;
                    }
                    
                    buildSize[path] = 0;
                    return 0;
                }

                size = 0;
                size += GetBundleSize(value.bundle);
                foreach (var bundle in value.bundles)
                {
                    size += GetBundleSize(bundle);
                }

                buildSize[path] = size;
            }

            return size;
        }


        protected override TreeViewItem BuildRoot()
        {
            var root = new TreeViewItem(-1, -1);
            manifest = editor.settings.manifests[editor.selected];

            buildSize.Clear();

            pathWithAssets = manifest.GetAssets();
            Build b = manifest.GetCurrentBuild();
            buildBundles = b.GetBundles();
            buildAssets = b.GetAssets();
            buildGroups = b.GetGroups();

            foreach (var group in manifest.groups)
            {
                var groupItem = new AssetTreeViewItem(group);
                if (group.assets.Count > 0)
                {
                    foreach (var asset in group.assets)
                    {
                        var assetItem = new AssetTreeViewItem(asset, groupItem.depth + 1);
                        groupItem.AddChild(assetItem);
                        asset.size = GetAssetSize(asset);
                        if (editor.settings.showEntryWithTopOnly)
                        {
                            continue;
                        }
                        var dirty = false;
                        foreach (var child in asset.GetChildren())
                        {
                            if (!pathWithAssets.TryGetValue(child, out var ca))
                            {
                                ca = Asset.Create(child, group, asset.label, asset.path);
                                pathWithAssets.Add(child, ca);
                            }

                            ca.readOnly = true;
                            ca.rootPath = asset.path;
                            ca.parentGroup = group;
                            ca.size = GetAssetSize(ca);
                            ca.dirty = !buildAssets.TryGetValue(ca.path, out var cav) || cav.dirty;
                            var childItem = new AssetTreeViewItem(ca, assetItem.depth + 1);
                            assetItem.AddChild(childItem);
                            if (!dirty && ca.dirty)
                            {
                                dirty = true;
                            }
                        }

                        if (asset.isFolder)
                        {
                            asset.dirty = dirty;
                        }
                        else
                        {
                            asset.dirty = !buildAssets.TryGetValue(asset.path, out var value) || value.dirty;
                        }
                    }
                }

                group.size = 0;
                if (buildGroups.TryGetValue(group.name, out var groupBuild))
                {
                    foreach (var bundle in groupBuild.bundles)
                    {
                        group.size += GetBundleSize(bundle);
                    }
                }

                root.AddChild(groupItem);
            }

            return root;
        }

        protected override void RowGUI(RowGUIArgs args)
        {
            if (labelStyle == null)
            {
                labelStyle = new GUIStyle("PR Label");
                if (labelStyle.name == "StyleNotFoundError")
                {
                    labelStyle = GUI.skin.GetStyle("Label");
                }
            }

            var item = (AssetTreeViewItem) args.item;
            if (item == null || item.group == null && item.asset == null)
            {
                using (new EditorGUI.DisabledScope(true))
                {
                    base.RowGUI(args);
                }
            }
            else if (item.group != null)
            {
                if (item.isRenaming && !args.isRenaming)
                {
                    item.isRenaming = false;
                }

                using (new EditorGUI.DisabledScope(item.group.readOnly))
                {
                    base.RowGUI(args);
                    DefaultGUI.Label(args.GetCellRect(1), $"{EditorUtility.FormatBytes(item.group.size)}",
                        args.selected, args.focused);
                }
            }
            else if (item.asset != null && !args.isRenaming)
            {
                using (new EditorGUI.DisabledScope(item.asset.parentGroup.readOnly || item.asset.readOnly))
                {
                    for (var i = 0; i < args.GetNumVisibleColumns(); ++i)
                    {
                        CellGUI(args.GetCellRect(i), args.item as AssetTreeViewItem, args.GetColumn(i), ref args);
                    }
                }
            }
        }

        private void CellGUI(Rect cellRect, AssetTreeViewItem viewItem, int column, ref RowGUIArgs args)
        {
            CenterRectUsingSingleLineHeight(ref cellRect);
            switch ((ColumnID) column)
            {
                case ColumnID.Path: // path
                    // The rect is assumed indented and sized after the content when pinging
                    var indent = GetContentIndent(viewItem) + extraSpaceBeforeIconAndLabel;
                    cellRect.xMin += indent;
                    labelStyle.richText = true;
                    if (Event.current.type == EventType.Repaint)
                    {
                        labelStyle.Draw(cellRect, viewItem.asset.path, false, false, args.selected, args.focused);
                    }

                    break;
                case ColumnID.Size:
                    DefaultGUI.Label(cellRect, $"{EditorUtility.FormatBytes(viewItem.asset.size)}", args.selected,
                        args.focused);
                    break;
                case ColumnID.Type: // type
                    GUI.DrawTexture(cellRect, viewItem.assetIcon, ScaleMode.ScaleToFit, true);
                    break;
                case ColumnID.Label: // label
                    viewItem.asset.label = EditorGUI.TextField(cellRect, viewItem.asset.label);
                    break;

                case ColumnID.Bundle: // bundle
                    if (!viewItem.asset.isFolder)
                    {
                        viewItem.asset.bundle = viewItem.asset.PackWithBundleMode();
                        DefaultGUI.Label(cellRect,
                            $"{viewItem.asset.bundle}({EditorUtility.FormatBytes(GetBundleSize(viewItem.asset.bundle))})",
                            args.selected, args.focused);
                    }

                    break;

                case ColumnID.Dirty: // time  
                    DefaultGUI.Label(cellRect, viewItem.asset.dirty.ToString(),
                        args.selected, args.focused);
                    break;
            }
        }

        protected override void ContextClicked()
        {
            var selectedNodes = new List<AssetTreeViewItem>();
            foreach (var nodeId in GetSelection())
            {
                var item = (AssetTreeViewItem) FindItem(nodeId, rootItem);
                if (item != null)
                {
                    selectedNodes.Add(item);
                }
            }

            var menu = new GenericMenu();
            if (selectedNodes.Count == 0)
            {
                menu.AddItem(new GUIContent("Create/New Group for Bundled Assets"), false,
                    _ =>
                    {
                        manifest.AddGroup("NewBundledGroup");
                        Reload();
                    }, "");
                menu.AddItem(new GUIContent("Create/New Group for Raw Assets"), false,
                    _ =>
                    {
                        manifest.AddGroup("NewRawGroup", true);
                        Reload();
                    }, "");
            }
            else
            {
                //拷贝路径右键操作
                if (selectedNodes.Count == 1)
                {
                    var item = selectedNodes[0];
                    menu.AddItem(new GUIContent("Copy Name"), false,
                        _ => { GUIUtility.systemCopyBuffer = item.displayName; }, null);
                }

                var isGroup = false;
                var isEntry = false;
                for (var index = 0; index < selectedNodes.Count; index++)
                {
                    var item = selectedNodes[index];
                    if (item.group != null)
                    {
                        isGroup = true;
                        if (item.group.readOnly)
                        {
                            selectedNodes.RemoveAt(index);
                            index--;
                        }
                    }
                    else if (item.asset != null)
                    {
                        isEntry = true;
                        if (item.asset.readOnly)
                        {
                            selectedNodes.RemoveAt(index);
                            index--;
                        }
                    }
                }

                if (!(isEntry && isGroup))
                {
                    if (selectedNodes.Count == 1)
                    {
                        var item = selectedNodes[0];
                        if (item.IsGroup)
                        {
                            menu.AddItem(new GUIContent("Rename"), false, _ => { BeginRename(item); }, null);
                        }
                    }

                    if (selectedNodes.Count >= 1)
                    {
                        menu.AddItem(new GUIContent("Remove"), false, _ =>
                        {
                            if (isEntry)
                            {
                                RemoveEntry(selectedNodes);
                            }

                            if (isGroup)
                            {
                                RemoveGroup(selectedNodes);
                            }
                        }, null);
                    }
                }
            }

            menu.ShowAsContext();
        }

        protected override void DoubleClickedItem(int id)
        {
            var item = (AssetTreeViewItem) FindItem(id, rootItem);
            if (item != null)
            {
                if (item.group != null)
                {
                    Selection.activeObject = item.group;
                    EditorGUIUtility.PingObject(item.group);
                }
                else if (item.asset != null)
                {
                    Selection.activeObject = item.asset.target;
                    EditorGUIUtility.PingObject(item.asset.target);
                }
            }
        }

        protected string CheckForRename(TreeViewItem item, bool isActualRename)
        {
            var rename = string.Empty;
            if (item is AssetTreeViewItem assetItem)
            {
                if (assetItem.group != null && !assetItem.group.readOnly)
                {
                    rename = "Rename";
                }

                if (isActualRename)
                {
                    assetItem.isRenaming = !string.IsNullOrEmpty(rename);
                }
            }

            return rename;
        }

        protected override bool CanRename(TreeViewItem item)
        {
            return !string.IsNullOrEmpty(CheckForRename(item, true));
        }

        private AssetTreeViewItem FindItemInVisibleRows(int id)
        {
            var rows = GetRows();
            foreach (var r in rows)
            {
                if (r.id == id)
                {
                    return r as AssetTreeViewItem;
                }
            }

            return null;
        }

        protected override void RenameEnded(RenameEndedArgs args)
        {
            var item = FindItemInVisibleRows(args.itemID);
            if (item != null)
            {
                item.isRenaming = false;
            }

            if (args.originalName == args.newName)
            {
                return;
            }

            if (item != null)
            {
                item.group.name = args.newName;
                var path = AssetDatabase.GetAssetPath(item.group);
                var error = AssetDatabase.RenameAsset(path, args.newName);
                if (!string.IsNullOrEmpty(error))
                {
                    EditorUtility.SaveAsset(item.group);
                    args.acceptedRename = true;
                }
                else
                {
                    args.acceptedRename = false;
                }

                Reload();
            }
        }

        protected override bool CanMultiSelect(TreeViewItem item)
        {
            return true;
        }

        protected override bool CanBeParent(TreeViewItem item)
        {
            var aeItem = (AssetTreeViewItem) item;
            if (aeItem != null && aeItem.group != null)
            {
                return true;
            }

            return false;
        }

        protected override void KeyEvent()
        {
            if (Event.current.type == EventType.KeyUp && Event.current.keyCode == KeyCode.Delete &&
                GetSelection().Count > 0)
            {
                var selectedNodes = new List<AssetTreeViewItem>();
                var allGroups = true;
                var allEntries = true;
                foreach (var nodeId in GetSelection())
                {
                    var item = FindItemInVisibleRows(nodeId);
                    if (item != null)
                    {
                        selectedNodes.Add(item);
                        if (item.asset == null)
                        {
                            allEntries = false;
                        }
                        else
                        {
                            allGroups = false;
                        }
                    }
                }

                if (allEntries)
                {
                    RemoveEntry(selectedNodes);
                }

                if (allGroups)
                {
                    RemoveGroup(selectedNodes);
                }
            }
        }

        protected void RemoveGroup(object context)
        {
            if (UnityEditor.EditorUtility.DisplayDialog(Constants.TIPS_TITLE_DELETE_GROUPS,
                Constants.TIPS_CONTENT_DELETE_REQUEST, Constants.TIPS_OK, Constants.TIPS_CANCEL))
            {
                var selectedNodes = (List<AssetTreeViewItem>) context;
                if (selectedNodes == null || selectedNodes.Count < 1)
                {
                    return;
                }

                foreach (var item in selectedNodes)
                {
                    manifest.RemoveGroup(item.group);
                }

                Reload();
            }
        }

        protected void RemoveEntry(object context)
        {
            if (UnityEditor.EditorUtility.DisplayDialog(Constants.TIPS_TITLE_DELETE_ASSETS,
                Constants.TIPS_CONTENT_DELETE_REQUEST, Constants.TIPS_OK, Constants.TIPS_CANCEL))
            {
                var selectedNodes = (List<AssetTreeViewItem>) context;
                if (selectedNodes == null || selectedNodes.Count < 1)
                {
                    return;
                }

                var groups = new HashSet<Group>();
                foreach (var item in selectedNodes)
                {
                    if (item.asset != null)
                    {
                        manifest.RemoveAsset(item.asset);
                        groups.Add(item.asset.parentGroup);
                    }
                }

                foreach (var assetGroup in groups)
                {
                    EditorUtility.SaveAsset(assetGroup);
                }

                Reload();
            }
        }

        protected override bool CanStartDrag(CanStartDragArgs args)
        {
            foreach (var id in args.draggedItemIDs)
            {
                var item = FindItemInVisibleRows(id);
                if (item != null)
                {
                    if (item.asset != null)
                    {
                        if (string.IsNullOrEmpty(item.asset.path) || item.asset.readOnly)
                        {
                            return false;
                        }
                    }
                }
            }

            return true;
        }

        protected override void SetupDragAndDrop(SetupDragAndDropArgs args)
        {
            DragAndDrop.PrepareStartDrag();
            var selectedNodes = new List<AssetTreeViewItem>();
            foreach (var id in args.draggedItemIDs)
            {
                var item = FindItemInVisibleRows(id);
                if (item.asset != null || item.parent == rootItem && item.group != null)
                {
                    selectedNodes.Add(item);
                }
            }

            DragAndDrop.paths = null;
            DragAndDrop.objectReferences = new Object[]
            {
            };
            DragAndDrop.SetGenericData("AssetTreeViewItem", selectedNodes);
            DragAndDrop.visualMode =
                selectedNodes.Count > 0 ? DragAndDropVisualMode.Copy : DragAndDropVisualMode.Rejected;
            DragAndDrop.StartDrag("AssetTreeView");
        }

        private static bool PathPointsToAssetGroup(string path)
        {
            return AssetDatabase.GetMainAssetTypeAtPath(path) == typeof(Group);
        }

        protected override DragAndDropVisualMode HandleDragAndDrop(DragAndDropArgs args)
        {
            DragAndDropVisualMode visualMode;
            var target = args.parentItem as AssetTreeViewItem;

            if (target?.asset != null && target.asset.readOnly)
            {
                return DragAndDropVisualMode.Rejected;
            }

            if (DragAndDrop.paths != null && DragAndDrop.paths.Length > 0)
            {
                visualMode = HandleDragAndDropPaths(target, args);
            }
            else
            {
                visualMode = HandleDragAndDropItems(target, args);
            }

            return visualMode;
        }

        private DragAndDropVisualMode HandleDragAndDropItems(AssetTreeViewItem target, DragAndDropArgs args)
        {
            var visualMode = DragAndDropVisualMode.None;

            var draggedNodes = (List<AssetTreeViewItem>) DragAndDrop.GetGenericData("AssetTreeViewItem");
            if (draggedNodes != null && draggedNodes.Count > 0)
            {
                visualMode = DragAndDropVisualMode.Copy;
                var isDraggingGroup = draggedNodes.First().parent == rootItem;
                var dropParentIsRoot = args.parentItem == rootItem || args.parentItem == null;
                if (isDraggingGroup && !dropParentIsRoot || !isDraggingGroup && dropParentIsRoot)
                {
                    visualMode = DragAndDropVisualMode.Rejected;
                }

                if (args.performDrop)
                {
                    if (args.parentItem == null ||
                        args.parentItem == rootItem && visualMode != DragAndDropVisualMode.Rejected)
                    {
                        // 修改分组的位置
                        var groups = manifest.groups;
                        var group = draggedNodes.First().group;
                        var index = groups.FindIndex(g => g == group);
                        if (index < args.insertAtIndex)
                        {
                            args.insertAtIndex--;
                        }

                        manifest.groups.RemoveAt(index);
                        if (args.insertAtIndex < 0 || args.insertAtIndex > groups.Count)
                        {
                            groups.Insert(groups.Count, group);
                        }
                        else
                        {
                            groups.Insert(args.insertAtIndex, group);
                        }

                        EditorUtility.SaveAsset(manifest);
                        Reload();
                    }
                    else
                    {
                        // 修改 entry 的分组
                        if (target != null && target.group != null)
                        {
                            var modifyGroups = new HashSet<Group>();
                            foreach (var node in draggedNodes)
                            {
                                if (node.asset != null)
                                {
                                    var parentGroup = node.asset.parentGroup;
                                    if (parentGroup != null)
                                    {
                                        modifyGroups.Add(parentGroup);
                                        manifest.RemoveAsset(node.asset);
                                    }

                                    node.asset.parentGroup = target.group;
                                    target.group.assets.Add(node.asset);
                                }
                            }

                            foreach (var assetGroup in modifyGroups)
                            {
                                UnityEditor.EditorUtility.SetDirty(assetGroup);
                            }

                            AssetDatabase.SaveAssets();
                            AssetDatabase.Refresh();
                            Reload();
                        }
                    }
                }
            }

            return visualMode;
        }

        private DragAndDropVisualMode HandleDragAndDropPaths(AssetTreeViewItem target, DragAndDropArgs args)
        {
            var containsGroup = false;
            var containsAsset = false;
            foreach (var path in DragAndDrop.paths)
            {
                if (PathPointsToAssetGroup(path))
                {
                    containsGroup = true;
                    break;
                }

                // 暂时不允许添加已有资源
                if (pathWithAssets.ContainsKey(path))
                {
                    containsAsset = true;
                    break;
                }
            }

            if (target == null && !containsGroup || containsAsset)
            {
                return DragAndDropVisualMode.Rejected;
            }

            var visualMode = DragAndDropVisualMode.Copy;
            if (args.performDrop)
            {
                if (!containsGroup)
                {
                    Group parent = null;
                    var targetIsGroup = false;
                    if (target.group != null)
                    {
                        parent = target.group;
                        targetIsGroup = true;
                    }
                    else if (target.asset != null)
                    {
                        parent = target.asset.parentGroup;
                    }

                    if (parent != null)
                    {
                        foreach (var path in DragAndDrop.paths)
                        {
                            manifest.AddAsset(path, parent);
                        }

                        if (targetIsGroup)
                        {
                            SetExpanded(target.id, true);
                        }

                        EditorUtility.SaveAsset(parent);
                        Reload();
                    }
                }
                else
                {
                    var modified = false;
                    foreach (var p in DragAndDrop.paths)
                    {
                        if (PathPointsToAssetGroup(p))
                        {
                            var loadedGroup = AssetDatabase.LoadAssetAtPath<Group>(p);
                            if (loadedGroup != null)
                            {
                                if (manifest.groups.Find(g => g == loadedGroup) == null)
                                {
                                    manifest.groups.Add(loadedGroup);
                                    modified = true;
                                }
                            }
                        }
                    }

                    if (modified)
                    {
                        manifest.Save();
                        Reload();
                    }
                }
            }

            return visualMode;
        }

        private void OnSortingChanged(MultiColumnHeader header)
        {
            SortChildren(rootItem);
            Reload();
        }

        private void SortChildren(TreeViewItem root)
        {
            if (!root.hasChildren)
            {
                return;
            }

            foreach (var child in root.children)
            {
                if (child != null)
                {
                    SortHierarchical(child.children);
                }
            }
        }

        private void SortHierarchical(ICollection<TreeViewItem> children)
        {
            if (children == null)
            {
                return;
            }

            var sortedColumns = multiColumnHeader.state.sortedColumns;
            if (sortedColumns.Length == 0)
            {
                return;
            }

            var kids = new List<AssetTreeViewItem>();
            var copy = new List<TreeViewItem>(children);
            children.Clear();
            foreach (var c in copy)
            {
                var child = (AssetTreeViewItem) c;
                if (child?.asset != null)
                {
                    kids.Add(child);
                }
                else
                {
                    children.Add(c);
                }
            }

            var col = sortOptions[sortedColumns[0]];
            var ascending = multiColumnHeader.IsSortedAscending(sortedColumns[0]);

            IEnumerable<AssetTreeViewItem> orderedKids;
            switch (col)
            {
                case ColumnID.Path:
                    orderedKids = kids.Order(l => l.asset.path, ascending);
                    break;
                case ColumnID.Size:
                    orderedKids = kids.Order(l => l.asset.size, ascending);
                    break;
                case ColumnID.Type:
                    orderedKids = kids.Order(l => l.asset.target.GetType(), ascending);
                    break;
                case ColumnID.Label:
                    orderedKids = kids.Order(l => l.asset.label, ascending);
                    break;
                case ColumnID.Bundle:
                    orderedKids = kids.Order(l => l.asset.bundle, ascending);
                    break;
                case ColumnID.Dirty:
                    orderedKids = kids.Order(l => l.asset.dirty, ascending);
                    break;
                default:
                    orderedKids = kids.Order(l => l.displayName, ascending);
                    break;
            }

            foreach (var o in orderedKids)
            {
                children.Add(o);
            }

            foreach (var child in children)
            {
                if (child != null)
                {
                    SortHierarchical(child.children);
                }
            }
        }

        internal void Search(string search)
        {
            customSearchString = search;
            Reload();
            GetRows();
        }

        public void SwapSearchType()
        {
            var temp = customSearchString;
            customSearchString = searchString;
            searchString = temp;
            searchedEntries.Clear();
        }

        internal enum ColumnID
        {
            Path = 0,
            Size = 1,
            Type = 2,
            Label = 3,
            Bundle = 4,
            Dirty = 5
        }
    }

    internal static class ExtensionMethods
    {
        internal static IOrderedEnumerable<T> Order<T, TKey>(this IEnumerable<T> source, Func<T, TKey> selector,
            bool ascending)
        {
            return ascending ? source.OrderBy(selector) : source.OrderByDescending(selector);
        }

        internal static IOrderedEnumerable<T> ThenBy<T, TKey>(this IOrderedEnumerable<T> source, Func<T, TKey> selector,
            bool ascending)
        {
            return ascending ? source.ThenBy(selector) : source.ThenByDescending(selector);
        }
    }
}
#endif



