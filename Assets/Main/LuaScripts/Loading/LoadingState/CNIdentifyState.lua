
local LoadingStateBase = require("Loading.LoadingState.LoadingStateBase")
local CNIdentifyState = BaseClass("AuthPinState", LoadingStateBase)

function CNIdentifyState:__init(startupLoading)
	LoadingStateBase:__init(startupLoading)
end

function CNIdentifyState:OnEnter(args)
	--self._startupLoading.IsPushInitReceived = false;
    --self:ShowAuthUI()
end

function CNIdentifyState:OnExit()

end

function CNIdentifyState:OnUpdate()

end

function CNIdentifyState:ShowAuthUI()
	--if (LuaEntry.GlobalData.IsChild) then
	--	UIManager:GetInstance():OpenWindow("UIIDCardAgeTips")
	--else
	--	UIManager:GetInstance():OpenWindow("UIIDCardAuthenticate")
	--end
end

return CNIdentifyState