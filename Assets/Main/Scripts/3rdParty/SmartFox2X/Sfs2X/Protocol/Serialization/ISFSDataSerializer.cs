using Sfs2X.Entities.Data;
using Sfs2X.Util;
using System.Collections.Generic;

namespace Sfs2X.Protocol.Serialization
{
  public interface ISFSDataSerializer
  {
    ByteArray Object2Binary(ISFSObject obj, ByteArray buffer);

    ByteArray Array2Binary(ISFSArray array, ByteArray buffer);

    ISFSObject Binary2Object(ByteArray data);

    ISFSArray Binary2Array(ByteArray data);

    string Object2Json(Dictionary<string, object> map);

    string Array2Json(List<object> list);

    ISFSObject Json2Object(string jsonStr);

    ISFSArray Json2Array(string jsonStr);
  }
}





