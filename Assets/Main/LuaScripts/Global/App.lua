-- APP信息功能类
-- 

local App = {}

-- 用来缓存App的各种变量使用
local self = {}

-- 返回analyticID
function App.GetAnalyticID()
	if self.analyticID == nil then
		self.analyticID = tostring(CS.GameEntry.GlobalData.analyticID)
	end

	return self.analyticID or ''
end

-- 返回来源国家
function App.GetFromCountry()
	if self.fromCountry == nil then
		self.fromCountry = tostring(CS.GameEntry.GlobalData.fromCountry)
	end

	return self.fromCountry or ''
end

-- 获取语言信息
function App.GetLanguageName()
	if self.languageName == nil then
		self.languageName = tostring(CS.GameEntry.Localization:GetLanguageName())
	end
	
	return self.languageName or ''
end

-- 返回版本号
function App.GetVersion()
	if self.version == nil then
		self.version = tostring(CS.GameEntry.Sdk.Version)
	end

	return self.version or ''
end

-- 返回版本号
function App.GetVersionCode()
	if self.versionCode == nil then
		self.versionCode = tonumber(CS.GameEntry.Sdk.VersionCode)
	end

	return self.versionCode or 1
end

-- 返回资源版本 x.y
function App.GetResVersion()
	if self.resVersion == nil then
		self.resVersion = tostring(CS.GameEntry.Resource:GetResVersion())
	end
	
	return self.resVersion or "0.0"
end

-- 返回设备ID
function App.GetDeviceUid()
	if string.IsNullOrEmpty(self.deviceUid) then
		self.deviceUid = tostring(CS.GameEntry.Device:GetDeviceUid())
	end

	return self.deviceUid or ''
end

-- 是否为调试状态
function App.IsDebug()
	if self.isDebug == nil then
		self.isDebug = CS.CommonUtils.IsDebug()
	end

	return self.isDebug or false
end

-- 是否为编辑器状态
function App.IsEditor()
	if self.isEditor == nil then
		self.isEditor = CS.CommonUtils.IsEditor()
	end

	return self.isEditor or false
end

-- 是否为GPTest
function App.IsGPTest()
	local t = App.GetPackageName()
	if string.endswith(t, "test") then
		return true
	end
	return false
end

-- 获取当前的包名
function App.GetPackageName()
	if self.packageName == nil then
		self.packageName = tostring(CS.GameEntry.Sdk:GetPackageName())
	end

	return self.packageName or ''
end

-- 获取平台名字
function App.GetPlatformName()
	if self.platformName == nil then
		self.platformName = tostring(CS.GameUtility:GetPlatformName())
	end
	
	return self.platformName or ''
end

function App.IS_ANDROID()
	if self.isAndroid == nil then
		self.isAndroid = CS.SDKManager.IS_UNITY_ANDROID()
	end
	
	return self.isAndroid
end

-- 是否为苹果手机使用
function App.IS_IPhonePlayer()
	if self.is_iPhonePlayer == nil then
		self.is_iPhonePlayer = CS.SDKManager.IS_IPhonePlayer()
	end
	
	return self.is_iPhonePlayer
end

function App.IS_IOS()
	if self.is_ios == nil then
		self.is_ios = CS.SDKManager.IS_UNITY_IOS()
	end
	
	return self.is_ios
end

--note: 商店包这个标记才为True!!!
function App.IsFinalRelease()
	if self.isFinalRelease == nil then
		self.isFinalRelease = CS.CommonUtils.IS_FINAL_RELEASE()
	end

	return self.isFinalRelease or false
end

-- 是否为APK
function App.IsAPK()
	local targetVersion = CS.GameEntry.Sdk:GetDataFromNative("PM_GetTargetSdkVersion", "")
	local _nversion = tonumber(targetVersion) or 0	
	if _nversion <= 30 then
		return true
	end
	
	return false
end

--是否编辑器连线上服 仅用于测试
function App.IsEditorConnectedToRelease()
	if not App.IsEditor() then
		return false
	end

	local curServerHost = LuaEntry.Network:GetGameServerUrl()
	--if curServerHost:match('^(10%.|172%.|192%.)') then
	if string.startswith(curServerHost, '10.') or string.startswith(curServerHost, '172.') or
			string.startswith(curServerHost, '192.') then
		return false
	end
	
	return true
end

--清理本地旧资源
function App.ClearOldAssetBundles(needTip)
	if App.IsEditor() then
		return
	end
	
	local function getFiles(dir, extension)
		local allFiles = CS.System.IO.Directory.GetFiles(dir)
		local bundleFiles = {}
		-- 过滤出以 .bundle 结尾的文件
		for i = 0, allFiles.Length - 1 do
			local filename = allFiles[i]
			if string.sub(filename, -string.len(extension)) == extension then
				local fileNameOnly = CS.System.IO.Path.GetFileName(filename)
				table.insert(bundleFiles, fileNameOnly)
			end
		end
		return bundleFiles
	end

	local function getBundleInfo(filename, totalManifestList)
		for i = 0, totalManifestList.Count - 1 do
			local manifest = totalManifestList[i]
			local bundleInfo = manifest:GetBundle(filename)
			if bundleInfo ~= nil then
				return bundleInfo
			end
		end
		
		return nil
	end
	
	
	local totalBundleCount = 0
	local toRemoveList = {}


	local totalManifestList = CS.VEngine.Versions.Manifests
	local folderPath = CS.VEngine.Versions.DownloadDataPath
	local bundleFiles = getFiles(folderPath, ".bundle")
	for _, filename in ipairs(bundleFiles) do
		totalBundleCount = totalBundleCount + 1
		local bundleInfo = getBundleInfo(filename, totalManifestList)
		if bundleInfo == nil then
			table.insert(toRemoveList, folderPath .. "/" .. filename)
		end
	end

	local CS_File = CS.System.IO.File
	for _, filepath in ipairs(toRemoveList) do
		CS_File.Delete(filepath)
		print("#zlh# Deleted file: " .. filepath)
	end

	PostEventLog.Record(string.format('totalBundleCount:%d, RemovedBundleCount:%d', totalBundleCount, #toRemoveList))

	if needTip then
		UIUtil.ShowTips(string.format('Clear complete! %d old files has removed!', #toRemoveList))
	end
end


return App
