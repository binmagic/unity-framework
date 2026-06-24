using System;
using UnityEngine;
using UnityEngine.Networking;

namespace Main.Scripts.Application.LoadingState
{
    //
    // Http 请求，自定义超时时间和重试次数
    //
    [UnityEngine.Scripting.Preserve]
    public class HttpRequest
    {
        public UnityWebRequest _httpRequest;
        private float _elapseTime;
        private float _timeout = 9;
        private int _maxTryCount = 3;
        private int _tryCount;
        private string _url;
        private bool _isDone;
        private string _error;
        private byte[] _data;

        public float Timeout
        {
            get => _timeout;
            set => _timeout = value;
        }

        public int TryCount
        {
            get => _tryCount;
            set => _tryCount = value;
        }

        public bool isDone => _isDone;

        public string error => _error;

        public byte[] data => _data;
        public string url => _url;
        public event Action<string> onFailed;
        public event Action<int> onRetry;
        public event Action onTimeOut;
        public event Action<DownloadHandler> onSuccess;

        private class WebRequestCertificateHandler : CertificateHandler
        {
            protected override bool ValidateCertificate(byte[] certificateData)
            {
                return true;
            }
        }
        
        public HttpRequest(string url)
        {
            _elapseTime = 0;
            _tryCount = 1;
            _url = url;
            _isDone = false;
            _error = null;
            _data = null;
            _httpRequest = UnityWebRequest.Get(url);
            if (_url.StartsWith("https://"))
            {
                _httpRequest.certificateHandler = new WebRequestCertificateHandler();
            }
        }

        public void SendRequest()
        {
            _httpRequest.SendWebRequest();
        }

        public void Dispose()
        {
            if (_httpRequest != null)
            {
                _httpRequest.Dispose();
                _httpRequest = null;
            }
        }

        public void OnUpdate()
        {
            if (_httpRequest.isDone)
            {
                _isDone = true;
                GameEntry.Event.Fire(EventId.NetworkRetry, false);
                
                //zlh: unity2021已弃用 isHttpError及isNetworkError, 并且发现旧的写法有隐患 当连接错误时，error有值，isHttpError及isNetworkError均为false
                //因此直接改成2021支持的result来判断  注意: isDone为false时，result始终时InProgress
                //if (_httpRequest.isHttpError || _httpRequest.isNetworkError)
                if(_httpRequest.result != UnityWebRequest.Result.Success)
                {
                    _error = $"{_url} {_tryCount} ### {_httpRequest.error}";
                    onFailed?.Invoke(_error);
                }
                else
                {
                    _data = _httpRequest.downloadHandler.data;
                    onSuccess?.Invoke(_httpRequest.downloadHandler);
                }
            }
            else
            {
                _elapseTime += Time.deltaTime;
                if (_elapseTime > _timeout)
                {
                    if (_tryCount < _maxTryCount)
                    {
                        _httpRequest.Abort();
                        _httpRequest.Dispose();
                        _httpRequest = UnityWebRequest.Get(_url);
                        _tryCount++;
                        _elapseTime = 0;
                        GameEntry.Event.Fire(EventId.NetworkRetry, true);
                        onRetry?.Invoke(_tryCount);
                    }
                    else
                    {
                        _httpRequest.Dispose();
                        _httpRequest = null;
                        _isDone = true;
                        _error = $"{_url} {_tryCount} ### timeout, reach max retry count";
                        GameEntry.Event.Fire(EventId.NetworkRetry, false);
                        onTimeOut?.Invoke();
                    }
                }
            }
        }
    }
}





