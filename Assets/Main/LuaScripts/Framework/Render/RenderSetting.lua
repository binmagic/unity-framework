---------------------------------------------------------------------
-- aps_client333 (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2022-01-07 17:18:39
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

local RenderSetting = {}
local _scriptableRendererData
local _gameQulity
local _memoryQulity
local _usePipeline
local Setting = require 'Global.SettingManager'
local _camera = CS.UnityEngine.Camera.main
local _renderLevel
local isLockUpdateDemanRendering
local startTime = CS.UnityEngine.Time.realtimeSinceStartup
local startDropTime = CS.UnityEngine.Time.realtimeSinceStartup
local Resource = CS.GameEntry.Resource
local _rainDropToggle=false
local _rainDropDirty =false
local planeShadowMat="Assets/Main/Material/CommonPlaneShadow.mat"
local unitySHParamNames = {
	"_Boyan_SHAr","_Boyan_SHAg","_Boyan_SHAb",
	"_Boyan_SHBr","_Boyan_SHBg","_Boyan_SHBb",
	"_Boyan_SHC"
}

local function ToggleOutlineRenderFeature( active )
	RenderSetting.SetRenderFeatureState("URPOutlineFeature", active)
end

local function SetRenderFeatureState( rfName, active )
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name== rfName then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(active)
				end
			end
		end
	end
end


local function ToggleBlur(isToggle, name, index)
	--Logger.Log(string.format('#Render# ToggleBlur:%s, name:%s, index:%d', tostring(isToggle), name, index))
	
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline~=nil then
		local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
		local objs =  propertyInfo:GetValue(pipeline);
		for i = 1, objs.Length do
			local isDone = false
			local _scriptableRendererData = objs[i-1]
			cast(_scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			--print(_scriptableRendererData.rendererFeatures.Count)
			for i = 0, _scriptableRendererData.rendererFeatures.Count-1 do
				local featureData=_scriptableRendererData.rendererFeatures[i]
				if featureData.name == name then
					--cast(featureData, typeof(CS.BlurURP))
					if isToggle then
						--featureData:SetActive(isToggle)
						CS.BlurURP.EnableFeature(index)
					else
						CS.BlurURP.DisableFeature(index)
					end
					--featureData:SetActive(isToggle)
					isDone = true
				end
			end

			if index==1 then

				for i = 0, _scriptableRendererData.rendererFeatures.Count-1 do
					local featureData=_scriptableRendererData.rendererFeatures[i]
					--print(featureData.name..":".."BlurURP"..tostring(i))
					if featureData.name == "BlurURP"..tostring(i-1) then
						--featureData:SetActive(isToggle)
						isDone = true
					end
				end
			end
		end

	end
end

local function SetUP(gameQulity,memoryQulity)

	

end
local function UpateScale(scaleValue)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	pipeline.renderScale=scaleValue
end
local function GetQulity()
	return  _gameQulity
end
local function InitLightAtten()
	--不用了，先注释掉吧

	--local texturePath="Assets/_Art_LastDay/Effect/Texture/LightAtten_1.png"
	--local req = Resource:LoadAsset(texturePath, typeof(CS.UnityEngine.Texture2D))
	--if req~=nil then
		--local texture = req.asset
		--CS.UnityEngine.Shader.SetGlobalTexture("_LightTexture1",texture)
	--else
		--print("没有找到灯光贴图!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	--end
end

local function InitRender()
    print("init render");
	--RenderSetting.InitLightAtten()
	local graphicLevel = Setting:GetPublicInt(SettingKeys.SCENE_GRAPHIC_LEVEL, EnumQualityLevel.Middle)
	local cameraData = _camera.gameObject:GetComponent(typeof(CS.UnityEngine.Rendering.Universal.UniversalAdditionalCameraData))
	
	Logger.Log("Render Qulity Level: ", tostring(graphicLevel))
	RenderSetting.SetGameDefaultLevel()
	RenderSetting.InitQulity()
	--graphicLevel = EnumQualityLevel.Middle
	if graphicLevel == EnumQualityLevel.Low or graphicLevel == EnumQualityLevel.Middle then
		--print("Lod Qulity........................."..tostring(graphicLevel))
		if graphicLevel == EnumQualityLevel.Low then
			RenderSetting.UpateScale(0.8)
			cameraData.renderPostProcessing = false
		elseif graphicLevel == EnumQualityLevel.Middle then
			RenderSetting.UpateScale(0.85)
			cameraData.renderPostProcessing = false
		end
	
		--if graphicLevel == EnumQualityLevel.Low then
			--RenderSetting.TogglePlaneShadowRenderFeature(false)
		--end
		--RenderSetting.ToggleAdditionLightShadow(false)
    else
		RenderSetting.TogglePlaneShadowRenderFeature(true)
		cameraData.renderPostProcessing = true
		--RenderSetting.ToggleAdditionLightShadow(true)
		RenderSetting.UpateScale(1)
	end
	if graphicLevel == EnumQualityLevel.Low then
		CS.UnityEngine.Shader.EnableKeyword("Low");
		CS.UnityEngine.Application.targetFrameRate = 30
	elseif graphicLevel == EnumQualityLevel.Middle then
		CS.UnityEngine.Shader.DisableKeyword("Low");
		CS.UnityEngine.Application.targetFrameRate = 45
    else
		CS.UnityEngine.Shader.DisableKeyword("Low");
		CS.UnityEngine.Application.targetFrameRate = 60
	end



	--RenderSetting.DumpSphericalHarmonicsL2()
	--RenderSetting.SettingFur()
	RenderSetting.SetShadowDistance(10)
	_rainDropToggle  = false
	_rainDropDirty = true
	RenderSetting.ToggleRainDropRenderFeatureTick(false)
	--CS.UnityEngine.QualitySettings.SetQualityLevel(0)
	--关闭深度图
	--RenderSetting.ToggleCopyDepth(false)
	--RenderSetting.ToggleTiltShift(false)
	--关闭些keyworld 避免中间Unity重启，显示错误
	RenderSetting.InitPlaneShadow()
	CS.UnityEngine.Shader.DisableKeyword("_BigWorld");
	CS.UnityEngine.Shader.SetGlobalColor("_LightColor1", CS.UnityEngine.Color.white);
	CS.UnityEngine.Shader.SetGlobalFloat("_LightIntensity1", 1);

	RenderSetting.curGraphicLevel = graphicLevel
	--RenderSetting.ToggleCameraOpaqueTexture(true)
end

local function InitPlaneShadow()
	
	local constructMaterialReq = Resource:LoadAssetAsync(planeShadowMat, typeof(CS.UnityEngine.Material))
	if constructMaterialReq == nil then
		return
	end

	constructMaterialReq:completed('+', function(req)
			if req.asset == nil then
				Logger.LogError("LoadConstructMaterial material is nil!")
				return
			end
            print("..................................................................................................................................")
			local asset = req.asset
			cast(asset, typeof(CS.UnityEngine.Material))
			print(asset.name)
			
			local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
			cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
			if pipeline == nil then
				return
			end

			local propertyInfo = pipeline:GetType():GetField("m_RendererDataList", 4|32 )
			if propertyInfo == nil then
				return
			end

			local objs = propertyInfo:GetValue(pipeline)
			if objs == nil then
				return
			end

			local found = false
			for i = 1, objs.Length do
				local scriptableRendererData = objs[i-1]
				if scriptableRendererData == nil then
					goto continue
				end

				cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
				--print(scriptableRendererData.rendererFeatures.Count)
				for ii = 0, scriptableRendererData.rendererFeatures.Count - 1 do
					local feature = scriptableRendererData.rendererFeatures[ii]
					if feature.name =="PlannerShadowOpaques" then
						if feature.isActive then
							feature.settings.overrideMaterial = asset
						end
						break
					end
				end
				--scriptableRendererData:SetDirty()

				if found then
					break
				end

				::continue::
			end

		end)
end


local function GetShadowDistance()
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	return pipeline.shadowDistance
end
local function SetShadowDistance(distance)
	print("distance============================================================="..tostring(distance))
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	if _usePipeline~=pipeline then
		cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
		_usePipeline = pipeline
	end
	_usePipeline.shadowDistance = distance
end
local function ToggleDepthTexture(toggle)
	--local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	--cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	--pipeline.supportsCameraDepthTexture=toggle
end
local function ToggleCameraOpaqueTexture(toggle)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	pipeline.supportsCameraOpaqueTexture = toggle
end

local function SetShadowReslution(size)

end
--先根据手机内存匹配
local function InitQulity()
	local systemMemorySize = CS.UnityEngine.SystemInfo.systemMemorySize
	if systemMemorySize>1024*5 then
		_gameQulity=2
	elseif systemMemorySize>1024*3 then
		_gameQulity=1 
	elseif systemMemorySize>1024*2 then
		_gameQulity = 0
	else
		_gameQulity = -1
	end
	RenderSetting.AddUpdater()
end

local function SetSupportsMainLightShadows(supported)

end

local function SetGameDefaultLevel()
	local graphicLevel = Setting:GetPublicInt(SettingKeys.SCENE_GRAPHIC_LEVEL, EnumQualityLevel.Middle)
	
	if graphicLevel == EnumQualityLevel.Low then
		RenderSetting.SetQualityLevel(0)
	elseif graphicLevel == EnumQualityLevel.Middle then
		RenderSetting.SetQualityLevel(1)
	else
		RenderSetting.SetQualityLevel(2)
	end
end

local function SetQualityLevel(level)
	_renderLevel = level
	print("update Game QualityLevle.."..tostring(_renderLevel))
	CS.UnityEngine.QualitySettings.SetQualityLevel(_renderLevel)
	
end
local function ToggleAdditionLightShadow(toggle)
	
	--local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	--cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	--if pipeline ~= nil then
		--pipeline.supportsAdditionalLightShadows =toggle
	--end
	
	
end
local function ToggleCopyDepth(toggle)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
    cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local graphicLevel = Setting:GetPublicInt(SettingKeys.SCENE_GRAPHIC_LEVEL, EnumQualityLevel.Middle)
	if graphicLevel == EnumQualityLevel.Low then
		pipeline.supportsCameraDepthTexture =false
	end
end
--设置皮毛材质设置
local function SettingFur()
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end

	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData == nil then
			goto continue
		end
		cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
		--print(scriptableRendererData.rendererFeatures.Count)
		for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
			if scriptableRendererData.rendererFeatures[i].name=="NewFurRenderFeature" then
				local featureData=scriptableRendererData.rendererFeatures[i]
				cast(featureData, typeof(CS.FurRenderFeature))
				if _gameQulity<2 then
					featureData.settings.PassLayerNum=1
				end
			end
		end

		::continue::
	end
end

local function HeightFogIsOpen()
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="NewHeightFogRenderFeature" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					return featureData.isActive
				end
			end
		end
	end
	return false

end

local function SettingHeightFog(fogHeight,fogY,color1,color2,fogIntensity)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData == nil then
			goto continue
		end
		cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
		for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
			if scriptableRendererData.rendererFeatures[i].name=="NewHeightFogRenderFeature" then
				local featureData=scriptableRendererData.rendererFeatures[i]
				cast(featureData, typeof(CS.HeightFogRenderFeature))
				featureData.fogSetting._FogDisappearHeight = fogHeight
				featureData.fogSetting._FogPosY = fogY
				--featureData.fogSetting.unexploredColor =color1
				--featureData.fogSetting.exploredColor =color2
				featureData.fogSetting.FogIntensity =fogIntensity
			end
		end

		::continue::
	end
end
local function ToggleRadialBlurRenderFeature(visible)
	
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="RadialBlur" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
	
	
end
local function TogglePlaneShadowRenderFeature(visible)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="PlannerShadowOpaques" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
end

local function ToggleTaaRenderFeature(visible)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="TAA" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
end
local function ToggleRainDropRenderFeatureTick(visible)
	
	--if _rainDropDirty==visible then
		--return
	--end
	--_rainDropDirty = visible

	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="RainDropRenderFeature" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(false)
				end
			end
		end
	end
end

local function ToggleRainDropRenderFeature(visible)
	_rainDropToggle  = visible
	_rainDropDirty = not visible
	
end


local function ToggleSSAORenderFeature(visible)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="ScreenSpaceAmbientOcclusion" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
end

local function ToggleFurRenderFeature(visible)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="NewFurRenderFeature" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
end

local function SetHeightFogVisible(visible)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name=="NewHeightFogRenderFeature" then
					local featureData=scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
end

local function DumpSphericalHarmonicsL2()
	Logger.Log("SH9 Init")
	local  _Boyan_SHAr=CS.UnityEngine.Vector4.New(0.004648618,0.04024808,0.1420737,0.07830186)
	
	local _Boyan_SHAg=CS.UnityEngine.Vector4.New(0.0002994311,0.02578158,0.09100345,0.05015705)
	
	local _Boyan_SHAb=CS.UnityEngine.Vector4.New(0.0002472363,0.02130016,0.07518087,0.04143815)
	
	local _Boyan_SHBr=CS.UnityEngine.Vector4.New(0.001815334,0.03099227,0.1303456,-0.0008579805)
	
	local _Boyan_SHBg=CS.UnityEngine.Vector4.New(0.001162766,0.0198522,0.08349172,-0.0008579805)

	local _Boyan_SHBb=CS.UnityEngine.Vector4.New(0.0009607048,0.01640104,0.06897455,-0.0007092103)
	
	local _Boyan_SHC=CS.UnityEngine.Vector4.New(00.004648618,0.002977597,0.002460187,1)
	
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[1],_Boyan_SHAr);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[2],_Boyan_SHAg);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[3],_Boyan_SHAb);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[4],_Boyan_SHBr);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[5],_Boyan_SHBg);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[6],_Boyan_SHBb);
	CS.UnityEngine.Shader.SetGlobalVector(unitySHParamNames[7],_Boyan_SHC);
	Logger.Log("SH9 Init Finish")
