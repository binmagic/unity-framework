#if UNITY_ANDROID

#if UNITY_6000_1_OR_NEWER || (UNITY_6000_0_OR_NEWER && !(UNITY_6000_0_1 || UNITY_6000_0_2 || UNITY_6000_0_3 || UNITY_6000_0_4 || UNITY_6000_0_5 || UNITY_6000_0_6 || UNITY_6000_0_7 || UNITY_6000_0_8 || UNITY_6000_0_9 || UNITY_6000_0_10 || UNITY_6000_0_11 || UNITY_6000_0_12 || UNITY_6000_0_13 || UNITY_6000_0_14 || UNITY_6000_0_15 || UNITY_6000_0_16 || UNITY_6000_0_17 || UNITY_6000_0_18 || UNITY_6000_0_19 || UNITY_6000_0_20 || UNITY_6000_0_21 || UNITY_6000_0_22 || UNITY_6000_0_23 || UNITY_6000_0_24 || UNITY_6000_0_25 || UNITY_6000_0_26 || UNITY_6000_0_27 || UNITY_6000_0_28 || UNITY_6000_0_29 || UNITY_6000_0_30 || UNITY_6000_0_31 || UNITY_6000_0_32 || UNITY_6000_0_33 || UNITY_6000_0_34 || UNITY_6000_0_35 || UNITY_6000_0_36 || UNITY_6000_0_37 || UNITY_6000_0_38 || UNITY_6000_0_39 || UNITY_6000_0_40 || UNITY_6000_0_41 || UNITY_6000_0_42 || UNITY_6000_0_43 || UNITY_6000_0_44))
#define ANDROID_GRADLE_PLUGIN_8_7_2_AVAILABLE
#endif

using UnityEngine;
using UnityEditor.Android;
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.Build;
using System.Collections.Generic;

//-----------------------------------------------------------------------------
// Copyright 2012-2021 RenderHeads Ltd.  All rights reserved.
//-----------------------------------------------------------------------------

namespace RenderHeads.Media.AVProVideo.Editor
{
	class PreProcessBuild_Android : IPreprocessBuildWithReport
	{
		public int callbackOrder { get { return 0; } }
		public void OnPreprocessBuild( BuildReport report )
		{
			if( PlayerSettings.Android.minSdkVersion < AndroidSdkVersions.AndroidApiLevel26 )
			{
				string message = "AVPro Video requires the 'Minimum API Level' must be set to Android 8.0 'Oreo' (API Level 26) or higher in 'Player Settings'";
				if( !EditorUtility.DisplayDialog( "Continue Build?", message, "Continue", "Cancel" ) )
				{
					throw new BuildFailedException( message );
				}
			}
			if( PlayerSettings.Android.targetSdkVersion <= AndroidSdkVersions.AndroidApiLevel30 &&
				PlayerSettings.Android.targetSdkVersion != AndroidSdkVersions.AndroidApiLevelAuto )
			{
				string message = "AVPro Video requires the 'Target API Level' must be set to Android 12.0 (API Level 31) or higher in 'Player Settings'";
				message += "\n\nYou may need to install/target an Android SDK externally to Unity. See 'Edit | Preferences | External Tools | Android SDK' override";
				if( !EditorUtility.DisplayDialog( "Continue Build?", message, "Continue", "Cancel" ) )
				{
					throw new BuildFailedException( message );
				}
			}
		}
	}

	public class PostProcessBuild_Android : IPostGenerateGradleAndroidProject
	{
		public int callbackOrder { get { return 1; } }

		public void OnPostGenerateGradleAndroidProject( string path )
		{
			if( PlayerSettings.Android.targetSdkVersion == AndroidSdkVersions.AndroidApiLevelAuto )
			{
				Debug.Log( "[AVProVideo] The 'Target API Level' in 'Player Settings' is currently set to 'Automatic (highest installed)'. AVPro Video requires this to be Android 12.0 (API Level 31) or higher. If the 'highest installed' is lower, you may encounter build errors" );
			}

			GradleProperty( path );
			GradleLauncherTemplate( path );
			GradleMainTemplate( path );
		}

