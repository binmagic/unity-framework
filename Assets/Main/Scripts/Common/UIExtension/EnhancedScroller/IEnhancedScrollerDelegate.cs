/**
 * [INPUT]: 引用同命名空间的 EnhancedScroller 与 EnhancedScrollerCellView 类型作为回调参数
 * [OUTPUT]: 对外提供 IEnhancedScrollerDelegate 接口，约定数据源三要素：单元格总数、单元格尺寸、按索引取回收后的单元格视图
 * [POS]: EnhancedScroller 模块的数据源契约，业务侧实现此接口把列表数据喂给滚动器，是滚动器与业务解耦的边界
 * [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
 */

using UnityEngine;
using System.Collections;

namespace EnhancedUI.EnhancedScroller
{
    /// <summary>
    /// All scripts that handle the scroller's callbacks should inherit from this interface
    /// </summary>
    public interface IEnhancedScrollerDelegate
    {
        /// <summary>
        /// Gets the number of cells in a list of data
        /// </summary>
        /// <param name="scroller"></param>
        /// <returns></returns>
        int GetNumberOfCells(EnhancedScroller scroller);

        /// <summary>
        /// Gets the size of a cell view given the index of the data set.
        /// This allows you to have different sized cells
        /// </summary>
        /// <param name="scroller"></param>
        /// <param name="dataIndex"></param>
        /// <returns></returns>
        float GetCellViewSize(EnhancedScroller scroller, int dataIndex);

        /// <summary>
        /// Gets the cell view that should be used for the data index. Your implementation
        /// of this function should request a new cell from the scroller so that it can
        /// properly recycle old cells.
        /// </summary>
        /// <param name="scroller"></param>
        /// <param name="dataIndex"></param>
        /// <param name="cellIndex"></param>
        /// <returns></returns>
        EnhancedScrollerCellView GetCellView(EnhancedScroller scroller, int dataIndex, int cellIndex);
    }
}





