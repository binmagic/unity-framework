--[[
-- [INPUT]: 依赖 Framework 的 BaseClass,依赖 string.split/string.IsNullOrEmpty 扩展与 Mathf.Repeat
-- [OUTPUT]: 对外提供 StringPool 类(GetRandom 随机取/Sequence 轮播取/First)
-- [POS]: Common 的字符串池,把分隔符串拆成数组后提供随机与顺序轮播两种取用策略,常用于台词/提示文案的多样化展示
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]
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