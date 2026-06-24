using System.Collections.Generic;
using GameFramework;
using UnityEngine;
/// <summary>
/// 渲染控制台
/// Lighting 主光，环境光
/// SceneViewer
/// ShaderLOD,globalShader
/// Other 其他参数
/// 注意 AddPanel要由外部来做
/// </summary>
public class BaseGFXConsole : MonoBehaviour
{
   private bool bShowConsole=true;
   
   private List<BaseGFXPanel> panelList;
   private string[] panelNameArr;
   private int currPanelIdx;
   
   private Rect windowRect;
   private Vector2 scrollPosi;

   //public GameObject inputRootGO;
   public static BaseGFXConsole Instance { get; private set; }


   private float screenWidth;
   private float screenHeight;
   private float resFactor  = 1.0f;
   private float fixedWidth  = 330;
   void Awake()
   {
      Instance = this;
      panelList=new List<BaseGFXPanel>();

      //添加各个面板
      Initialize();
   }

   protected virtual void Initialize()
   {
      
   }
   
   protected virtual void OnShowConsole()
   {
      
   }
   protected virtual void OnHideConsole()
   {
      
   }

   protected void AddPanel(BaseGFXPanel panel)
   {
     panelList.Add(panel);
     panel.Init();
   }


   private bool firstShow = true;
   void OnGUI()
   {
      //有可能在profiler中改了分辨率
      screenWidth = Screen.width;
      screenHeight = Screen.height;
      resFactor = screenHeight / 750f;
      
      MakeBigGUISkin();

      if (GUI.Button(new Rect(300,screenHeight/2 - 200* resFactor,150 * resFactor,80* resFactor),"渲染控制台"))
      {
         bShowConsole = !bShowConsole;
       
         if (bShowConsole)
         {
            OnShowConsole();
         }
         else
         {
            OnHideConsole();
         }
      }

      if (GUI.Button(new Rect(300, screenHeight / 2 - 100* resFactor, 150* resFactor, 80* resFactor), "Login"))
      {
         //ApplicationLaunch.Instance.Loading.ReConnect();
      }
      
      if (GUI.Button(new Rect(300, screenHeight / 2 + 0* resFactor, 150* resFactor, 80* resFactor), "GC Collect"))
      {
         GameEntry.Lua.Env.FullGc();
         GameEntry.Resource.CollectGarbage();
         System.GC.Collect();
      }
      
      if (GUI.Button(new Rect(300, screenHeight / 2 + 100* resFactor, 150* resFactor, 80* resFactor), "Debug Cache"))
      {
         GameEntry.Resource.DebugOutput();
      }
      
      if (GUI.Button(new Rect(300, screenHeight / 2 + 200* resFactor, 150* resFactor, 80* resFactor), "LoadCount"))
      {
         GameEntry.Resource.DebugLoadCount();
      }

      if (bShowConsole)
      {


         var width = fixedWidth * resFactor;
         windowRect = new Rect(screenWidth - width, 0, width, screenHeight);
         windowRect = GUILayout.Window(0, windowRect, DoMyWindow, "");

         if (firstShow) //首次默认打开手动调用下OnShow
         {
            firstShow = false;
            OnShowConsole();
         }
      }
   }
   
   void DoMyWindow(int windowID)
   {
      scrollPosi = GUILayout.BeginScrollView(scrollPosi);
      DrawHead();
      GUILayout.Space(30);
      DrawBody();
      GUILayout.EndScrollView();
   }
   
   private void DrawHead()
   {
      if (panelNameArr == null)
      {
         InitPanelNameArray();
      }

      int oldPanelIdx = currPanelIdx;
      currPanelIdx = GUILayout.SelectionGrid(currPanelIdx, panelNameArr,3);
      if (oldPanelIdx != currPanelIdx)
      {
         panelList[currPanelIdx].Init();
         Debug.Log("变化了"+currPanelIdx);
      }
   }
   
   private void InitPanelNameArray()
   {
      var list = new List<string>();
      foreach (var panel in panelList)
      {
         list.Add(panel.name);
      }

      panelNameArr = list.ToArray();
   }

   private void DrawBody()
   {
      var currPanel = panelList[currPanelIdx];
      currPanel.DrawGUI();
   }

   private void MakeBigGUISkin()
   {
      var fontSize = Mathf.CeilToInt(20 * resFactor);
      var fixedHeight = 40 * resFactor;

      GUI.skin.button.fixedHeight = fixedHeight;
      GUI.skin.button.fontSize = fontSize;
      GUI.skin.label.fontSize = fontSize;
      GUI.skin.textField.fontSize = fontSize;
      GUI.skin.textField.fixedHeight = fixedHeight;
      GUI.skin.horizontalSlider.fixedHeight = fixedHeight;
      GUI.skin.horizontalSliderThumb.fixedHeight = fixedHeight;
      GUI.skin.horizontalSliderThumb.fixedWidth = fixedHeight;

      GUI.skin.verticalScrollbar.fixedWidth = fixedHeight;
      GUI.skin.verticalScrollbarThumb.fixedWidth = fixedHeight;
      GUI.skin.verticalScrollbarThumb.fixedHeight = fixedHeight;
      GUI.skin.toggle.fixedHeight = fixedHeight;
      GUI.skin.toggle.fontSize = fontSize;
   }
}





