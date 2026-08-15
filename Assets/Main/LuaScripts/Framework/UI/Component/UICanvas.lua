--[[
-- added by wsh @ 2017-12-13
-- Lua侧UICanvas：
-- 注意：
-- 1、为了调整UI层级，所以这里的overrideSorting设置为true
-- 2、如果只是类似NGUI的Panel那样划分drawcall管理，直接在预设上添加Canvas，并设置overrideSorting为false
-- 3、这里的order是相对于window.view中base_order的差量，窗口内的order最多为10个---UIManager中配置
-- 4、旧窗口内所有canvas的real_order都应该在新窗口之下，即保证旧窗口内包括UI特效在内的所有组件，不会跑到新窗口之上
-- 5、UI逻辑代码禁止手动直接设置Unity侧Cavans组件的orderInLayer，全部使用本脚本接口调整层级，避免层级混乱
--]]

--[[
-- [INPUT]: 依赖 UIBaseComponent 基类、CS.UnityEngine.Canvas 原生画布组件
-- [OUTPUT]: 对外提供 UICanvas 组件类，封装对节点上 Canvas 的持有与访问（overrideSorting 恒为 true，order 为相对窗口 base_order 的差量）
-- [POS]: Component 层对 Unity Canvas 的 Lua 封装，用于局部覆盖排序；层级调整须统一走本脚本接口，禁止业务直接改 orderInLayer 以免层级混乱
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
local UICanvas = BaseClass("UICanvas", UIBaseComponent)
local base = UIBaseComponent
local UnityCanvas = typeof(CS.UnityEngine.Canvas)

-- 创建
local function OnCreate(self)
	base.OnCreate(self)
	self.unity_canvas = self.gameObject:GetComponent(UnityCanvas)
end

-- 销毁
local function OnDestroy(self)
	self.unity_canvas = nil
	base.OnDestroy(self)
end


UICanvas.OnCreate = OnCreate
UICanvas.OnDestroy = OnDestroy

return UICanvas