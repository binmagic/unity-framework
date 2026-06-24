using Sfs2X.Bitswarm;
using Sfs2X.FSM;
using Sfs2X.Logging;

namespace Sfs2X.Core.Sockets
{
  public class BaseSocketLayer
  {
    protected volatile bool isDisconnecting = false;
    protected Logger log;
    protected ISocketClient socketClient;
    protected FiniteStateMachine fsm;

    protected States State => (States) fsm.GetCurrentState();

    protected void InitStates()
    {
      fsm = new FiniteStateMachine();
      fsm.AddAllStates(typeof (States));
      fsm.AddStateTransition((int)States.Disconnected, (int)States.Connecting, (int)Transitions.StartConnect);
      fsm.AddStateTransition((int)States.Connecting, (int)States.Connected, (int)Transitions.ConnectionSuccess);
      fsm.AddStateTransition((int)States.Connecting, (int)States.Disconnected, (int)Transitions.ConnectionFailure);
      fsm.AddStateTransition((int)States.Connected, (int)States.Disconnected, (int)Transitions.Disconnect);
      fsm.SetCurrentState((int)States.Disconnected);
    }

    protected enum States
    {
      Disconnected,
      Connecting,
      Connected,
    }

    protected enum Transitions
    {
      StartConnect,
      ConnectionSuccess,
      ConnectionFailure,
      Disconnect,
    }
  }
}





