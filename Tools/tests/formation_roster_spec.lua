-- 独立内存存档验证，不读取或改动玩家存档。可在项目 Lua 环境中 dofile 执行。
local saved = {}
local heroes = {}
function heroes:IsHeroOwned(id) return id == 1001 or id == 1002 or id == 1004 end
function heroes:GetDeployedHeroId() return 1001 end
function heroes:GetHeroLevel() return 1 end
function heroes:GetHeroConfig(id)
    return { id = id, name = tostring(id), role = id == 1004 and "Support" or "Output" }
end
local env = setmetatable({
    BaseClass = function() return {} end,
    Singleton = {},
    DataCenter = { HeroDataManager = heroes },
    Setting = {
        GetPrivateInt = function(_, key, default)
            if saved[key] == nil then return default end
            return saved[key]
        end,
        SetPrivateInt = function(_, key, value) saved[key] = value end,
    },
}, { __index = _G })
local path = "Assets/Main/LuaScripts/DataCenter/PlaneBattle/PlaneBattleDataManager.lua"
local function newManager() return assert(loadfile(path, "t", env))() end
local m = newManager()
local Profile = require "UI.UIPlaneBattle.Logic.BattleHeroProfile"
local function expect(a, b)
    for i = 1, 5 do assert(a[i] == b[i], "slot " .. i .. ": " .. tostring(a[i])) end
end

-- 新玩家仍有默认主机；第一次保存后，空主位必须保持空位。
expect(m:GetFormation(), {1001,0,0,0,0})
assert(m:SetFormationSlot(2,1002))
assert(m:SetFormationSlot(1,0))
expect(m:GetFormation(), {0,1002,0,0,0})
m = newManager() -- 模拟重新加载页面/重启后读取同一份存档。
expect(m:GetFormation(), {0,1002,0,0,0})
local team = Profile.BuildFormation(m:GetFormation(), heroes)
assert(#team.members == 1 and team.members[1].slot == 2 and team.leader.id == nil)

-- 护航可移入空主位；主机也可移到空护航位，避免只能替换。
assert(m:SetFormationSlot(1,1002))
expect(m:GetFormation(), {1002,0,0,0,0})
assert(m:SetFormationSlot(3,1002))
expect(m:GetFormation(), {0,0,1002,0,0})
assert(m:SetFormationSlot(1,1001))
assert(m:SetFormationSlot(3,1001))
expect(m:GetFormation(), {1002,0,1001,0,0})
team = Profile.BuildFormation(m:GetFormation(), heroes)
assert(team.leader.id == 1002 and team.leader.aircraft.sprite:find("1002"))

-- 全部下阵后重读也不能自动补人；重新上阵后正常恢复编队。
assert(m:SetFormationSlot(1,0))
assert(m:SetFormationSlot(3,0))
expect(newManager():GetFormation(), {0,0,0,0,0})
assert(m:SetFormationSlot(1,1004))
assert(Profile.BuildFormation(m:GetFormation(), heroes).leader.id == 1004)
assert(not m:SetFormationSlot(0,1001))
assert(not m:SetFormationSlot(6,1001))
assert(not m:SetFormationSlot(1,9999))
expect(m:GetFormation(), {1004,0,0,0,0})
print("PASS: main removal, persisted empty slots, move/swap, leader identity, reassign, validation")
