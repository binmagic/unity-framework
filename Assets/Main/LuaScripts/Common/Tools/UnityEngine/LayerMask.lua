--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
-- added by wsh @ 2017-12-28
-- 注意：
-- 1、已经被修改，别从tolua轻易替换来做升级

local Layer = {}
local rawget = rawget
local setmetatable = setmetatable

local LayerMask = {}
local unity_layermask = CS.UnityEngine.LayerMask

LayerMask.__index = function(t,k)
	return rawget(LayerMask, k)	
end

LayerMask.__call = function(t,v)
	return setmetatable({value = value or 0}, LayerMask)
end

--function LayerMask.New(value)	
	--return setmetatable({value = value or 0}, LayerMask)		
--end

--function LayerMask:Get()
	--return self.value
--end

function LayerMask.LayerToName(layer)
	local name = Layer[layer]
	if (name == nil) then
		name = unity_layermask.LayerToName(layer)
		Layer[layer] = name
	end
	return name
end

function LayerMask.NameToLayer(name)
	local layer = Layer[name]
	if (layer == nil) then
		layer = unity_layermask.NameToLayer(name)
		Layer[name] = layer
	end
	return layer
end

function LayerMask.GetMask(...)

	local value = 0	
	local list_count = select('#', ...)

	for i = 1, list_count do		
		local t = select(i, ...)
		local n = LayerMask.NameToLayer(t)
		if n ~= nil then
			value = value | (1 << n)				
		end
	end	
		
	return value
end

LayerMask.unity_layermask = CS.UnityEngine.LayerMask
--CS.UnityEngine.LayerMask = LayerMask
setmetatable(LayerMask, LayerMask)
return LayerMask



