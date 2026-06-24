--[[
-- added by wsh @ 2017-11-30
-- UI视图层基类：该界面所有UI刷新操作，只和展示相关的数据放在这，只有操作相关数据放Model去
-- 注意：
-- 1、被动刷新：所有界面刷新通过消息驱动---除了打开界面时的刷新
-- 2、对Model层可读，不可写---调试模式下强制
-- 3、所有写数据、游戏控制操作、网络相关操作全部放Ctrl层
-- 4、Ctrl层不依赖View层，但是依赖Model层
-- 5、任何情况下不要在游戏逻辑代码操作界面刷新---除了打开、关闭界面
--]]

---@class UIBaseView : UIBaseContainer
local UIBaseView = BaseClass("UIBaseView", UIBaseContainer)
local base = UIBaseContainer
local UnityCanvas = CS.UnityEngine.Canvas
local UnityGraphicRayCaster = CS.UnityEngine.UI.GraphicRaycaster
local CS_UIParticleSetUpBase = CS.UIParticleSetUpBase

-- 这里的var_arg对于我们项目来说，就是WindowName
---note: 非View的请不要从UIBaseView派生！！！ 改为从UIBaseContainer派生！
local function __init(self, holder, winName, ctrl, config)
	self.WindowName = winName

	if UIConfig[self.WindowName] == nil then
		Logger.LogError('Error! 不是view的容器请从UIBaseContainer派生 - name: ', tostring(self.WindowName))
	end
	
	self.layer = holder
	self.ctrl = ctrl
	self.winConfig = config
	self.blurOrderNum = -1
end

local function SetBlurObj(self, blurObj, order)
	if blurObj ~= nil then
		UIUtil.StretchFullRectTransform(blurObj.transform)

		self.blurScript = blurObj:GetComponent(typeof(CS.UIFormBlurEffect))
		if self.blurScript ~= nil and not IsNull(self.blurScript) then
			self.blurOrderNum = order
			if self.blurOrderNum > 4 then
				self.blurOrderNum = 4
			end
			
			if self.blurScript ~= nil and self.blurScript.ShowBlurImage ~= nil then
				self.blurScript:ShowBlurImage(self.blurOrderNum)
			end
		end
	end
end

-- 创建：资源加载完毕
local function OnCreate(self)
	base.OnCreate(self)
	UIUtil.StretchFullRectTransform(self.rectTransform)

	----------------------特效排序 改之前先找zlh讨论下----------------------
	--要想ui和特效排序 overrideSorting必须设置为true overrideSorting不设的情况下 相邻的ui会在同个srp batch中绘制 特效无法通过更改z值 在相邻的ui中间渲染
	local canvas = self.rectTransform:GetOrAddComponent(typeof(UnityCanvas))
	canvas.renderMode = CS.UnityEngine.RenderMode.ScreenSpaceCamera
	canvas.worldCamera = UIManager:GetInstance():GetUICamera()
	canvas.overrideSorting = true
	canvas.sortingLayerName = 'Default'
	self.canvas = canvas
	--防止影响点击事件
	self.rectTransform:GetOrAddComponent(typeof(UnityGraphicRayCaster))
	self.lastSortingOrder = IntMinValue

	--通过添加基类 此时获取出来的就是根据hierarchy树自动排序好的相关脚本了
	self.allParticleAboutSet = self.rectTransform:GetComponentsInChildren(typeof(CS_UIParticleSetUpBase), true)
	-------------------------------------------------------
end

local function HideBlur(self)
	if self.blurScript ~= nil and not IsNull(self.blurScript) then
		if self.blurScript.HideBlurImage ~= nil then
			self.blurScript:HideBlurImage()
		end
		
		local obj = self.blurScript.gameObject
		CS.UnityEngine.GameObject.Destroy(obj)
		self.blurScript = nil

		return true
	end

	self.blurScript = nil
	return false
end

-- 销毁：窗口销毁
local function OnDestroy(self)
	self.layer = nil
	self.ctrl = nil
	base.OnDestroy(self)
end

--默认根据openOptions.isBlur > window.Config.isBlur来决定是否显示
--如果有页面有根据业务特殊处理，则重载这个函数
function UIBaseView:IsNeedShowBlur(openOptions)
	if openOptions.isBlur ~= nil then
		return openOptions.isBlur
	end

	if self.winConfig ~= nil then
		return self.winConfig.isBlur
	end

	return false
end

local function SetUserData(self, userData)
	self.userData = userData
end

local function GetUserData(self)
	return SafeUnpack(self.userData)
end

