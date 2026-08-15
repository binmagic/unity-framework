--[[
-- [INPUT]: 依赖 UIBaseContainer 基类、CS.GameKit.Base.UnlimitedScrollView 第三方无限滚动组件
-- [OUTPUT]: 对外提供 UnlimitedScrollView 组件类，含 AddItemWrap/InsertItemWrap/RemoveItemWrap/ClearItemWraps 按包装项管理、SetOnItemMoveIn/SetOnItemMoveOut 进出回调
-- [POS]: Component 层基于 GameKit UnlimitedScrollView 的循环列表封装，按 itemWrap 组织；与 UIScrollView/UILoopListView2 同为滚动列表家族的另一实现
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UIUnlimitedScrollView = BaseClass("UnlimitedScrollView", UIBaseContainer)
local base = UIBaseContainer
local UnityUnlimitedScrollView = typeof(CS.GameKit.Base.UnlimitedScrollView)

local function OnCreate(self)
	base.OnCreate(self)
	self.unity_unlimited_scroll_view = self.gameObject:GetComponent(UnityUnlimitedScrollView)
end

local function ClearItemWraps(self)
	self.unity_unlimited_scroll_view:Clear()
end

local function AddItemWrap(self, prefab, userdata)
	self.unity_unlimited_scroll_view:AddItemWrap(prefab, userdata)
end

local function InsertItemWrap(self, index, prefab, userdata )
	self.unity_unlimited_scroll_view:InsertItemWrap(index, prefab, userdata)
end

local function RemoveItemWrap(self, userdata)
	self.unity_unlimited_scroll_view:RemoveItemWrap(userdata)
end

-- callback(itemObj, userData)
local function SetOnItemMoveIn(self, callback)
	self.unity_unlimited_scroll_view.OnItemMoveIn = callback
end

local function SetOnItemMoveOut(self, callback)
	self.unity_unlimited_scroll_view.OnItemMoveOut = callback
end

local function OnDestroy(self)
	self.unity_unlimited_scroll_view.OnItemMoveIn = nil
	self.unity_unlimited_scroll_view.OnItemMoveOut = nil
	self.unity_unlimited_scroll_view = nil

	base.OnDestroy(self)
end

UIUnlimitedScrollView.OnCreate = OnCreate
UIUnlimitedScrollView.ClearItemWraps = ClearItemWraps
UIUnlimitedScrollView.AddItemWrap = AddItemWrap
UIUnlimitedScrollView.InsertItemWrap = InsertItemWrap
UIUnlimitedScrollView.RemoveItemWrap = RemoveItemWrap
UIUnlimitedScrollView.SetOnItemMoveIn = SetOnItemMoveIn
UIUnlimitedScrollView.SetOnItemMoveOut = SetOnItemMoveOut
UIUnlimitedScrollView.OnDestroy= OnDestroy


return UIUnlimitedScrollView