		private void GradleProperty( string path )
		{
#if UNITY_2020_1_OR_NEWER || UNITY_2020_OR_NEWER
			// When using Unity 2020.1 and above it has been seen that the build process overly optimises which causes issues in the ExoPlayer library.
			// To overcome this issue, we need to add 'android.enableDexingArtifactTransform=false' to the gradle.properties.
			// Note that this can be done by the developer at project level already.

			Debug.Log( "[AVProVideo] Post-processing Android project: patching gradle.properties" );

			StringBuilder stringBuilder = new StringBuilder();

			// Path to gradle.properties
			string filePath = Path.Combine( path, "..", "gradle.properties" );

			if( File.Exists( filePath ) )
			{
				// Load in all the lines in the file
				string[] allLines = File.ReadAllLines( filePath );

				foreach( string line in allLines )
				{
					if( line.Length > 0 )
					{
#if UNITY_6000_0_OR_NEWER
						// Add everything except useFullClasspathForDexingTransform and android.useAndroidX
						if ( !line.Contains( "android.useFullClasspathForDexingTransform" ) && 
							!line.Contains( "android.useAndroidX" ) )
						{
							stringBuilder.AppendLine( line );
						}
#else
						// Add everything except enableDexingArtifactTransform and android.useAndroidX
						if( !line.Contains( "android.enableDexingArtifactTransform" ) &&
							!line.Contains( "android.useAndroidX" ) )
						{
							stringBuilder.AppendLine( line );
						}
#endif
					}
				}

#if UNITY_6000_0_OR_NEWER
				// Add in line to set useFullClasspathForDexingTransform to true
				stringBuilder.AppendLine( "android.useFullClasspathForDexingTransform=true" );
#else
				// Add in line to set enableDexingArtifactTransform to false
				stringBuilder.AppendLine( "android.enableDexingArtifactTransform=false" );
#endif

				// Add in line to set useAndroidX to true
				stringBuilder.AppendLine( "android.useAndroidX=true" );

				// Write out the amended file
				File.WriteAllText( filePath, stringBuilder.ToString() );
			}
#endif
		}

		private void GradleLauncherTemplate( string path )
		{
#if !UNITY_2020_1_OR_NEWER
			Debug.Log( "[AVProVideo] Post-processing Android project: patching launcher build.gradle" );

			// Path to build.gradle that came from mainTemplate.gradle
			string filePath = Path.Combine( path, "", "../launcher/build.gradle" );

			bool bFileExists = File.Exists( filePath );
			if( !bFileExists )
			{
				// Warning that file does not exist - should never happen
				EditorUtility.DisplayDialog( "AVPro Video", "Something went wrong during the build process. Could not find launcher file 'build.gradle'.", "OK" );
			}
			else
			{
				StringBuilder stringBuilder = new StringBuilder();

				// Load in all the lines in the file
				string[] allLines = File.ReadAllLines( filePath );

				bool bInPackagingOptionsBlock = false;
				foreach( string line in allLines )
				{
					if( line.Length > 0 )
					{
						if( bInPackagingOptionsBlock )
						{
							// Watch for the closing brace of the 'dependencies' block
							if( line.Trim().Equals( "}" ) )
							{
								// Coming out of the dependencies block
								bInPackagingOptionsBlock = false;
							}

							if( !bInPackagingOptionsBlock )
							{
								stringBuilder.AppendLine( "\t\texclude 'META-INF/*'" );
							}

							// Add the line
							stringBuilder.AppendLine( line );
						}
						else
						{
							// Watch for 'packagingOptions {' block
							if( line.Contains( "packagingOptions {" ) )
							{
								bInPackagingOptionsBlock = true;
							}

							// Add the line
							stringBuilder.AppendLine( line );
						}
					}
				}

				// Write out the amended file
				File.WriteAllText( filePath, stringBuilder.ToString() );
			}
#endif
		}

