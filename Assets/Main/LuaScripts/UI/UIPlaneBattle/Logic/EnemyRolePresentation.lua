-- Visual identity only. HP, speed, warnings and fire rules remain level-editor data.
local Presentation = {}
local DIR = "Assets/Main/Sprites/STG/Aircraft/"
local roles = {
    swarm = {sprite=DIR.."enemy_swarm.png", width=52, height=60, radius=28,
        color={.65,.86,1}, engines=1, trail=24, deathSize=76, deathColor={.55,.82,1}, deathSound="light"},
    armored = {sprite=DIR.."enemy_armored.png", width=136, height=96, radius=48,
        color={1,.78,.28}, engines=2, trail=27, deathSize=160, deathColor={1,.68,.25}, deathSound="heavy"},
    charger = {sprite=DIR.."enemy_charger.png", width=88, height=76, radius=37,
        color={1,.32,.22}, engines=2, trail=32, deathSize=115, deathColor={1,.38,.2}, deathSound="charge_down"},
}
function Presentation.Get(role) return roles[role] end
return Presentation
