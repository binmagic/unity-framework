using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace VEngine
{
    /// <summary>
    ///     场景类，持有 Dependencies 可以自动管理依赖，不论是 ScenesInBuild 中的场景还是打包 AssetBundle 的场景都能通过此类加载，目前只提供异步加载接口。
    /// </summary>
    public class Scene : Loadable, IEnumerator
    {
        internal static readonly List<Scene> Unused = new List<Scene>();

        public static Action<Scene> onSceneUnloaded;
        public static Action<Scene> onSceneLoaded;
        internal readonly List<Scene> additives = new List<Scene>();
        internal readonly List<SceneObject> objects = new List<SceneObject>();

        public Action<Scene> completed;
        protected string sceneName;

        public AsyncOperation operation { get; protected set; }

        /// <summary>
        ///     当前存在的主场景，主场景是 Single 场景，主场景回收后，所有在主场景加载后的叠加场景都会回收
        /// </summary>
        public static Scene main { get; private set; }

        /// <summary>
        ///     当前加载的场景。
        /// </summary>
        public static Scene current { get; private set; }

        protected internal LoadSceneMode loadSceneMode { get; set; }

        public bool MoveNext()
        {
            return !isDone;
        }

        public void Reset()
        {
        }

        public object Current => null;

        /// <summary>
        ///     异步加载场景，可以通过返回的 Scene 对象获取加载进度，加载完成后会通过 Scene 对象的 completed 事件进行回调，此外也可以用协程来阻塞场景状态。
        /// </summary>
        /// <param name="assetPath">场景路径，以 “Assets” 开头</param>
        /// <param name="completed"></param>
        /// <param name="additive"> 是否是叠加模式</param>
        /// <returns></returns>
        /// <exception cref="ArgumentNullException"></exception>
        public static Scene LoadAsync(string assetPath, Action<Scene> completed = null, bool additive = false)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                throw new ArgumentNullException(nameof(assetPath));
            }

            var scene = Versions.CreateScene(assetPath, additive);
            if (completed != null)
            {
                scene.completed += completed;
            }

            current = scene;
            scene.Load();
            return scene;
        }

        /// <summary>
        ///     异步加载 Additive 场景
        /// </summary>
        /// <param name="assetPath"></param>
        /// <param name="completed"></param>
        /// <returns></returns>
        public static Scene LoadAdditiveAsync(string assetPath, Action<Scene> completed = null)
        {
            return LoadAsync(assetPath, completed, true);
        }

        protected override void OnUpdate()
        {
            if (status == LoadableStatus.Loading)
            {
                UpdateLoading();
            }
        }

        protected void UpdateLoading()
        {
            if (operation == null)
            {
                Finish("operation == null");
                return;
            }

            progress = 0.5f + operation.progress * 0.5f;

            if (operation.allowSceneActivation)
            {
                if (!operation.isDone)
                {
                    return;
                }
            }
            else
            {
                // https://docs.unity3d.com/ScriptReference/AsyncOperation-allowSceneActivation.html
                if (operation.progress < 0.9f)
                {
                    return;
                }
            }

            Finish();
        }

        protected override void OnLoad()
        {
            PrepareToLoad();
            operation = UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(sceneName, loadSceneMode);
        }

        protected void PrepareToLoad()
        {
            sceneName = Path.GetFileNameWithoutExtension(pathOrURL);
            if (loadSceneMode == LoadSceneMode.Single)
            {
                if (main != null)
                {
                    main.Release();
                    main = null;
                }

                main = this;
            }
            else
            {
                if (main != null)
                {
                    main.additives.Add(this);
                }
            }
        }

        protected override void OnUnused()
        {
            // 不需要使用的时候，加载完成不回调。
            completed = null;
            Unused.Add(this);
        }

        protected override void OnUnload()
        {
            foreach (var sceneObject in objects)
            {
                sceneObject.Release();
            }

            objects.Clear();

            if (loadSceneMode == LoadSceneMode.Additive)
            {
                if (main != null)
                {
                    main.additives.Remove(this);
                }

                if (string.IsNullOrEmpty(error))
                {
                    UnityEngine.SceneManagement.SceneManager.UnloadSceneAsync(sceneName);
                }
            }
            else
            {
                foreach (var item in additives)
                {
                    item.Release();
                }

                additives.Clear();
            }

            if (onSceneUnloaded != null)
            {
                onSceneUnloaded.Invoke(this);
            }
        }

        protected override void OnComplete()
        {
            if (onSceneLoaded != null)
            {
                onSceneLoaded.Invoke(this);
            }

            if (completed == null)
            {
                return;
            }

            var saved = completed;
            if (completed != null)
            {
                completed(this);
            }

            completed -= saved;
        }

        public static void UpdateScenes()
        {
            if (current == null || !current.isDone)
            {
                return;
            }

            for (var index = 0; index < Unused.Count; index++)
            {
                var item = Unused[index];
                if (Updater.busy)
                {
                    break;
                }

                if (!item.isDone)
                {
                    continue;
                }

                Unused.RemoveAt(index);
                index--;
                item.Unload();
            }
        }
    }
}





