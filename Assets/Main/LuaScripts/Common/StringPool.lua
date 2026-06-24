---
--- 随机池 + 轮播池
---
---@class Common.StringPool
local StringPool = BaseClass("StringPool")

--local STAT={}
--local rapidjson = require "rapidjson"

function StringPool:__init(str,separator)
    if not string.IsNullOrEmpty(str) then
        self.pool = string.split(str,separator)
        self.poolLength = #self.pool
    end
end

function StringPool:__delete()
    self.pool = nil
end


function StringPool:GetRandom()
    if self.pool then
        local rand=math.random(self.poolLength)
        --if not STAT[self.poolLength] then
        --    STAT[self.poolLength]={}
        --end
        --if not STAT[self.poolLength][rand] then
        --    STAT[self.poolLength][rand] = 0
        --end
        --STAT[self.poolLength][rand] = STAT[self.poolLength][rand] + 1
        --local json = rapidjson.encode(STAT)
        --Logger.LogError(json)
        return self.pool[rand]
    end
    return nil
end

function StringPool:Sequence()
    if self.pool == nil then
        return nil
    end

    if self.poolLength == 1 then
        return self.pool[1]
    end
    
    local lastIdxFromZero = self.curIdxFromZero or -1
    local curIdxFromZero = Mathf.Repeat(lastIdxFromZero + 1, self.poolLength)
    self.curIdxFromZero = curIdxFromZero
    return self.pool[curIdxFromZero + 1] -- to lua index 
end

function StringPool:First()
    if self.pool ~= nil then
        return self.pool[1]
    end
    
    return nil
end


return StringPool