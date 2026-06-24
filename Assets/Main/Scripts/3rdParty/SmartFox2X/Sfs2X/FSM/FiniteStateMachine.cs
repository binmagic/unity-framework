using System;
using System.Collections.Generic;

namespace Sfs2X.FSM
{
    public class FiniteStateMachine
    {
        private Dictionary<int, FSMState> states = new Dictionary<int, FSMState>();
        private object locker = new object();
        private volatile int currentStateName;
        public OnStateChangeDelegate onStateChange;

        public void AddState(int st)
        {
            int newStateName =  st;
            FSMState fsmState = new FSMState();
            fsmState.SetStateName(newStateName);
            states.Add(st, fsmState);
        }

        public void AddAllStates(Type statesEnumType)
        {
            foreach (int st in Enum.GetValues(statesEnumType))
                AddState(st);
        }

        public void AddStateTransition(int from, int to, int tr)
        {
            int num = from;
            int outputState = to;
            int transition = tr;
            FindStateObjByName(num).AddTransition(transition, outputState);
        }

        public int ApplyTransition(int tr)
        {
            lock (locker)
            {
                int transition = tr;
                int currentStateName = this.currentStateName;
                this.currentStateName = FindStateObjByName(this.currentStateName).ApplyTransition(transition);
                if (currentStateName != this.currentStateName && onStateChange != null)
                    onStateChange(currentStateName, this.currentStateName);
                return this.currentStateName;
            }
        }

        public int GetCurrentState()
        {
            lock (locker)
                return currentStateName;
        }

        public void SetCurrentState(int state)
        {
            int toStateName = state;
            onStateChange?.Invoke(currentStateName, toStateName);
            currentStateName = toStateName;
        }

        private FSMState FindStateObjByName(int st)
        {
            if (states.TryGetValue(st, out var state))
            {
                return state;
            }

            return null;
        }

        public delegate void OnStateChangeDelegate(int fromStateName, int toStateName);
    }
}





