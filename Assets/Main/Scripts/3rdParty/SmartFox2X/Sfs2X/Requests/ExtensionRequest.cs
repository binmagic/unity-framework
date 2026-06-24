using System.Collections.Generic;
using Sfs2X.Entities;
using Sfs2X.Entities.Data;
using Sfs2X.Exceptions;

namespace Sfs2X.Requests
{
  public class ExtensionRequest : BaseRequest
  {
    public static readonly string KEY_CMD = "c";
    public static readonly string KEY_PARAMS = "p";
    public static readonly string KEY_ROOM = "r";
    private string extCmd;
    private ISFSObject parameters;
    //private Room room;
    private bool useUDP;

    private void Init(string extCmd, ISFSObject parameters, bool useUDP)
    {
      targetController = 1;
      this.extCmd = extCmd;
      this.parameters = parameters;
      //this.room = room;
      this.useUDP = useUDP;
    }

    public ExtensionRequest(string extCmd, ISFSObject parameters, bool useUDP)
      : base(RequestType.CallExtension)
    {
      Init(extCmd, parameters, useUDP);
    }

    public ExtensionRequest(string extCmd, ISFSObject parameters)
      : base(RequestType.CallExtension)
    {
      Init(extCmd, parameters, false);
    }

    public bool UseUDP => useUDP;

    public override void Validate(SmartFox sfs)
    {
      List<string> stringList = new List<string>();
      if (string.IsNullOrEmpty(extCmd))
        stringList.Add("Missing extension command");
      if (parameters == null)
        stringList.Add("Missing extension parameters");
      if (stringList.Count > 0)
        throw new SFSValidationError("ExtensionCall request error", stringList);
    }

    public override void Execute(SmartFox sfs)
    {
      sfso.PutUtfString(KEY_CMD, extCmd);
      //sfso.PutInt(KEY_ROOM, room?.Id ?? -1);
      sfso.PutInt(KEY_ROOM, -1);
      sfso.PutSFSObject(KEY_PARAMS, parameters);
    }
  }
}





