-- LUA版本的Localization
-- 其实就是对C#的字符串做了一些缓存
-- 否则有时候获取一个字符串要先从C#获取，然后再传回C#，有点浪费效率
-------------------------------------------------------------
-- 注意：字符串的总表存在CS。因为我们最终要把字符串传递给UGUI
-- 从理论上说，lua就不应该存在任何UI的字符串，应该只存在字符串的ID
-- Lua的逻辑层，只需要把字符串的ID和所需参数传给C#，然后在C#那边处理才是正确的

---@class Localization
local Localization = {}
local CS_Localization = CS.GameEntry.Localization
local fmt = {'{0}', '{1}', '{2}', '{3}', '{4}', '{5}', '{6}', '{7}', '{8}', '{9}'}

-- 获取Localization的一个缓存加速
Localization.id_to_string = {}
local langName = nil


-- 获取id -> str
-- 先从lua缓存的查找，没有找到的话，再去CS请求，
local function Localization_GetIdString(dialogid)
	
	if string.IsNullOrEmpty(dialogid) then
		if App.IsEditor() then
			Logger.LogError(debug.traceback('Localization_GetIdString dialogid = nil or empty!', 4))
		end
		return ''
	end
	
	if Localization.id_to_string == nil then
		Logger.LogError("getstring_error_nil")
		return ''
	end
	
	dialogid = Localization.GetRealId(dialogid)
	
	local str = Localization.id_to_string[dialogid]
	if str == nil then
		xpcall(function()  
			str = CS_Localization:GetString(dialogid)
			Localization.id_to_string[dialogid] = str
		end, function()
			Logger.LogError("getstring_error_dialogid_" .. tostring(dialogid) .. "done")
		end)
	end

	return str
end

local function Localization_GetString0(dialogid)
	dialogid = Localization.GetRealId(dialogid)
	return Localization_GetIdString(dialogid)
end

local function Localization_GetStringN(dialogid, N, ...)
	dialogid = Localization.GetRealId(dialogid)
	local fmt = Localization_GetIdString(dialogid)
	
	-- 这个format处理，放到C代码中了
	local str = string.format_params(fmt, N, ...)
	
	-- 下面的代码是LUA版的format_params
	-- 在LUA这边组合字符串；但是配置表里配置的是{0},{1}这样，所以直接把{0}替换成第0个参数
	--for i = 1, N do
		--local v = select(i, ...)
		--str = string.gsub(str, fmt[i], tostring(v))
	--end

	return str
end

-- 获取一个字符串处理
function Localization.GetString(self, dialogid, ...)

	--dialogid = tostring(dialogid)
	
	if type(dialogid) == "string" then
		dialogid = math.tointeger(dialogid) or dialogid
		if type(dialogid) == "string" then
			-- 这里表示有一些确实就是字符串的ID，历史遗留问题（大约2012年的某些人没整好）
			local t = 0
		end	
	end

	local c = select('#', ...)
	if c==0 then
		return Localization_GetString0(dialogid)
	end
	
	
	-- 有问题把这个打开，直接从C#取
	--local str = CS_Localization:GetString(dialogid, ...)
	
	local str = Localization_GetStringN(dialogid, c, ...)
	return str
end

-- 重置多语言；当切换语言的时候调用一下
function Localization.Reset(self)
	Localization.id_to_string = {}
end

--获取当前语言
function Localization.GetLanguage()
	return CS_Localization:GetLanguage()
end

function Localization.SetLanguage(self, lang)
	return CS_Localization:SetLanguage(lang)
end

function Localization.GetLanguageName()
	return App.GetLanguageName()
end

function Localization.IsInitDone()
	return CS_Localization.IsInitDone
end

local function flipTable(tbl)
	local flipped = {}
	for k, v in pairs(tbl) do
		flipped[v] = k
	end
	return flipped
end

--横=>竖 id映射
--[[local ToPortraitIdMapping = {
	[141166] = 900000,
	[141198] = 900001,
	[372440] = 900002,
	[897634] = 900003,
	[372462] = 900004,
	[896167] = 900005,
	[372470] = 900006,
	[880013] = 900007,
	[141208] = 900008,
	[320486] = 900009,
	[372956] = 900010,
	[372099] = 900011,
	[897855] = 897867,
	[897856] = 897868,
	[897857] = 897869,
}]]--

--竖=>横 id映射
--local ToLandScapeIdMapping = flipTable(ToPortraitIdMapping)

function Localization.GetRealId(originId)
	local id = tonumber(originId)
	if id == nil then
		return originId
	end
	
	local lookupTable = IS_PORTRAIT and ToPortraitIdMapping or ToLandScapeIdMapping
	local pId = lookupTable[id]
	if pId ~= nil then
		return pId
	end
	
	return originId
end


return Localization
