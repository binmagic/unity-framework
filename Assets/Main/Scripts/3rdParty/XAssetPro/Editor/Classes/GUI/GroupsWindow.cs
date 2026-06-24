#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace VEngine.Editor
{
    public class GroupsWindow : EditorWindow, IHasCustomMenu
    {
        [SerializeField] private GroupsEditor _editor;


        private void OnEnable()
        {
            if (_editor != null)
            {
                _editor.OnEnable();
            }
        }

        private void OnDisable()
        {
            if (_editor != null)
            {
                _editor.OnDisable();
            }
        }

        private void OnGUI()
        {
            _editor = _editor ?? new GroupsEditor();
            var contentRect = new Rect(0, 0, position.width, position.height);
            if (_editor.OnGUI(contentRect))
            {
                Repaint();
            }
        }

        public void AddItemsToMenu(GenericMenu menu)
        {
            menu.AddItem(new GUIContent("Help"), false, OnHelp);
        }


        [MenuItem("XASSET/Groups")]
        private static void Init()
        {
            var window = GetWindow<GroupsWindow>(false, "XASSET Groups");
            window.minSize = new Vector2(640, 320);
        }

        private static void OnHelp()
        {
            Application.OpenURL("https://game4d.cn");
        }
    }
}
#endif



