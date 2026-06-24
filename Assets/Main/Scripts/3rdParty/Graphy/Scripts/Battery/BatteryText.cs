using Tayx.Graphy.Utils.NumString;
using UnityEngine;
using UnityEngine.UI;

namespace Tayx.Graphy.Battery
{
    public class BatteryText : MonoBehaviour
    {
        public Text capacity;
        public Text voltage;
        public Text electricity;
        public Text power;
        public Text time;

        private float lastTime;
        
        void Update()
        {
            float now = Time.time;
            if (now - lastTime > 10)
            {
                lastTime = now;
                
                float c = Battery.capacity;
                float v = Battery.voltage;
                float e = Battery.electricity;
                int p = (int) (e * v * 0.001f);
                float h = c / e;

                capacity.text = c.ToStringNonAlloc();
                voltage.text = v.ToStringNonAlloc();
                electricity.text = e.ToStringNonAlloc();
                power.text = p.ToStringNonAlloc();
                time.text = h.ToStringNonAlloc();
            }
        }
    }
}





