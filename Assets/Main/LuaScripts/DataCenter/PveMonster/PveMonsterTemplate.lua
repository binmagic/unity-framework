---
--- Pve 丧尸配置
---
---@class DataCenter.PveMonster.PveMonsterTemplate
local PveMonsterTemplate = BaseClass("PveMonsterTemplate")

local function __init(self)
    
end

local function __delete(self)
    self.skill=nil
    self.collide_damage = nil
end

local function InitData(self, row)
    if row == nil then
        return
    end
    
    self.id = tonumber(row:getValue("id")) or 0
    self.baseId = row:getValue("baseId")
    self.property = row:getValue("property")
    
    --zlh: 直接把基础表设置成元表
    setmetatable(self, {
        __index = function(t, k)
            if rawget(t, k) == nil then
                local baseTemplate = DataCenter.PveMonsterTemplateManager:GetBaseTemplate(self.baseId)
                if baseTemplate ~= nil then
                    return baseTemplate[k]
                end

                return nil
            end
        end
    })
end


local deathAssetGlobalIdx = 0
local function GetRandomDeathAsset(self)
    if self.death_asset == nil or next(self.death_asset) == nil then
        return nil
    end

    local keys = table.keys(self.death_asset)
    local len = table.count(keys)
    deathAssetGlobalIdx = deathAssetGlobalIdx + 1
    if deathAssetGlobalIdx > len then
        deathAssetGlobalIdx = 1
    end
    
    local path = keys[deathAssetGlobalIdx]
    local duration = tonumber(self.death_asset[path])/ 1000
    
    return path, duration
end


PveMonsterTemplate.__init = __init
PveMonsterTemplate.__delete = __delete
PveMonsterTemplate.InitData = InitData
PveMonsterTemplate.GetRandomDeathAsset = GetRandomDeathAsset


return PveMonsterTemplate