---@class UIScrollViewEx : UIScrollView
local UIScrollViewEx = BaseClass("UIScrollViewEx", UIScrollView)
local base = UIScrollView

-- 创建
function UIScrollViewEx:OnCreate(itemComponent)
    base.OnCreate(self)
    self.dataList = {}
    self.itemComponent = itemComponent
    self.itemCells = {}
    -- 设置回调
    self:SetOnItemMoveIn(function(itemObj, index)
        self:OnCellMoveIn(itemObj, index)
    end)
    
    self:SetOnItemMoveOut(function(itemObj, index)
        self:OnCellMoveOut(itemObj, index)
    end)
end

-- 销毁
function UIScrollViewEx:OnDestroy()
    self:ClearCells()
    self.dataList = nil
    self.itemComponent = nil
    self.itemCells = nil
    self.onItemMoveInCallback = nil
    self.onItemMoveOutCallback = nil
    base.OnDestroy(self)
end

function UIScrollViewEx:ClearCells()
    base.ClearCells(self)
    self:RemoveComponents(self.itemComponent)
end

-- 设置数据和组件
-- @param dataList 数据列表
-- @param itemComponent 要添加的组件类
-- @param offset 偏移量
-- @param fillViewRect 是否填充视图区域
-- @param params 透传参数
function UIScrollViewEx:SetData(dataList, offset, fillViewRect, params)
    self.dataList = dataList
    self.params = params
    -- 刷新列表
    self:RefreshList(offset, fillViewRect)
end

-- 刷新列表
function UIScrollViewEx:RefreshList(offset, fillViewRect)
    self:ClearCells()
    if #self.dataList > 0 then
        self:SetTotalCount(#self.dataList)
        self:RefillCells(offset, fillViewRect)
    end
end

function UIScrollViewEx:SetOnItemMoveInCallback(callback)
    self.onItemMoveInCallback = callback
end

function UIScrollViewEx:SetOnItemMoveOutCallback(callback)
    self.onItemMoveOutCallback = callback
end

-- 单元格移入
function UIScrollViewEx:OnCellMoveIn(itemObj, index)
    itemObj.name = tostring(index)
    local item = self:AddComponent(self.itemComponent, itemObj)
    item:ReInit(self.dataList[index], self.params, index)
    self.itemCells[index] = item
    if self.onItemMoveInCallback then
        self.onItemMoveInCallback(item, index)
    end
end

-- 单元格移出
function UIScrollViewEx:OnCellMoveOut(itemObj, index)
    if self.onItemMoveOutCallback then
        self.onItemMoveOutCallback(itemObj, index)
    end
    self.itemCells[index] = nil
    self:RemoveComponent(itemObj.name, self.itemComponent)        
end

-- 更新数据
function UIScrollViewEx:UpdateData(dataList)
    self.dataList = dataList
    self:RefreshList()
end

-- 刷新当前显示的组件
function UIScrollViewEx:Refresh(dataList)
    if dataList ~= nil then
        self.dataList = dataList
    end
    for k, item in pairs(self.itemCells) do
        if item and not item:IsDestroy() then
            item:ReInit(self.dataList[k], self.params, k)
        end
    end
end

function UIScrollViewEx:GetCellByIndex(index)
    return self.itemCells[index]
end

return UIScrollViewEx 