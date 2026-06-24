using Sfs2X.Bitswarm;
using Sfs2X.Entities.Data;

namespace Sfs2X.Requests
{
  public class BaseRequest : IRequest
  {
    public static readonly string KEY_ERROR_CODE = "ec";
    public static readonly string KEY_ERROR_PARAMS = "ep";
    protected ISFSObject sfso;
    protected int targetController;
    private bool isEncrypted;

    public BaseRequest(RequestType tp)
    {
      sfso = SFSObject.NewInstance();
      targetController = 0;
      isEncrypted = false;
      Id = (int) tp;
    }

    public BaseRequest(int id)
    {
      sfso = SFSObject.NewInstance();
      targetController = 0;
      isEncrypted = false;
      this.Id = id;
    }

    public virtual void Validate(SmartFox sfs)
    {
    }

    public virtual void Execute(SmartFox sfs)
    {
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

    public IMessage Message
    {
      get
      {
        IMessage message = new Message();
        message.Id = Id;
        message.IsEncrypted = isEncrypted;
        message.TargetController = targetController;
        message.Content = sfso;
        if (this is ExtensionRequest)
          message.IsUDP = ((ExtensionRequest) this).UseUDP;
        return message;
      }
    }

    public int Id { get; set; }

    public RequestType Type
    {
      get => (RequestType) Id;
      set => Id = (int) value;
    }
  }
}





