--[[
-- added by wsh @ 2017-12-04
-- UILayer配置
--]]

--note:
--OrderInLayer unity有限制 取值范围（-32,768 to 32,767）

local UILayer = {
	-- 场景UI，如：点击建筑查看建筑信息---一般置于场景之上，界面UI之下
    World = {
		Name = "WorldUIContainer",
		PlaneDistance = 1000,
		OrderInLayer = -20000,
	},
	-- 暂时没用到
	Scene = {
		Name = "UIContainer/Scene",
		PlaneDistance = 1000,
		OrderInLayer = -15000,
	},
	-- 显示在主界面之下的UI，如：造兵界面，主界面资源条需要能显示点击
	Background = {
		Name = "UIContainer/Background",
		PlaneDistance = 900,
		OrderInLayer = -10000,
	},
	-- UIMain
	UIResource = {
		Name = "UIContainer/UIResource",
		PlaneDistance = 900,
		OrderInLayer = -5000,
	},
	-- 普通UI，一级、二级、三级等窗口---一般由用户点击打开的多级窗口
	Normal = {
		Name = "UIContainer/Normal",
		PlaneDistance = 800,
		OrderInLayer = 0,
	},
	-- 信息UI---如：跑马灯、广播等---一般永远置于用户打开窗口顶层
	Info = {
		Name = "UIContainer/Info",
		PlaneDistance = 700,
		OrderInLayer = 5000,
	},
	-- 提示UI，如：错误弹窗，网络连接弹窗等
	Dialog = {
		Name = "UIContainer/Dialog",
		PlaneDistance = 700,
		OrderInLayer = 10000,
	},
	-- 新手引导
	Guide = {
		Name = "UIContainer/Guide",
		PlaneDistance = 600,
		OrderInLayer = 15000,
	},
	-- 顶层UI
	TopMost = {
		Name = "UIContainer/TopMost",
		PlaneDistance = 500,
		OrderInLayer = 20000,
	},
	-- 因为之前做粒子特效的时候每个UI上都通过代码增加了一个canvas,通过调整canvas的sortingorder来处理的,所以我们增加一个canvas节点,将其节点设置为最高
	-- 之后如果有类似于飞道具这种的,我们都设置在这个上面,不能每个都给一个canvas，1是合批这块的处理。2.是代码太low了
	TopCanvas = {
		Name = "UIContainer/TopCanvas",
		PlaneDistance = 300,
		OrderInLayer = 25000,
	},
}
	
return UILayer