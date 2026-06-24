using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace RenderHeads.Media.AVProVideo.Editor
{

	internal class ProjectSettings : ScriptableObject
	{
		const string ProjectSettingsFilename = "ProjectSettings.asset";

#pragma warning disable 0414   // "field is assigned but its value is never used"

		[SerializeField]
		bool _enableFacebook360Support = true;

		[SerializeField]
		bool _enableFacebook360Support_x86_64 = false;

#pragma warning restore 0414

		internal bool IsFacebook360SupportEnabled
		{
			get { return _enableFacebook360Support; }
		}

		internal bool IsFacebook360SupportOnx86_64Enabled
		{
			get { return _enableFacebook360Support_x86_64; }
		}

		internal static ProjectSettings GetOrCreateProjectSettings()
		{
			ProjectSettings settings = null;

			// Find the AVProVideo/Editor folder
		#if UNITY_6000_0_OR_NEWER
			var assetGuids = AssetDatabase.FindAssetGUIDs("glob:AVProVideo/Editor");
		#else
			var assetGuids = AssetDatabase.FindAssets("glob:AVProVideo/Editor");
		#endif
			if (assetGuids.Length == 0)
			{
				// Can't find it, just bail
                return ScriptableObject.CreateInstance<ProjectSettings>();
            }

			string path = AssetDatabase.GUIDToAssetPath(assetGuids[0]);
			string projectSettingsPath = System.IO.Path.Combine(path, ProjectSettingsFilename);
			settings = AssetDatabase.LoadAssetAtPath<ProjectSettings>(projectSettingsPath);
			if (settings == null)
			{
				settings = ScriptableObject.CreateInstance<ProjectSettings>();
				AssetDatabase.CreateAsset(settings, projectSettingsPath);
				AssetDatabase.SaveAssets();
			}

			return settings;
		}

		internal static SerializedObject GetSerializedSettings()
		{
			return new SerializedObject(GetOrCreateProjectSettings());
		}
	}

	internal static class ProjectSettingsIMGUIRegister
	{
#if UNITY_2018_3_OR_NEWER
		private class ProjectSettingsProvider : SettingsProvider
		{
			public ProjectSettingsProvider(string path, SettingsScope scope)
			:	base(path, scope)
			{
				this.keywords = new HashSet<string>(new[] { "facebook", "audio360" });
			}

			public override void OnGUI(string searchContext)
			{
				ProjectSettingsGUI();
			}
		}

		[SettingsProvider]
		static SettingsProvider CreateSettingsProvider()
		{
			return new ProjectSettingsProvider("Project/AVPro Video", SettingsScope.Project);
		}

#elif UNITY_5_6_OR_NEWER
		[PreferenceItem("AVPro Video")]
#endif
		private static void ProjectSettingsGUI()
		{
			SerializedObject settings = ProjectSettings.GetSerializedSettings();

			SerializedProperty propEnableFacebook360Support =
					settings.FindProperty("_enableFacebook360Support");

			SerializedProperty propEnableFacebook360Support_x86_64 =
					settings.FindProperty("_enableFacebook360Support_x86_64");

			EditorGUILayout.Space();
			EditorGUILayout.BeginVertical();
			{
				EditorGUILayout.LabelField("Android", EditorStyles.boldLabel);

				// Facebook360
				EditorGUILayout.BeginHorizontal();
				{
					EditorGUILayout.LabelField(
						new GUIContent(
							"Enable Facebook Audio 360",
							"Enable this to include support for Facebook Audio 360"
						),
						GUILayout.MaxWidth(250.0f)
					);

					propEnableFacebook360Support.boolValue =
							EditorGUILayout.Toggle(propEnableFacebook360Support.boolValue);
				}
				EditorGUILayout.EndHorizontal();

				// Facebook360 x86_64
				if (propEnableFacebook360Support.boolValue)
				{
					EditorGUILayout.BeginHorizontal();
					{
						EditorGUILayout.LabelField(
							new GUIContent(
								"Enable Facebook Audio 360 on x86_64",
								"Enable this to include support for Facebook Audio 360 on x86_64"
							),
							GUILayout.MaxWidth(250.0f)
						);

						propEnableFacebook360Support_x86_64.boolValue =
								EditorGUILayout.Toggle(propEnableFacebook360Support_x86_64.boolValue);
					}
					EditorGUILayout.EndHorizontal();

					if (propEnableFacebook360Support_x86_64.boolValue)
					{
						EditorHelper.IMGUI.NoticeBox(
							MessageType.Warning,
							"The Facebook 360 Audio libraries are not 16KiB aligned."
						);
					}
				}
			}
			EditorGUILayout.EndVertical();

			settings.ApplyModifiedPropertiesWithoutUndo();
		}
	}
}
