--[[
-- added by wsh @ 2017-11-30
-- 1、加载全局模块，所有全局性的东西都在这里加载，好集中管理
-- 2、模块定义时一律用local再return，模块是否是全局模块由本脚本决定，在本脚本加载的一律为全局模块
-- 3、对必要模块执行初始化
-- 注意：
-- 1、全局的模块和被全局模块持有的引用无法GC，除非显式设置为nil
-- 2、除了单例类、通用的工具类、逻辑上的静态类以外，所有逻辑模块不要暴露到全局命名空间
-- 3、Unity侧导出所有接口到CS命名空间，访问cs侧函数一律使用CS.xxx，命名空间再cs代码中给了，这里不需要处理
-- 4、这里的全局模块是相对与游戏框架或者逻辑而言，lua语言层次的全局模块放Common.Main中导出
--]]

-- 加载全局模块
require "Framework.Common.BaseClass"
require "Framework.Common.DataClass"
require "Framework.Common.ConstClass"
require "Framework.LuaMono.MonoClass"

App = require "Global.App"
Setting = require 'Global.SettingManager'

-- 创建全局模块
Config = require "Global.Config"
StringLookupTable = require "Global.StringLookupTable"
_ToID = StringLookupTable.Get

Singleton = require "Framework.Common.Singleton"

LocalController = require "Common.LocalController"
Logger = require "Framework.Logger.Logger"
PostEventLog = require "Framework.Logger.PostEventLog"
FireBaseLog = require "Framework.Logger.FireBaseLog"
EventId = require "Framework.UI.Message.EventId"
EventManager = require "Framework.UI.Message.EventManager"

UITimeManager = require "Framework.UI.Time.UITimeManager"
Hex = require "Util.Hex"
ListenerHandler = require 'Global.ListenerHandler'
SingletonListenerHandler = require 'Global.SingletonListenerHandler'
LuaWebRequest = require 'Global.LuaWebRequest'
require "Global.UnityUtils"

-- DOTween 全局别名（C# 已通过 XLua 导出，见 GenConfig；框架多处以裸全局方式使用）
DOTween = CS.DG.Tweening.DOTween
Ease = CS.DG.Tweening.Ease

-- game data
NameCount = 0
DataCenter = require "DataCenter.DataCenter"
RenderSetting =require "Framework.Render.RenderSetting"

-- LUA全局数据
LuaEntry = require "DataCenter.Global.LuaEntry"
AppStartupLoading = require "Loading.AppStartupLoading"

-- util 类
CommonUtil = require "Util.CommonUtil"
UIStrCache = require "Util.UIStrCache"
UIUtil = require "Util.UIUtil"
---@type SUSoundUtil
SoundUtil = require "Util.SoundUtil"

-- ui base
PathUtil = require "Framework.Common.PathUtil"
UIBaseCtrl = require "Framework.UI.Base.UIBaseCtrl"
UIBaseComponent = require "Framework.UI.Base.UIBaseComponent"
UIBaseContainer = require "Framework.UI.Base.UIBaseContainer"
UIBaseView = require "Framework.UI.Base.UIBaseView"

-- ui component
UILayerComponent = require "Framework.UI.Component.UILayerComponent"
UICanvas = require "Framework.UI.Component.UICanvas"
UITextMeshProUGUI = require "Framework.UI.Component.UITextMeshProUGUI"
UITextMeshProUGUIEx = require "Framework.UI.Component.UITextMeshProUGUIEx"

