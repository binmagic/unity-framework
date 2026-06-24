using UnityEditor;
using UnityEngine;

public static class CreateEmptyGameObject
{
    [MenuItem("GameObject/Create Empty GameObject #&n", false, 0)]
    private static void Create()
    {
        var go = new GameObject("GameObject");
        Undo.RegisterCreatedObjectUndo(go, "Create Empty GameObject");
        Selection.activeGameObject = go;
    }
}
