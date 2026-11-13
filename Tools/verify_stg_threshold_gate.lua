-- Unity component regression: actual third-level legacy gate, no persistent writes.
local v = assert(UIManager:GetInstance():GetWindow(UIWindowNames.UIPlaneBattle)).View
local oldLose = rawget(v, "_OnBattleLose")
local checks = 0
local function check(ok, message) assert(ok, message); checks = checks + 1 end
local ok, err = xpcall(function()
    for _, count in ipairs({8, 9, 10, 11}) do
        v:_EnterLevel(1003)
        v:_HideGuide()
        v.isChoicePaused = true
        check(v.logic == nil, "third level uses the legacy table")
        v:_SetWingmanCount(count)
        local row
        for _, event in ipairs(v.timeline) do
            if event.type == 5 then row = event; break end
        end
        check(row ~= nil and row.time == 68 and tonumber(row.para) == 10, "actual third-level threshold event")
        v:_SpawnByRow(row)
        local gate = v.gates[#v.gates]
        check(gate.rt.rect.height == 112 and gate.threshold == 10, "compact visual preserves threshold")
        check(gate.thresholdCountText.text == string.format("僚机 %d / 10", count), "display matches logical count")
        check(gate.thresholdHintText.text == (count >= 10 and "数量达标 · 可安全通过" or "数量不足 · 穿过将判负"), "consequence shown before contact")
        for _, text in ipairs({gate.thresholdCountText, gate.thresholdHintText}) do
            check(not text.raycastTarget, "labels cannot intercept drag")
        end
        local px, py = v:GetPlayerPlanePos()
        gate.rt.anchoredPosition = CS.UnityEngine.Vector2(0, py + 380)
        local title, detail, _, _, positionY = v:_GetGatePreview(gate)
        check(title == (count >= 10 and "编队达标 · 可通过" or string.format("编队不足 · 还差 %d 架", 10 - count)), "approach preview title")
        check(detail == (count >= 10 and "保持航线通过检查门" or "优先选择增援门，当前穿过将判负"), "approach preview consequence")
        check(positionY == 820, "approach preview stays above formation")
        gate:RefreshThresholdDisplay(10)
        check(gate.thresholdCountText.text == "僚机 10 / 10", "live quantity refresh")
        gate:RefreshThresholdDisplay(count)
        local lost = false
        v._OnBattleLose = function() lost = true end
        gate.rt.anchoredPosition = CS.UnityEngine.Vector2(0, py)
        v:_UpdateGates(0)
        check(lost == (count < 10), "unchanged pass/fail boundary")
        check(v.wingmanCount == count, "check does not consume wingmen")
        if count >= 10 then check(#v.gates == 0, "passed gate recycled") end
        v._OnBattleLose = oldLose
    end
end, debug.traceback)
v._OnBattleLose = oldLose
v:_ShowLevelSelect()
assert(ok, err)
return "Unity threshold gate PASS " .. checks .. "; returned to level selection"