		private void GradleMainTemplate( string path )
		{
			// Add in the use of media3 libraries

			Debug.Log( "[AVProVideo] Post-processing Android project: patching build.gradle" );

			// Path to build.gradle that came from mainTemplate.gradle
			string filePath = Path.Combine( path, "", "build.gradle" );

			bool bFileExists = File.Exists( filePath );
			if( !bFileExists )
			{
				// Warning that file does not exist - should never happen
				EditorUtility.DisplayDialog( "AVPro Video", "Something went wrong during the build process. Could not find file 'build.gradle'.", "OK" );
			}
			else
			{
				StringBuilder stringBuilder = new StringBuilder();

				// Load in all the lines in the file
				string[] allLines = File.ReadAllLines( filePath );

#if ANDROID_GRADLE_PLUGIN_8_7_2_AVAILABLE
				const string media3Version = "1.8.0";
#else
				const string media3Version = "1.4.1";
#endif
				Debug.Log($"[AVProVideo] Using media3 version {media3Version}");

				List<CLibInfo> libs = new List<CLibInfo>
				{
					new CLibInfo( "androidx.media3", "media3-common", media3Version ),
					new CLibInfo( "androidx.media3", "media3-container", media3Version ),
					new CLibInfo( "androidx.media3", "media3-database", media3Version ),
					new CLibInfo( "androidx.media3", "media3-datasource", media3Version ),
					new CLibInfo( "androidx.media3", "media3-datasource-cronet", media3Version ),
					new CLibInfo( "androidx.media3", "media3-datasource-okhttp", media3Version ),
					new CLibInfo( "androidx.media3", "media3-decoder", media3Version ),
					new CLibInfo( "androidx.media3", "media3-extractor", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer-dash", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer-hls", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer-rtsp", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer-smoothstreaming", media3Version ),
					new CLibInfo( "androidx.media3", "media3-exoplayer-workmanager", media3Version ),
					new CLibInfo( "androidx.media3", "media3-datasource-rtmp", media3Version )
				};

				//
				string guavaFixLine = "dependencies.constraints { implementation( \"com.google.guava:guava\" ) { attributes { attribute( Attribute.of( \"org.gradle.jvm.environment\", String ), \"standard-jvm\" ) } } }";

				//
				string rtmpClientFixLine = "configurations.implementation { exclude group:'io.antmedia', module:'rtmp-client' }";

				//
				bool bInDependenciesBlock = false;
				bool bWatchForDependenciesBlock = true;
				foreach( string line in allLines )
				{
					if( line.Length > 0 )
					{
						if (bInDependenciesBlock)
						{
							bool bAddLine = true;

							for (int iLib = 0; iLib < libs.Count; ++iLib)
							{
								if (line.Contains(libs[iLib].GetLibrary()))
								{
									bAddLine = false;
									break;
								}
							}

							if (bAddLine)
							{
								// Watch for the closing brace of the 'dependencies' block
								if (line.Equals("}"))
								{
									for (int iLib = 0; iLib < libs.Count; ++iLib)
									{
										var info = libs[iLib];
										var implementation = $"\timplementation('{info.GetString()}')";
										stringBuilder.AppendLine(implementation);
									}

									// Coming out of the dependencies block
									bInDependenciesBlock = false;
								}

								// Add the line
								stringBuilder.AppendLine(line);

								if (!bInDependenciesBlock)
								{
									// Add guava fix line
									stringBuilder.AppendLine("");
									stringBuilder.AppendLine(guavaFixLine);
									stringBuilder.AppendLine("");
									stringBuilder.AppendLine(rtmpClientFixLine);
									stringBuilder.AppendLine("");

									bWatchForDependenciesBlock = false;
								}
							}
						}
						else
						{
							if (bWatchForDependenciesBlock)
							{
								// Watch for 'dependencies {' block
								if (line.StartsWith("dependencies {"))
								{
									bInDependenciesBlock = true;
								}
							}

							if (!(line.Contains(guavaFixLine) || line.Contains(rtmpClientFixLine)))
							{
								// Add the line
								stringBuilder.AppendLine(line);
							}
						}
					}
				}

				// Write out the amended file
				File.WriteAllText( filePath, stringBuilder.ToString() );
			}
		}

		class CLibInfo
		{
			private string m_Package = "";
			private string m_Library = "";
			private string m_Version = "";

			public CLibInfo(string package, string library, string version)
			{
				m_Package = package;
				m_Library = library;
				m_Version = version;
			}

			public string GetLibrary()
			{
				return m_Library;
			}

			public string GetString()
			{
				return $"{m_Package}:{m_Library}:{m_Version}";
			}
		};
	}
}

#endif // UNITY_ANDROID