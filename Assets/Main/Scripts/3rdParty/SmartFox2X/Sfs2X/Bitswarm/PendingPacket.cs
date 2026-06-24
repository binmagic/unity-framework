using Sfs2X.Core;
using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public struct PendingPacket
    {
        private PacketHeader header;
        private ByteArray buffer;

        // public PendingPacket(PacketHeader header)
        // {
        //     this.header = header;
        //     buffer = new ByteArray {Compressed = header.Compressed};
        // }
        // public PendingPacket()
        // {
        //     buffer = new ByteArray();
        // }
        //
        public PacketHeader Header
        {
            get => header;
            set => header = value;
        }

        public ByteArray Buffer
        {
            get => buffer;
            set => buffer = value;
        }
    }
}





