---@class UIScrollView : UIBaseContainer
local UIScrollView = BaseClass("UIScrollView", UIBaseContainer)
local base = UIBaseContainer
local UnityScrollView = typeof(CS.ScrollView)

local function OnCreate(self)
    base.OnCreate(self)
    self.unity_scroll_view = self.gameObject:GetComponent(UnityScrollView)
    self.__onvaluechanged = nil
    self.index = 1
end

local function OnDestroy(self)
    self.unity_scroll_view.onItemMoveIn = nil
    self.unity_scroll_view.onItemMoveOut = nil
    if self.__onvaluechanged ~= nil then
        self.unity_scroll_view.onValueChanged:RemoveListener(self.__onvaluechanged)
    end
    pcall(function() self.unity_scroll_view.onValueChanged:Clear() end)
    self.__onvaluechanged = nil
    self.unity_scroll_view = nil
    self.index = nil
    base.OnDestroy(self)
end

local function SetOnItemMoveIn(self, callback)
    self.unity_scroll_view.onItemMoveIn = function(obj, index)
        callback(obj, index + 1)
    end
end

local function SetOnItemMoveOut(self, callback)
    self.unity_scroll_view.onItemMoveOut = function(obj, index)
        callback(obj, index + 1)
    end
end

local function ResetContentConstraintCount(self)
    self.unity_scroll_view.m_ContentConstraintCount = 0
end

local function SetTotalCount(self, totalCount)
    self.unity_scroll_view.totalCount = totalCount
end

local function SetExtraFillSize(self, extraSizeX, extraSizeY)
    self.unity_scroll_view:SetExtraFillSize(extraSizeX, extraSizeY)
end

local function RefreshCells(self)
    self.unity_scroll_view:RefreshCells()
end

local function RefillCells(self, offset, fillViewRect)
    offset = offset or 1
    fillViewRect = fillViewRect or false
    self.unity_scroll_view:RefillCells(offset - 1, fillViewRect)
end

local function ScrollToCell(self, index, speed)
    self.unity_scroll_view:ScrollToCell(index - 1, speed)
end

local function ClearCells(self)
    self.unity_scroll_view:ClearCells(true)
end

local function OnBeginDrag(self,eventData)
    self.unity_scroll_view:OnBeginDrag(eventData)
    self:StopMovement()
end

local function OnEndDrag(self,eventData)
    self.unity_scroll_view:OnEndDrag(eventData)
end

local function OnDrag(self,eventData)
    self.unity_scroll_view:OnDrag(eventData)
end

local function SetOnValueChanged(self,eventData)
    if eventData then
        if self.__onvaluechanged then
            self.unity_scroll_view.onValueChanged:RemoveListener(self.__onvaluechanged)
        end
        self.__onvaluechanged = eventData
        self.unity_scroll_view.onValueChanged:AddListener(self.__onvaluechanged)
    elseif self.__onvaluechanged then
        self.unity_scroll_view.onValueChanged:RemoveListener(self.__onvaluechanged)
        self.__onvaluechanged = nil
    end
end
local function GetChildCount(self)
     return self.unity_scroll_view.content.childCount
end

local function GetVerticalNormalizedPosition(self)
    return self.unity_scroll_view.verticalNormalizedPosition
end

local function SetVerticalNormalizedPosition(self, value)
    self.unity_scroll_view.verticalNormalizedPosition = value
end

local function GetHorizontalNormalizedPosition(self)
    return self.unity_scroll_view.horizontalNormalizedPosition
end

local function SetHorizontalNormalizedPosition(self, value)
    self.unity_scroll_view.horizontalNormalizedPosition = value
end

local function StopMovement(self)
    self.unity_scroll_view:StopMovement()
end

local function SetScrollEndDrag(self)
    self.unity_uiscrollRect:ScrollRect_EndDrag()
end

local function SetEnable(self, value)
    self.unity_scroll_view.enabled = value
end

function UIScrollView:SetIndex(index)
    self.index = index
end

function UIScrollView:GetIndex()
    return self.index
end
function UIScrollView:SetNestedScrolling(value)
    self.unity_scroll_view.nestedScrolling = value
end


UIScrollView.SetScrollEndDrag = SetScrollEndDrag
UIScrollView.OnCreate = OnCreate
UIScrollView.OnDestroy = OnDestroy
UIScrollView.SetTotalCount = SetTotalCount
UIScrollView.RefreshCells = RefreshCells
UIScrollView.RefillCells = RefillCells
UIScrollView.ScrollToCell = ScrollToCell
UIScrollView.ClearCells = ClearCells
UIScrollView.SetOnItemMoveIn = SetOnItemMoveIn
UIScrollView.SetOnItemMoveOut = SetOnItemMoveOut
UIScrollView.OnBeginDrag = OnBeginDrag
UIScrollView.OnEndDrag = OnEndDrag
UIScrollView.OnDrag = OnDrag
UIScrollView.SetOnValueChanged = SetOnValueChanged
UIScrollView.GetChildCount = GetChildCount
UIScrollView.GetVerticalNormalizedPosition = GetVerticalNormalizedPosition
UIScrollView.SetVerticalNormalizedPosition = SetVerticalNormalizedPosition
UIScrollView.GetHorizontalNormalizedPosition = GetHorizontalNormalizedPosition
UIScrollView.SetHorizontalNormalizedPosition = SetHorizontalNormalizedPosition
UIScrollView.SetExtraFillSize = SetExtraFillSize
UIScrollView.StopMovement = StopMovement
UIScrollView.ResetContentConstraintCount = ResetContentConstraintCount
UIScrollView.SetEnable = SetEnable

return UIScrollView