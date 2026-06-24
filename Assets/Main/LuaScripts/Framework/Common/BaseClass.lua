--[[
-- added by wsh @ 2017-11-30
-- Lua面向对象设计
-----------------------------------
-- 这个类整理一下，修改两个小问题；
-- 1. 函数不需要每次都去function一个
-- 2. 所有的对象共享一个类虚表
--]]

--保存类类型的虚表
local _class = {}
--虚表的元表
local _class_mt = {}
 
-- 自定义类型
ClassType = {
	class = 1,
	instance = 2,
}

local function create(obj, classtype, ...)
	if classtype.super then
		create(obj, classtype.super, ...)
	end
	if classtype.__init then
		classtype.__init(obj, ...)
	end
end

local function delete(self)
	local now_super = self._class_type
	while now_super ~= nil do
		if now_super.__delete then
			now_super.__delete(self)
		end
		now_super = now_super.super
	end
end
 
-- 定义一个类
function BaseClass(classname, super)
    assert(type(classname) == "string" and #classname > 0, "Class name must be a non-empty string")
    
    -- 生成一个类类型
    local class_type = {
        __init = false,   -- 初始化函数
        __delete = false, -- 删除函数
        __cname = classname, -- 类名
        __ctype = ClassType.class, -- 类型标识
        super = super, -- 父类引用
		New = true,
    }

    -- 定义 New 方法，用于创建类对象
    class_type.New = function(...)
        -- 生成类对象
        local obj = {
            _class_type = class_type,
            Delete = delete -- 对象的删除方法共享，不重复创建
        }

        -- 注册类的元表
        setmetatable(obj, _class_mt[class_type])

        -- 调用构造函数链
        create(obj, class_type, ...)
        
        return obj
    end

	local vtbl = {}
	_class[class_type] = vtbl
 
	setmetatable(class_type, {
		__newindex = function(t,k,v)
			vtbl[k] = v
		end
		, 
		--For call parent method
		__index = vtbl,
	})
 
	if super then
		setmetatable(vtbl, {
			__index = function(t,k)
 				--local ret = _class[super][k]
				--do not do accept, make hot update work right!
				--vtbl[k] = ret
				--return ret
				return _class[super][k]
			end
		})
	end
 
	-- 直接把元表的虚表缓存一下，每个类成员共享一份
	local vtbl_mt = { __index = _class[class_type] }
	_class_mt[class_type] = vtbl_mt
	
	return class_type
end
