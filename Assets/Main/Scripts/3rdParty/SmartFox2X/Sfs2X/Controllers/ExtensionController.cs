using System.Collections;
using Sfs2X.Bitswarm;
using Sfs2X.Core;
using Sfs2X.Entities.Data;
using Sfs2X.Util;

namespace Sfs2X.Controllers
{
    public class ExtensionController : BaseController
    {
        public static readonly string KEY_CMD = "c";
        public static readonly string KEY_PARAMS = "p";
        public static readonly string KEY_ROOM = "r";

        public ExtensionController(ISocketClient socketClient)
            : base(socketClient)
        {
        }

        public override void HandleMessage(IMessage message)
        {
#if false
            if (sfs.Debug)
                log.Info(message.ToString());
            ISFSObject content = message.Content;
            Hashtable data = new Hashtable();
            data["cmd"] = content.GetUtfString(KEY_CMD);
            data["params"] = content.GetSFSObject(KEY_PARAMS);
            if (content.ContainsKey(KEY_ROOM))
            {
                int id = content.GetInt(KEY_ROOM);
                data["sourceRoom"] = id;
                //data["room"] = sfs.GetRoomById(id);
            }
            if (message.IsUDP)
                data["packetId"] = message.PacketId;
            sfs.DispatchEvent(new SFSEvent(SFSEvent.EXTENSION_RESPONSE, data));
#else
            // Hashtable data = new Hashtable
            // {
            //     ["cmd"] = message.Header.GetUtfString("cmd"),
            //     ["rawData"] = message.RawData
            // };
            // sfs.DispatchEvent(new SFSEvent(SFSEvent.EXTENSION_RESPONSE, data));

            var cmd = message.Header.GetUtfString("cmd");
            var e = new ExtensionEvent(SFSEvent.EXTENSION_RESPONSE, cmd, message.RawData);
            sfs.DispatchEvent(e);
#endif
        }

        public void HandleExtensionResponse(string cmd, ByteArray RawData)
        {
            var e = new ExtensionEvent(SFSEvent.EXTENSION_RESPONSE, cmd, RawData);
            sfs.DispatchEvent(e);
        }
    }
}





