--[[
-- MockServer - 单机模式下的模拟服务器
-- 提供 push_init 等服务器消息的模拟数据
-- 仅用于无服务器的本地开发/测试环境
--]]

local MockServer = {}

--- 生成模拟的 push_init 数据（对应服务器 push_init 消息包）
--- @return table 模拟的服务器数据
function MockServer.GeneratePushInitData()
    local data = {}

    -- 玩家基础信息
    data.player = {
        uid = "local_test_001",
        name = "测试玩家",
        level = 1,
        exp = 0,
        avatar = 1,
        vipLevel = 0,
        createTime = os.time(),
    }

    -- 资源数据
    data.resource = {
        gold = 10000,
        diamond = 500,
        wood = 5000,
        stone = 5000,
        food = 5000,
    }

    -- 全局数据
    data.globalData = {
        serverTime = os.time(),
        serverId = 1,
        serverName = "本地测试服",
        isOpen = true,
    }

    -- 配置数据
    data.config = {}

    -- 特效/道具数据
    data.effect = {}

    return data
end

--- 模拟 push_init 完整流程
--- 对应 InitMessage.HandleMessage() 的逻辑
function MockServer.SimulatePushInit()
    Logger.Log("[MockServer] SimulatePushInit")

    -- 1. 生成模拟数据
    local data = MockServer.GeneratePushInitData()

    -- 2. 调用 LuaEntry:onMessage（填充 Player/Resource/Effect 等）
    if LuaEntry and LuaEntry.onMessage then
        LuaEntry:onMessage(data)
    end

    -- 3. 广播 PUSH_INIT_OK（通知状态机继续）
    EventManager:GetInstance():Broadcast(EventId.PUSH_INIT_OK, data)
end

return MockServer
