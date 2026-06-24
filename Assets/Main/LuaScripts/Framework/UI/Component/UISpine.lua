--[[
-- UISpine组件：
-- 用于处理Spine动画的灰度和冻结状态
-- 功能：
-- 1. SetGray：设置Spine动画的灰度状态
-- 2. SetFreeze：设置Spine动画的冻结状态
-- 注意!!!:Spine有个问题,过早设置Freeze会导致数组越界错误,所以写了监听事件,再设置Freeze,很绕但是有必要.
--]]
---@class UISpine
local UISpine = BaseClass("UISpine", UIBaseComponent)
local base = UIBaseComponent

-- 静态变量，用于缓存灰度材质，避免重复创建
UISpine.grayMaterial = nil
-- 灰色材质路径
local GRAY_MATERIAL_PATH = "Assets/Main/Material/SkeletonGraphic_CustomGray.mat"

-- 检查C#对象是否有效（未被销毁）
local function IsValidGameObject(obj)
    -- 检查对象是否为nil
    if obj == nil then
        return false
    end

    -- 检查gameObject是否为nil
    if obj.gameObject == nil then
        return false
    end

    -- 检查对象是否已被销毁
    -- Unity中，被销毁的对象引用不会立即变为nil，但可以通过Equals(nil)检测
    if obj.gameObject:Equals(nil) then
        return false
    end

    return true
end

-- 添加动画完成事件的成功回调
local function OnAddAnimationEventSuccess(self)
    -- 添加动画完成事件
    self.instructionsPreparedDelegate = function(x)
        self:OnPrepared()
    end
    -- 将 Lua 函数转换为正确类型的委托
    cast(self.instructionsPreparedDelegate, typeof(CS.Spine.Unity.SkeletonGraphic.InstructionDelegate))
    self.skeletonGraphic:OnInstructionsPrepared('+', self.instructionsPreparedDelegate)
end

-- 添加动画完成事件的失败回调
local function OnAddAnimationEventFailed(self, err)
    Logger.LogError("[UISpine] Add animation complete event error: " .. err)
    -- 如果添加事件失败，直接标记为初始化完成
    self.initializeComplete = true
    -- 应用挂起的状态
    self:ApplyPendingStates()
end

-- 移除动画完成事件的成功回调
local function OnRemoveAnimationEventSuccess(self)
    if IsValidGameObject(self.skeletonGraphic) and self.instructionsPreparedDelegate then
        self.skeletonGraphic:OnInstructionsPrepared('-', self.instructionsPreparedDelegate)
        self.instructionsPreparedDelegate = nil
    end
end

-- 移除动画完成事件的失败回调
local function OnRemoveAnimationEventFailed(self, err)
    Logger.LogError("[UISpine] Remove animation complete event error: " .. err)
end

-- 创建
function UISpine:OnCreate()
    base.OnCreate(self)
    -- 初始化变量
    self.initializeComplete = false

    -- 记录请求的状态和当前应用的状态
    self.pendingGray = false
    self.currentGray = false
    self.pendingFreeze = false
    self.currentFreeze = false

    -- 对外暴露的状态
    self.isGray = false
    self.isFreeze = false

    -- 获取SkeletonGraphic组件
    self.skeletonGraphic = self.gameObject:GetComponent(typeof(CS.Spine.Unity.SkeletonGraphic))
    --if not self.skeletonGraphic then
    --    self.skeletonGraphic = self.gameObject:GetComponentInChildren(typeof(CS.Spine.Unity.SkeletonGraphic))
    --end
    if not self.skeletonGraphic then
        Logger.LogError("[UISpine] GameObject(" ..
                self.gameObject.name .. ") cannot find SkeletonGraphic component in itself")
        return
    end

    -- 缓存原始材质
    self.originalMaterial = self.skeletonGraphic.material

    -- 添加动画完成事件监听
    if IsValidGameObject(self.skeletonGraphic) and self.skeletonGraphic.AnimationState then
        -- 使用xpcall避免可能的错误
        xpcall(function()
            OnAddAnimationEventSuccess(self)
        end,
                function(err)
                    OnAddAnimationEventFailed(self, err)
                end)
    else
        -- 如果没有AnimationState，直接标记为初始化完成
        self.initializeComplete = true
    end
end

