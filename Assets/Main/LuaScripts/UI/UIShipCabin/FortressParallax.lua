---
--- 移动堡垒背景视差滚动
---
--- 职责：让履带堡垒看起来在废土上持续前进。堡垒本体居中不动（只做轻微颠簸），
--- 背景按层以不同速度向左滚，近的快、远的慢，靠速度差造出纵深。
---
--- 层次与速度比例来自 FortressBackgroundKit：天空、云、远景、中景、
--- 履带接触地面、前景。视差模块只负责按配置比例推进，不再维护第二份层表。
---
--- **为什么前景能无缝循环**：bg_foreground_seamless.png 左右边缘已做过
--- 192px crossfade 处理（素材自带，附三联预览验证过接缝），所以可以首尾相接平铺。
--- 其余层是普通图，不保证无缝，因此只给它们很慢的速度 ——
--- 慢到一个循环周期内玩家不会注意到接缝，或者干脆不动。
---
--- 用法：
---   local parallax = FortressParallax.New()
---   parallax:Init({ sky = img1, mesaFar = img2, ... })   -- 传各层的 RectTransform
---   parallax:Start()   -- 开始滚
---   parallax:Stop()    -- 界面关闭/切后台时停
---
local FortressParallax = BaseClass("FortressParallax")

--- Vector2/Vector3 在本项目不是全局别名（各文件自行 local 引入），这里取本地引用
local Vector2 = CS.UnityEngine.Vector2
local Vector3 = CS.UnityEngine.Vector3

--- ---------------------------------------------------------------
--- 车速：全场唯一速度源（屏幕像素/秒）
---
--- **所有滚动速度都从它推导，不要再手调单个层。**
---
--- 上一版三个速度各自手调（地面 22 / 履带 230 / 前景 60），结果履带在
--- 屏幕上的实际速度是 183px/s（230 × Fortress 的 localScale 0.794），
--- 而它踩着的地面只有 22px/s —— **差 8.3 倍**。
--- 真车的履带底面和地面是无滑动接触，这两个速度必须严格相等；
--- 差这么多眼睛会直接读成"履带在空转打滑"，车却在慢慢爬，
--- 这是上一版"履带移动太假"的首要原因（用户反馈）。
---
--- 速度不是观感参数，是**物理约束**。所以这里只留一个数，其余全部算出来。
local VEHICLE_SPEED = 90

--- 车身颠簸参数：履带车在碎石地上走的那种上下抖动
---
--- 把原 ±9px 收到 ±3.5px：大幅跳动会让履带离开固定在地面的接触阴影，读成悬浮。
--- 不旋转整个 Fortress。整车只要有约 0.5° 的旋转，
--- 1672px 长的底盘两端在屏幕上就会相差十几像素，履带看起来明显一高一低。
--- 履带与地面接触的横向构图必须保持水平；轮子转动和链节平移不受这里影响。
local BOB_AMPLITUDE = 3.5    -- 垂直振幅（像素）
local BOB_SPEED     = 2.3    -- 振荡角速度（弧度/秒）

--- 定时器间隔：0 表示每帧回调（use_frame = true 时按帧走）
local TICK_INTERVAL = 0

function FortressParallax:__init()
    self.layers     = nil
    self.fortress   = nil
    self.trackUpper = nil
    self.wheels     = nil
    self.timer    = nil
    self.elapsed  = 0
    self.dust     = {}
    self.shadows  = nil

    --- 各层已累计的位移，单独记是因为每层循环宽度不同，不能用统一的 elapsed 反推
    self.offset   = {}

    --- 各层的循环宽度（图宽），到达后回绕
    self.loopWidth = {}
    self.layerSpeed = {}

    --- 堡垒本体的基准位置，颠簸是在它上面叠加偏移，不能覆盖掉原始摆位
    self.fortressBaseY = 0
end

