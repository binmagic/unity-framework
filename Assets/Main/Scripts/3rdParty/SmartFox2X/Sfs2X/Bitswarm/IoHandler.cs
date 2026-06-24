using Sfs2X.Protocol;
using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public interface IoHandler
    {
        void OnDataRead(ByteArray buffer);

        void OnDataRead(string jsonData);

        void OnDataWrite(IMessage message);
        
        void OnDataWrite(byte[] data, int dataLen);

        IProtocolCodec Codec { get; }
    }
}





