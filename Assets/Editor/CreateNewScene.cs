using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

public static class CreateNewScene
{
    [MenuItem("Tools/Create New Scene In Root")]
    private static void Create()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single);
        EditorSceneManager.SaveScene(scene, "Assets/NewScene.unity");
        EditorSceneManager.OpenScene("Assets/NewScene.unity");
    }
}