--- 初始化各层引用
---
---@param layers table<string, table> key 为层 ID，值为 { rt, loopWidth, speedRatio }
---        单图重复层传单张宽；多变体层传 A/B 整组宽度，并在容器末尾补第一张缓冲图。
---@param fortress UnityEngine.RectTransform|nil 堡垒本体，传入则附加颠簸效果
---@param dustLayers table[]|nil 扬尘层 { { rt, loopWidth }, ... }，可为空
---@param track table|nil 履带链节纹，可为空
---        { rt, loopWidth, fortressScale, upperRt?, upperLoopWidth? }
---        fortressScale 必传：履带节点在 Fortress 内，要用它把屏幕速度换算成局部速度，
---        否则又会打滑（见下方 self.track 的说明）
---@param wheels table[]|nil 负重轮 { { rt, rOuter }, ... }，可为空
---        rOuter 是轮缘外半径（像素），角速度按 v/rOuter 算
---@param shadows table|nil 地面阴影 { wideRt, wideGroup, contactRt, contactGroup }
function FortressParallax:Init(layers, fortress, dustLayers, track, wheels, shadows)
    self.layers   = {}
    self.offset   = {}
    self.loopWidth = {}
    self.layerSpeed = {}
    self.fortress = fortress
    self.shadows = shadows

    for key, info in pairs(layers or {}) do
        if info ~= nil and info.rt ~= nil then
            self.layers[key]    = info.rt
            self.offset[key]    = 0
            self.loopWidth[key] = info.loopWidth or 0
            self.layerSpeed[key] = VEHICLE_SPEED * (info.speedRatio or 0)
        end
    end

    --- 扬尘单独存：它不走背景层配置（速度要比普通背景更快，
    --- 因为尘土紧贴地面、相对镜头移动最快），而且要记各自的基准位置做上下浮动。
    self.dust = {}
    for i, info in ipairs(dustLayers or {}) do
        if info ~= nil and info.rt ~= nil then
            table.insert(self.dust, {
                rt        = info.rt,
                loopWidth = info.loopWidth or 0,
                offset    = 0,
                -- 两层速度错开，叠加后像在翻滚而不是整块平移
                speed     = (i == 1) and 150 or 105,
                baseY     = info.rt.anchoredPosition.y,
                baseX     = info.rt.anchoredPosition.x,
                phase     = i * 1.7,
            })
        end
    end

    --- 履带：底面速度必须**严格等于地面速度**（无滑动接触）。
    ---
    --- 注意单位换算：履带节点挂在 Fortress 内部，而 Fortress 带 localScale
    --- （约 0.794，见 FORTRESS_VIEW_RATIO）。局部位移 1px 在屏幕上只走 0.794px，
    --- 所以要达到屏幕 VEHICLE_SPEED，局部速度得**除以** scale。
    --- 上一版漏了这步换算，直接写了个手调的 230，于是打滑 8.3 倍。
    ---
    --- fortressScale 由调用方传入（它知道自己给 Fortress 设了多少）。
    self.track = nil
    if track ~= nil and track.rt ~= nil then
        local scale = (track.fortressScale ~= nil and track.fortressScale > 0)
            and track.fortressScale or 1
        self.track = {
            rt        = track.rt,
            loopWidth = track.loopWidth or 0,
            offset    = 0,
            -- 零打滑：屏幕速度 = VEHICLE_SPEED = 地面层速度
            speed     = VEHICLE_SPEED / scale,
            baseX     = track.rt.anchoredPosition.x,
            baseY     = track.rt.anchoredPosition.y,
        }

        --- 上半圈：真履带是**循环**的，下面相对车体往后、上面往前。
        --- 只让底边单向平移的话读不出"在绕圈"，这是上一版显假的另一个原因。
        --- 速度相同、方向相反（dir = +1 向右）。
        if track.upperRt ~= nil then
            self.trackUpper = {
                rt        = track.upperRt,
                loopWidth = track.upperLoopWidth or track.loopWidth or 0,
                offset    = 0,
                speed     = VEHICLE_SPEED / scale,
                dir       = 1,
                baseX     = track.upperRt.anchoredPosition.x,
                baseY     = track.upperRt.anchoredPosition.y,
            }
        end
    end

    --- 负重轮：角速度由**各自半径**决定（v = ωr → ω = v/r）。
    ---
    --- 轮子也在 Fortress 内，但旋转是无量纲的，所以这里用**局部**线速度
    --- （已换算过 scale 的 track.speed）配局部半径 rOuter，比值正确。
    --- 半径必须用轮缘外半径 rOuter 而不是抠图用的 rSprite ——
    --- 后者小 14%，会让轮子转快约 16%，等于又引入一次打滑。
    ---
    --- 符号：车向右前进 → 轮子顺时针转 → 屏幕 z 角递减，所以取负。
    self.wheels = {}
    if wheels ~= nil and self.track ~= nil then
        local v = self.track.speed
        for _, w in ipairs(wheels) do
            if w.rt ~= nil and w.rOuter ~= nil and w.rOuter > 0 then
                table.insert(self.wheels, {
                    rt    = w.rt,
                    -- rad/s → deg/s
                    omega = -(v / w.rOuter) * 180 / math.pi,
                    angle = 0,
                })
            end
        end
    end

    if self.fortress ~= nil then
        self.fortressBaseY = self.fortress.anchoredPosition.y
    end
