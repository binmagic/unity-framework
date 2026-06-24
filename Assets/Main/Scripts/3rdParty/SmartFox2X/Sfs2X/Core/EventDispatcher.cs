using System;
using System.Collections;

namespace Sfs2X.Core
{
    public class EventDispatcher
    {
        private Hashtable listeners = new Hashtable();
        private object target;

        public EventDispatcher(object target)
        {
            this.target = target;
        }

        public void AddEventListener(string eventType, EventListenerDelegate listener)
        {
            EventListenerDelegate listenerDelegate = (listeners[eventType] as EventListenerDelegate) + listener;
            listeners[eventType] = listenerDelegate;
        }

        public void RemoveEventListener(string eventType, EventListenerDelegate listener)
        {
            if (listeners[eventType] is EventListenerDelegate val)
            {
                val -= listener;
                listeners[eventType] = val;
            }
        }

        public void DispatchEvent(BaseEvent evt)
        {
            if (!(listeners[evt.Type] is EventListenerDelegate listener))
                return;
            evt.Target = target;
            try
            {
                listener(evt);
            }
            catch (Exception ex)
            {
                throw new Exception("Error dispatching event " + evt.Type + ": " + ex.Message + " " + ex.StackTrace, ex);
            }
        }

        public void RemoveAll()
        {
            listeners.Clear();
        }
    }
}





