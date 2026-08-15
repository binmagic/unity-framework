/**
 * [INPUT]: 依赖 DynamicInfinityListRenderer 的循环列表渲染能力与 DynamicInfinityItem 数据项，依赖 UnityEngine.UI.Button
 * [OUTPUT]: 对外提供 LoopListExample 示例组件（无业务导出）
 * [POS]: LoopList 的用法演示脚本，通过按钮驱动 SetData/定位/增删数据以示范动态无限列表 API，仅供参考非运行时业务
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LoopListExample : MonoBehaviour
{
    public DynamicInfinityListRenderer m_Dl;

    public Button m_BtnSetDatas;

    public Button m_BtnMove2Data;

    public Button m_BtnRemoveData;

    public Button m_BtnAddData;
    // Use this for initialization
    void Start () {
	    m_Dl.InitRendererList(OnSelectHandler,null);
        m_BtnSetDatas.onClick.AddListener(() =>
        {
            List<int> datas = new List<int>();
            for (int i = 0; i < 500; ++i)
            {
                datas.Add(i);
            }
            m_Dl.SetDataProvider(datas);

        });

	    m_BtnMove2Data.onClick.AddListener(() =>
	    {
	        if (m_Dl.GetDataProvider() != null)
	        {
	            m_Dl.LocateRenderItemAtTarget(24, 1);
	        }
	        else
	        {
	            print("先设置数据吧");
            }

	    });

	    m_BtnRemoveData.onClick.AddListener(() =>
	    {
	        if (m_Dl.GetDataProvider() != null)
	        {
	            if (m_Dl.GetDataProvider().Contains(6))
	            {
	                m_Dl.GetDataProvider().Remove(6);
	                m_Dl.RefreshDataProvider();
	            }
	            else
	            {
	                print("找不到数据");
	            }
            }
	        else
	        {
	            print("先设置数据吧");
	        }	                     
	    });

        m_BtnAddData.onClick.AddListener(() =>
        {
            if (m_Dl.GetDataProvider() != null)
            {
                m_Dl.GetDataProvider().Add(999);
                m_Dl.RefreshDataProvider();
            }
            else
            {
                print("先设置数据吧");
            }
        });
    }

    void OnSelectHandler(DynamicInfinityItem item)
    {
        print("on select "+item.ToString());
    }

    // Update is called once per frame
    void Update () {
		
	}
}





