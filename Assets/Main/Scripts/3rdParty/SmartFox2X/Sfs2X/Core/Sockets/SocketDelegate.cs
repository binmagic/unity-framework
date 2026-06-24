using System.Net.Sockets;
using Sfs2X.Util;

namespace Sfs2X.Core.Sockets
{
  public delegate void ConnectionDelegate();
  
  public delegate void OnDataDelegate(ByteArray msg);

  public delegate void OnErrorDelegate(string error, SocketError se);
  
  public delegate void OnStringDataDelegate(string msg);


}





