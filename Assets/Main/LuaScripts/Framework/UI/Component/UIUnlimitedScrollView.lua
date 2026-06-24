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