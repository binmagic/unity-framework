/**
 * [INPUT]: 继承 DynamicInfinityItem，依赖 UnityEngine.UI 的 Text 与 Button
 * [OUTPUT]: 对外提供 ItemRender 组件，重写 OnRenderer 把数据 ToString 显示到文本并绑定按钮点击
 * [POS]: LoopList 模块的示例单元格实现，演示如何继承 DynamicInfinityItem 消费数据，是渲染器用法的参考样板
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class ItemRender : DynamicInfinityItem
{
    public Text m_TxtName;

    public Button m_Btn;
	// Use this for initialization
	void Start () {
		m_Btn.onClick.AddListener(() =>
		{
            print("Click "+mData.ToString());
		});
	}

    protected override void OnRenderer()
    {
        base.OnRenderer();
        m_TxtName.text = mData.ToString();
    }
}





