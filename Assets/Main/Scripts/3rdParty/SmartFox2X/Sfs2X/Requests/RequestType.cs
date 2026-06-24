/*

SmartFox 消息类型格式：

(byte) type 消息报的标识，主要包括三个属性：消息是小包还是大包（65535)，是否压缩，是否加密
(short) len 如果是小包的话，这个len长度就是short，否则是int

后面跟着就是协议头，主要有三个属性
(sfs_object) p          具体的参数信息，最后解析即可
(short) a               表示ActionId，主要就是指：public enum RequestType。譬如：0，1，13
(byte) c                表示ControllId，主要就是0和1；0对应SystemController，1表示ExtensionController应用层消息

对于c=0来讲，不同的ActionId所携带的参数（即p）不一样

对于c=1来讲，紧跟着协议头的还有个应用头
(utf_string) c          应用层具体的消息id，user.get.shop.info
(sfs_object) p          具体的消息格式，接SFSObject
(int) r                 房间ID，一般为-1，没加入房间这个值貌似也可以没有

*/

namespace Sfs2X.Requests
{
  public enum RequestType
  {
    Handshake = 0,
    Login = 1,
    Logout = 2,
    CallExtension = 13, // 0x0000000D
    ManualDisconnection = 26, // 0x0000001A
    PingPong = 29, // 0x0000001D
  }
}





