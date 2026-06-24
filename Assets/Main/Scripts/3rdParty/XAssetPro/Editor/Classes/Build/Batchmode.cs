#if UNITY_EDITOR
using System;
using UnityEngine;

namespace VEngine.Editor
{
    public static class Batchmode
    {
        public static string GetArg(string name)
        {
            var args = Environment.GetCommandLineArgs();
            for (var i = 0; i < args.Length; i++)
                if (args[i] == name && args.Length > i + 1)
                    return args[i + 1];
            return null;
        }

        public static void BuildBundles()
        {
            var manifest = GetArg("-manifest");
            Debug.LogFormat("Batchmode.BuildBundles {0}", manifest);
            var settings = Settings.GetDefaultSettings();
            var target = settings.manifests.Find(m => m.name.Equals(manifest, StringComparison.OrdinalIgnoreCase));
            if (target != null)
                BuildScript.BuildBundle(target);
            else
                BuildScript.BuildBundles();
        }

        public static void BuildPlayer()
        {
            var playerGroups = GetArg("-player_groups");
            Debug.LogFormat("Batchmode.BuildPlayer {0}", playerGroups);

            if (!string.IsNullOrEmpty(playerGroups))
            {
                var settings = Settings.GetDefaultSettings();
                var list = settings.playerGroups;
                for (var index = 0; index < list.Count; index++)
                {
                    var playerGroup = list[index];
                    if (playerGroup.name.Equals(playerGroups))
                    {
                        settings.buildPlayerGroupsIndex = index;
                        settings.Save();
                        break;
                    }
                }
            }

            BuildScript.BuildPlayer();
        }
    }
}
#endif