end

function FortressParallax:Start()
    if self.timer ~= nil then return end
    if self.layers == nil then
        Logger.LogWarning("FortressParallax 未 Init 就 Start，已忽略")
        return
    end
    -- use_frame = true、unscaled = true：按帧走且不受 timeScale 影响，
    -- 这样暂停弹窗把 timeScale 调 0 时背景仍在动（它是环境演出，不是游戏逻辑）
    self.timer = TimerManager:GetInstance():GetTimer(TICK_INTERVAL, self._OnTick, self, false, true, true)
    self.timer:Start()
end

function FortressParallax:Stop()
    if self.timer ~= nil then
        self.timer:Stop()
        self.timer = nil
    end
end

--- 复位到初始状态（重新打开界面时用，避免上次的累计偏移残留）
function FortressParallax:Reset()
    for key, _ in pairs(self.offset) do
        self.offset[key] = 0
    end
    -- 履带/轮子的累计量也要清，否则重开界面时链节和轮子角度从上次的位置接着走
    if self.track ~= nil then self.track.offset = 0 end
    if self.trackUpper ~= nil then self.trackUpper.offset = 0 end
    for _, w in ipairs(self.wheels or {}) do w.angle = 0 end
    self.elapsed = 0
    self:_Apply()
end

function FortressParallax:_OnTick()
    local dt = Time.unscaledDeltaTime
    if dt == nil or dt <= 0 then return end
    -- 切后台回来时 dt 可能是个很大的值，钳一下免得背景瞬移一大截
    if dt > 0.1 then dt = 0.1 end

    self.elapsed = self.elapsed + dt

    for key, speed in pairs(self.layerSpeed) do
        if self.layers[key] ~= nil and speed > 0 then
            local o = (self.offset[key] or 0) + speed * dt
            local loop = self.loopWidth[key] or 0
            -- 回绕：走过一整张图宽就减回去，保持 offset 有界，避免长时间运行后精度流失
            if loop > 0 then
                while o >= loop do o = o - loop end
            end
            self.offset[key] = o
        end
    end

    -- 扬尘：横向平移 + 轻微上下浮动（尘土被卷起又落下）
    for _, d in ipairs(self.dust) do
        local o = d.offset + d.speed * dt
        if d.loopWidth > 0 then
            while o >= d.loopWidth do o = o - d.loopWidth end
        end
        d.offset = o
    end

    -- 履带链节平移（底面：向左，和地面同向同速）
    if self.track ~= nil then
        local o = self.track.offset + self.track.speed * dt
        if self.track.loopWidth > 0 then
            while o >= self.track.loopWidth do o = o - self.track.loopWidth end
        end
        self.track.offset = o
    end

    -- 履带上半圈：同速反向，凑成"绕圈"
    if self.trackUpper ~= nil then
        local o = self.trackUpper.offset + self.trackUpper.speed * dt
        if self.trackUpper.loopWidth > 0 then
            while o >= self.trackUpper.loopWidth do o = o - self.trackUpper.loopWidth end
        end
        self.trackUpper.offset = o
    end

    -- 负重轮旋转：角度累积后取模，避免长时间运行后浮点精度流失
    for _, w in ipairs(self.wheels or {}) do
        w.angle = (w.angle + w.omega * dt) % 360
    end

    self:_Apply()
