// /************************************************************
// *                                                           *
// *   Mobile Touch Camera                                     *
// *                                                           *
// *   Created 2015 by BitBender Games                         *
// *                                                           *
// *   bitbendergames@gmail.com                                *
// *                                                           *
// ************************************************************/

using UnityEngine;
using System.Collections;

namespace BitBenderGames {

  /// <summary>
  /// Helper script that adds Double Click To Zoom functionality to Mobile Touch Camera.
  /// 
  /// Usage: Add this component to the GameObject that also has the MobileTouchCamera
  ///        and the TouchInputController attached.
  /// </summary>
  [RequireComponent(typeof(MobileTouchCamera))]
  [RequireComponent(typeof(TouchInputController))]
  public class DoubleClickZoom : MonoBehaviour {

    [SerializeField]
    private float zoomAmount = 5f;

    private MobileTouchCamera mobileTouchCamera;

    private TouchInputController touchInputController;

    private void Awake() {
      mobileTouchCamera = GetComponent<MobileTouchCamera>();
      touchInputController = GetComponent<TouchInputController>();
      touchInputController.OnInputClick += TouchInputController_OnInputClick;
    }

    private void TouchInputController_OnInputClick(Vector3 clickPosition, bool isDoubleClick, bool isLongTap) {
      if(isDoubleClick == true) {
        OnDoubleClick();
      }
    }

    public void OnDoubleClick() {
      var zoom = mobileTouchCamera.CamZoom;
      var zoomTarget = zoom - zoomAmount;
      StartCoroutine(mobileTouchCamera.ZoomToTargetValueCoroutine(zoomTarget));
    }
  }
}