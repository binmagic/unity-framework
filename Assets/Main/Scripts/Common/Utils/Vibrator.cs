using MoreMountains.NiceVibrations;

//
// 振动器，控制手机设备振动
//
public class Vibrator
{
    public static void SoftImpact()
    {
#if UNITY_ANDROID
        MMVibrationManager.Haptic(HapticTypes.SoftImpact);
#endif
    }

    public static void LightImpact()
    {
#if UNITY_ANDROID
        MMVibrationManager.Haptic(HapticTypes.LightImpact);
#endif
    }
    
    public static void MediumImpact()
    {
#if UNITY_ANDROID
        MMVibrationManager.Haptic(HapticTypes.MediumImpact);
#endif
    }
    
    public static void HeavyImpact()
    {
#if UNITY_ANDROID
        MMVibrationManager.Haptic(HapticTypes.HeavyImpact);
#endif
    }
}





