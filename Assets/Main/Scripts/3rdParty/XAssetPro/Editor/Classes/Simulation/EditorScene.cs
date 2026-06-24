#if UNITY_EDITOR
using System.IO;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;

namespace VEngine
{
    public class EditorScene : Scene
    {
        private UnityEngine.SceneManagement.Scene scene;

        internal static Scene Create(string assetPath, bool additive = false)
        {
            Versions.GetActualPath(ref assetPath);

            if (!File.Exists(assetPath))
            {
                throw new FileNotFoundException(assetPath);
            }

            var scene = new EditorScene
            {
                pathOrURL = assetPath,
                loadSceneMode = additive ? LoadSceneMode.Additive : LoadSceneMode.Single
            };
            return scene;
        }

        protected override void OnLoad()
        {
            var parameters = new LoadSceneParameters
            {
                loadSceneMode = loadSceneMode
            };
            scene = EditorSceneManager.LoadSceneInPlayMode(pathOrURL, parameters);
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.Loading:
                    if (scene.isLoaded)
                    {
                        Finish();
                    }

                    break;
            }
        }

        protected override void OnUnload()
        {
            if (loadSceneMode == LoadSceneMode.Additive)
            {
                UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(scene);
            }
        }
    }
}
#endif