-- 应用挂起的状态
function UISpine:ApplyPendingStates()
    -- 应用灰度状态
    if self.pendingGray ~= self.currentGray then
        self:ApplyGrayState(self.pendingGray)
    end

    -- 应用冻结状态
    if self.pendingFreeze ~= self.currentFreeze then
        self:ApplyFreezeState(self.pendingFreeze)
    end
end

-- 动画完成回调
function UISpine:OnPrepared()
    self.initializeComplete = true
    -- 应用挂起的状态
    self:ApplyPendingStates()
end

-- 实际应用灰度状态
function UISpine:ApplyGrayState(isGray)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    self.currentGray = isGray
    if isGray then
        -- 懒加载灰度材质
        if not UISpine.grayMaterial then
            local loadMaterial = CS.GameEntry.Resource:LoadAsset(GRAY_MATERIAL_PATH, typeof(CS.UnityEngine.Material))
            if loadMaterial and loadMaterial.asset then
                UISpine.grayMaterial = loadMaterial.asset
                -- 设置材质不随场景销毁
                CS.UnityEngine.Object.DontDestroyOnLoad(UISpine.grayMaterial)
            else
                Logger.LogError("[UISpine] Cannot load gray material from path: " .. GRAY_MATERIAL_PATH)
                return
            end
        end

        -- 应用灰度材质
        self.skeletonGraphic.material = UISpine.grayMaterial
    else
        -- 恢复原始材质
        self.skeletonGraphic.material = self.originalMaterial
    end
end

-- 实际应用冻结状态
function UISpine:ApplyFreezeState(isFreeze)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end
    self.currentFreeze = isFreeze
    if isFreeze then
        self.skeletonGraphic.freeze = true
    else
        -- 恢复动画
        self.skeletonGraphic.freeze = false
    end
end

-- 销毁
function UISpine:OnDestroy()
    xpcall(function()
        self:SetColor(Color.white)
        self:SetGray(false)
        self:SetFreeze(false)
    end, function(err)
        Logger.LogError("[UISpine] OnDestroy error: " .. err)
    end)

    -- 移除事件监听
    xpcall(function()
        OnRemoveAnimationEventSuccess(self)
    end,
            function(err)
                OnRemoveAnimationEventFailed(self, err)
            end)

    self.skeletonGraphic = nil
    self.originalMaterial = nil
    
    base.OnDestroy(self)
end

-- 设置灰度状态
function UISpine:SetGray(isGray)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    -- 更新对外暴露的状态
    self.isGray = isGray

    -- 如果请求的状态没变，直接返回
    if self.pendingGray == isGray then
        return
    end

    -- 记录请求的状态
    self.pendingGray = isGray

    -- 如果尚未初始化完成，记录请求并返回
    if not self.initializeComplete then
        return
    end

    -- 直接应用灰度状态
    self:ApplyGrayState(isGray)
end

-- 设置颜色
function UISpine:SetColor(color)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end
    self.color = color
    self.skeletonGraphic.color=color
end

-- 设置冻结状态
function UISpine:SetFreeze(isFreeze)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    -- 更新对外暴露的状态
    self.isFreeze = isFreeze

    -- 如果请求的状态没变，直接返回
    if self.pendingFreeze == isFreeze then
        return
    end

    -- 记录请求的状态
    self.pendingFreeze = isFreeze

    -- 如果尚未初始化完成，记录请求并返回
    if not self.initializeComplete then
        return
    end

    -- 直接应用冻结状态
    self:ApplyFreezeState(isFreeze)
end

-- 获取当前灰度状态
function UISpine:IsGray()
    return self.isGray
end

-- 获取当前冻结状态
function UISpine:IsFreeze()
    return self.isFreeze
end

-- 获取初始化状态
function UISpine:IsInitialized()
    return self.initializeComplete
end

function UISpine:SetAnimation(trackIndex, animation, loop)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    self.skeletonGraphic.AnimationState:SetAnimation(trackIndex, animation, loop)
end

function UISpine:AddAnimation(trackIndex, animation, loop, delay)
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    self.skeletonGraphic.AnimationState:AddAnimation(trackIndex, animation, loop, delay)
end

function UISpine:ClearTracks()
    if not IsValidGameObject(self.skeletonGraphic) then
        return
    end

    self.skeletonGraphic.AnimationState:ClearTracks()
end

return UISpine
