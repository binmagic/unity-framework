---
--- 对象池，对象进池之前要清数据
---
---@class Common.ObjectPool
-----@field GetInstance fun():Common.ObjectPool
local ObjectPool = BaseClass("ObjectPool", Singleton)


function ObjectPool:__init()
    self.pool = {}---@type table<class,table<number,obj>>
end

function ObjectPool:__delete()
    self:ClearAll()
end


--清空
function ObjectPool:ClearAll()
    for _,v in pairs(self.pool) do
        for i = 1, #v do
            v[i]:Delete()
        end
    end
    self.pool = {}
end

--清空
function ObjectPool:Clear(class)
    if not self.pool[class] then
        return
    end
    for i = 1, #self.pool[class] do
        self.pool[class][i]:Delete()
    end
    self.pool[class] = nil
end

--取出
function ObjectPool:Load(class)
    if not self.pool[class] then
        self.pool[class] = {}
    end
    if #self.pool[class]==0 then
        return class.New()
    end
    return table.remove(self.pool[class])
end

--存入
function ObjectPool:Save(object)
    local class = object._class_type
    if not self.pool[class] then
        self.pool[class] = {}
    end
    table.insert(self.pool[class],object)
end




return ObjectPool