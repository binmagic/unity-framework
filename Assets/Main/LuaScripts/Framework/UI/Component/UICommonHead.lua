---
--- 通用头像组件（可以显示玩家头像、丧尸头像、城市头像或其他什么玩意）
---
---@class UICommonHead : UIBaseContainer
local UICommonHead = BaseClass("UICommonHead", UIBaseContainer)
local base = UIBaseContainer

local DefaultUserHead = "Assets/Main/Sprites/UI/UIHeadIcon/player_head_2.png"
local CACHE_FOLDER = "LocalImages";
local closeLoadingTime = 10 --10秒内没加载出来头像就干掉加载动画

function UICommonHead:ComponentDefine()
    local head = self.transform:Find("HeadIcon")
    local loading = self.transform:Find("Imgloading")
    if loading then
        self.loading_img =  self:AddComponent(UIImage, "Imgloading")
        self.loading_img:SetActive(false)
    end
    self.uiPlayerHead = head:GetComponent(typeof(CS.UIPlayerHead))
    self.circleImage = head:GetComponent(typeof(CS.CircleImage))
    self.frameBg = self:AddComponent(UIImage, "Foreground")
    self.headBtn = self:AddComponent(UIButton, '') -- 根节点是个按钮组件
    self.headBtn:SetOnClick(function ()
        self:OnHeadClick()
    end)
    self.countryFlag = self:AddComponent(UIImage, "countryFlag")
end
function UICommonHead:ComponentDestroy()
    self.uiPlayerHead:SetCustomLoadCallback(nil)
    self.uiPlayerHead = nil
    self.circleImage = nil
    self.frameBg = nil
    self.headBtn = nil
    self.countryFlag = nil
end
function UICommonHead:DataDefine()
end
function UICommonHead:DataDestroy()
    self.playerUid = nil
    self.picVer = nil
    self.pic = nil
    if not IsNull(self.loading_img) then
        self:HideLoadingAinmation()
    end
end

function UICommonHead:GetIsSystemHead()
    if not self.picVer then
        self.picVer = 0
    end
    return not string.IsNullOrEmpty(self.pic) or self.picVer <= 0 or self.picVer > 1000000
end

function UICommonHead:ShowLoadingAinmation()
    if not IsNull(self.loading_img) then
        self.loading_img:SetActive(true)
        if self.closeLoadingAction then
            self.closeLoadingAction:Stop()
            self.closeLoadingAction = nil
        else
            self.closeLoadingAction = TimerManager:GetInstance():DelayInvoke(function()
                if not IsNull(self.loading_img) then
                    self.loading_img:SetActive(false)
                end
            end,closeLoadingTime)
        end
    end
end

function UICommonHead:HideLoadingAinmation()
    if self.closeLoadingAction then
        self.closeLoadingAction:Stop()
        self.closeLoadingAction = nil
    end
    if not IsNull(self.loading_img) then
        self.loading_img:SetActive(false)
    end
end


function UICommonHead:OnDestroy()
    self:ComponentDestroy()
    self:DataDestroy()
    base.OnDestroy(self)
    self.__loadHeadCallback = nil
end

function UICommonHead:OnCreate()
    base.OnCreate(self)
    self:DataDefine()
    self:ComponentDefine()
end

-- 打开
function UICommonHead:OnEnable()
    base.OnEnable(self)
end

-- 关闭
function UICommonHead:OnDisable()
    base.OnDisable(self)
end

function UICommonHead:OnAddListener()
end

function UICommonHead:OnRemoveListener()
end

---对外接口：显示头像
function UICommonHead:SetHead(uid,pic,picVer,useBig,headFramePath)
    if useBig == nil then
        useBig = false
    end
    self.playerUid = uid
    self.picVer = picVer
    self.pic = pic
    if uid then--有uid，显示玩家头像
        local specifiedRes = nil
        if pic and pic ~= '' and type(pic) == 'string' then
            local pic1, pic2 = string.match(pic, "(Assets/Main/.*)(Assets/Main/.*)")
            if pic1 and pic2 then
                specifiedRes = pic2
            end
        end
        if specifiedRes then
            --self.uiPlayerHead:UseSpecifiedRes(specifiedRes)
            self.uiPlayerHead:UseSystemHead()
        elseif not pic and not picVer then
            self.uiPlayerHead:UseSystemHead()
        else
            self.uiPlayerHead:SetData(uid, pic, tonumber(picVer), useBig)
        end
    elseif pic and pic ~= '' then--没有uid，显示其他头像
        --self.uiPlayerHead:UseSpecifiedRes(pic)
        self.uiPlayerHead:UseSystemHead()
        self:HideLoadingAinmation()
    else
        self.uiPlayerHead:UseSystemHead()
        self:HideLoadingAinmation()
    end
    if not string.IsNullOrEmpty(headFramePath) then
        self.frameBg:LoadSprite(headFramePath)
    else
        --self.frameBg:LoadSprite(DefaultHeadFramePath)
    end
    -- 兼容以前prefab
    self.countryFlag:SetActive(false)
