---
--- Pve 丧尸配置管理
---

local PveMonsterTemplateManager = BaseClass("PveMonsterTemplateManager")
local PveMonsterTemplate = require"DataCenter.PveMonster.PveMonsterTemplate"
local BarrelMonsterBaseTemplate = require"DataCenter.PveMonster.BarrelMonsterBaseTemplate"

local function __init(self)
    self.templateDict = createtable(0, 300)
    self.baseTemplateDict = createtable(0, 100)
end

local function __delete(self)
end

local function GetTemplate(self, id)
    id = tonumber(id)
    --id = 90000262
    if self.templateDict[id] then
        return self.templateDict[id]
    end

    local lineData = LocalController:instance():getLine(TableName.Barrel_Monster, id)
    if lineData == nil then
        Logger.LogError("PveMonsterTemplate GetTemplate lineData is nil id:"..id)
        return nil
    end

    local template = PveMonsterTemplate.New()
    template:InitData(lineData)
    
    ----直接把索引的基础信息
    --setmetatable(template, {
    --    __index = function(t, k)
    --        if rawget(t, k) == nil then
    --            local baseTemplate = self:GetBaseTemplate(template.baseId)
    --            if baseTemplate ~= nil then
    --                return baseTemplate[k]
    --            end
    --            
    --            return nil
    --        end
    --    end
    --})
    
    
    self.templateDict[id] = template

    return template
end

function PveMonsterTemplateManager:GetBaseTemplate(baseId)
    if self.baseTemplateDict[baseId] then
        return self.baseTemplateDict[baseId]
    end

    local lineData = LocalController:instance():getLine(TableName.Barrel_Monster_Base, baseId)
    if lineData == nil then
        Logger.LogError("PveMonsterTemplate GetBaseTemplate lineData is nil baseId: " .. baseId)
        return nil
    end

    local baseTemplate = BarrelMonsterBaseTemplate.New()
    baseTemplate:InitData(lineData)
    self.baseTemplateDict[baseId] = baseTemplate

    return baseTemplate
end

PveMonsterTemplateManager.__init = __init
PveMonsterTemplateManager.__delete = __delete
PveMonsterTemplateManager.GetTemplate = GetTemplate

return PveMonsterTemplateManager