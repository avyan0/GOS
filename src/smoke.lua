-- Render smoke test: drives every screen with a sweeping mouse and random
-- input for a few hundred frames, so nil errors in draw code surface headless.
--   "C:\Program Files\LOVE\lovec.exe" . --smoke      (exit code 1 on any error)
local smoke = {}
local B = require 'src/battle'

local SCREENS = {
    {'loading'}, {'home'}, {'aliens'}, {'weapons'}, {'shop'}, {'items'}, {'settings'}, {'profile'}, {'howToPlay'},
    {'planetMap', 6}, {'loadout'}, {'stageSelect', {stage = 2}}, {'result', {won = true}}, {'result', {won = false}},
    {'reward', {tier = 'God'}}, {'reward', {tier = 'Item'}}, {'battle'}, {'pause'},
}
local MAX_CLICKS = 120 -- per screen: click every clickable ui.hit reports, including ones in sub-views that open
local BATTLE_FRAMES = 2400
local KEYS = {'a', 's', 'd', '1', '2', '3', '4', '5', 'return', 'return', 'return', 'space', 'f9', 'f9', 'escape', 'p'}

local frame, phase, idx, clicks, done = 0, 'screens', 1, 0, {}
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

local realQuit = love.event.quit
function smoke.begin()
    io.stdout:setvbuf('no')
    love.event.quit = function() end        -- the Settings 'Quit game' button must not end the run
    toggleFullscreen = function() end
    -- everything unlocked so every card/branch draws
    for _, id in ipairs(WEAPON_ORDER) do data.weapons[id] = true; data.upgrades[id] = math.random(0, MAX_UPGRADE) end
    for _, a in ipairs(Aliensrand) do data.seen[a.name] = true end
    data.gold, data.gems = 5000, 100
    for _, it in ipairs(ITEMS) do data[it.stat] = 2 end
    data.planet, data.level, data.currentLevel = 6, 24, '6-25'
    data.weaponChoose1, data.weaponChoose2, data.weaponChoose3 = 'ChainLightning', 'Plague', 'Barricade'
    math.randomseed(tonumber(os.getenv('SMOKE_SEED')) or os.time())
    gStateMachine:change(SCREENS[1][1])
    ui.hitLog = {}
end

-- called from love.update after the state machine has updated; returns true when finished
function smoke.step(dt)
    frame = frame + 1
    visited[gStateMachine.currentName or '?'] = (visited[gStateMachine.currentName or '?'] or 0) + 1
    -- mouse sweeps the whole screen so every hover path runs
    if phase ~= 'screens' then
        local t = frame * 0.37
        ui.mouse.x = (t * 97) % VIRTUAL_WIDTH
        ui.mouse.y = (t * 53) % VIRTUAL_HEIGHT
    end
    if phase == 'screens' then
        local target = SCREENS[idx]
        local rects = ui.hitLog or {}
        ui.hitLog = {}
        if gStateMachine.currentName ~= target[1] then
            gStateMachine:change(target[1], target[2]) -- a click navigated away: go back
        elseif frame % 3 == 0 then
            -- next clickable on this view we have not pressed yet
            local pick
            for _, r in ipairs(rects) do
                local key = target[1] .. ':' .. math.floor(r[1]) .. ',' .. math.floor(r[2]) .. ',' .. math.floor(r[3])
                if not done[key] then pick = r; done[key] = true; break end
            end
            if pick and clicks < MAX_CLICKS then
                clicks = clicks + 1
                ui.mouse.x, ui.mouse.y = pick[1] + pick[3] / 2, pick[2] + pick[4] / 2
                ui.click(ui.mouse.x, ui.mouse.y)
                guarded(function() gStateMachine:mousePressed(ui.mouse.x, ui.mouse.y, 1) end)
            else
                clicks = 0
                idx = idx + 1
                if idx > #SCREENS then
                    phase = 'battle'; frame = 0
                    ui.hitLog = nil
                    gStateMachine:change('battle')
                else
                    gStateMachine:change(SCREENS[idx][1], SCREENS[idx][2])
                end
            end
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
            local n = 0; for _ in pairs(done) do n = n + 1 end
            print(string.format('SMOKE DONE: %d clickables pressed', n))
            print(string.format('SMOKE DONE: %d errors; battle turn %s stage %s; frames per state: %s', errors, bs and bs.turn or '-', bs and bs.stage or '-', table.concat(names, ' ')))
            love.event.quit = realQuit
            return true
        end
    end
    return false
end

function smoke.errors() return errors end
smoke.guarded = guarded

return smoke
