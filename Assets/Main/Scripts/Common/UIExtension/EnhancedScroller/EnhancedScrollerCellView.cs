/**
 * [INPUT]: 继承 UnityEngine 的 MonoBehaviour
 * [OUTPUT]: 对外提供 EnhancedScrollerCellView 基类，携带 cellIdentifier/cellIndex/dataIndex/active 等回收标识，供子类重写 RefreshCellView 刷新显示
 * [POS]: EnhancedScroller 模块的单元格视图基类，所有列表项预制体脚本的父类，是滚动器识别与复用单元格的载体
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;
using System;
using System.Collections;

namespace EnhancedUI.EnhancedScroller
{
    /// <summary>
    /// This is the base class that all cell views should derive from
    /// </summary>
    public class EnhancedScrollerCellView : MonoBehaviour
    {
        /// <summary>
        /// The cellIdentifier is a unique string that allows the scroller
        /// to handle different types of cells in a single list. Each type
        /// of cell should have its own identifier
        /// </summary>
        public string cellIdentifier;

        /// <summary>
        /// The cell index of the cell view
        /// This will differ from the dataIndex if the list is looping
        /// </summary>
        [NonSerialized]
        public int cellIndex;

        /// <summary>
        /// The data index of the cell view
        /// </summary>
        [NonSerialized]
        public int dataIndex;

        /// <summary>
        /// Whether the cell is active or recycled
        /// </summary>
        [NonSerialized]
        public bool active;

        /// <summary>
        /// This method is called by the scroller when the RefreshActiveCellViews is called on the scroller
        /// You can override it to update your cell's view UID
        /// </summary>
        public virtual void RefreshCellView() { }
    }
}





