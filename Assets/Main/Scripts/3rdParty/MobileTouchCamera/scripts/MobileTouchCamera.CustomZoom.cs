//  ***
//  * Restored project-specific MobileTouchCamera members that lived on the old, customized
//  * copy of this plugin and were lost when it was replaced with the stock BitBenderGames version.
//  *
//  * Kept in a partial class so the 3rd-party MobileTouchCamera.cs stays otherwise untouched.
//  * These provide the read/write/storage surface consumed by CameraGFXPanel (debug panel) and
//  * any gameplay code that frames the camera for buildings / farm / formation.
//  *
//  * NOTE: this restores the stored values only. The camera *behaviour* that originally consumed
//  * them (zoom-to-building-height, per-level sensitivity, farm/formation framing) was also part of
//  * the old customized plugin and must be restored separately if it is still required.
//  ***/

using System.Collections.Generic;
using UnityEngine;

namespace BitBenderGames
{
    public partial class MobileTouchCamera
    {
        /// <summary>
        /// Per-zoom-level parameters. Reference type on purpose: callers mutate list
        /// elements in place (e.g. CameraGFXPanel), which only persists for a class.
        /// </summary>
        [System.Serializable]
        public class ZoomParam
        {
            public float posY;
            public float offsetZ;
            public float sensitivity;
        }

        [Header("Custom Zoom (restored)")]
        [SerializeField] private float camZoomInit;
        [SerializeField] private List<ZoomParam> customZoomParams = new List<ZoomParam>();

        [SerializeField] private float camZoomBuild;
        [SerializeField] private float camZoomFocusRotation;
        [SerializeField] private float camZoomFarmPlant;
        [SerializeField] private float camZoomFarmPlantRotation;
        [SerializeField] private float camZoomFormation;
        [SerializeField] private float camZoomFocusFormationRotation;

        public float CamZoomInit
        {
            get { return camZoomInit; }
            set { camZoomInit = value; }
        }

        public float CamZoomBuild
        {
            get { return camZoomBuild; }
            set { camZoomBuild = value; }
        }

        public float CamZoomFocusRotation
        {
            get { return camZoomFocusRotation; }
            set { camZoomFocusRotation = value; }
        }

        public float CamZoomFarmPlant
        {
            get { return camZoomFarmPlant; }
            set { camZoomFarmPlant = value; }
        }

        public float CamZoomFarmPlantRotation
        {
            get { return camZoomFarmPlantRotation; }
            set { camZoomFarmPlantRotation = value; }
        }

        public float CamZoomFormation
        {
            get { return camZoomFormation; }
            set { camZoomFormation = value; }
        }

        public float CamZoomFocusFormationRotation
        {
            get { return camZoomFocusFormationRotation; }
            set { camZoomFocusFormationRotation = value; }
        }

        public List<ZoomParam> GetZoomParams()
        {
            return customZoomParams;
        }

        public void SetZoomParams(List<ZoomParam> zoomParams)
        {
            customZoomParams = zoomParams;
        }
    }
}
