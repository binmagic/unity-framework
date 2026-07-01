//  ***
//  * Created by zhangliheng.
//  * DateTime: 2025/05/21 10:04 PM
//  *
//  * 横竖屏切换时自动设置GameViewResolution
//  ***/

#if UNITY_EDITOR

using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEditor.ShortcutManagement;

public static class GameViewResHelper
{
    private static object gameviewSizesInstance;
    private static Type GameViewType;
    private static MethodInfo GameView_SizeSelectionCallback;
    private static Type GameViewSizesType;
    private static MethodInfo GameViewSizes_GetGroup;
    private static Type GameViewSizeSingleType;

    static GameViewResHelper()
    {
        GameViewType = typeof(Editor).Assembly.GetType( "UnityEditor.GameView" );
        GameView_SizeSelectionCallback = GameViewType.GetMethod( "SizeSelectionCallback", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic );
        GameViewSizesType = typeof(Editor).Assembly.GetType( "UnityEditor.GameViewSizes" );
        GameViewSizeSingleType = typeof( ScriptableSingleton<> ).MakeGenericType( GameViewSizesType );
        GameViewSizes_GetGroup = GameViewSizesType.GetMethod( "GetGroup" );

        var instanceProp = GameViewSizeSingleType.GetProperty("instance");
        gameviewSizesInstance = instanceProp.GetValue( null, null );
    }
    
    static GameViewSizeGroupType GetCurrentGroupType()
    {
    #if UNITY_STANDALONE
        return GameViewSizeGroupType.Standalone;
    #elif UNITY_IOS
        return GameViewSizeGroupType.iOS;
    #elif UNITY_ANDROID
        return GameViewSizeGroupType.Android;
    #elif UNITY_WEBGL
        // WebGL 在 Game View 里没有独立分组，复用 Standalone
        return GameViewSizeGroupType.Standalone;
    #else
        return GameViewSizeGroupType.Standalone;
    #endif
    }
    
    [MenuItem( "Tools/zlh/ChangeToLandScape" )]
    public static void ChangeToLandScape( )
    {
        TrySetSize( 1750, 750, GetCurrentGroupType());
    }

    [MenuItem( "Tools/zlh/ChangeToPortrait" )]
    public static void ChangeToPortrait( )
    {
        TrySetSize( 750, 1750, GetCurrentGroupType());
    }
    
    public static bool TrySetSize(int w, int h, GameViewSizeGroupType currentView=GameViewSizeGroupType.Standalone)
    {
        int foundIndex = FindOrAddSize(currentView, w, h);
        if (foundIndex < 0)
        {
            return false;
        }

        SetSizeIndex (foundIndex);
        return true;
    }


    public static void SetSizeIndex( int index )
    {
        EditorWindow currentWindow = EditorWindow.focusedWindow;
        SceneView lastSceneView = SceneView.lastActiveSceneView;

        EditorWindow gv = EditorWindow.GetWindow( GameViewType );
        GameView_SizeSelectionCallback.Invoke( gv, new object[] { index, null } );
        if( lastSceneView != null )
            lastSceneView.Focus( );

        if( currentWindow != null )
            currentWindow.Focus( );
    }

    public static int FindOrAddSize( GameViewSizeGroupType sizeGroupType, int width, int height)
    {
        var group = GetGroup(sizeGroupType);
        
        var getGameViewSize = group.GetType().GetMethod("GetGameViewSize");
        var getBuiltinCount = group.GetType().GetMethod("GetBuiltinCount");
        var getTotalCount = group.GetType().GetMethod("GetTotalCount");
        
        var builtinCount = (int)getBuiltinCount.Invoke(group, null);
        var totalCount = (int)getTotalCount.Invoke(group, null);

        for (int i = builtinCount; i < totalCount; i++)
        {
            var size = getGameViewSize.Invoke(group, new object[] { i }); //class GameViewSize
            var sizeType = size.GetType();
            int sizeWidth = (int)sizeType.GetProperty("width").GetValue(size);
            int sizeHeight = (int)sizeType.GetProperty("height").GetValue(size);

            if (sizeWidth == width && sizeHeight == height)
                return i;
        }

        var gameViewSizeType = Type.GetType("UnityEditor.GameViewSize,UnityEditor");
        var gameViewSizeTypeEnum = Type.GetType("UnityEditor.GameViewSizeType,UnityEditor");
        var fixedResolution = Enum.Parse(gameViewSizeTypeEnum, "FixedResolution");

        var ctor = gameViewSizeType.GetConstructor(new Type[]
        {
            gameViewSizeTypeEnum, typeof(int), typeof(int), typeof(string)
        });

        var newSize = ctor.Invoke(new object[] { fixedResolution, width, height, $"lz_{width}x{height}"});

        
        var addCustomSize = group.GetType().GetMethod("AddCustomSize");
        addCustomSize.Invoke(group, new object[] { newSize });
        
        return totalCount;
    }
    
    static object GetGroup( GameViewSizeGroupType type )
    {
        return GameViewSizes_GetGroup.Invoke( gameviewSizesInstance, new object[] { (int)type } );
    }
}
#endif