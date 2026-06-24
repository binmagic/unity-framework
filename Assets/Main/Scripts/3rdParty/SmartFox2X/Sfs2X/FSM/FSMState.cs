using System.Collections.Generic;

namespace Sfs2X.FSM
{
  public class FSMState
  {
    private Dictionary<int, int> transitions = new Dictionary<int, int>();
    private int stateName;

    public void SetStateName(int newStateName)
    {
      stateName = newStateName;
    }

    public int GetStateName()
    {
      return stateName;
    }

    public void AddTransition(int transition, int outputState)
    {
      transitions[transition] = outputState;
    }

    public int ApplyTransition(int transition)
    {
      int num = stateName;
      if (transitions.ContainsKey(transition))
        num = transitions[transition];
      return num;
    }
  }
}