end

local function SetHDR(enable)
	--local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	--cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	--pipeline.supportsHDR = enable
end


local function IsToggleDepthTexture()
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline,typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	return pipeline.supportsCameraDepthTexture
end
local function ToggleTiltShift(visibletoggle)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name == "TiltShift" then
					local featureData = scriptableRendererData.rendererFeatures[i]
					featureData:SetActive(visible)
				end
			end
		end
	end
	
end


local function ToggleMosaicRenderPassFeature(visible,rectangle)
	local pipeline = CS.UnityEngine.QualitySettings.renderPipeline
	cast(pipeline, typeof(CS.UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset))
	if pipeline == nil then
		return
	end
	local propertyInfo = pipeline:GetType():GetField("m_RendererDataList",4|32 );
	if propertyInfo == nil then
		return
	end

	local objs = propertyInfo:GetValue(pipeline);
	if objs == nil then
		return
	end

	for i = 1, objs.Length do
		local scriptableRendererData = objs[i-1]
		if scriptableRendererData ~= nil then
			cast(scriptableRendererData, typeof(CS.UnityEngine.Rendering.Universal.ScriptableRendererData))
			for i = 0, scriptableRendererData.rendererFeatures.Count-1 do
				if scriptableRendererData.rendererFeatures[i].name == "MosaicRenderPassFeature" then
					local featureData = scriptableRendererData.rendererFeatures[i]
					cast(featureData, typeof(CS.MosaicRenderPassFeature))
					featureData:SetActive(visible)
					if rectangle then
						featureData.settings.Rectangle = rectangle
					end
				end
			end
		end
	end
