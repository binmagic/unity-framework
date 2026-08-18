--[[
-- [INPUT]: 依赖 LianLianModifierRegistry 的 register 自注册；表现依赖 TileItem 的
--          ShowModifierSprite（静态显示）/ PlayModifierEnter（入场）/ PlayModifierShatter（震碎）
-- [OUTPUT]: 向注册表注册 type="ice" 的薄冰修饰器 def（机制 + 生死过场）
-- [POS]: Modifiers 下的一枚具体修饰器，与 Vine 同构；机制相同、表现不同，
--        是「加元素=一个文件」的示范：冰额外实现 onEnter/onRemove 做冻结/震碎
-- [PROTOCOL]: 变更时更新此头部，然后检查 CLAUDE.md
--
-- 格子修饰器：薄冰层(ice) — E01
-- 机制：冰封格子无法选中；冰层是实体障碍，连线不能穿过；
--       相邻格发生任意消除 → 震碎冰层（单层，无叠加）。
-- 表现：结冰时「铺开」入场(onEnter)，震碎时逐帧碎裂(onRemove)——冰的生命全在那一「碎」。
--
-- 机制与藤蔓(Vine)同构；冰比藤蔓多了 onEnter/onRemove 两段过场，仍是一个文件搞定。
--]]

local LianLianModifier = require "Game.LianLian.Special.LianLianModifierRegistry"

local ART = "Assets/_Art_LianLian/ItemSprites/item_special/"

-- 霜面图：占位先用现有 vine.png（配淡蓝 tint 出「冰」意）。
-- TODO(美术): 换成 ice_frost.png（白/灰霜 + 边缘亮 + 一道斜高光，底牌透出），并把 dbg.tintA 置 nil 去 tint。
local ICE_FROST_SPRITE = ART .. "vine.png"

-- 震碎序列帧：占位先用单帧 vine.png 跑通时序。
-- TODO(美术): 换成 { ice_shatter_0.png .. ice_shatter_N.png }（裂纹加深→碎块四散→透明，4~6 张）。
local ICE_SHATTER_FRAMES = { ART .. "vine.png" }

-- 占位 tint 的色相（淡蓝、使底牌透出）；alpha 走 dbg.tintA 以便 Debug 实时调。
local ICE_TINT_RGB = { r = 0.55, g = 0.8, b = 1.0 }

-- 可调表现参数：挂到 def 上（dbg = dbg），Debug 面板经 get("ice").dbg 就地读写，不改代码调手感。
--   fps      震碎序列帧帧率
--   enterDur 结冰入场时长（秒）
--   tintA    霜面透明度（0~1）；真图到位后置 nil，onShow 不再染色
local dbg = { fps = 20, enterDur = 0.2, tintA = 0.45 }

LianLianModifier.register({
    type = "ice",
    name = "薄冰",
    icon = ICE_FROST_SPRITE,
    defaultState = true,   -- 开关型：true=有冰层（单层，无叠加）
    dbg = dbg,             -- 暴露可调表现参数（fps/enterDur/tintA）给 Debug 面板就地读写

    -- 阻挡连线：冰层是实体障碍，任何连线不能穿过
    blocksPath = function(cell, state)
        return true
    end,

    -- 不可选中：冰封的牌不能选
    blocksSelect = function(cell, state)
        return true
    end,

    -- 相邻任意消除 → 震碎冰层（返回 nil = 解除该修饰器；单层，一次即碎）
    onNeighborCleared = function(mgr, layer, pos, state)
        return nil
    end,

    -- 静态显示（幂等）：淡蓝半透明霜面覆盖，alpha 低使内部原图清晰可见
    onShow = function(tile, state)
        if tile.ShowModifierSprite then
            if dbg.tintA then
                tile:ShowModifierSprite(ICE_FROST_SPRITE, ICE_TINT_RGB.r, ICE_TINT_RGB.g, ICE_TINT_RGB.b, dbg.tintA)
            else
                tile:ShowModifierSprite(ICE_FROST_SPRITE)   -- 真图自带霜色，不染色
            end
        end
    end,

    -- 入场（仅新出现时一次）：冰面「铺开」——scale 回落 + 淡入
    onEnter = function(tile, state)
        if tile.PlayModifierEnter then
            tile:PlayModifierEnter(dbg.enterDur)
        end
    end,

    -- 消亡：逐帧震碎，播完由视图层收尾隐藏覆盖层
    onRemove = function(tile, state, onDone)
        if tile.PlayModifierShatter then
            tile:PlayModifierShatter(ICE_SHATTER_FRAMES, dbg.fps, onDone)
        elseif onDone then
            onDone()
        end
    end,
})

return true
