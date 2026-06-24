using System;
using System.Collections.Generic;
using System.Threading;
using GameFramework;

namespace Main.Scripts.Network
{
    struct msgSendInfo
    {
        private int _futureId;
        private string _msgId;
        private long _sendTime;

        public msgSendInfo(int fuid, string msgId)
        {
            _futureId = fuid;
            _msgId = msgId;
            _sendTime = DateTimeOffset.Now.ToUnixTimeMilliseconds();
        }

        public long getSendTime()
        {
            return _sendTime;
        }

        public string getMsgId()
        {
            return _msgId;
        }
    }
    
    [UnityEngine.Scripting.Preserve]
    public class FutureManager
    {
        private Dictionary<int, msgSendInfo> _sendInfos = new Dictionary<int, msgSendInfo>(256);
        private int _futureId = 0;
        private const long _timeOutTime = 500;//超时时间
        private long _totalCount = 0;
        private float _totalTime = 0;
        private long _minTime = long.MaxValue;
        private long _maxTime = 0;
        
        public void reset()
        {
            _futureId = 0;
            _totalCount = 0;
            _totalTime = 0;
            _minTime = long.MaxValue;
            _maxTime = 0;
            _sendInfos.Clear();
        }

        public int getFutureId()
        {
            Interlocked.Increment(ref _futureId);
            return _futureId;
        }

        public float getPing()
        {
            if (_totalCount == 0)
            {
                return 0;
            }

            return _totalTime / _totalCount;
        }

        public void onSendRequest(int fuid, string msgId)
        {
            msgSendInfo tmp = new msgSendInfo(fuid, msgId);
            if (!_sendInfos.ContainsKey(fuid))
            {
                _sendInfos.Add(fuid, tmp);
            }
        }

        public void onServerMsgCome(int fuid, int serverTime)
        {
            if (_sendInfos.ContainsKey(fuid))
            {
                long dt = DateTimeOffset.Now.ToUnixTimeMilliseconds() - _sendInfos[fuid].getSendTime() - serverTime;
                _totalCount += 1;
                _totalTime += dt;
                
                _minTime = Math.Min(_minTime, dt);
                _maxTime = Math.Max(_maxTime, dt);
                //Log.Debug("{0} cmd use time {1} ping {2} servertime {3} min {4} max {5}", _sendInfos[fuid].getMsgId(), dt, getPing(), serverTime, _minTime, _maxTime);
            }

            _sendInfos.Remove(fuid);
        }

        public void update()
        {
            long curTime = DateTimeOffset.Now.ToUnixTimeMilliseconds();
            foreach (var tmp in _sendInfos.Values)
            {
                long dt = curTime - tmp.getSendTime();
                if (dt > _timeOutTime)
                {
                    Log.Debug("{0} in time {1} not return", tmp.getMsgId(), dt);
                }
            }
        }


    }
}





