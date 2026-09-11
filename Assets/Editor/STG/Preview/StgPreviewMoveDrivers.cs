using System.Collections.Generic;
using UnityEngine;

// 各类对象在编辑器态预览下的逐帧移动/行为模拟，详见关卡编辑器设计文档 4.1/4.4 节
// 每个 Tick 只做纯 C# 的位置/状态推进，不发起任何跨语言调用，对应《技术架构设计》里
// "逐帧调用禁止跨语言边界"的硬约束在预览态的延伸——这里天然满足，因为预览运行时整体就是纯 C#
public static class StgPreviewMoveDrivers
{
    // 玩家吸附的固定预览锚点：屏幕竖直方向 80% 高度处（见设计文档 4.1 节"没有真正的玩家角色"）
    public static Vector2 PlayerAnchor => new Vector2(0f, StgPreviewRuntime.ScreenBottomY + (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY) * 0.2f);

    // ---------- 背景 ----------

    public static void TickBackground(StgPreviewObjectHandle handle, float scrollDeltaY)
    {
        var layer = handle.ConfigRef as StgBackgroundLayer;
        float coeff = layer != null ? layer.speedCoefficient : 1f;
        handle.Position += new Vector2(0f, -scrollDeltaY * coeff);
        handle.GameObject.transform.localPosition = new Vector3(handle.Position.x, handle.Position.y, handle.GameObject.transform.localPosition.z);
    }

    // ---------- 小怪 ----------

    // scrollDelta 是这一帧的全局卷轴位移量（来自 StgPreviewRuntime.TickScroll）。
    // 只在 behaviorType == "stationary" 时叠加：该行为语义是"不主动移动"，即"贴着地面走"
    // （比如站在土坡上的静止敌人应该跟着卷轴滚动过来，而不是钉死在生成坐标上）；
    // 其余 behaviorType 都有自己的独立位移公式（追踪玩家/正弦横移等），本来就会移动，
    // 不叠加卷轴位移是为了避免和自身位移叠加成双倍速下滑。
    public static void TickEnemy(StgPreviewObjectHandle handle, float previewTime, float deltaTime, float scrollDelta, List<StgPreviewObjectHandle> bulletSink, Transform bulletParent)
    {
        var state = handle.RuntimeState as StgEnemyRuntimeState;
        if (state == null) return;

        // 未到该单位的生成时间（formation 的 rowDelay 分批生成），保持隐藏不推进
        if (previewTime < handle.SpawnTime)
        {
            return;
        }
        if (!handle.GameObject.activeSelf)
        {
            handle.GameObject.SetActive(true);
        }

        var template = state.Template;
        if (state.Phase == "entry")
        {
            Vector2 newPos = ComputeEntryPath(template.entryPathType, handle.Position, state.EntryStartX, previewTime - handle.SpawnTime, template.entryPathSpeed, template.entryPathAmplitude);
            handle.Position = newPos;
            handle.GameObject.transform.localPosition = new Vector3(newPos.x, newPos.y, 0f);

            // 入场路径认为在到达屏幕中上部区域后结束，转入 behavior 阶段
            if (newPos.y <= StgPreviewRuntime.ScreenTopY - (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY) * 0.25f)
            {
                state.Phase = "behavior";
                state.PhaseStartTime = previewTime;
            }
        }
        else if (template.behaviorType == "stationary")
        {
            handle.Position += new Vector2(0f, -scrollDelta);
            handle.GameObject.transform.localPosition = new Vector3(handle.Position.x, handle.Position.y, 0f);
        }
        else
        {
            state.BehaviorTimer += deltaTime;
            Vector2 newPos = ComputeBehaviorMove(template.behaviorType, handle.Position, previewTime - state.PhaseStartTime, template.entryPathSpeed);
            handle.Position = newPos;
            handle.GameObject.transform.localPosition = new Vector3(newPos.x, newPos.y, 0f);

            if (template.behaviorFireInterval > 0f)
            {
                state.FireTimer += deltaTime;
                if (state.FireTimer >= template.behaviorFireInterval)
                {
                    state.FireTimer = 0f;
                    // 子弹演出只画方向和频率，不做命中判定（见设计文档 4.1 节边界说明）
                    Vector2 dir = (PlayerAnchor - handle.Position).normalized;
                    bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(handle.Position, dir * 6f, 1.2f, 0.18f, bulletParent));
                }
            }
        }

