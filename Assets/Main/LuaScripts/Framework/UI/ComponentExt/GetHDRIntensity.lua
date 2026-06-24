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