end


local function SetLevelLayerCulling()
	local distance = {}
	for i = 1, 32 do
		distance[i]=0
	end
	distance[7]=50  --Grass
	distance[1]=110 --Default
	distance[12]=100 --PlaneShadow
	distance[28]=150 --Ground
	_camera.layerCullDistances = distance
end
local function SetDefaultLayerCulling()
	local distance = {}
	for i = 1, 32 do
		distance[i]=0
	end
	--distance[7]=500
	_camera.layerCullDistances = distance
end

local function AddUpdater()
	if RenderSetting.update == nil then
		RenderSetting.update = function() RenderSetting.Update() end
		UpdateManager:GetInstance():AddUpdate(RenderSetting.update)
	end
end

local function RemoveUpdater()
	if RenderSetting.update then
		UpdateManager:GetInstance():RemoveUpdate(RenderSetting.update)
		RenderSetting.update = nil
	end

end      

local OnDemandRendering = CS.UnityEngine.Rendering.OnDemandRendering
local lastRFInterval = nil
local function SesetRenderFrameInterval( value )
	if lastRFInterval ~= value and OnDemandRendering ~= nil  then
		OnDemandRendering.renderFrameInterval = value
		lastRFInterval = value
	end
end

local function ToggleLoworHightFrame(isLow)
	if CS.UnityEngine.Rendering.OnDemandRendering==nil then
		return
	end
	if isLow then
		CS.UnityEngine.Rendering.OnDemandRendering.renderFrameInterval = 2
	else
		CS.UnityEngine.Rendering.OnDemandRendering.renderFrameInterval = 1
	end
	isLockUpdateDemanRendering = isLow