end

-- 显示自己的头像，让外面的使用者简单点
function UICommonHead:SetAsMyself()
    local player = LuaEntry.Player
    local userPic = player:GetPic() or ""
    local userPicVer = player.picVer or 0
    self:SetData(player:GetUid(), userPic, userPicVer, nil, player:GetHeadBgImg())
end

---对外接口：显示头像
function UICommonHead:SetData(uid,pic,picVer,useBig,headFramePath)
    self:SetHead(uid,pic,picVer,useBig,headFramePath)
end

---对外接口：显示头像和头像框
function UICommonHead:SetHeadAndFrame(uid,pic,picVer,useBig,headSkinId,headSkinET)
    local headBgImg = DataCenter.DecorationDataManager:GetHeadFrame(headSkinId,headSkinET)
    self:SetHead(uid,pic,picVer,useBig,headBgImg)
end

---对外接口：切换方圆
function UICommonHead:SetIsCircle(isCircle)
    self.circleImage.isCircle = isCircle
end

---status = true:点击后打开玩家详情ui
---notHideTop = true:打开玩家详情ui时不隐藏上一个ui
function UICommonHead:SetEnableClickShowInfo(status, notHideTop)
    self.enableClickShowInfo = (status == true)
    self.hideTopWhenClick = (notHideTop ~= true)
end

function UICommonHead:OnHeadClick()
    if self.enableClickShowInfo == true and self.playerUid ~= nil then
        if self.playerUid == LuaEntry.Player.uid then
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIPlayerInfo) then
                UIManager:GetInstance():DestroyWindow(UIWindowNames.UIPlayerInfo)
            end
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIPlayerInfo, {anim = true, hideTop = self.hideTopWhenClick}, self.playerUid)
        else
            if UIManager:GetInstance():IsWindowOpen(UIWindowNames.UIOtherPlayerInfo) then
                UIManager:GetInstance():DestroyWindow(UIWindowNames.UIOtherPlayerInfo)
            end
            UIManager:GetInstance():OpenWindow(UIWindowNames.UIOtherPlayerInfo,{ anim = true, hideTop = false }, self.playerUid)
        end
    end
end

function UICommonHead:SetFlag(country)
    --if LuaEntry.Player:IsFromBIGCHINAorUsingLangZH() then
        self.countryFlag:SetActive(false)
        --return
    --end

	--[[
    local _country = string.IsNullOrEmpty(country) and DefaultNation or country
    local template = DataCenter.NationTemplateManager:GetNationTemplate(_country)
    if template == nil then
        self.countryFlag:SetActive(false)
    else
        if not LuaEntry.GlobalData:IsChina() then
            self.countryFlag:SetActive(true)
            self.countryFlag:LoadSprite(template:GetNationFlagPath())
        else
            self.countryFlag:SetActive(false)
        end
    end
	]]
end

function UICommonHead:ParseHeadInfo(cfg)
	--[[
    if cfg then
        if cfg.isActiveAnonymity then--伪装者
            self:SetHead("-1")
        else
            local headBgImg = cfg.frameBg
            if headBgImg == nil and cfg.headSkinId then
                headBgImg = DataCenter.DecorationDataManager:GetHeadFrame(cfg.headSkinId, cfg.headSkinET)
            end
            if headBgImg == nil and cfg.tHeadSkinId then
                headBgImg = DataCenter.DecorationDataManager:GetHeadFrame(cfg.tHeadSkinId, cfg.tHeadSkinET)
            end
            self:SetHead(cfg.uid or cfg.ownerUid or cfg.Uid or cfg.tUid
                , cfg.pic or cfg.headPic or cfg.tPic or ''
                , cfg.picVer or cfg.headPicVer or cfg.picver or cfg.tPicVer or 0
                ,nil, headBgImg)
        end
    end
	]]
end

function UICommonHead:SetCustomLoadCallback(callback)
    self.uiPlayerHead:SetCustomLoadCallback(callback)
end

return UICommonHead