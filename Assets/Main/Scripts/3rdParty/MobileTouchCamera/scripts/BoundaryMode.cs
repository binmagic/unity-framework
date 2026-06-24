// /************************************************************
// *                                                           *
// *   Mobile Touch Camera                                     *
// *                                                           *
// *   Created 2015 by BitBender Games                         *
// *                                                           *
// *   bitbendergames@gmail.com                                *
// *                                                           *
// ************************************************************/

namespace BitBenderGames {

  public enum BoundaryMode {
    DEFAULT, //This mode tries to ensure that the camera can never see what's behind the boundary line.
    CLAMP_POSITION, //This mode just clamps the position of the camera to the given boundary values.
                    //Depending on the zoom and tilt the camera will be able to see behind the boundary lines but not move beyond them.
                    //This mode should be used when creating a google-earth-like camera that can have low tilt angles.
  }
}
