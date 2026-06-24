using Sfs2X.Exceptions;
using Sfs2X.Logging;
using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public abstract class BaseController : IController
    {
        protected int id = -1;
        protected SmartFox sfs;
        protected ISocketClient socketClient;
        protected Logger log;

        public BaseController(ISocketClient socketClient)
        {
            this.socketClient = socketClient;
            if (socketClient == null)
                return;
            this.log = socketClient.Log;
            this.sfs = socketClient.Sfs;
        }

        public int Id
        {
            get
            {
                return this.id;
            }
            set
            {
                if (this.id != -1)
                    throw new SFSError("Controller ID is already set: " + (object) this.id + ". Can't be changed at runtime!");
                this.id = value;
            }
        }

        public abstract void HandleMessage(IMessage message);
    }
}