UIText = require "Framework.UI.Component.UIText"
UIOutline = require "Framework.UI.Component.UIOutline"
UITweenNumberText = require "Framework.UI.Component.UITweenNumberText"
UINewText = require "Framework.UI.Component.UINewText"
UINewTMPText = require "Framework.UI.Component.UINewTMPText"
UIImage = require "Framework.UI.Component.UIImage"
UIRawImage = require "Framework.UI.Component.UIRawImage"
UISlider = require "Framework.UI.Component.UISlider"
UIInput = require "Framework.UI.Component.UIInput"
UIButton = require "Framework.UI.Component.UIButton"
UIButton_LongPress = require "Framework.UI.ComponentExt.UIButton_LongPress"
UIToggle = require "Framework.UI.Component.UIToggle"
UIUnlimitedScrollView = require "Framework.UI.Component.UIUnlimitedScrollView"
UIAnimator = require "Framework.UI.Component.UIAnimator"
UISimpleAnimation = require "Framework.UI.Component.UISimpleAnimation"
UIScrollRect = require "Framework.UI.Component.UIScrollRect"
UIEventTrigger = require "Framework.UI.Component.UIEventTrigger"
UIScrollView = require "Framework.UI.Component.UIScrollView"
UIScrollViewEx = require "Framework.UI.Component.UIScrollViewEx"
UIHorizontalOrVerticalLayoutGroup = require "Framework.UI.Component.UIHorizontalOrVerticalLayoutGroup"
UICanvasGroup = require "Framework.UI.Component.UICanvasGroup"
UIShadow = require "Framework.UI.Component.UIShadow"
UIDropdown = require "Framework.UI.Component.UIDropdown"
UITMPDropdown = require "Framework.UI.Component.UITMPDropdown"
UILayoutElement = require "Framework.UI.Component.UILayoutElement"
UILoopListView2 = require "Framework.UI.Component.UILoopListView2"
UIScrollViewExclusive = require "Framework.UI.Component.UIScrollViewExclusive"
HorizontalInfinityScrollView = require "Framework.UI.Component.HorizontalInfinityScrollView"
GridInfinityScrollView = require "Framework.UI.Component.GridInfinityScrollView"
UIScrollPage = require "Framework.UI.Component.UIScrollPage"
UISpine = require "Framework.UI.Component.UISpine"
UITMPInput = require "Framework.UI.Component.UITMPInput"

require "Global.EnumType"

UIWindowNames = require "UI.Config.UIWindowNames"
UIConfig = require "UI.Config.UIConfig"


-- ui window
UILayer = require "Framework.UI.UILayer"
UIWindow = require "Framework.UI.UIWindow"
UIManager = require "Framework.UI.UIManager"

-- update & time
Timer = require "Framework.Updater.Timer"
TimerManager = require "Framework.Updater.TimerManager"
UpdateManager = require "Framework.Updater.UpdateManager"
TimeUpEventId = require "Framework.Updater.TimeUpEventId"
TimeUpManager = require "Framework.Updater.TimeUpManager"

-- net core
MsgDefines = require "Net.Config.MsgDefines"
SFSBaseMessage = require "Net.SFSBaseMessage"
SFSNetwork = require "Net.SFSNetwork"
SFSObject = require "Common.Data.SFSObject"
SFSArray = require "Common.Data.SFSArray"

PosConverse = require "Common.PosConverse"
ApsRandom = require "Common.ApsRandom"
StringPool = require "Common.StringPool"
ObjectPool = require "Common.ObjectPool"
UITimeManager = require "Framework.UI.Time.UITimeManager"
RenderSetting = require "Framework.Render.RenderSetting"

--just for debug
function get_mem_addr (o)
    return tostring(o):sub(type(o):len() + 3)
end

--zlh: 检查是否有对应的csharp class存在 直接用CS.ClassN 返回的并不是nil
function HasCsClass(className)
    if string.IsNullOrEmpty(className) then
        return false
    end

    local assemblies = CS.System.AppDomain.CurrentDomain:GetAssemblies()
    for i = 0, assemblies.Length - 1 do
        local types = assemblies[i]:GetTypes()
        for j = 0, types.Length - 1 do
            if types[j].FullName == className then
                return true
            end
        end
    end

    return false
end

--这里临时做一个版本兼容的类型检查 由于检查比较耗 只在启动时获取一次
HasCSClassMap = {
    AudioMixerSnapshot = HasCsClass("UnityEngine.Audio.AudioMixerSnapshot"),
    LoopListViewInitParam= HasCsClass("SuperScrollView.LoopListViewInitParam"),
    ByPassCertificate = HasCsClass("BypassCertificate")
}