--UI与特效排序: zlh
--历史：aps开发过程中 美术对UIParticle插件比较抵触 基于此C项目开发了 UI与特效排序
--发现通过override+z值的方式来实现排序 实测 有些发散的粒子特效还是会有部分穿透的情况 猜想可能是粒子做了随机 z值并不固定
--因此改用canvas.sortingOrder + childrenRender.orderInLayer方式来实现，相邻两个Layer差值5000，相邻俩个UIWindow差值100，单个ui内特效局部order设置范围[0, 100)
--有部分ui关闭时有动画 因此单纯通过transform.childCount计算order并不准确 会因关闭动画带来的时序问题计算有误
--同样如果缓存layer节点数量易出问题 unity的sortingOrder也有范围限制(-32,768 to 32,767)无法简单递增, 因此改为每次ui打开都对当前所在layer重排一下
function UIBaseView:ResortOrder(baseLayerOrder)
	if self.canvas == nil or self.transform == nil then
		return
	end
	
	local siblingIndex = self.transform:GetSiblingIndex()
	local globalOrder = math.min(baseLayerOrder + siblingIndex * 100, baseLayerOrder + 5000 - 100)
	if globalOrder ~= self.lastSortingOrder then
		self.lastSortingOrder = globalOrder
		self.canvas.sortingOrder = globalOrder

		if App.IsEditor() then
			Logger.Log(string.format('#zlh# #UI# siblingIndex:<color=red>[%d]</color> Order: <color=cyan>[%d]</color>, viewName: <color=cyan>[%s]</color>', 
					siblingIndex, globalOrder, self.WindowName))
		end
		
		if self.blurScript ~= nil and not IsNull(self.blurScript) then
			local blurCanvas = self.blurScript.gameObject:GetComponent(typeof(UnityCanvas))
			if blurCanvas ~= nil then
				blurCanvas.overrideSorting = true
				blurCanvas.sortingLayerName = 'Default'
				blurCanvas.sortingOrder = globalOrder - 1
			end
		end
		
		self:__checkAllChildrenOrderSetUp()
	end
end

local tAnim = {anim = true}
local function CloseSelf(self, anim)
	if anim == true then
		UIManager:GetInstance():DestroyWindow(self.WindowName, tAnim)
	else
		UIManager:GetInstance():DestroyWindow(self.WindowName)
	end
end

function UIBaseView:__checkAllChildrenOrderSetUp()
	if self.allParticleAboutSet ~= nil and self.allParticleAboutSet.Length > 0 then
		for i = 0, self.allParticleAboutSet.Length -1 do
			local script = self.allParticleAboutSet[i]
			if not IsNull(script) then
				script:Refresh()
			end
		end
	end
	
	self:ResortUIEffect()
end

--zlh note: 针对非常驻的ui特效尽可能调用UIBaseComponent:AddUIEffect接口动态加载 会在异步加载完成后自动处理层级排序
--异步加载含有Particle的子UI时，self.allParticleSet需要重新初始化，特效排序有问题的UI，可尝试手动调用此接口
function UIBaseView:ForceRefreshParticleSet()
	self.allParticleAboutSet = self.rectTransform:GetComponentsInChildren(typeof(CS_UIParticleSetUpBase), true)
	if self.allParticleAboutSet ~= nil and self.allParticleAboutSet.Length > 0 then
		for i = 0, self.allParticleAboutSet.Length -1 do
			self.allParticleAboutSet[i]:Refresh()
		end
	end
end

local function OnEnable(self)
	base.OnEnable(self)
	self:TryHideMainCamera()
end

local function OnDisable(self)
	base.OnDisable(self)
	self:TryRecoverMainCamera()
end

function UIBaseView:TryHideMainCamera()
	--躲避球战斗中不禁用主相机
	local isInBarrel = DataCenter.LWBattleManager:IsInBattleLevel()
	if isInBarrel then
		return
	end

	local needHideCamera = self.blurOrderNum > 0 or self.winConfig ~= nil and self.winConfig.hideCamera
	if needHideCamera then
		SceneManager.ToggleMainCamera(false)
		self.hasHideCamera = true
	end
end

--zlh: 播放MoveOut动画时或者Disable时调用
function UIBaseView:TryRecoverMainCamera()
	if self.hasHideCamera then
		SceneManager.ToggleMainCamera(true)
		self.hasHideCamera = false
	end
end


UIBaseView.OnEnable = OnEnable
UIBaseView.OnDisable = OnDisable
UIBaseView.__init = __init
UIBaseView.GetUserData = GetUserData
UIBaseView.SetUserData = SetUserData
UIBaseView.OnCreate = OnCreate
UIBaseView.OnDestroy = OnDestroy
UIBaseView.SetBlurObj = SetBlurObj
UIBaseView.HideBlur = HideBlur
UIBaseView.CloseSelf = CloseSelf

return UIBaseView