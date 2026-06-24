using UnityEngine;
using UnityEditor;

//-----------------------------------------------------------------------------
// Copyright 2015-2025 RenderHeads Ltd.  All rights reserved.
//-----------------------------------------------------------------------------

namespace RenderHeads.Media.AVProVideo.Editor
{
	[CustomPropertyDrawer(typeof(MediaHints))]
	public class MediaHintsDrawer : PropertyDrawer
	{
		public override float GetPropertyHeight(SerializedProperty property, GUIContent label) { return 0f; }

		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			EditorGUI.BeginProperty(position, GUIContent.none, property);

			SerializedProperty propHintsTransparency = property.FindPropertyRelative("transparency");
			SerializedProperty propHintsAlphaPacking = property.FindPropertyRelative("alphaPacking");
			SerializedProperty propHintsStereoPacking = property.FindPropertyRelative("stereoPacking");

			EditorGUILayout.PropertyField(propHintsTransparency);
			if ((TransparencyMode)propHintsTransparency.enumValueIndex == TransparencyMode.Transparent)
			{
				EditorGUILayout.PropertyField(propHintsAlphaPacking);
			}

			EditorGUILayout.PropertyField(propHintsStereoPacking);

			EditorGUI.EndProperty();
		}
	}
}
