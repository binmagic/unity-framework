--[[
-- 格子修饰器：细藤蔓(vine) — E02
-- 机制：包裹的元素无法选中；藤蔓格阻挡所有连线；相邻格发生消除 → 藤蔓断裂消失。
-- 美术：绿色藤蔓覆盖（当前无 vine.png，用占位图+绿色着色，见 onShow）。
--
-- 这是「格子修饰器框架」的第一个真实修饰器，加新修饰器（冰冻/石头/锁链…）仿此新建一个文件。
--]]

local LianLianModifier = require "Game.LianLian.Special.LianLianModifierRegistry"

-- 占位图：正式藤蔓美术出图后改这里
local VINE_SPRITE = "Assets/_Art_LianLian/ItemSprites/item_special/vine.png"  -- TODO: 换 vine.png

LianLianModifier.register({
    type = "vine",
    name = "藤蔓",
    icon = VINE_SPRITE,
    defaultState = true,   -- 开关型：true=有藤蔓

    -- 阻挡连线：藤蔓格（有牌或空格）都挡
    blocksPath = function(cell, state)
        return true
    end,

    -- 不可选中：被藤蔓包裹的牌不能选
    blocksSelect = function(cell, state)
        return true
    end,

    -- 相邻消除 → 藤蔓断裂（返回 nil 表示解除该修饰器）
    onNeighborCleared = function(mgr, layer, pos, state)
        return nil
    end,

    -- 显示：绿色藤蔓覆盖层（占位着色，换正式图后可去 tint）
    onShow = function(tile, state)
        if tile.ShowModifierSprite then
            tile:ShowModifierSprite(VINE_SPRITE, 0.2, 0.9, 0.2, 0.85)
        end
    end,
})

return true
