---------------------------------------------------------------------
-- LazyTemplate 用来缓式解析表格；主要目的是增加启动效率
-- 因为lua元表的开销，所以惰式解析总体上性能肯定是降低的，但是可以增加启动效率和减少内存
--
-- 我们策划配置的表格数据，毫无章法，毫无规律，甚至毫无人性(毕竟不考虑后来维护者)
-- 所以通常的表格，我们使用的时候，会用一个Template来进行结构化数据
-- 但是如果我们一开始就将整个表格结构化，就会比较耗时。所以大表格，推荐使用Lazy
-- 
-- 原理，如果是使用原始Value——这里表示数据+类型都是原始规格——那么就直接从表格读取
-- 如果想使用解析数据，这里使用回调函数抛给Templdate自身去解析
-- 如果不想每次都解析，只需要第一次解析之后，把结果值存入到self即可

---@class LazyTemplate
local LazyTemplate = BaseClass("LazyTemplate")

function LazyTemplate:set_meta_value(row, SubTemplate, parser_table)
	
	self.indexData = row._indexData
	self.lineData = row._lineData
	
	self.lazyParser = parser_table or {}
	
	-- 数据元表
	local TemplateMeta =
	{
		__index = function(t, k)
			local var1 = SubTemplate[k]
			if var1 then
				return var1
			end
			
			return t:get_value(k)
		end
	}
	
	--local tt = getmetatable(self)
	setmetatable(self, TemplateMeta)
	
	return
end

function LazyTemplate:set_lazy_parser(key, parser)
	if self.lazyParser then
		self.lazyParser[key] = parser
	else
		-- 要先调用set_meta_value
	end
end

-- 数据元表；k 表示表格中的键值
function LazyTemplate:get_meta_value(k)
	-- 直接使用原始的value	
	local it = self.indexData
	local idata = it[k]

	-- 这种情况表示访问的类型不存在；有可能表格没填
	if idata == nil then
		Logger.Debug("lazy - proprety not found 1: ", k)
		return nil
	end

	-- 直接从表格数据取内容
	local v = self.lineData[idata[1]]
	if v then
		return v
	end

	-- 表示改字段策划有些字段没配置，也没有明确的类型
	Logger.LogError("proprety not set: ", k)
	return nil
end

-- 兼容接口
function LazyTemplate:getValue(k)
	return self:get_meta_value(k)
end

function LazyTemplate:getIntValue(k)
	return tonumber(self:get_meta_value(k))
end

function LazyTemplate:get_value(rowname)
	-- 如果有缓式解析的话
	local p = self.lazyParser[rowname]
	if p then
		return p(self, rowname)
	end

	return self:get_meta_value(rowname)
end


return LazyTemplate