local UIScrollRect = BaseClass("UIScrollRect", UIBaseContainer)
local base = UIBaseContainer
local UnityScrollRect = typeof(CS.UnityEngine.UI.ScrollRect)

local function OnCreate(self, ...)
	base.OnCreate(self)
	self.unity_uiscrollRect = self.gameObject:GetComponent(UnityScrollRect)
	self.horizontal = self.unity_uiscrollRect.horizontal
	self.vertical = self.unity_uiscrollRect.vertical
end

local function GetScrollRect(self)
	return self.unity_uiscrollRect
end

local function OnDestroy(self)
	if self.scrollTween then
		self.scrollTween:Kill()
		self.scrollTween = nil
	end
	pcall(function() self.unity_uiscrollRect.onValueChanged:Clear() end)
	self.unity_uiscrollRect = nil
	base.OnDestroy(self)
end

local function OnBeginDrag(self,eventData)
	self.unity_uiscrollRect:OnBeginDrag(eventData)
end

local function OnEndDrag(self,eventData)
	self.unity_uiscrollRect:OnEndDrag(eventData)
end

local function OnDrag(self,eventData)
	self.unity_uiscrollRect:OnDrag(eventData)
end

local function SetScrollEndDrag(self)
	self.unity_uiscrollRect:ScrollRect_EndDrag()
end

local function SetEnable(self, value) 
	self.unity_uiscrollRect.enabled = value
end

local function StopMovement(self) 
	self.unity_uiscrollRect:StopMovement()
end

local function AddValueChangeListener( self, callback )
	self.unity_uiscrollRect.onValueChanged:AddListener(callback)
end

local function RemoveAllListeners(self)
	self.unity_uiscrollRect.onValueChanged:RemoveAllListeners()
end

local function SetHorizontalNormalizedPosition( self, data )
	self.unity_uiscrollRect:SetHorizontalNormalizedPosition( data )
end

local function GetHorizontalNormalizedPosition( self )
	return self.unity_uiscrollRect:GetHorizontalNormalizedPosition()
end

local function SetVerticalNormalizedPosition( self ,value)
	self.unity_uiscrollRect.verticalNormalizedPosition = value
end

local function GetVerticalNormalizedPosition(self)
	return self.unity_uiscrollRect.verticalNormalizedPosition
end

function  UIScrollRect:MoveToBegin()
	if IsNull(self.unity_uiscrollRect.content) == nil then
		return
	end
	self:StopMovement()
	self.unity_uiscrollRect.content.anchoredPosition = Vector2.New(0,0)
end

function  UIScrollRect:MoveToByIndex(index,size,maxcount,spacing)
	index = math.min(index-1, maxcount);
	index = math.max(0, index);
	if IsNull(self.unity_uiscrollRect.content) == nil then
		return
	end
	self:StopMovement()
	local pos = self.unity_uiscrollRect.content.anchoredPosition;
	local moveToPos = Vector2.New(index * -(size+spacing), pos.y);
	if self.horizontal and not self.vertical then
		
	elseif not self.horizontal and self.vertical then
		moveToPos = Vector2.New(pos.x, index * -(size+spacing));
	end
	local sizeDelta = self.unity_uiscrollRect.content.sizeDelta;
	local limitX = -( sizeDelta.x - self.rectTransform.rect.width );
	local limitY = -( sizeDelta.y - self.rectTransform.rect.height );
	if( self.horizontal and moveToPos.x < limitX ) then
		moveToPos.x = limitX;
	elseif( self.vertical and moveToPos.y < limitY ) then 
		moveToPos.y = limitY;
	end
	self.unity_uiscrollRect.content.anchoredPosition = moveToPos;
end

function UIScrollRect:IsScrolling()
	return self.unity_uiscrollRect.velocity.magnitude > 0.01
end

-- 滚动到指定位置
-- @param position Vector3 目标位置（世界坐标）
-- @param duration number 缓动时间（秒），如果小于等于0则立即滚动
function UIScrollRect:ScrollToPosition(position, duration)
	if IsNull(self.unity_uiscrollRect) then
		return
	end
	
	-- 停止当前滚动和正在执行的tween
	self:StopMovement()
	if self.scrollTween then
		self.scrollTween:Kill()
		self.scrollTween = nil
	end
	
	-- 将世界坐标转换为相对于 content 的本地坐标
	local content = self.unity_uiscrollRect.content
	local localPosition = content:InverseTransformPoint(position)
	
	-- 获取 viewport 的大小
	local viewportHeight = self.rectTransform.rect.height
	local viewportWidth = self.rectTransform.rect.width
	
	-- 获取 content 的大小
	local contentHeight = content.rect.height
	local contentWidth = content.rect.width
	
	-- 计算目标归一化位置
	local targetVerticalNormalized = 0
	local targetHorizontalNormalized = 0
	
	if self.vertical then
		local targetY = -localPosition.y
		targetVerticalNormalized = (targetY - viewportHeight * 0.5) / (contentHeight - viewportHeight)
		targetVerticalNormalized = math.max(0, math.min(1, targetVerticalNormalized))
		targetVerticalNormalized = 1 - targetVerticalNormalized
	end
	
	if self.horizontal then
		local targetX = -localPosition.x
		targetHorizontalNormalized = (targetX - viewportWidth * 0.5) / (contentWidth - viewportWidth)
		targetHorizontalNormalized = math.max(0, math.min(1, targetHorizontalNormalized))
	end
	
	-- 如果duration小于等于0，直接设置位置
	if not duration or duration <= 0 then
		if self.vertical then
			self:SetVerticalNormalizedPosition(targetVerticalNormalized)
		end
		if self.horizontal then
			self:SetHorizontalNormalizedPosition(targetHorizontalNormalized)
		end
		return
	end
	
	-- 创建DOTween序列
	local sequence = DOTween.Sequence()
	
	if self.vertical then
		local currentVertical = self:GetVerticalNormalizedPosition()
		sequence:Insert(0, DOTween.To(
			function() return currentVertical end,
			function(value) self:SetVerticalNormalizedPosition(value) end,
			targetVerticalNormalized,
			duration
		):SetEase(Ease.OutQuad))
	end
	
	if self.horizontal then
		local currentHorizontal = self:GetHorizontalNormalizedPosition()
		sequence:Insert(0, DOTween.To(
			function() return currentHorizontal end,
			function(value) self:SetHorizontalNormalizedPosition(value) end,
			targetHorizontalNormalized,
			duration
		):SetEase(Ease.OutQuad))
	end
	
	-- 保存tween引用以便后续可以停止
	self.scrollTween = sequence
end

UIScrollRect.SetScrollEndDrag = SetScrollEndDrag
UIScrollRect.OnCreate = OnCreate
UIScrollRect.OnDestroy = OnDestroy
UIScrollRect.OnBeginDrag = OnBeginDrag
UIScrollRect.OnEndDrag = OnEndDrag
UIScrollRect.OnDrag = OnDrag
UIScrollRect.SetEnable = SetEnable
UIScrollRect.StopMovement = StopMovement
UIScrollRect.AddValueChangeListener = AddValueChangeListener
UIScrollRect.RemoveAllListeners = RemoveAllListeners
UIScrollRect.SetHorizontalNormalizedPosition = SetHorizontalNormalizedPosition
UIScrollRect.GetHorizontalNormalizedPosition = GetHorizontalNormalizedPosition
UIScrollRect.GetScrollRect = GetScrollRect
UIScrollRect.SetVerticalNormalizedPosition = SetVerticalNormalizedPosition
UIScrollRect.GetVerticalNormalizedPosition = GetVerticalNormalizedPosition

return UIScrollRect