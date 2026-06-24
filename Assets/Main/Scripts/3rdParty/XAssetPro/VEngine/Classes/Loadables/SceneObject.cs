using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

namespace VEngine
{
    /// <summary>
    ///     场景对象，可以是 UI，也可以是 3D 模型
    /// </summary>
    public class SceneObject : Loadable, IEnumerator
    {
        internal static readonly List<SceneObject> Unused = new List<SceneObject>();

        internal readonly Dictionary<string, SceneObjectAction> actions = new Dictionary<string, SceneObjectAction>();

        public readonly Assets assets = new Assets();

        protected readonly List<SceneObject> children = new List<SceneObject>();

        protected int actionTimes;

        private Asset asset;

        public Action<SceneObject> completed;

        protected Scene owner;

        protected SceneObject parent;

        protected Transform transformParent;

        protected bool transformWorldPositionStays;

        public GameObject gameObject { get; private set; }

        public bool MoveNext()
        {
            return !isDone;
        }

        public void Reset()
        {
        }

        public object Current => null;

        public void SetTransformParent(Transform tranParent, bool worldPositionStays)
        {
            transformParent = tranParent;
            transformWorldPositionStays = worldPositionStays;
            if (gameObject != null)
            {
                gameObject.transform.SetParent(tranParent, worldPositionStays);
            }
        }

        public bool ActiveSelf { get; private set; }

        public void SetActive(bool active)
        {
            if (ActiveSelf != active)
            {
                ActiveSelf = active;
                if (gameObject != null)
                {
                    gameObject.SetActive(active);
                }
            }
        }

        public bool RemoveAction(string key)
        {
            return actions.Remove(key);
        }

        public SceneObjectAction RunAction(Action<SceneObject> func, string key = null)
        {
            if (string.IsNullOrEmpty(key))
            {
                key = $"actions_{actionTimes++}";
            }

            if (actions.TryGetValue(key, out var value))
            {
                value.func = func;
                return value;
            }

            var action = new SceneObjectAction
            {
                func = func,
                key = key,
                sceneObject = this
            };

            actions.Add(action.key, action);
            action.Start();
            return action;
        }

        public static SceneObject LoadAsync(string assetPath, Action<SceneObject> completed = null)
        {
            if (string.IsNullOrEmpty(assetPath))
            {
                throw new ArgumentNullException(nameof(assetPath));
            }

            var view = new SceneObject
            {
                pathOrURL = assetPath
            };
            view.completed += completed;
            view.Load();
            return view;
        }

        public void AddChild(SceneObject child)
        {
            if (child.parent != null)
            {
                child.parent.RemoveChild(child);
            }

            children.Add(child);
            child.parent = this;
        }

        public bool RemoveChild(SceneObject child)
        {
            return children.Remove(child);
        }

        protected override void OnUpdate()
        {
            switch (status)
            {
                case LoadableStatus.Loading:
                    if (asset == null)
                    {
                        Finish("asset == null");
                        return;
                    }

                    progress = 0.5f + asset.progress * 0.5f;
                    if (!asset.isDone)
                    {
                        return;
                    }

                    var prefab = asset.Get<GameObject>();
                    if (prefab == null)
                    {
                        Finish("prefab == null");
                        return;
                    }

                    gameObject = Object.Instantiate(prefab);
                    gameObject.transform.SetParent(transformParent, transformWorldPositionStays);
                    if (gameObject.activeSelf != ActiveSelf)
                    {
                        gameObject.SetActive(ActiveSelf);
                    }

                    Finish();
                    break;
            }
        }

        protected override void OnLoad()
        {
            asset = assets.Preload(pathOrURL, typeof(GameObject));
            owner = Scene.current;
            if (owner != null)
            {
                owner.objects.Add(this);
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
            if (gameObject != null)
            {
                Object.Destroy(gameObject);
                gameObject = null;
            }

            if (owner != null)
            {
                owner.objects.Remove(this);
                owner = null;
            }

            foreach (var item in actions)
            {
                item.Value.Cancel();
            }

            actions.Clear();
            foreach (var child in children)
            {
                child.Release();
            }

            children.Clear();
            assets.Clear();
        }

        protected override void OnComplete()
        {
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

        public static void UpdateObjects()
        {
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





