var WeChatJsLib = {

    // ========== SDK 平台接口 ==========

    wx_Login: function(callbackObj, callbackMethod) {
        var obj = UTF8ToString(callbackObj);
        var method = UTF8ToString(callbackMethod);
        wx.login({
            success: function(res) {
                if (res.code) {
                    // 将 code 发送到服务端换取 openid
                    var data = JSON.stringify({ code: res.code });
                    SendMessage(obj, method, data);
                }
            },
            fail: function(err) {
                console.error('wx.login fail:', err);
                SendMessage(obj, method, JSON.stringify({ error: err }));
            }
        });
    },

    wx_Pay: function(data, callbackObj, callbackMethod) {
        var payData = UTF8ToString(data);
        var obj = UTF8ToString(callbackObj);
        var method = UTF8ToString(callbackMethod);
        var params = JSON.parse(payData);

        wx.requestPayment({
            timeStamp: params.timeStamp,
            nonceStr: params.nonceStr,
            package: params.package,
            signType: params.signType,
            paySign: params.paySign,
            success: function(res) {
                SendMessage(obj, method, JSON.stringify({ code: '1', data: res }));
            },
            fail: function(err) {
                SendMessage(obj, method, JSON.stringify({ code: '-1', error: err }));
            }
        });
    },

    wx_GetSystemInfo: function(key) {
        var k = UTF8ToString(key);
        try {
            var info = wx.getSystemInfoSync();
            var value = info[k] || '';
            var bufferSize = lengthBytesUTF8(value) + 1;
            var buffer = _malloc(bufferSize);
            stringToUTF8(value, buffer, bufferSize);
            return buffer;
        } catch(e) {
            return 0;
        }
    },

    wx_SendDataToNative: function(funcName, data) {
        // 微信小游戏 SDK 事件回调
        var fn = UTF8ToString(funcName);
        var d = UTF8ToString(data);
        // 通过 SendMessage 发送到 Unity
        SendMessage('SDKManager', 'OnNativeEvent', JSON.stringify({ func: fn, data: d }));
    },

    wx_GetDataFromNative: function(funcName, data) {
        var fn = UTF8ToString(funcName);
        // 返回空字符串，由具体实现决定
        var result = '';
        var bufferSize = lengthBytesUTF8(result) + 1;
        var buffer = _malloc(bufferSize);
        stringToUTF8(result, buffer, bufferSize);
        return buffer;
    },

    // ========== WebSocket 网络接口 ==========

    _wsSocket: null,

    ws_connect: function(url, callbackObj, callbackMethod) {
        var wsUrl = UTF8ToString(url);
        var obj = UTF8ToString(callbackObj);
        var method = UTF8ToString(callbackMethod);

        console.log('[WS] Connecting to:', wsUrl);

        WeChatJsLib._wsSocket = wx.connectSocket({
            url: wsUrl,
            success: function() {
                console.log('[WS] connectSocket success');
            }
        });

        WeChatJsLib._wsSocket.onOpen(function(res) {
            console.log('[WS] onOpen');
            SendMessage(obj, 'OnWsOpen');
        });

        WeChatJsLib._wsSocket.onMessage(function(res) {
            if (res.data instanceof ArrayBuffer) {
                // 二进制数据 — 转 Base64 传给 C#
                var bytes = new Uint8Array(res.data);
                var binary = '';
                for (var i = 0; i < bytes.length; i++) {
                    binary += String.fromCharCode(bytes[i]);
                }
                var base64 = btoa(binary);
                SendMessage(obj, 'OnWsMessage', base64);
            } else {
                // 文本数据
                SendMessage(obj, 'OnWsMessage', res.data);
            }
        });

        WeChatJsLib._wsSocket.onClose(function(res) {
            console.log('[WS] onClose:', res.code, res.reason);
            SendMessage(obj, 'OnWsClose', res.reason || 'closed');
        });

        WeChatJsLib._wsSocket.onError(function(err) {
            console.error('[WS] onError:', err);
            SendMessage(obj, 'OnWsError', JSON.stringify(err));
        });
    },

    ws_send: function(data, length) {
        if (WeChatJsLib._wsSocket == null) {
            console.error('[WS] send failed: socket is null');
            return;
        }

        // 从 HEAP 中读取字节数据
        var bytes = new Uint8Array(HEAPU8.buffer, data, length);

        WeChatJsLib._wsSocket.send({
            data: bytes.buffer,
            success: function() {
                // 发送成功
            },
            fail: function(err) {
                console.error('[WS] send fail:', err);
            }
        });
    },

    ws_close: function() {
        if (WeChatJsLib._wsSocket != null) {
            WeChatJsLib._wsSocket.close({
                success: function() {
                    console.log('[WS] closed');
                }
            });
            WeChatJsLib._wsSocket = null;
        }
    }
};

mergeInto(LibraryManager.library, WeChatJsLib);
