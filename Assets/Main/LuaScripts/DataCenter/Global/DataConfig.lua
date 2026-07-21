--[[
	游戏的全局配置
	因为这个配置其实不是和账号绑定的
]]
local rapidjson = require "rapidjson"
local util = require "Common.Tools.cjson.util"

---@class  DataConfig
local DataConfig = BaseClass("DataConfig")

function DataConfig:__init()
	self.dataConfig = {}
	self.functionOnConfig = {}
	self.itemMd5 = ""
end

function DataConfig:InitFromTable()
	local path = util.GetPersistentDataPath()
	local name = path.."/".."data_config.txt"
	local jsonStr = util.file_load(name)
	if jsonStr~=nil then
		local message = rapidjson.decode(jsonStr)
		if message~=nil then
			self.dataConfig = message["dataConfig"]
			self.functionOnConfig = message["function_on_config"]
			if self.dataConfig~=nil then
				if self.dataConfig["itemMd5"]~=nil then
					self.itemMd5 = self.dataConfig["itemMd5"]
				end
			end
		end
	end
end

function DataConfig:GetMd5()
	return self.itemMd5
end

function DataConfig:ClearMd5()
	self.itemMd5 = ""
	local path = util.GetPersistentDataPath()
	local name = path.."/".."data_config.txt"
	local jsonStr = ""
	util.file_save(name,jsonStr)
end

function DataConfig:InitFromNet(msg)
	if msg["dataConfig"]~=nil then
		self.dataConfig = msg["dataConfig"]
		--if self.dataConfig["monster_interval"]~=nil then
			--local str = self.dataConfig["monster_interval"]
			--local strArr = string.split(str,";")
			--if #strArr == 2 then
				----由于aps那边只存没取，所以lm这边先不要
				----CS.GameEntry.GlobalData:SetGlobalValue("staminaIntervalTime", strArr[2])
				----CS.GameEntry.GlobalData:SetGlobalValue("staminaIntervalNum", strArr[1])
			--end
		--end
		if self.dataConfig["itemMd5"]~=nil then
			self.itemMd5 = self.dataConfig["itemMd5"]
		end
		if msg["function_on_config"]~=nil then
			self.functionOnConfig = msg["function_on_config"]
		end
		local path = util.GetPersistentDataPath()
		local name = path.."/".."data_config.txt"
		local data = {}
		data["dataConfig"] = self.dataConfig
		data["function_on_config"] = self.functionOnConfig
		local jsonStr = rapidjson.encode(data)
		util.file_save(name,jsonStr)
	end
end

function DataConfig:CheckSwitch(key)
	local isSwitch =false
	if self.functionOnConfig~=nil and self.functionOnConfig[key]~=nil then
		local num = tonumber(self.functionOnConfig[key])
		if num == 1 then
			isSwitch = true
		end
	end
	return isSwitch
end

function DataConfig:GetObj(key1)
	if self.dataConfig == nil then
		return nil
	end
	
	--英雄使用 a/b是两个字段，这里特殊处理下 trial_hero_barrel 
	if LuaEntry.Player.abTest ~= ABTestType.A and key1 == 'trial_hero_barrel' then
		key1 = 'trial_hero_barrel_B'
	end
	
	--竖版特殊处理 如果竖版配置需要和横板不同 则让策划添加竖版新字段，字段名为原有字段接_portrait后缀 外部调用不变
	if IS_PORTRAIT then
		local portraitKey = key1 .. '_portrait'
		if self.dataConfig[portraitKey] ~= nil then
			return self.dataConfig[portraitKey]
		end
	end
	
	if self.dataConfig[key1] ~= nil then
		return self.dataConfig[key1]
	end
end

function DataConfig:GetValue(key1,key2)
	local obj = self:GetObj(key1)
	if obj~=nil and obj[key2]~=nil then
		return obj[key2]
	end
end

function DataConfig:TryGetStr(key1,key2)
	local value = self:GetValue(key1,key2)
	if value~=nil then
		return tostring(value)
	else
		return ""
	end
end

function DataConfig:TryGetNum(key1,key2)
	local value = self:GetValue(key1,key2)
	if value~=nil then
		return tonumber(value)
	else
		return 0
	end
end

-- 尝试获取缓存
function DataConfig:TryGetCache(key1, key2)

	if self.functionOnConfig[key1] == nil then
		self.functionOnConfig[key1] = {}
	end

	local t2 = self.functionOnConfig[key1][key2]

	return t2
end

-- 获取[int]类型的数组，如："1,2,3,4,5" 返回 {1,2,3,4,5}
-- 使用这个函数，第一次分割，然后会缓存，之后再调用是直接取表
function DataConfig:TryGetArray_i(key1, key2, sep)

	local t2 = self:TryGetCache(key1, key2)
	if t2 then
		return t2
	end

	sep = sep or ','
	local value = self:TryGetStr(key1, key2)
	local t = string.split_ii_array(value, sep)
	self.functionOnConfig[key1][key2] = t
	return t
end

-- 获取[string]类型的数组，如："1,2,3,4,5" 返回 {"1","2","3","4","5"}
-- 使用这个函数，第一次分割，然后会缓存，之后再调用是直接取表
function DataConfig:TryGetArray_s(key1, key2, sep)
	
	local t2 = self:TryGetCache(key1, key2)
	if t2 then
		return t2
	end

	sep = sep or ','
	local value = self:TryGetStr(key1, key2)
	local t = string.split_ss_array(value, sep)
	self.functionOnConfig[key1][key2] = t
	return t
end

-- 获取[float]类型的数组，如："1.0,2.0,3.0,4.0,5.0" 返回 {1.0,2.0,3.0,4.0,5.0}
-- 使用这个函数，第一次分割，然后会缓存，之后再调用是直接取表
function DataConfig:TryGetArray_f(key1, key2, sep)
	
	local t2 = self:TryGetCache(key1, key2)
	if t2 then
		return t2
	end

	sep = sep or ','
	local value = self:TryGetStr(key1, key2)
	local t = string.split_ff_array(value, sep)
	self.functionOnConfig[key1][key2] = t
	return t
end

-- 获取map类型的数组，如："1=2,2=4" 返回 {[1]=2, [2]=4}
-- ii 表示 key的类型是i
function DataConfig:TryGetMap_ii(key1, key2, sep1, sep2)

	local t2 = self:TryGetCache(key1, key2)
	if t2 then
		return t2
	end

	--sep = sep or ','
	local value = self:TryGetStr(key1, key2)
	local t = string.string2table_ii(value, sep1, sep2)
	self.functionOnConfig[key1][key2] = t
	return t
end

-- 获取[int]类型的二位数组，如："1008|1|1|1|2024202401;1006|1|1|1|2024202402" 返回 {{10081,1,1,1,2024202401},{1006,1,1,1,2024202402}}
-- 使用这个函数，第一次分割，然后会缓存，之后再调用是直接取表
function DataConfig:TryGetArray_2D_i(key1, key2, sep1, sep2)
	local t2 = self:TryGetCache(key1, key2)
	if t2 then
		return t2
	end
	
	local value = self:TryGetStr(key1, key2)
	local strArr = string.split_ss_array(value, sep1)
	local array = {}
	for k,v in pairs(strArr) do
		local t = string.split_ii_array(v, sep2)
		table.insert(array, t)
	end
	self.functionOnConfig[key1][key2] = array
	return array
end

return DataConfig
