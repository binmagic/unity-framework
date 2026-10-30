---
--- 移动堡垒舱位布局配置
---
--- 履带堡垒的运行时几何辅助：轮心、轮盘素材和模块配置展开后的舱位查询。
---
--- 车身模块、模块实例、舱位声明和顶部挂件锚点的唯一真相源在 FortressModularKit。
--- 本文件不再维护第二份车身部件或舱位表；GetSlotRects(ACTIVE) 已展开绝对坐标。
---
local FortressLayout = {}
local FortressModularKit = require "UI.UIShipCabin.FortressModularKit"
local ACTIVE_BUILD = FortressModularKit.ACTIVE

--- 堡垒整图尺寸（像素坐标系的基准；舱位由模块声明自动展开）
FortressLayout.IMAGE_WIDTH  = FortressModularKit.GetWidth(ACTIVE_BUILD)
FortressLayout.IMAGE_HEIGHT = 941

--- 原整图已不再用于渲染；保留路径只作为轮心/遮罩测量来源和回归参考。
FortressLayout.FORTRESS_SPRITE = "Assets/Main/Sprites/UIShipFortress/fortress_empty.png"

--- 舱位不再由本文件维护另一套分段与坐标表。
--- 每个车厢模块在 FortressModularKit.MODULES 中声明自己的 grid/single 舱位，
--- GetSlotRects 根据 ACTIVE build 的模块实例位置自动展开。增加/删除标准列时，
--- 车身和舱位来自同一份配置，不会出现车变长但点击格仍停在旧位置的分叉。
local SLOTS = FortressModularKit.GetSlotRects(ACTIVE_BUILD)

FortressLayout.SLOTS = SLOTS

--- ---------------------------------------------------------------
--- 负重轮：让履带"真的在转"的关键
---
--- 堡垒是一整张图，轮子画死在里面。做法是把每个轮子的**辐条盘**抠成独立
--- sprite（fx_wheel_NN.png），按原位叠回去、每帧旋转 ——
--- 转动的圆盘正好盖住原图里静止的那个轮子，所以**不需要**把车体挖洞补底。
---
--- 为什么只抠 0.86 倍半径的内盘而不是整个轮子：
--- 外侧轮缘和链节咬合在一起，抠大了会把链节一起转走；
--- 而轮缘本身近似旋转对称（一圈螺栓），不转肉眼也看不出来。
--- 辐条才是转动的视觉线索，它全在内盘里。
--- 实测 15 个内盘区域 alpha 全为 255（不透明），所以叠回去能完全遮住底图。
---
--- 坐标实测自 fortress_empty.png：亮铜轮缘做环形打分 + 非极大抑制，
--- 叠回原图肉眼核对过（Temp/trackdbg/wheel_fit5.png、wheel_rot25.png）。
--- 手绘图没有规则周期，**轮距不等**（左组 ~104，右组 ~75，中间两个过渡轮），
--- 所以只能逐个列出，不能用等间距生成 —— 试过等间距，右组整体错位。
---
--- x/y      轮心在整图里的像素坐标（图左上为原点，y 向下）
--- rOuter   轮缘外半径，**算角速度用这个**（不是 rSprite）
---          用 rSprite 会让轮子转快约 16%，又变成打滑
--- rSprite  抠出来的内盘半径 = round(rOuter * 0.86)，sprite 边长 = rSprite*2+1
--- ---------------------------------------------------------------
local WHEELS = {
    --- 左组：6 个大轮，轮距约 104
    { x = 172,  y = 707, rOuter = 40, rSprite = 34 },
    { x = 274,  y = 710, rOuter = 38, rSprite = 33 },
    { x = 379,  y = 713, rOuter = 40, rSprite = 34 },
    { x = 484,  y = 716, rOuter = 40, rSprite = 34 },
    { x = 586,  y = 716, rOuter = 38, rSprite = 33 },
    { x = 691,  y = 719, rOuter = 40, rSprite = 34 },

    --- 左右组之间的两个过渡小轮（车体收窄处）
    { x = 787,  y = 734, rOuter = 28, rSprite = 24 },
    { x = 868,  y = 731, rOuter = 30, rSprite = 26 },

    --- 右组：7 个小轮，轮距约 75
    { x = 979,  y = 752, rOuter = 22, rSprite = 19 },
    { x = 1060, y = 755, rOuter = 22, rSprite = 19 },
    { x = 1132, y = 755, rOuter = 24, rSprite = 21 },
    { x = 1216, y = 758, rOuter = 22, rSprite = 19 },
    { x = 1297, y = 758, rOuter = 24, rSprite = 21 },
    { x = 1375, y = 755, rOuter = 26, rSprite = 22 },
    { x = 1453, y = 752, rOuter = 30, rSprite = 26 },
}

--- EXTENDED 复用了原右段的 B/C 列，补三只与复制图案对应的转动轮盘。
--- spriteIndex 指向原轮盘素材；位置是原轮心按列复制后的新坐标。
if (ACTIVE_BUILD.rightColumns or 4) > 4 then
    table.insert(WHEELS, { x = 1516, y = 758, rOuter = 22, rSprite = 19, spriteIndex = 12 })
    table.insert(WHEELS, { x = 1597, y = 758, rOuter = 24, rSprite = 21, spriteIndex = 13 })
    table.insert(WHEELS, { x = 1675, y = 755, rOuter = 26, rSprite = 22, spriteIndex = 14 })
end

FortressLayout.WHEELS = WHEELS

--- 轮子 sprite 路径（序号和 WHEELS 的下标一一对应）
function FortressLayout.GetWheelSprite(index)
    return string.format("Assets/Main/Sprites/UIShipFortress/fx_wheel_%02d.png", index)
end

--- 舱位总数（19 个 < Building_Config 的 37 条，
--- 所以只铺已解锁 + 可解锁的建筑，其余走列表入口，见 UIShipCabinCtrl:GetFortressRoomList）
function FortressLayout.GetSlotCount()
    return #SLOTS
end

--- 返回以图片左上角为原点的像素矩形。slot 已由模块配置展开为绝对坐标。
function FortressLayout.GetSlotRect(slot)
    return {
        x = slot.x, y = slot.y, w = slot.w, h = slot.h,
    }
end

--- 取第 index 个舱位的像素矩形（index 超范围返回 nil）
---@param index number
---@return table|nil rect, table|nil slot
function FortressLayout.GetRectByIndex(index)
    local slot = SLOTS[index]
    if slot == nil then return nil, nil end
    return FortressLayout.GetSlotRect(slot), slot
end

return FortressLayout
