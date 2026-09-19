-- Render smoke test: drives every screen with a sweeping mouse and random
-- input for a few hundred frames, so nil errors in draw code surface headless.
--   "C:\Program Files\LOVE\lovec.exe" . --smoke      (exit code 1 on any error)
local smoke = {}
local B = require 'src/battle'

local SCREENS = {
    {'loading'}, {'home'}, {'aliens'}, {'weapons'}, {'shop'}, {'items'}, {'settings'}, {'profile'}, {'howToPlay'},
    {'planetMap', 6}, {'loadout'}, {'stageSelect', {stage = 2}}, {'result', {won = true}}, {'result', {won = false}},
    {'reward', {tier = 'God'}}, {'reward', {tier = 'Item'}},
}
local FRAMES_PER_SCREEN = 40
local BATTLE_FRAMES = 2400
local KEYS = {'a', 's', 'd', '1', '2', '3', '4', '5', 'return', 'return', 'return', 'space', 'f9', 'f9', 'escape', 'p'}

local frame, phase, idx = 0, 'screens', 1
local errors = 0
local visited = {}

local function fail(msg)
    errors = errors + 1
    print('SMOKE ERROR: ' .. tostring(msg))
end

local function guarded(fn, ...)
    local ok, err = xpcall(fn, debug.traceback, ...)
    if not ok then fail(err) end
end

function smoke.begin()
    -- everything unlocked so every card/branch draws
    for _, id in ipairs(WEAPON_ORDER) do data.weapons[id] = true; data.upgrades[id] = math.random(0, MAX_UPGRADE) end
    for _, a in ipairs(Aliensrand) do data.seen[a.name] = true end
    data.gold, data.gems = 5000, 100
    for _, it in ipairs(ITEMS) do data[it.stat] = 2 end
    data.planet, data.level, data.currentLevel = 6, 24, '6-25'
    data.weaponChoose1, data.weaponChoose2, data.weaponChoose3 = 'ChainLightning', 'Plague', 'Barricade'
    math.randomseed(tonumber(os.getenv('SMOKE_SEED')) or os.time())
    gStateMachine:change(SCREENS[1][1])
end

-- called from love.update after the state machine has updated; returns true when finished
function smoke.step(dt)
    frame = frame + 1
    visited[gStateMachine.currentName or '?'] = (visited[gStateMachine.currentName or '?'] or 0) + 1
    -- mouse sweeps the whole screen so every hover path runs
    local t = frame * 0.37
    ui.mouse.x = (t * 97) % VIRTUAL_WIDTH
    ui.mouse.y = (t * 53) % VIRTUAL_HEIGHT
    if phase == 'screens' then
        if frame % FRAMES_PER_SCREEN == 0 then
            idx = idx + 1
            if idx > #SCREENS then
                phase = 'battle'; frame = 0
                gStateMachine:change('battle')
            else
                gStateMachine:change(SCREENS[idx][1], SCREENS[idx][2])
            end
        elseif frame % FRAMES_PER_SCREEN == 20 then
            ui.click(ui.mouse.x, ui.mouse.y) -- one stray click per screen
        end
    elseif phase == 'battle' then
        local state = gStateMachine.currentName
        if frame % 12 == 0 then
            if state == 'pause' then guarded(love.keypressed, 'p')
            elseif state ~= 'battle' then guarded(love.keypressed, 'return') -- loadout / stage select / result: move on
            else guarded(love.keypressed, KEYS[math.random(#KEYS)]) end
        elseif frame % 12 == 6 and state == 'battle' then
            local x, y = math.random(0, VIRTUAL_WIDTH), math.random(0, VIRTUAL_HEIGHT)
            ui.click(x, y)
            guarded(function() gStateMachine:mousePressed(x, y, 1) end)
        end
        if frame >= BATTLE_FRAMES then
            phase = 'done'
            local names = {}
            for k, v in pairs(visited) do names[#names + 1] = k .. '=' .. v end
            table.sort(names)
            local bs = B.state()
            print(string.format('SMOKE DONE: %d errors; battle turn %s stage %s; frames per state: %s', errors, bs and bs.turn or '-', bs and bs.stage or '-', table.concat(names, ' ')))
            return true
        end
    end
    return false
end

function smoke.errors() return errors end
smoke.guarded = guarded

return smoke
