using System.Collections.Generic;

/**
 * 策划配置缓存，策划配置都在lua缓存，c#获取配置内容需要调用lua接口，
 * 由于世界加载时同一帧会有多次获取配置需求，在此处针对获取配置做个缓存提高调用效率
 */
public class ConfigCache
{
  private Dictionary<string, Dictionary<int, Dictionary<string, string>>> cacheConfig;

  public ConfigCache()
  {
      cacheConfig = new Dictionary<string, Dictionary<int, Dictionary<string, string>>>();
  }

  public string GetTemplateData(string tabName, int id, string colName)
  {
      if (cacheConfig.ContainsKey(tabName))
      {
          if (cacheConfig[tabName].ContainsKey(id))
          {
              if (cacheConfig[tabName][id].ContainsKey(colName))
              {
                  return cacheConfig[tabName][id][colName];
              }
              else
              {
                  var res = GameEntry.Lua.GetTemplateData(tabName, id, colName);
                  cacheConfig[tabName][id].Add(colName, res);
                  return res;
              }
          }
          else
          {
              var res = GameEntry.Lua.GetTemplateData(tabName, id, colName);
              Dictionary<string, string> infos = new Dictionary<string, string>();
              infos.Add(colName, res);
              cacheConfig[tabName].Add(id, infos);
              return res;
          }
      }
      else
      {
          var res = GameEntry.Lua.GetTemplateData(tabName, id, colName);
          Dictionary<string, string> infos = new Dictionary<string, string>();
          infos.Add(colName, res);
          Dictionary<int, Dictionary<string, string>> tmp = new Dictionary<int, Dictionary<string, string>>();
          tmp.Add(id, infos);
          cacheConfig.Add(tabName, tmp);
          return res;
      }
  }

  public void reset()
  {
      cacheConfig.Clear();
  }
}





