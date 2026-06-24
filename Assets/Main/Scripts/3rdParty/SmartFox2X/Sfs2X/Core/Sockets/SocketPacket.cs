using System;
using System.Net.Sockets;
using System.Threading;
using Sfs2X.Util;

namespace Sfs2X.Core.Sockets
{
    public struct InPacket
    {
        public Delegate Callback;
        public ByteArray Data;
        public string StrError;
        public SocketError SocketError;
      
        public void Execute()
        {
            switch (Callback)
            {
                case OnDataDelegate onDataDelegate:
                    onDataDelegate(Data);
                    break;
                case ParameterizedThreadStart parameterizedThreadStart:
                    parameterizedThreadStart(this);
                    break;
            }
        }
    }
    
    /*
    public struct OutPacket
    {
        public WriteBinaryDataDelegate Callback;
        public PacketHeader Header;
        public ByteArray Data;
        public bool IsUdp;

        public void Execute()
        {
            Callback(Header, Data, IsUdp);
        }
    }
    */
}