        // 出画幅回收（下方超出一定距离）
        if (handle.Position.y < StgPreviewRuntime.ScreenBottomY - 3f)
        {
            handle.MarkedForRecycle = true;
        }
    }

    // t 是相对该单位进入 entry 阶段以来的累计时间，位置按 t 直接算绝对坐标（不依赖 Time.deltaTime，
    // Editor 态下 Time.deltaTime 由 Play Mode 驱动，预览走 EditorApplication.update，deltaTime 由调用方显式传入）
    static Vector2 ComputeEntryPath(string entryPathType, Vector2 current, float startX, float t, float speed, float amplitude)
    {
        switch (entryPathType)
        {
            case "from_left_curve":
                return new Vector2(startX - 4f + Mathf.Min(t * speed * 0.05f, 4f), StgPreviewRuntime.ScreenTopY - t * speed * 0.05f);
            case "from_right_curve":
                return new Vector2(startX + 4f - Mathf.Min(t * speed * 0.05f, 4f), StgPreviewRuntime.ScreenTopY - t * speed * 0.05f);
            case "from_top_sine":
                return new Vector2(startX + Mathf.Sin(t * 2f) * amplitude, StgPreviewRuntime.ScreenTopY - t * speed * 0.05f);
            case "teleport":
                return new Vector2(startX, StgPreviewRuntime.ScreenTopY - (StgPreviewRuntime.ScreenTopY - StgPreviewRuntime.ScreenBottomY) * 0.3f);
            case "from_top_straight":
            default:
                return new Vector2(startX, StgPreviewRuntime.ScreenTopY - t * speed * 0.05f);
        }
    }

    static Vector2 ComputeBehaviorMove(string behaviorType, Vector2 current, float t, float speed)
    {
        switch (behaviorType)
        {
            case "sine_move":
                return current + new Vector2(Mathf.Sin(t * 3f) * 0.06f, -speed * 0.01f);
            case "track_player":
                return Vector2.MoveTowards(current, new Vector2(PlayerAnchor.x, current.y - 1f), speed * 0.02f);
            case "circle_strafe":
                return current + new Vector2(Mathf.Cos(t * 2f) * 0.08f, Mathf.Sin(t * 2f) * 0.03f - speed * 0.006f);
            case "kamikaze":
                return Vector2.MoveTowards(current, PlayerAnchor, speed * 0.03f);
            case "stationary":
                return current;
            case "straight_down":
            default:
                return current + new Vector2(0f, -speed * 0.015f);
        }
    }

    // ---------- Boss ----------

    public static void TickBoss(StgPreviewObjectHandle handle, float deltaTime, List<StgPreviewObjectHandle> bulletSink, Transform bulletParent)
    {
        var state = handle.RuntimeState as StgBossRuntimeState;
        if (state == null) return;
        var config = state.Config;
        if (config.phases.Count == 0) return;

        // 假血量按整个 Boss 演出时长内匀速下降（见设计文档 4.4 节说明），演出时长固定按 30 秒估算
        const float fakeFightDuration = 30f;
        state.FakeHpFraction = Mathf.Max(0f, state.FakeHpFraction - deltaTime / fakeFightDuration);

        int targetPhaseIndex = 0;
        for (int i = 0; i < config.phases.Count; i++)
        {
            if (state.FakeHpFraction <= config.phases[i].hpThreshold) targetPhaseIndex = i;
        }
        if (targetPhaseIndex != state.CurrentPhaseIndex)
        {
            state.CurrentPhaseIndex = targetPhaseIndex;
            var phase = config.phases[targetPhaseIndex];
            state.SkillTimers = new List<float>();
            for (int i = 0; i < phase.skills.Count; i++) state.SkillTimers.Add(0f);
        }

        var currentPhase = config.phases[state.CurrentPhaseIndex];

        // 巡逻移动
        state.PatrolTimer += deltaTime;
        Vector2 pos = handle.Position;
        switch (currentPhase.movePattern)
        {
            case "horizontal_patrol":
                pos = new Vector2(Mathf.Sin(state.PatrolTimer * 0.5f) * StgPreviewRuntime.ScreenHalfWidth * 0.7f, StgPreviewRuntime.BossStationY);
                break;
            case "vertical_patrol":
                pos = new Vector2(handle.Position.x, StgPreviewRuntime.BossStationY + Mathf.Sin(state.PatrolTimer * 0.5f) * 1.5f);
                break;
            case "figure_eight":
                pos = new Vector2(Mathf.Sin(state.PatrolTimer * 0.5f) * 3f, StgPreviewRuntime.BossStationY + Mathf.Sin(state.PatrolTimer) * 1f);
                break;
            case "chase_player":
                pos = Vector2.MoveTowards(handle.Position, new Vector2(PlayerAnchor.x, StgPreviewRuntime.BossStationY), deltaTime * 2f);
                break;
            case "stationary_center":
            default:
                pos = new Vector2(0f, StgPreviewRuntime.BossStationY);
                break;
        }
        handle.Position = pos;
        handle.GameObject.transform.localPosition = new Vector3(pos.x, pos.y, 0f);

        // 技能定时触发（演出效果，不做真实弹幕数量精确还原，只按 interval 生成示意子弹）
        for (int i = 0; i < currentPhase.skills.Count && i < state.SkillTimers.Count; i++)
        {
            var skill = currentPhase.skills[i];
            state.SkillTimers[i] += deltaTime;
            if (skill.interval > 0f && state.SkillTimers[i] >= skill.interval)
            {
                state.SkillTimers[i] = 0f;
                FireBossSkillFx(skill, pos, bulletSink, bulletParent);
            }
        }
    }

    static void FireBossSkillFx(StgBossSkill skill, Vector2 origin, List<StgPreviewObjectHandle> bulletSink, Transform bulletParent)
    {
        switch (skill.skillId)
        {
            case "spread_shot":
            {
                int n = Mathf.Max(1, skill.bulletCount);
                float halfAngle = skill.spreadAngle * 0.5f;
                for (int i = 0; i < n; i++)
                {
                    float angle = -90f + Mathf.Lerp(-halfAngle, halfAngle, n == 1 ? 0.5f : i / (float)(n - 1));
                    Vector2 dir = new Vector2(Mathf.Cos(angle * Mathf.Deg2Rad), Mathf.Sin(angle * Mathf.Deg2Rad));
                    bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(origin, dir * 5f, 1.5f, 0.16f, bulletParent));
                }
                break;
            }
            case "aimed_shot":
            {
                int n = Mathf.Max(1, skill.bulletCount);
                Vector2 dir = (PlayerAnchor - origin).normalized;
                for (int i = 0; i < n; i++)
                {
                    bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(origin, dir * 5f, 1.5f + i * 0.1f, 0.16f, bulletParent));
                }
                break;
            }
            case "laser_beam":
                bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(origin, new Vector2(0f, -8f), Mathf.Max(0.3f, skill.duration), Mathf.Max(0.1f, skill.width * 0.02f), bulletParent));
                break;
            case "bullet_hell":
            {
                int n = Mathf.Max(4, skill.bulletCount);
                int rings = Mathf.Max(1, skill.rings);
                for (int ring = 0; ring < rings; ring++)
                {
                    for (int i = 0; i < n; i++)
                    {
                        float angle = i * 360f / n + ring * 15f;
                        Vector2 dir = new Vector2(Mathf.Cos(angle * Mathf.Deg2Rad), Mathf.Sin(angle * Mathf.Deg2Rad));
                        bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(origin, dir * (3f + ring), 2f, 0.14f, bulletParent));
                    }
                }
                break;
            }
            case "missile_volley":
            {
                int n = Mathf.Max(1, skill.count);
                for (int i = 0; i < n; i++)
                {
                    Vector2 dir = (PlayerAnchor - origin + new Vector2((i - n / 2f) * 0.3f, 0f)).normalized;
                    bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(origin, dir * Mathf.Max(1f, skill.speed * 0.02f), 2f, 0.15f, bulletParent));
                }
                break;
            }
            case "summon_minions":
                // 召唤小怪的演出交由 StgPreviewRuntime 在事件层处理（需要引用 waveTemplateId 生成真正的敌人），这里不重复处理
                break;
            case "shield_up":
                // 护盾是状态而非位移演出，预览态用 GameObject 颜色变化表现（由调用方在 UI 层附加，不在移动驱动里处理）
                break;
        }
    }

    // ---------- 机关 ----------

    // scrollDelta 是这一帧的全局卷轴位移量。机关是摆在场景里的固定物（土坡、炮塔、激光门等），
    // 理论上都该随卷轴滚动过来，不是钉死在生成坐标上不动——除了 moving_obstacle，它有自己的
    // 绝对路径公式（ComputeTrapPath 以 PathOrigin 为基准点），这里改成让 PathOrigin 本身随卷轴
    // 平移，这样路径运动是叠加在"随卷轴滚动"这个基础位移之上，而不是被卷轴覆盖掉。
    public static void TickTrap(StgPreviewObjectHandle handle, float previewTime, float deltaTime, float scrollDelta, List<StgPreviewObjectHandle> bulletSink, Transform bulletParent)
    {
        var state = handle.RuntimeState as StgTrapRuntimeState;
        if (state == null) return;
        var config = state.Config;

        if (config.type != "moving_obstacle")
        {
            handle.Position += new Vector2(0f, -scrollDelta);
            handle.GameObject.transform.localPosition = new Vector3(handle.Position.x, handle.Position.y, handle.GameObject.transform.localPosition.z);
        }

        switch (config.type)
        {
            case "turret":
                handle.GameObject.transform.Rotate(Vector3.forward, config.paramRotateSpeed * deltaTime);
                state.StateTimer += deltaTime;
                if (config.paramFireInterval > 0f && state.StateTimer >= config.paramFireInterval)
                {
                    state.StateTimer = 0f;
                    Vector2 dir = (PlayerAnchor - handle.Position).normalized;
                    bulletSink.Add(StgPreviewSpawner.SpawnBulletFx(handle.Position, dir * 5f, 1.2f, 0.14f, bulletParent));
                }
                break;
            case "laser_gate":
                state.StateTimer += deltaTime;
                float threshold = state.GateOn ? config.paramOnDuration : config.paramOffDuration;
                if (threshold > 0f && state.StateTimer >= threshold)
                {
                    state.StateTimer = 0f;
                    state.GateOn = !state.GateOn;
                    var sr = handle.GameObject.GetComponentInChildren<SpriteRenderer>();
                    if (sr != null)
                    {
                        var c = sr.color;
                        c.a = state.GateOn ? 1f : 0.25f;
                        sr.color = c;
                    }
                }
                break;
            case "moving_obstacle":
                state.PathOrigin += new Vector2(0f, -scrollDelta);
                state.PathTimer += deltaTime;
                Vector2 newPos = ComputeTrapPath(config.paramPathType, state.PathOrigin, state.PathTimer, config.paramSpeed);
                handle.Position = newPos;
                handle.GameObject.transform.localPosition = new Vector3(newPos.x, newPos.y, 0f);
                break;
            case "static_obstacle":
            case "destructible":
            case "slow_field":
            case "digital_gate":
            case "decoration":
            default:
                // 无专属逐帧演出（数字门的抛撒弧线由 StgPreviewRuntime 在生成瞬间用一次性动画驱动，不在这里逐帧处理）
                // decoration 是纯视觉装饰机关（如站着坦克的土坡），本身无专属行为，只走上面统一的卷轴跟随
                break;
        }
    }

    // origin 是该机关生成时的初始位置，作为路径基准点；t 是累积时间，纯函数按 t 直接算绝对坐标
    // （不依赖 Time.deltaTime，理由同 ComputeEntryPath 的注释）
    static Vector2 ComputeTrapPath(string pathType, Vector2 origin, float t, float speed)
    {
        switch (pathType)
        {
            case "sine":
                return new Vector2(origin.x + Mathf.Sin(t * speed * 0.05f) * 1.5f, origin.y);
            case "circular":
            {
                float radius = 1.5f;
                float angle = t * speed * 0.03f;
                return origin + new Vector2(Mathf.Cos(angle) * radius, Mathf.Sin(angle) * radius);
            }
            case "linear":
            default:
                return origin + new Vector2(0f, -t * speed * 0.01f);
        }
    }

    // ---------- 物品 ----------

    public static void TickItem(StgPreviewObjectHandle handle, float deltaTime)
    {
        var state = handle.RuntimeState as StgItemRuntimeState;
        if (state == null) return;
        var config = state.Config;

        switch (config.moveMode)
        {
            case "float_toward_player":
                handle.Position = Vector2.MoveTowards(handle.Position, PlayerAnchor, deltaTime * 2f);
                break;
            case "static_until_collected":
                if (config.attractToPlayer && Vector2.Distance(handle.Position, PlayerAnchor) <= config.attractRadius * 0.05f)
                {
                    handle.Position = Vector2.MoveTowards(handle.Position, PlayerAnchor, deltaTime * 4f);
                }
                break;
            case "fall_down":
            default:
                handle.Position += new Vector2(0f, -deltaTime * 1.5f);
                if (config.attractToPlayer && Vector2.Distance(handle.Position, PlayerAnchor) <= config.attractRadius * 0.05f)
                {
                    handle.Position = Vector2.MoveTowards(handle.Position, PlayerAnchor, deltaTime * 4f);
                }
                break;
        }
        handle.GameObject.transform.localPosition = new Vector3(handle.Position.x, handle.Position.y, 0f);

        if (Vector2.Distance(handle.Position, PlayerAnchor) < 0.15f)
        {
            handle.MarkedForRecycle = true; // 到达吸附锚点视为被"拾取"
        }
    }

    // ---------- 子弹/技能视觉演出 ----------

    public static void TickBulletFx(StgPreviewObjectHandle handle, float deltaTime)
    {
        handle.Position += handle.Velocity * deltaTime;
        handle.GameObject.transform.localPosition = new Vector3(handle.Position.x, handle.Position.y, 0f);
    }
}
