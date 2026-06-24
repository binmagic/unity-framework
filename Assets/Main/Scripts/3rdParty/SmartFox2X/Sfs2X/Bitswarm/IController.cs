using Sfs2X.Util;

namespace Sfs2X.Bitswarm
{
    public interface IController
    {
        int Id { get; set; }

        void HandleMessage(IMessage message);
    }
}