end

local hasToResetStartTime = false
local function ResetStartTime()
	hasToResetStartTime = true
end

local function Update()
	--local graphicLevel = Setting:GetPublicInt(SettingKeys.SCENE_GRAPHIC_LEVEL, EnumQualityLevel.Middle)
	--每帧GetPublicInt太耗了 缓存一下
	--local graphicLevel = RenderSetting.curGraphicLevel
--	if graphicLevel==EnumQualityLevel.High then
		--if _rainDropToggle then
			--local diffTime1 = CS.UnityEngine.Time.realtimeSinceStartup-startDropTime
			--if diffTime1>=0 and diffTime1<10 then
				--RenderSetting.ToggleRainDropRenderFeatureTick(true)
			--elseif diffTime1>=10 and diffTime1<240 then
				--RenderSetting.ToggleRainDropRenderFeatureTick(false)
			--else
				--startDropTime = CS.UnityEngine.Time.realtimeSinceStartup
			--end
	    --else
			--RenderSetting.ToggleRainDropRenderFeatureTick(false)
		--end
	--end
	
	--
	--if CS.UnityEngine.Rendering.OnDemandRendering==nil then
	--	return
	--end
	if hasToResetStartTime or CS.UnityEngine.Input.GetMouseButton(0) or CS.UnityEngine.Input.touchCount>0 then
		startTime = CS.UnityEngine.Time.realtimeSinceStartup
		hasToResetStartTime = false
		--RenderSetting.ToggleRadialBlurRenderFeature(false)
	else
		local diffTime = CS.UnityEngine.Time.realtimeSinceStartup-startTime
		if diffTime>=90 and diffTime<300 then
			--RenderSetting.ToggleRadialBlurRenderFeature(true)
			RenderSetting.SesetRenderFrameInterval(2)
		elseif diffTime>=300 then
			RenderSetting.SesetRenderFrameInterval(4)
		else
			RenderSetting.SesetRenderFrameInterval(1)
		end
	end

	-- 每帧调用,设置中高端机型渲染帧为30，当有输入事件的时候，恢复到原本的帧率
	--if _gameQulity>1 then
	--	if CS.UnityEngine.Input.GetMouseButton(0) or CS.UnityEngine.Input.touchCount>0 then
	--CS.UnityEngine.Rendering.OnDemandRendering.renderFrameInterval = 1
	--else
	--CS.UnityEngine.Rendering.OnDemandRendering.renderFrameInterval = 2
	--end

	--end
	--判断是否存在
	--if CS.UnityEngine.Rendering.OnDemandRendering~=nil then
	--
	--end
