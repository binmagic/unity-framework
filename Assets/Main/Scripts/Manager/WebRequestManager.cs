using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

#if ODIN_INSPECTOR
using Sirenix.OdinInspector;
#endif

namespace GameKit.Base
{

    public class WebRequestManager : SingletonBehaviour<WebRequestManager>
    {
        [System.Serializable]
        struct WebRequestParams
        {
            public OnWebRequestCallback calback;
            public int priority;
            public object userdata;
        }

        public const string FILE_NO_EXISTS = "file no exists";

        public delegate void OnWebRequestCallback(UnityWebRequest request, bool hasErr, object userdata);
        
        private readonly Dictionary<string, UnityWebRequestAsyncOperation> m_WorkingRequests = new Dictionary<string, UnityWebRequestAsyncOperation>();
        private readonly List<UnityWebRequest> m_WaitingRequests = new List<UnityWebRequest>();

        private readonly Dictionary<UnityWebRequest, WebRequestParams> m_ParamsStack = new Dictionary<UnityWebRequest, WebRequestParams>();
        [SerializeField]
        private int maxWorkingWebRequestThread = 3;

        private Dictionary<string, UnityWebRequestAsyncOperation>.Enumerator enumeratorWorking;

        private readonly List<string> keysToRemove = new List<string>();

        private void OnDisable()
        {
            enumeratorWorking = m_WorkingRequests.GetEnumerator();
            while (enumeratorWorking.MoveNext())
            {
                UnityWebRequest request = enumeratorWorking.Current.Value.webRequest;
                Dispose(request);
            }
            m_WorkingRequests.Clear();
        }

        public bool IsDownloadResult(UnityWebRequest request, string result)
        {
            if (string.IsNullOrEmpty(result))
                return request.downloadedBytes == 0;

            return request.downloadedBytes == (ulong)result.Length && request.downloadHandler.text == result;
        }
        
        public void LoadTexture(string uri, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequestTexture.GetTexture(uri, false), callback, priority, timeout, userdata);
        }

        public void LoadTexture(string uri, bool nonReadable, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequestTexture.GetTexture(uri, nonReadable), callback, priority, timeout, userdata);
        }

        public void Get(string uri, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Get(uri), callback, priority, timeout, userdata);
        }
        
        public void Post(string uri, string postData, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.PostWwwForm(uri, postData), callback, priority, timeout, userdata);
        }

        public void Post(string uri, WWWForm formData, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Post(uri, formData), callback, priority, timeout, userdata);
        }

        public void Post(string uri, List<IMultipartFormSection> multipartFormSections, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Post(uri, multipartFormSections), callback, priority, timeout, userdata);
        }

        public void Post(string uri, Dictionary<string, string> formFields, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Post(uri, formFields), callback, priority, timeout, userdata);
        }

        public void Head(string uri, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Head(uri), callback, priority, timeout, userdata);
        }

        public void Put(string uri, string bodyData, OnWebRequestCallback callback = null, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Put(uri, bodyData), callback, priority, timeout, userdata);
        }

        public void Put(string uri, byte[] bodyData, OnWebRequestCallback callback = null, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Put(uri, bodyData), callback, priority, timeout, userdata);
        }

        public void Delete(string uri, OnWebRequestCallback callback = null, int priority = 0, int timeout = 0, object userdata = null)
        {
            Request(UnityWebRequest.Delete(uri), callback, priority, timeout, userdata);
        }

        public void DownFile(string uri, string localFilePath, OnWebRequestCallback callback, int priority = 0, int timeout = 0, object userdata = null)
        {
            UnityWebRequest downloader = UnityWebRequest.Get(uri);
            downloader.downloadHandler = new DownloadHandlerFile(localFilePath);
            Request(downloader, callback, priority, timeout, userdata);
        }
        
        private void Request(UnityWebRequest request, OnWebRequestCallback callback = null, int priority = 0, int timeout = 0, object userdata = null)
        {
            if (request != null)
            {
                request.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36");
                if (request.url.StartsWith("https://"))
                {
                    request.certificateHandler = new BypassCertificate();
                }
                
                if (timeout > 0)
                    request.timeout = timeout;
                m_WaitingRequests.Add(request);
                m_ParamsStack.Add(request, new WebRequestParams { calback = callback, priority = priority, userdata = userdata });
            }
        }

        protected override void OnUpdate(float delta)
        {
            enumeratorWorking = m_WorkingRequests.GetEnumerator();
            while (enumeratorWorking.MoveNext())
            {
                string key = enumeratorWorking.Current.Key;
                UnityWebRequestAsyncOperation operation = enumeratorWorking.Current.Value;

                try
                {
                    if (m_ParamsStack.TryGetValue(operation.webRequest, out WebRequestParams param))
                    {
                        bool isError = false;
                        if (operation.webRequest.isHttpError || operation.webRequest.isNetworkError || !string.IsNullOrEmpty(operation.webRequest.error))
                        {
                            isError = true;
                            Debug.LogFormat("{0} : {1}", operation.webRequest.error, key);
                        }

                        // 通知最终用户请求进度
                        param.calback?.Invoke(operation.webRequest, isError, param.userdata);
                    }
                    else
                    {
                        throw new System.Exception(string.Format("{0} is out of control", operation.webRequest.url));
                    }
                }
                catch (System.Exception e)
                {
                    Debug.LogError(e);
                }
                finally
                {
                    if (operation.isDone)
                    {
                        keysToRemove.Add(key);
                    }
                }
            }

            for (int i = 0; i < keysToRemove.Count; ++i)
            {
                if (m_WorkingRequests.TryGetValue(keysToRemove[i], out UnityWebRequestAsyncOperation operation))
                {
                    m_WorkingRequests.Remove(keysToRemove[i]);
                    m_ParamsStack.Remove(operation.webRequest);
                    Dispose(operation.webRequest);
                }
            }
            keysToRemove.Clear();

            if (m_WorkingRequests.Count < maxWorkingWebRequestThread)
            {
                for (int i = 0; i < m_WaitingRequests.Count;)
                {
                    if (m_WaitingRequests[i] != null)
                    {
                        UnityWebRequest request = m_WaitingRequests[i];
                        if (!m_WorkingRequests.ContainsKey(request.url))
                        {
                            UnityWebRequestAsyncOperation operation = request.SendWebRequest();
                            operation.priority = m_ParamsStack[request].priority;
                            m_WorkingRequests.Add(request.url, operation);
                            m_WaitingRequests.RemoveAt(i);

                            if (m_WorkingRequests.Count >= maxWorkingWebRequestThread)
                                break;
                        }
                        else
                        {
                            i++;
                        }
                    }
                    else
                    {
                        m_WaitingRequests.RemoveAt(i);
                    }
                }
            }

            //if (m_WorkingRequests.Count > 0)
                //Debug.LogFormat("{0} webrequest thread in working!", m_WorkingRequests.Count);
        }

        private void Dispose(UnityWebRequest request)
        {
            if (request != null)
            {
                request.Dispose();
                System.GC.SuppressFinalize(request);
            }
        }
    }
}





