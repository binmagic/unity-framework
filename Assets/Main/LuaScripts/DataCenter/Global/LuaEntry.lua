--[[
-- [INPUT]: （当前为简化桩）后续将依赖各核心数据子模块的 New；由框架在启动/前后台切换时驱动
-- [OUTPUT]: 对外提供 LuaEntry 表，暴露 Init/Uninit/OnApplicationPause 生命周期钩子及 Player/Resource/Network 等核心数据字段
-- [POS]: DataCenter 模块的核心数据入口（类似 C# GameEntry.Data），持有最高频的玩家/资源/网络数据；冒号方法风格单例，与 DataCenter 并列。连连看简化流程下暂为存根
-- [PROTOCOL]: 变更时更新此头部,然后检查 CLAUDE.md
--]]

--[[
    LuaEntry - Lua端全局数据入口
    游戏启动时初始化，管理核心子模块的生命周期

    后续开发时按需添加子模块，例如：
        self.Player    -- 玩家信息
        self.Resource  -- 资源数据
        self.GlobalData -- 全局数据
        self.Network   -- 网络管理
]]

local PlayerInfo = require "DataCenter.Global.PlayerInfo"
local DataConfig = require "DataCenter.Global.DataConfig"


local LuaEntry = {}

-- 初始化
function LuaEntry:Init()
    self.Player = PlayerInfo.New()
    -- TODO: 后续开发时初始化其它子模块
    -- self.Resource = xxx.New()
    -- self.Network = xxx.New()

    -- 模块启动
    UIManager:GetInstance():Startup()
    LuaEntry:LoadDataConfig()
    
end

-- 销毁
function LuaEntry:Uninit()
    if self.Player then
        self.Player:Delete()
        self.Player = nil
    end
    -- TODO: 后续开发时销毁其它子模块
end

-- 进入后台
function LuaEntry:OnApplicationPause(pause)
    -- TODO: 后续开发时处理前后台切换
end

-- 从服务器登录数据填充
function LuaEntry:onMessage(data)


    -- 在这里初始化一下声音
    SoundUtil.InitSound()
end

-- 从本地配置表填充
function LuaEntry:LoadDataConfig()
    self.DataConfig = DataConfig.New()
    self.DataConfig:InitFromTable()

    -- 在这里初始化一下声音
    SoundUtil.InitSound()
end

return LuaEntry