end

--- 把累计位移写到各层 transform 上
function FortressParallax:_Apply()
    for key, _ in pairs(self.layers or {}) do
        local rt = self.layers[key]
        if rt ~= nil then
            local pos = rt.anchoredPosition
            rt.anchoredPosition = Vector2(-(self.offset[key] or 0), pos.y)
        end
    end

    if self.fortress ~= nil then
        -- 两个不同频率的正弦叠加，避免单一正弦那种机械的规律感
        local t    = self.elapsed
        local bob  = math.sin(t * BOB_SPEED) * BOB_AMPLITUDE
                   + math.sin(t * BOB_SPEED * 2.7) * BOB_AMPLITUDE * 0.3
        local pos = self.fortress.anchoredPosition
        self.fortress.anchoredPosition = Vector2(pos.x, self.fortressBaseY + bob)
        -- 始终保持底盘水平。这里显式归零，也能清掉热重载前遗留的旋转角。
        self.fortress.localEulerAngles = Vector3(0, 0, 0)
    end

    -- 扬尘：横向滚 + 上下浮沉。浮沉幅度比车身颠簸小，频率不同，避免跟车同步
    for _, d in ipairs(self.dust) do
        local sway = math.sin(self.elapsed * 1.9 + d.phase) * 1.5
        d.rt.anchoredPosition = Vector2(d.baseX - d.offset, d.baseY + sway)
    end

    -- 阴影保持在地面坐标，不跟车跳；只用透明度表达离地距离。
    -- 车升高时宽影稍淡、贴地窄影更淡，落回地面时恢复，避免像固定贴纸。
    if self.shadows ~= nil and self.fortress ~= nil then
        local lift = math.max(0, self.fortress.anchoredPosition.y - self.fortressBaseY)
        local normalized = math.min(1, lift / (BOB_AMPLITUDE * 1.3))
        if self.shadows.wideGroup ~= nil then
            self.shadows.wideGroup.alpha = 1 - normalized * 0.16
        end
        if self.shadows.contactGroup ~= nil then
            self.shadows.contactGroup.alpha = 1 - normalized * 0.34
        end
    end

    -- 履带链节：只横向平移，不跟着颠簸（它已经是 Fortress 子节点，颠簸由父节点带）
    if self.track ~= nil then
        self.track.rt.anchoredPosition =
            Vector2(self.track.baseX - self.track.offset, self.track.baseY)
    end

    -- 上半圈：dir = +1，往右走（和底面反向）
    if self.trackUpper ~= nil then
        self.trackUpper.rt.anchoredPosition = Vector2(
            self.trackUpper.baseX + self.trackUpper.dir * self.trackUpper.offset,
            self.trackUpper.baseY)
    end

    -- 负重轮：绕自身中心转（节点 pivot 设在中心，见 UIShipCabinView 建节点处）
    for _, w in ipairs(self.wheels or {}) do
        w.rt.localEulerAngles = Vector3(0, 0, w.angle)
    end
end

function FortressParallax:__delete()
    self:Stop()
    self.layers   = nil
    self.fortress = nil
    self.offset   = nil
    self.loopWidth = nil
    self.layerSpeed = nil
    self.dust       = nil
    self.track      = nil
    self.trackUpper = nil
    self.wheels     = nil
    self.shadows    = nil
end

return FortressParallax
