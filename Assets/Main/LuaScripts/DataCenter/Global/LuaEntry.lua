--[[
    LuaEntry - Lua端全局数据入口
    游戏启动时初始化，管理核心子模块的生命周期

    后续开发时按需添加子模块，例如：
        self.Player    -- 玩家信息
        self.Resource  -- 资源数据
        self.GlobalData -- 全局数据
        self.Network   -- 网络管理
]]

local LuaEntry = {}

-- 初始化
function LuaEntry:Init()
    -- TODO: 后续开发时初始化子模块
    -- self.Player = xxx.New()
    -- self.Resource = xxx.New()
    -- self.Network = xxx.New()
end

-- 销毁
function LuaEntry:Uninit()
    -- TODO: 后续开发时销毁子模块
end

-- 进入后台
function LuaEntry:OnApplicationPause(pause)
    -- TODO: 后续开发时处理前后台切换
end

return LuaEntry
