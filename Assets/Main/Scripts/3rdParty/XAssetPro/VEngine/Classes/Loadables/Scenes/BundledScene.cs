using UnityEngine.SceneManagement;

namespace VEngine
{
    public class BundledScene : Scene
    {
        protected Dependencies dependencies;

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.DependentLoading:
                    UpdateDependencies();
                    break;

                case LoadableStatus.Loading:
                    UpdateLoading();
                    break;
            }
        }

        private void UpdateDependencies()
        {
            if (dependencies == null)
            {
                Finish("dependencies == null");
                return;
            }

            progress = dependencies.progress * 0.5f;
            if (!dependencies.isDone)
            {
                return;
            }

            var assetBundle = dependencies.assetBundle;
            if (assetBundle == null)
            {
                Finish("assetBundle == null");
                return;
            }

            operation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(sceneName, loadSceneMode);
            status = LoadableStatus.Loading;
        }

        protected override void OnUnload()
        {
            base.OnUnload();
            if (dependencies != null)
            {
                dependencies.Unload();
                dependencies = null;
            }
        }


        protected override void OnLoad()
        {
            PrepareToLoad();
            dependencies = new Dependencies
            {
                pathOrURL = pathOrURL
            };
            dependencies.Load();
            status = LoadableStatus.DependentLoading;
        }

        internal static Scene Create(string assetPath, bool additive = false)
        {
            AssetInfo asset;
            var info = Versions.GetAsset(ref assetPath, out asset);
            if (info == false)
            {
                return new Scene
                {
                    pathOrURL = assetPath,
                    loadSceneMode = additive ? LoadSceneMode.Additive : LoadSceneMode.Single
                };
            }

            return new BundledScene
            {
                pathOrURL = assetPath,
                loadSceneMode = additive ? LoadSceneMode.Additive : LoadSceneMode.Single
            };
        }
    }
}





