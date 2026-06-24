using System.Text;
using Sfs2X.Entities.Data;
using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public class Message : IMessage
    {
        private int id;
        private ISFSObject content;
        private int targetController;
        private bool isEncrypted;
        private bool isUDP;
        private long packetId;

        //将消息逻辑上拆分为header信息和原始字节数据来传递
        private ISFSObject header;
        private ByteArray rawData;
        public ISFSObject Header
        {
            get => header;
            set => header = value;
        }
        
        public ByteArray RawData
        {
            get => rawData;
            set => rawData = value;
        }
        
        
        public Message()
        {
            isEncrypted = false;
        }

        public int Id
        {
            get => id;
            set => id = value;
        }

        public ISFSObject Content
        {
            get => content;
            set => content = value;
        }

        public int TargetController
        {
            get => targetController;
            set => targetController = value;
        }

        public bool IsEncrypted
        {
            get => isEncrypted;
            set => isEncrypted = value;
        }

        public bool IsUDP
        {
            get => isUDP;
            set => isUDP = value;
        }

        public long PacketId
        {
            get => packetId;
            set => packetId = value;
        }

        public override string ToString()
        {
            StringBuilder stringBuilder = new StringBuilder("{ Message id: " + id + " }\n");
            if (content != null)
            {
                stringBuilder.Append("{ Dump: }\n");
                stringBuilder.Append(content.GetDump());
            }
            return stringBuilder.ToString();
        }
    }
}