end

RenderSetting.ResetStartTime = ResetStartTime
RenderSetting.SesetRenderFrameInterval = SesetRenderFrameInterval
RenderSetting.RemoveUpdater = RemoveUpdater
RenderSetting.AddUpdater = AddUpdater
RenderSetting.Update = Update
RenderSetting.ToggleLoworHightFrame = ToggleLoworHightFrame
RenderSetting.SetDefaultLayerCulling = SetDefaultLayerCulling
RenderSetting.SetLevelLayerCulling = SetLevelLayerCulling
RenderSetting.InitRender=InitRender
RenderSetting.ToggleBlur=ToggleBlur
RenderSetting.InitQulity = InitQulity
RenderSetting.GetQulity = GetQulity
RenderSetting.ToggleDepthTexture =ToggleDepthTexture
RenderSetting.SetShadowDistance =SetShadowDistance
RenderSetting.GetShadowDistance =GetShadowDistance
RenderSetting.SetSupportsMainLightShadows = SetSupportsMainLightShadows
RenderSetting.DumpSphericalHarmonicsL2 = DumpSphericalHarmonicsL2
RenderSetting.SetHDR = SetHDR
RenderSetting.SettingHeightFog =SettingHeightFog
RenderSetting.SetHeightFogVisible = SetHeightFogVisible
RenderSetting.SettingFur = SettingFur
RenderSetting.SetUP=SetUP
RenderSetting.UpateScale = UpateScale
RenderSetting.ToggleFurRenderFeature=ToggleFurRenderFeature
RenderSetting.IsToggleDepthTexture = IsToggleDepthTexture
RenderSetting.HeightFogIsOpen =HeightFogIsOpen
RenderSetting.ToggleCopyDepth = ToggleCopyDepth
RenderSetting.ToggleTaaRenderFeature = ToggleTaaRenderFeature
RenderSetting.ToggleMosaicRenderPassFeature = ToggleMosaicRenderPassFeature
RenderSetting.ToggleAdditionLightShadow = ToggleAdditionLightShadow
RenderSetting.ToggleTiltShift =ToggleTiltShift
RenderSetting.SetShadowReslution =SetShadowReslution
RenderSetting.SetQualityLevel = SetQualityLevel
RenderSetting.SetGameDefaultLevel=SetGameDefaultLevel
RenderSetting.ToggleRadialBlurRenderFeature = ToggleRadialBlurRenderFeature
RenderSetting.InitLightAtten = InitLightAtten
RenderSetting.ToggleRainDropRenderFeature = ToggleRainDropRenderFeature
RenderSetting.ToggleRainDropRenderFeatureTick = ToggleRainDropRenderFeatureTick
RenderSetting.InitPlaneShadow = InitPlaneShadow
RenderSetting.TogglePlaneShadowRenderFeature = TogglePlaneShadowRenderFeature
RenderSetting.ToggleSSAORenderFeature = ToggleSSAORenderFeature
RenderSetting.SetRenderFeatureState = SetRenderFeatureState
RenderSetting.ToggleOutlineRenderFeature = ToggleOutlineRenderFeature
RenderSetting.ToggleCameraOpaqueTexture = ToggleCameraOpaqueTexture
return RenderSetting