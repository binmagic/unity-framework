--[[
-- [INPUT]: 依赖 UIBaseComponent 基类、CS.GetHDRIntensity 原生组件
-- [OUTPUT]: 对外提供 GetHDRIntensity 组件类，含 Init(mat) 将材质交给原生组件做 HDR 强度处理
-- [POS]: ComponentExt 扩展组件，对 CS 侧自定义 GetHDRIntensity 脚本的 Lua 薄封装；供需要 HDR 泛光强度控制的界面使用
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

---
--- Created by SHIMIN.
--- DateTime: 2022/04/19 18:49
---
local GetHDRIntensity = BaseClass("GetHDRIntensity", UIBaseComponent)
local base = UIBaseComponent
local UnityOutline = typeof(CS.GetHDRIntensity)

-- 创建
local function OnCreate(self)
    base.OnCreate(self)
    -- Unity侧原生组件
    self.GetHDRIntensity = self.gameObject:GetComponent(UnityOutline)
end


-- 销毁
local function OnDestroy(self)
    self.GetHDRIntensity = nil
    base.OnDestroy(self)
end

local function Init(self,mat)
    self.GetHDRIntensity:Init(mat)
end

GetHDRIntensity.OnCreate = OnCreate
GetHDRIntensity.OnDestroy = OnDestroy
GetHDRIntensity.Init = Init

return GetHDRIntensity