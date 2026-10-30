---
--- 移动堡垒可拼装素材 V1（当前正式渲染配置）
---
--- 这套配置把手绘唯一件和可重复件明确分开：车头/旧舱段/机库/车尾保持唯一，
--- 最规整的右侧 3 层舱段拆成逻辑宽 100px 的标准列。每张内部切片左右保留 2px
--- 出血，因此渲染位置要加 offsetX=-2，逻辑推进仍只加 logicalWidth。
---
local FortressModularKit = {}

local ROOT = "Assets/Main/Sprites/UIShipFortress/modular_v1/"

FortressModularKit.CANVAS_HEIGHT = 941
FortressModularKit.BASE_Y = 295
FortressModularKit.REPEAT_COLUMN_WIDTH = 100

FortressModularKit.MODULES = {
    upper_mast      = { sprite = ROOT .. "upper_mast.png",      width = 732, height = 297, logicalWidth = 0,   offsetX =  0, offsetY =  0, kind = "attachment" },
    upper_gantry    = { sprite = ROOT .. "upper_gantry.png",    width = 944, height = 297, logicalWidth = 0,   offsetX =  0, offsetY =  0, kind = "attachment" },
    base_head       = { sprite = ROOT .. "base_head.png",       width = 302, height = 648, logicalWidth = 300, offsetX =  0, offsetY = -2, kind = "unique" },
    base_left_3x2   = { sprite = ROOT .. "base_left_3x2.png",   width = 284, height = 648, logicalWidth = 280, offsetX = -2, offsetY = -2, kind = "unique",
        slots = { type = "grid", rows = 2, cols = 3, originX = 2, originY = 57, cellW = 90, cellH = 76, gapX = 4, gapY = 6, slotKind = "small", priority = 30 } },
    base_hangar     = { sprite = ROOT .. "base_hangar.png",     width = 514, height = 648, logicalWidth = 510, offsetX = -2, offsetY = -2, kind = "unique",
        slots = { type = "single", x = 44, y = 57, w = 458, h = 153, slotKind = "big", priority = 10 } },
    base_room_join  = { sprite = ROOT .. "base_room_join.png",  width = 14,  height = 648, logicalWidth = 10,  offsetX = -2, offsetY = -2, kind = "connector" },
    base_room_col_a = { sprite = ROOT .. "base_room_col_a.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_room_col_b = { sprite = ROOT .. "base_room_col_b.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_room_col_c = { sprite = ROOT .. "base_room_col_c.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_room_col_d = { sprite = ROOT .. "base_room_col_d.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_room_col_e = { sprite = ROOT .. "base_room_col_e.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_room_col_f = { sprite = ROOT .. "base_room_col_f.png", width = 104, height = 648, logicalWidth = 100, offsetX = -2, offsetY = -2, kind = "repeat",
        slots = { type = "grid", rows = 3, cols = 1, originX = 4, originY = 50, cellW = 96, cellH = 80, gapX = 4, gapY = 5, slotKind = "small", priority = 20 } },
    base_tail       = { sprite = ROOT .. "base_tail.png",       width = 174, height = 648, logicalWidth = 172, offsetX = -2, offsetY = -2, kind = "unique" },
}

--- 逐像素拼回 a.png / fortress_empty.png 的原车配置。
FortressModularKit.ORIGINAL = {
    base = {
        { id = "head",   module = "base_head" },
        { id = "left",   module = "base_left_3x2" },
        { id = "hangar", module = "base_hangar" },
        { id = "join",   module = "base_room_join" },
        { id = "room_a", module = "base_room_col_a" },
        { id = "room_b", module = "base_room_col_b" },
        { id = "room_c", module = "base_room_col_c" },
        { id = "room_d", module = "base_room_col_d" },
        { id = "tail",   module = "base_tail" },
    },
    attachments = {
        { id = "mast",   module = "upper_mast",   anchor = "head",   offsetX = 0,   y = 0 },
        { id = "gantry", module = "upper_gantry", anchor = "hangar", offsetX = 148, y = 0 },
    },
}

--- 验证“配置加列，车身真的变长”的示例：右舱段从 4 列增加为 6 列。
FortressModularKit.EXTENDED = {
    base = {
        { id = "head",   module = "base_head" },
        { id = "left",   module = "base_left_3x2" },
        { id = "hangar", module = "base_hangar" },
        { id = "join",   module = "base_room_join" },
        { id = "room_a", module = "base_room_col_a" },
        { id = "room_b", module = "base_room_col_b" },
        { id = "room_c", module = "base_room_col_c" },
        { id = "room_d", module = "base_room_col_d" },
        { id = "room_e", module = "base_room_col_e" },
        { id = "room_f", module = "base_room_col_f" },
        { id = "tail",   module = "base_tail" },
    },
    attachments = FortressModularKit.ORIGINAL.attachments,
    rightColumns = 6,
    trackMaskSprite = ROOT .. "fx_track_mask_extended.png",
    trackUpperMaskSprite = ROOT .. "fx_track_upper_mask_extended.png",
}

FortressModularKit.ORIGINAL.rightColumns = 4
FortressModularKit.ORIGINAL.trackMaskSprite = "Assets/Main/Sprites/UIShipFortress/fx_track_mask.png"
FortressModularKit.ORIGINAL.trackUpperMaskSprite = "Assets/Main/Sprites/UIShipFortress/fx_track_upper_mask.png"

--- 当前正式运行配置。所有车宽、舱位列数、履带遮罩和轮组扩展都从这里取。
FortressModularKit.ACTIVE = FortressModularKit.EXTENDED

function FortressModularKit.GetWidth(build)
    local width = 0
    for _, item in ipairs(build.base) do
        width = width + FortressModularKit.MODULES[item.module].logicalWidth
    end
    return width
end

function FortressModularKit.GetModuleStarts(build)
    local starts = {}
    local cursor = 0
    for _, item in ipairs(build.base) do
        starts[item.id] = cursor
        cursor = cursor + FortressModularKit.MODULES[item.module].logicalWidth
    end
    return starts, cursor
end

function FortressModularKit.GetTailStart(build)
    return FortressModularKit.GetWidth(build) - FortressModularKit.MODULES.base_tail.logicalWidth
end

--- 将配置展开成渲染器可直接使用的摆件列表。
--- 返回顺序就是渲染顺序：顶部挂件先画，基座后画，以便基座覆盖横切处的出血重叠。
function FortressModularKit.GetPlacements(build)
    local placements = {}
    local starts = FortressModularKit.GetModuleStarts(build)

    for _, item in ipairs(build.attachments or {}) do
        local module = FortressModularKit.MODULES[item.module]
        local anchorX = starts[item.anchor] or 0
        table.insert(placements, {
            name   = item.id or item.module,
            sprite = module.sprite,
            x      = anchorX + (item.offsetX or 0) + (module.offsetX or 0),
            y      = (item.y or 0) + (module.offsetY or 0),
            width  = module.width,
            height = module.height,
            kind   = module.kind,
        })
    end

    local cursor = 0
    for index, item in ipairs(build.base) do
        local module = FortressModularKit.MODULES[item.module]
        table.insert(placements, {
            name   = string.format("%s_%02d", item.id, index),
            sprite = module.sprite,
            x      = cursor + (module.offsetX or 0),
            y      = FortressModularKit.BASE_Y + (module.offsetY or 0),
            width  = module.width,
            height = module.height,
            kind   = module.kind,
        })
        cursor = cursor + module.logicalWidth
    end

    return placements, cursor
end


--- 从模块自己的 slots 声明展开全部舱位。priority 小的先占位；同优先级按模块和网格顺序。
function FortressModularKit.GetSlotRects(build)
    local starts = FortressModularKit.GetModuleStarts(build)
    local slots = {}

    for moduleOrder, item in ipairs(build.base) do
        local module = FortressModularKit.MODULES[item.module]
        local spec = module.slots
        if spec ~= nil then
            if spec.type == "single" then
                table.insert(slots, {
                    x = starts[item.id] + spec.x, y = FortressModularKit.BASE_Y + spec.y,
                    w = spec.w, h = spec.h, kind = spec.slotKind,
                    moduleId = item.id, row = 1, col = 1,
                    rows = 1, cols = 1, gapX = 0, gapY = 0,
                    priority = spec.priority or 100, moduleOrder = moduleOrder,
                })
            elseif spec.type == "grid" then
                for row = 1, spec.rows do
                    for col = 1, spec.cols do
                        table.insert(slots, {
                            x = starts[item.id] + spec.originX + (col - 1) * (spec.cellW + spec.gapX),
                            y = FortressModularKit.BASE_Y + spec.originY + (row - 1) * (spec.cellH + spec.gapY),
                            w = spec.cellW, h = spec.cellH, kind = spec.slotKind,
                            moduleId = item.id, row = row, col = col,
                            rows = spec.rows, cols = spec.cols,
                            gapX = spec.gapX or 0, gapY = spec.gapY or 0,
                            priority = spec.priority or 100, moduleOrder = moduleOrder,
                        })
                    end
                end
            end
        end
    end

    table.sort(slots, function(a, b)
        if a.priority ~= b.priority then return a.priority < b.priority end
        if a.row ~= b.row then return a.row < b.row end
        if a.moduleOrder ~= b.moduleOrder then return a.moduleOrder < b.moduleOrder end
        return a.col < b.col
    end)
    return slots
end

return FortressModularKit
