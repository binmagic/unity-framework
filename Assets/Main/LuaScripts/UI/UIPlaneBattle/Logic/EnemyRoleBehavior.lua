-- Pure movement state: windup freezes with the battle, then charges down the advertised lane.
local Role = {}
local function number(value, fallback, minimum, maximum)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then value = fallback end
    return math.max(minimum, math.min(maximum, value))
end
function Role.Config(config)
    config = config or {}
    local role = config.role
    if role ~= "swarm" and role ~= "armored" and role ~= "charger" then role = "standard" end
    return {
        role = role,
        shotCount = math.floor(number(config.shotCount, 1, 1, 7)),
        spreadAngle = number(config.spreadAngle, 0, 0, 90),
        warningDuration = number(config.warningDuration, .75, .3, 2),
        chargeTriggerRatio = number(config.chargeTriggerRatio, .58, .35, .8),
        chargeSpeedMultiplier = number(config.chargeSpeedMultiplier, 2.4, 1, 4),
    }
end
function Role.New(config)
    return {config = Role.Config(config), phase = "approach", remaining = 0}
end
-- Returns vertical distance this frame. Consume overshoot only after the full warning.
function Role.Step(state, y, height, speed, dt)
    dt = number(dt, 0, 0, 1)
    if dt <= 0 then return 0 end
    speed = math.max(0, tonumber(speed) or 0)
    if state.config.role ~= "charger" then return speed * dt end
    if state.phase == "approach" then
        local trigger = height * state.config.chargeTriggerRatio
        if y > trigger then
            local distance = math.min(speed * dt, y - trigger)
            if y - distance > trigger then return distance end
            dt = math.max(0, dt - (speed > 0 and distance / speed or 0))
            state.phase, state.remaining = "warning", state.config.warningDuration
            if dt <= 0 then return distance end
            return distance + Role.Step(state, trigger, height, speed, dt)
        end
        state.phase, state.remaining = "warning", state.config.warningDuration
    end
    if state.phase == "warning" then
        local consumed = math.min(state.remaining, dt)
        state.remaining = math.max(0, state.remaining - consumed)
        dt = dt - consumed
        if state.remaining > 0 then return 0 end
        state.phase = "charge"
    end
    return speed * state.config.chargeSpeedMultiplier * dt
end
return Role
