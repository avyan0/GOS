GameState = Class{}

local spotTaken = {}
local weapon1Clicked = false
local weapon2Clicked = false
local weapon3Clicked = false
local mousePressed = true
local weapon1Cooldown = 0
local weapon2Cooldown = 0
local weapon3Cooldown = 0
local chooseTile = false
local selectedLane = 0
local selectedRow = 0
local chooseLane = false
local fieldCleared = false
local alienCounter = 0
local respawnLane = 0
local attackCounter = 0
local attacker = {aoe = '', id = 'none', attack = 0}
local stage = 'first'
local aliensNeeded = 0
local lastTileLane = 0
local lastTileRow = 0
local damageBuff = 1
local stellar = 0
local commonBuff = 1
local rareBuff = 1
local scarceBuff = 1
local targetBuff = 1
local allGood = false

for i = 1, 13 do
    spotTaken[i] = {}
 for j = 1, 5 do
    spotTaken[i][j] = false
    end
end


alienAlive= {}
for i = 1, 13 do
    alienAlive[i] = {}
    for j = 1, 5 do
        alienAlive[i][j] = false
    end
end

alienStats = {}
for i = 1, 13 do
    alienStats[i] = {}
    for j = 1, 5 do
        alienStats[i][j] = {speed = 1, health = 0, hevalten = false, poisoned = false,poisonDamage = 0, stunned = false, stunDuration = 0, hypno = false,immmunity = false,fly = false,flyCounter = -1,name = '',giant = 0,morph = false}
    end
end
walls = {}
for i = 1,12 do
    walls[i]= {}
    for j = 1,5 do
        walls[i][j] = false
    end
end
  
-- ------------------------------------------------------------ presentation
-- Field geometry: 5 lanes x 10 rows, aliens enter at row 1 (top) and reach the base past row 10.
local FIELD_X, FIELD_Y, LANE_W, ROW_H = 40, 12, 188, 58
local SIDE_X, SIDE_W = 1000, 240
local turnCount = 1
local popups = {}      -- floating damage numbers
local lastHP = {}
for i = 1, 13 do lastHP[i] = {} end

local function laneAt(x) if x < FIELD_X or x > FIELD_X + LANE_W * 5 then return nil end return math.floor((x - FIELD_X) / LANE_W) + 1 end
local function rowAt(y) if y < FIELD_Y or y > FIELD_Y + ROW_H * 10 then return nil end return math.floor((y - FIELD_Y) / ROW_H) + 1 end
local function cellCenter(i, j) return FIELD_X + (j - 0.5) * LANE_W, FIELD_Y + (i - 0.5) * ROW_H end

local function weaponSlots()
    return {
        {id = data.weaponChoose1, used = weapon1Clicked, cd = weapon1Cooldown, key = 'A'},
        {id = data.weaponChoose2, used = weapon2Clicked, cd = weapon2Cooldown, key = 'S'},
        {id = data.weaponChoose3, used = weapon3Clicked, cd = weapon3Cooldown, key = 'D'},
    }
end

local function endTurn()
    mousePressed = true
    turnCount = turnCount + 1
    if weapon1Cooldown >= Weapons[data.weaponChoose1].cooldown then weapon1Clicked = false; weapon1Cooldown = 0 end
    if weapon2Cooldown >= Weapons[data.weaponChoose2].cooldown then weapon2Clicked = false; weapon2Cooldown = 0 end
    if weapon3Cooldown >= Weapons[data.weaponChoose3].cooldown then weapon3Clicked = false; weapon3Cooldown = 0 end
    if weapon1Clicked then weapon1Cooldown = weapon1Cooldown + 1 end
    if weapon2Clicked then weapon2Cooldown = weapon2Cooldown + 1 end
    if weapon3Clicked then weapon3Cooldown = weapon3Cooldown + 1 end
end

local function fireSlot(n)
    if chooseLane or chooseTile then return end
    if n == 1 and not weapon1Clicked then GameState:attack(data.weaponChoose1); weapon1Clicked = true
    elseif n == 2 and not weapon2Clicked then GameState:attack(data.weaponChoose2); weapon2Clicked = true
    elseif n == 3 and not weapon3Clicked then GameState:attack(data.weaponChoose3); weapon3Clicked = true end
end

local function cancelAim()
    chooseLane, chooseTile = false, false
    selectedLane, selectedRow, attackCounter, lastTileLane, lastTileRow = 0, 0, 0, 0, 0
end

local function trackDamage()
    for i = 1, 10 do
        for j = 1, 5 do
            local hp = alienAlive[i][j] and alienStats[i][j].health or nil
            local last = lastHP[i][j]
            if hp and last and hp < last - 0.5 then
                local cx, cy = cellCenter(i, j)
                popups[#popups + 1] = {x = cx + math.random(-20, 20), y = cy - 10, text = '-' .. math.round(last - hp), t = 0, color = ui.c.warn}
            end
            lastHP[i][j] = hp
        end
    end
end

function GameState:render(dimmed)
    local dt = love.timer.getDelta()
    local t = love.timer.getTime()
    if not dimmed then trackDamage() end
    ui.background(t, false)

    -- field
    ui.color(ui.c.bg2); ui.rrect('fill', FIELD_X - 4, FIELD_Y - 4, LANE_W * 5 + 8, ROW_H * 10 + 8, 10)
    local hoverLane, hoverRow = laneAt(ui.mouse.x), rowAt(ui.mouse.y)
    for j = 1, 5 do
        for i = 1, 10 do
            local x, y = FIELD_X + (j - 1) * LANE_W, FIELD_Y + (i - 1) * ROW_H
            local shade = ((i + j) % 2 == 0) and 0.8 or 0.55
            ui.color(ui.c.panel, shade)
            love.graphics.rectangle('fill', x + 1, y + 1, LANE_W - 2, ROW_H - 2, 4, 4)
            if walls[i][j] then
                ui.color(ui.c.warn, 0.85); love.graphics.rectangle('fill', x + 6, y + ROW_H - 12, LANE_W - 12, 6, 3, 3)
            end
        end
        -- aiming highlights
        if chooseLane and hoverLane == j and not dimmed then
            ui.color(ui.c.accent, 0.18); love.graphics.rectangle('fill', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
            ui.color(ui.c.accent, 0.9); love.graphics.setLineWidth(2); love.graphics.rectangle('line', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
        end
    end
    if chooseTile and hoverLane and hoverRow and not dimmed then
        local x, y = FIELD_X + (hoverLane - 1) * LANE_W, FIELD_Y + (hoverRow - 1) * ROW_H
        ui.color(ui.c.accent, 0.25); love.graphics.rectangle('fill', x, y, LANE_W, ROW_H, 4, 4)
        ui.color(ui.c.accent); love.graphics.setLineWidth(2); love.graphics.rectangle('line', x, y, LANE_W, ROW_H, 4, 4)
    end
    -- lane numbers along the top, base bar along the bottom
    for j = 1, 5 do ui.text(tostring(j), FIELD_X + (j - 1) * LANE_W, FIELD_Y + ROW_H * 10 + 6, LANE_W, 'center', 'hud', 14, ui.c.dim) end
    ui.color(ui.c.danger, 0.7); love.graphics.rectangle('fill', FIELD_X, FIELD_Y + ROW_H * 10 + 26, LANE_W * 5, 4, 2, 2)
    ui.text('BASE', FIELD_X, FIELD_Y + ROW_H * 10 + 34, LANE_W * 5, 'center', 'hud', 14, ui.c.danger)

    -- aliens
    for i = 1, 10 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] then
                local a = alienStats[i][j]
                local spec = Aliens[a.name] and Aliens[a.name].spec or {shape = 'round', eyes = 2, hue = 0.3}
                local cx, cy = cellCenter(i, j)
                local bob = a.fly and math.sin(t * 6 + i + j) * 3 or 0
                local ax = cx - 56
                icons.alien(spec, ax, cy - 2 + bob, 40, a.fly and 0.55 or 1)
                if a.stunned then ui.color(ui.c.warn); love.graphics.circle('line', ax, cy - 2, 20) end
                if a.hypno then ui.color(ui.c.scarce or ui.rarity.scarce); love.graphics.setLineWidth(2); love.graphics.circle('line', ax, cy - 2, 23) end
                if a.immmunity then ui.color(ui.c.gold); love.graphics.setLineWidth(2); love.graphics.circle('line', ax, cy - 2, 25) end
                -- name + hp
                local maxHP = Aliens[a.name] and Aliens[a.name].health or a.health
                local title = Aliens[a.name] and Aliens[a.name].title or a.name
                ui.text(title, ax + 26, cy - 24, LANE_W - 60, 'left', 'body', 12, ui.c.muted)
                ui.text(tostring(math.max(0, math.round(a.health))), ax + 26, cy - 10, LANE_W - 60, 'left', 'hud', 16, ui.c.text)
                local frac = math.max(0, math.min(1, a.health / math.max(1, maxHP)))
                ui.progress(ax + 26, cy + 12, LANE_W - 70, 5, frac, a.hevalten and ui.c.danger or ui.c.good, ui.c.bg)
                -- status glyphs
                local gx = ax + 26
                if a.poisoned then ui.text('P', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.good); gx = gx + 14 end
                if a.stunned then ui.text('S', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.warn); gx = gx + 14 end
                if a.hypno then ui.text('H', gx, cy + 18, 20, 'left', 'hud', 11, ui.rarity.scarce); gx = gx + 14 end
                if a.immmunity then ui.text('I', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.gold) end
            end
        end
    end

    -- damage popups
    for k = #popups, 1, -1 do
        local p = popups[k]
        if not dimmed then p.t = p.t + dt end
        if p.t > 1.3 then table.remove(popups, k) else
            ui.text(p.text, p.x - 40, p.y - p.t * 30, 80, 'center', 'hud', 20, p.color, math.min(1, (1.3 - p.t) * 2))
        end
    end

    -- sidebar
    ui.panel(SIDE_X, FIELD_Y - 4, SIDE_W, 700, {radius = 12})
    local planet, lvl = data.currentLevel:match('(%d+)%-(%d+)')
    ui.text(PLANETS[tonumber(planet)].name, SIDE_X + 16, 16, SIDE_W - 32, 'left', 'display', 20)
    ui.text('Level ' .. lvl .. '   -   Turn ' .. turnCount, SIDE_X + 16, 44, SIDE_W - 32, 'left', 'body', 14, ui.c.muted)
    local stageIdx = ({first = 1, second = 2, third = 3})[stage]
    ui.text('Stage ' .. stageIdx .. ' of 3', SIDE_X + 16, 70, 110, 'left', 'body', 15)
    ui.text(alienCounter .. ' / ' .. aliensNeeded, SIDE_X + 16, 68, SIDE_W - 32, 'right', 'hud', 18, ui.c.accent)
    ui.progress(SIDE_X + 16, 98, SIDE_W - 32, 6, aliensNeeded > 0 and alienCounter / aliensNeeded or 0, ui.c.accent)

    -- weapon cards
    local slots = weaponSlots()
    for n, s in ipairs(slots) do
        local w = Weapons[s.id]
        local y = 124 + (n - 1) * 118
        local color = w and ui.rarity[w.rarity] or ui.c.dim
        local ready = w and not s.used
        local hover = ui.hovered(SIDE_X + 12, y, SIDE_W - 24, 108)
        ui.panel(SIDE_X + 12, y, SIDE_W - 24, 108, {fill = ready and ui.c.panel2 or ui.c.bg2, border = (hover and ready and not dimmed) and color or ui.c.line, radius = 10})
        if w then
            icons.weapon(w.shape, SIDE_X + 40, y + 34, 38, ready and color or ui.c.dim)
            ui.text(w.name, SIDE_X + 68, y + 14, SIDE_W - 90, 'left', 'display', 15, ready and ui.c.text or ui.c.dim)
            local target = ({all = 'Field', lane = 'Lane', tile = 'Tile', row = 'Rows', buff = 'Buff', ['Random Lane'] = 'Random'})[w.aoe] or w.aoe
            ui.text(target .. (w.damage > 0 and ('   -   ' .. math.round(w.damage * upgradeMultiplier(w))) or ''), SIDE_X + 68, y + 38, SIDE_W - 90, 'left', 'body', 13, ui.c.muted)
            local status
            if ready then status = 'READY   -   ' .. s.key
            elseif w.cooldown > 0 then status = 'RECHARGING ' .. s.cd .. '/' .. w.cooldown
            else status = 'USED THIS TURN' end
            ui.text(status, SIDE_X + 24, y + 80, SIDE_W - 48, 'left', 'hud', 12, ready and color or ui.c.dim)
            if w.cooldown > 0 then ui.pips(SIDE_X + SIDE_W - 24 - w.cooldown * 12, y + 84, w.cooldown, ready and w.cooldown or s.cd, color, 7, 5) end
        end
        if not dimmed and ready and ui.hit(SIDE_X + 12, y, SIDE_W - 24, 108) then fireSlot(n) end
    end

    -- prompt / end turn
    local py = 124 + 3 * 118 + 4
    if chooseLane or chooseTile then
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = ui.c.accent, border = false, radius = 10})
        local msg = chooseLane and 'Click a lane' or ('Click a tile' .. (attacker.attack > 1 and ('  (' .. (attackCounter + 1) .. '/' .. attacker.attack .. ')') or ''))
        ui.textBox(msg, SIDE_X + 12, py, SIDE_W - 24, 40, 'display', 17, ui.c.bg)
        ui.textBox('Esc to cancel', SIDE_X + 12, py + 34, SIDE_W - 24, 24, 'body', 12, ui.c.bg)
    else
        if not dimmed and ui.button('End turn', SIDE_X + 12, py, SIDE_W - 24, 64, {size = 22, id = 'endturn'}) then endTurn() end
        if dimmed then ui.button('End turn', SIDE_X + 12, py, SIDE_W - 24, 64, {size = 22, id = 'endturn', disabled = true}) end
    end
    if not dimmed and ui.button('Pause', SIDE_X + 12, py + 74, SIDE_W - 24, 40, {outline = true, size = 16, id = 'pausebtn', color = ui.c.muted}) then gStateMachine:change('pause') end
end

function GameState:keyPressed(key)
    if key == 'escape' and (chooseLane or chooseTile) then
        -- undo the "used" flag so the weapon can be fired again
        if attacker.id == data.weaponChoose1 then weapon1Clicked = false
        elseif attacker.id == data.weaponChoose2 then weapon2Clicked = false
        elseif attacker.id == data.weaponChoose3 then weapon3Clicked = false end
        cancelAim()
    elseif key == 'escape' or key == 'p' then
        if not chooseLane and not chooseTile then gStateMachine:change('pause') end
    end
end

function GameState:mousePressed(x, y)
    local lane, row = laneAt(x), rowAt(y)
    if chooseLane and lane then
        GameState:attackLane(attacker, lane)
        chooseLane = false
    elseif chooseTile and lane and row then
        selectedLane, selectedRow = lane, row
    end
end

function GameState:resetPresentation()
    turnCount = 1
    popups = {}
    for i = 1, 13 do lastHP[i] = {} end
end

function GameState:update(dt)
    local god = false
    for i = 10,2,-1 do
        for j = 1,5 do
            if alienStats[i][j].immmunity then
                alienStats[i][j].immmunity = false
            end
            if alienStats[i][j].name == 'GodOfSpace' then
                god = true
            end
        end
    end
    if god then 
        allGood = true
    end
    god = false

    if chooseTile and attacker.aoe == 'tile' then
        if love.keyboard.wasPressed('q') then
            selectedLane = 1
        elseif love.keyboard.wasPressed('w') then
            selectedLane = 2
        elseif love.keyboard.wasPressed('e') then
            selectedLane = 3
        elseif love.keyboard.wasPressed('r') then
            selectedLane = 4
        elseif love.keyboard.wasPressed('t') then
            selectedLane = 5
        end

        if love.keyboard.wasPressed('0') then
            selectedRow = 10
        elseif love.keyboard.wasPressed('1') then
            selectedRow = 1
        elseif love.keyboard.wasPressed('2') then
            selectedRow = 2
        elseif love.keyboard.wasPressed('3') then
            selectedRow = 3
        elseif love.keyboard.wasPressed('4') then
            selectedRow = 4
        elseif love.keyboard.wasPressed('5') then
            selectedRow = 5
        elseif love.keyboard.wasPressed('6') then
            selectedRow = 6
        elseif love.keyboard.wasPressed('7') then
            selectedRow = 7
        elseif love.keyboard.wasPressed('8') then
            selectedRow = 8
        elseif love.keyboard.wasPressed('9') then
            selectedRow = 9
        end

        if (lastTileLane ~= selectedLane or lastTileRow ~= selectedRow) then
        if not (attackCounter >= attacker.attack) then
        if (0 ~= selectedLane and 0 ~= selectedRow) then
            if attackCounter >= attacker.attack then
                chooseTile = false
                selectedLane = 0
                selectedRow = 0
                attackCounter = 0
                lastTileLane = 0
                lastTileRow = 0
            else
                attackCounter = attackCounter + 1
                GameState:attackTile(attacker, selectedRow, selectedLane)
                lastTileLane = selectedLane
                lastTileRow = selectedRow
                selectedLane = 0
                selectedRow = 0
            end
        end
        else
            chooseTile = false
                selectedLane = 0
                selectedRow = 0
                attackCounter = 0
                lastTileLane = 0
                lastTileRow = 0
        end
    end
    end

    if not chooseLane and not chooseTile then
        if love.keyboard.wasPressed('a') then fireSlot(1)
        elseif love.keyboard.wasPressed('s') then fireSlot(2)
        elseif love.keyboard.wasPressed('d') then fireSlot(3)
        elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('kpenter') then endTurn()
        end
    end

    if stage == 'first' then
        aliensNeeded =  Levels[data.currentLevel].first
    elseif stage == 'second' then
        aliensNeeded =  Levels[data.currentLevel].second
    elseif stage == 'third' then
        aliensNeeded =  Levels[data.currentLevel].third
    end
    
    if stage == 'first' then-- check stages
        if alienCounter >= Levels[data.currentLevel].first and GameState:checkDead() then
            stage = 'second'
            GameState:switchStage()
            gStateMachine:change('stageSelect', {stage = 2})
        end
    elseif stage == 'second' then
        if alienCounter >= Levels[data.currentLevel].second and GameState:checkDead() then
            stage = 'third'
            GameState:switchStage()
            gStateMachine:change('stageSelect', {stage = 3})        
        end
    elseif stage == 'third' then
        if alienCounter >= Levels[data.currentLevel].third and GameState:checkDead() then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('result', {won = true})
        end
    end

    if mousePressed and not love.mouse.isDown(1) then -- checks if end turn
        mousePressed = false
        GameState:applyPoison()
        GameState:spawnAliens()
        for i = 2, 10 do
            for j = 1, 5 do
                if alienStats[i][j].morph then
                    alienStats[i][j] = GameState:morph(i, j)
                end
            end
        end
        data.turn = true
        saveData()
    end

    if attacker.aoe == 'lane' and chooseLane then -- does lane damage
        if love.keyboard.wasPressed('1') then
            GameState:attackLane(attacker,1)
            chooseLane = false
        elseif love.keyboard.wasPressed('2') then
             GameState:attackLane(attacker,2)
            chooseLane = false
        elseif love.keyboard.wasPressed('3') then
             GameState:attackLane(attacker,3)
            chooseLane = false
        elseif love.keyboard.wasPressed('4') then
             GameState:attackLane(attacker,4)
            chooseLane = false
        elseif love.keyboard.wasPressed('5') then
             GameState:attackLane(attacker,5)
            chooseLane = false
        end
    end

    for i =1,5 do -- check if lose
        if spotTaken[11][i] then
            data.turn = false
            stage = 'first'
            GameState:switchStage()
            saveData()
            gStateMachine:change('result', {won = false})
        end
    end
end

function GameState:spawnAliens()
    if alienCounter < aliensNeeded  then
            local alien = math.random(1,100)
             alien1 = nil
             for _, alienName in ipairs(alienNames) do
                if alien <= Levels[data.currentLevel][alienName] then
                    alien1 = Aliens[alienName]
                    break
                end
            end

            local lane = 1
        if respawnLane ~= 0 then
            for i = 1, 5 do
                if respawnLane == i then
                    if respawnLane == 1 then
                        lane = math.random(2,5)
                    elseif respawnLane == 5 then
                        lane = math.random(1,4)
                    else
                        lane = math.random(1,5)
                        while lane == i do
                            lane = math.random(1,5)
                        end
                    end
                end
            end
        else
            lane = math.random(1,5)
        end
        if alien1.hevalten then
            lane = math.random(1,5)
        end
        respawnLane = 0 -- Respawn only blocks one spawn
        if lane == 1 then
            GameState:moveLane(1,alien1)
        elseif lane == 2 then
            GameState:moveLane(2,alien1)
        elseif lane == 3 then
            GameState:moveLane(3,alien1)
        elseif lane == 4 then
            GameState:moveLane(4,alien1)
        elseif lane == 5 then
            GameState:moveLane(5,alien1)
        end
    else
        GameState:moveLane()
    end
end

function GameState:moveLane(n, thingy)
    local sameSpot = false
    local hypnoDone = true
    local moveThenKill = false
    local allAliensDone = false
    stellar = stellar -1
    local counter = 0
    if stellar == 2 then        
        damageBuff = damageBuff /(1.2 * ((data.upgrades[attacker.id] * 0.1) + 1))
        damageBuff = damageBuff*1.1 * ((data.upgrades[attacker.id] * 0.1) + 1)
    elseif stellar == 0 then
        damageBuff = damageBuff/(1.1 *((data.upgrades[attacker.id] * 0.1) + 1))
    end
    
    for a = 10,1,-1 do
        for b = 1,5 do
            if alienStats[a][b].name == 'Albot' then
                if not alienAlive[a][1] or not alienAlive[a][2] or not alienAlive[a][3] or not alienAlive[a][4] or not alienAlive[a][5] then
                    local temp1 = math.random(1,5)
                    while alienAlive[a][temp1] do
                        temp1 = math.random(1,5)
                    end
                    local randAlien = math.random(1,9)
                    if randAlien == 1 then
                        alienStats[a][temp1].health = Aliens['Joe'].health
                        alienStats[a][temp1].hevalten = Aliens['Joe'].hevalten
                        alienStats[a][temp1].speed = Aliens['Joe'].speed
                        alienStats[a][temp1].name = Aliens['Joe'].name
                    elseif randAlien == 2 then
                        alienStats[a][temp1].health = Aliens['Gen57'].health
                        alienStats[a][temp1].hevalten = Aliens['Gen57'].hevalten
                        alienStats[a][temp1].speed = Aliens['Gen57'].speed
                        alienStats[a][temp1].name = Aliens['Gen57'].name
                    elseif randAlien == 3 then
                        alienStats[a][temp1].health = Aliens['President'].health
                        alienStats[a][temp1].hevalten = Aliens['President'].hevalten
                        alienStats[a][temp1].speed = Aliens['President'].speed
                        alienStats[a][temp1].name = Aliens['President'].name
                        GameState:setMost(a,temp1)
                    elseif randAlien == 4 then
                        alienStats[a][temp1].health = Aliens['King'].health
                        alienStats[a][temp1].hevalten = Aliens['King'].hevalten
                        alienStats[a][temp1].speed = Aliens['King'].speed
                        alienStats[a][temp1].name = Aliens['King'].name
                        GameState:setMost(a,temp1)
                    elseif randAlien == 5 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['DJ'].health
                        alienStats[a][temp1].hevalten = Aliens['DJ'].hevalten
                        alienStats[a][temp1].speed = Aliens['DJ'].speed
                        alienStats[a][temp1].name = Aliens['DJ'].name
                    elseif randAlien == 6 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['SpaceFence'].health
                        alienStats[a][temp1].hevalten = Aliens['SpaceFence'].hevalten
                        alienStats[a][temp1].speed = Aliens['SpaceFence'].speed
                        alienStats[a][temp1].name = Aliens['SpaceFence'].name
                    elseif randAlien == 7 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['Spaceship'].health
                        alienStats[a][temp1].hevalten = Aliens['Spaceship'].hevalten
                        alienStats[a][temp1].speed = Aliens['Spaceship'].speed
                        alienStats[a][temp1].name = Aliens['Spaceship'].name
                    elseif randAlien == 8 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['VRWorkout'].health
                        alienStats[a][temp1].hevalten = Aliens['VRWorkout'].hevalten
                        alienStats[a][temp1].speed = Aliens['VRWorkout'].speed
                        alienStats[a][temp1].name = Aliens['VRWorkout'].name
                    elseif randAlien == 9 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['OldGranny'].health
                        alienStats[a][temp1].hevalten = Aliens['OldGranny'].hevalten
                        alienStats[a][temp1].speed = Aliens['OldGranny'].speed
                        alienStats[a][temp1].name = Aliens['OldGranny'].name
                    end
                end
            end
        end
    end

    for j = 1, 5 do--hypno shit
        hypnoDone = true
        for i = 10, 1,-1 do
        if i > 1 then
            if alienStats[i][j].hypno and not alienAlive[i-1][j]  and hypnoDone then
                hypnoDone = false
                moveThenKill = true
                GameState:changeStats(i-1,j,i,j)

                GameState:reset(i,j)
            elseif alienStats[i][j].hypno and alienAlive[i-1][j] then
                local temp = alienStats[i-1][j].health
                local win = false

                alienStats[i-1][j].health =  alienStats[i-1][j].health - alienStats[i][j].health
                alienStats[i][j].health =  alienStats[i][j].health - temp
                if alienStats[i][j].health >= 0 and alienStats[i-1][j].health <= 0 then
                    win = true
                end

                if alienStats[i][j].health >= 0 and alienStats[i-1][j].health <= 0 and not moveThenKill then
                    hypnoDone = false
                    GameState:changeStats(i-1,j,i,j)
                    GameState:resetStats(i,j)
                elseif alienStats[i-1][j].health >= 0 and alienStats[i][j].health <= 0  then
                    hypnoDone = false
                    spotTaken[i][j] = false
                    moveThenKill = false
                    GameState:reset(i,j)
                end
                if moveThenKill and win then
                    GameState:resetStats(i-1,j)
                end
                moveThenKill = false

            end
        elseif i == 1 and alienStats[i][j].hypno and hypnoDone then
            GameState:reset(i,j)
        end
        if alienStats[i][j].fly then
            alienStats[i][j].fly = false
        end
        if alienStats[i][j].flyCounter >= 0 and  not alienStats[i][j].fly then
            alienStats[i][j].flyCounter = alienStats[i][j].flyCounter + 1
        end
        if  alienStats[i][j].flyCounter > 2 and not alienStats[i][j].fly then
            alienStats[i][j].fly = true
            alienStats[i][j].flyCounter = 0
        end
        if alienStats[i][j].health <= 0 then
            GameState:reset(i,j)
        end
    end
    end

    for i = 10, 1, -1 do
        for j = 1, 5 do
            if alienAlive[i][j] then
                counter = counter +1
            end
            if alienStats[i][j].name ~= 'Giant' or  alienStats[i][j].giant == 1 then
                alienStats[i][j].giant = 0
                if alienStats[i][j].name == 'Army' then
                    damageBuff = damageBuff - 0.02
                end
                if alienStats[i][j].name == 'Interdimentional' then
                    damageBuff = damageBuff * .75
                end
                if alienAlive[i][j] then
                    local alien = alienStats[i][j]
                    local speed = 1
                    if alienStats[i][j].stunned then
                        speed = 0 -- Stunned aliens cannot move
                    end


                    local destRow = i
                    local canMove = false

                    for k = 1, speed do
                        destRow = destRow + 1
                        if alienAlive[destRow] and not alienStats[destRow][j].stunned then
                            canMove = true
                        else
                            canMove = false
                        break
                        end
                    end

                    if canMove and not alienStats[i][j].hypno and not alienAlive[destRow][j] then
                        if not walls[destRow][j] then
                                GameState:changeStats(destRow,j,i,j)
                                GameState:reset(i,j)
                        else
                            if alienStats[i][j].name == 'Jumper' then
                                local temp = 1
                                while walls[destRow + temp] and walls[destRow + temp][j] do
                                    temp = temp +1
                                end
                                GameState:changeStats(destRow + temp,j,i,j)
                                GameState:reset(i,j)
                            else
                                walls[destRow][j] = false
                            end
                        end
                    end
                end
            else
                alienStats[i][j].giant = 1
            end
        end
    end

    if n ~= nil and not (alienAlive[1][1] and alienAlive[1][2] and alienAlive[1][3] and alienAlive[1][4] and alienAlive[1][5]) then
        while alienAlive[1][n] do
            n = math.random(1, 5)
        end
        if thingy.name == 'DarkArts' then
            GameState:upgrade()
        end
        if thingy.name == 'Virus' then
            weapon1Cooldown = weapon1Cooldown - 1
            weapon2Cooldown = weapon2Cooldown -1
            weapon3Cooldown = weapon3Cooldown -1
        end
        if thingy.name == 'GodOfSpace' then
            GameState:godRand(thingy)
            GameState:godRand(thingy)
            GameState:godRand(thingy)
        end
            
        GameState:makeAlien(1,n,thingy.health,thingy.hevalten,thingy.name)
    end

    for x = 1,10 do
        for y = 1,5 do
            if alienStats[x][y].name == 'Fusion' then
                local tempRow = math.random(1,10)
                local tempLane = math.random(1,5)
                local tempRow1 = math.random(1,10)
                local tempLane1 = math.random(1,5)
                if counter >= 2 then
                    while (not alienAlive[tempRow][tempLane] or not alienAlive[tempRow1][tempLane1]) or (tempRow == tempRow1 or tempLane == tempLane1) do
                        tempRow = math.random(1,10)
                        tempLane = math.random(1,5)
                        tempRow1 = math.random(1,10)
                        tempLane1 = math.random(1,5)
                    end
                    local tempHold = (alienStats[tempRow][tempLane].health + alienStats[tempRow1][tempLane1].health)*1.5
                    local tempAlien = nil
                    GameState:reset(tempRow,tempLane)
                    GameState:reset(tempRow1,tempLane1)
                    for l = 1,27 do
                        if Aliensrand[l].health >= tempHold then
                            tempAlien = Aliensrand[l]
                            break
                        end
                        if l == 27 then
                            tempAlien = Aliensrand[27]
                        end
                    end
                    GameState:makeAlien(tempRow,tempLane,tempAlien.health,tempAlien.hevalten,tempAlien.name)
                end
            end
        end
    end
    for i = 1,10 do
        for j = 1,5 do
            if alienAlive[i][j] then
                if alienStats[i][j].stunned then
                    alienStats[i][j].stunDuration = alienStats[i][j].stunDuration -1
                end
                if alienStats[i][j].stunDuration <= 0 then
                    alienStats[i][j].stunned = false
                end
            end
        end
    end
end

function GameState:attack(weapon)
    attacker = Weapons[weapon]
    attacker.damageAll = attacker.damageAll * ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageLane = attacker.damageLane * ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageTile = attacker.damageTile * ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.poison = attacker.poison * ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageRandLane = attacker.damageRandLane * ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damage = attacker.damage * ((data.upgrades[attacker.id] * 0.1) + 1)

    if attacker.name == 'Death Virus' then
        GameState:DeathVirus()
    end
    if attacker.aoe == 'buff' then
        GameState:StellarBoost()
        stellar = 3
    end
    if attacker.name == 'Protected' then
        GameState:protected()
    end
    if attacker.name == 'Grenade Launcher' then
        GameState:GrenadeLancher()
    end
    if attacker.name == 'Offguard' then
        GameState:Offguard()
    end
    if attacker.name == 'Hypnosis' then
        GameState:Hynosis()
    end
   
    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] and not alienStats[i][j].immmunity then
                local alien = alienStats[i][j]
                local preHealth = alien.health
                if not (alien.name == 'Splashfest') then
                    if GameState:checkGuardian(j) then
                        if attacker.rarity == 'common' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * commonBuff)
                        elseif attacker.rarity == 'rare' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * rareBuff)
                        elseif attacker.rarity == 'scarce' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * scarceBuff)
                        else
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff)
                        end
                    elseif attacker.rarity == 'common' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * commonBuff)
                    elseif attacker.rarity == 'rare' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * rareBuff)
                    elseif attacker.rarity == 'scarce' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * scarceBuff)
                    else
                        alien.health = alien.health - (attacker.damageAll * damageBuff)
                    end
                end

                if attacker.aoe == 'lane' then
                    chooseLane = true
                end

                if attacker.aoe == 'tile'then
                    chooseTile = true
                end

                if alien.health <= 0 then -- check if killed
                    GameState:resetStats(i,j)
                end
                if alien.name == 'OldGranny' and alien.health ~= preHealth and not alienAlive[i+1][j] and not GameState:checkGuardian(j) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alien,preHealth)
            end
        end
    end
    attacker.damageAll = attacker.damageAll / ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageLane = attacker.damageLane / ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageTile = attacker.damageTile / ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.poison = attacker.poison / ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damageRandLane = attacker.damageRandLane / ((data.upgrades[attacker.id] * 0.1) + 1)
    attacker.damage = attacker.damage / ((data.upgrades[attacker.id] * 0.1) + 1)
end

function GameState:attackLane(weapon, lane)
    local weaponTemp = weapon
    if attacker.name == 'Laser Kill' then
        GameState:LaserKill(lane)
    end
    if attacker.name == 'Celestial Disruption' then
        GameState:CelestialDisruption(lane)
    end
    if attacker.name == 'Laser Beam' then
        GameState:LaserBeam(lane)
    end
    if attacker.name == 'Thunder Strike' then
        GameState:ThunderStrike(lane)
    end
    if attacker.name == 'Battle Ram' or attacker.name == 'Hevalstruck' then
        GameState:attackFirst(lane)
    end
    if attacker.name ==  'Dueltroid' then
        GameState:Dueltroid(lane)
    end
    if attacker.name == 'Respawn' then
        GameState:respawn(lane)
    end
    if attacker.name == 'Mind Blast' then
        GameState:MindBlast(lane)
    end
    for i = 10,1,-1 do
        if spotTaken[i][lane] and alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            local alien = alienStats[i][lane]
            local preHealth = alien.health
            if not (alien.name == 'Splashfest') then
                if GameState:checkGuardian(lane) then
                    if attacker.rarity == 'common' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
                    elseif attacker.rarity == 'rare' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * rareBuff)
                    elseif attacker.rarity == 'scarce' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * scarceBuff)
                    else
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff)
                    end
                elseif weaponTemp.rarity == 'common' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff * commonBuff)
                elseif  weaponTemp.rarity == 'rare' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff* rareBuff)
                elseif weaponTemp.rarity == 'scarce' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff*scarceBuff)
                else
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff)
                end
            end
            if weaponTemp.poison > 0 and not GameState:checkGuardian(lane) and not(allGood) then
                GameState:checkPoison(weaponTemp.poison,lane)
            end
            if alien.health <= 0 then
                GameState:resetStats(i,lane)
            end
            if alien.name == 'OldGranny' and alien.health ~= preHealth and not alienAlive[i+1][lane] and not GameState:checkGuardian(lane)then
                GameState:changeStats(i+1,lane,i,lane)
                GameState:reset(i,lane)
            end
            GameState:spawnRand(alien,preHealth)
        end
    end
    if attacker.knockback > 0 then
        GameState:knockback(attacker,lane)
    end
    if attacker.stunDuration > 0 then
        GameState:stun(attacker,lane)
    end
end

function GameState:killAllAliens() -- kills all aliens

    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] then
                GameState:reset(i,j)
            end
            walls[i][j] = false
        end
    end
end

function GameState:checkDead() -- checks if any alien is left
    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] or alienAlive[i][j] then
                    return false
            end
        end
    end
    return true
    
end

function GameState:checkPoison(damage, lane)
    for i = 1, 11 do
        if spotTaken[i][lane] and alienAlive[i][lane] and not(allGood) then
            alienStats[i][lane].poisonDamage = damage
            alienStats[i][lane].poisoned = true
        end
    end
end

function GameState:resetStats(i,j)

    alienAlive[i][j] = false
    spotTaken[i][j] = false
    alienCounter = alienCounter + 1
    data.aliensKilled = data.aliensKilled + 1
    saveData()
    alienStats[i][j].health = 0 
    alienStats[i][j].hevalten = false 
    alienStats[i][j].immmunity = false 
    alienStats[i][j].speed = 1
    alienStats[i][j].poisoned = false
    alienStats[i][j].giant = 0 
    alienStats[i][j].morph = false
    if alienStats[i][j].name == 'Army' then
        damageBuff = damageBuff +.02
    end
    if alienStats[i][j].name == 'CommonCrippler' then
        commonBuff = commonBuff / 0.75
    end
    if alienStats[i][j].name == 'Protected' then
        targetBuff = targetBuff /.5
    end
    if alienStats[i][j].name == 'Rare' then
        rareBuff = rareBuff / 0.8
    end
    if alienStats[i][j].name == 'Scarce' then
        scarceBuff = scarceBuff / 0.85
    end         
    alienStats[i][j].name = ''
    alienStats[i][j].fly = false
    alienStats[i][j].flyCounter = -1
    alienStats[i][j].poisonDamage = 0 
    alienStats[i][j].stunned = false 
    alienStats[i][j].stunDuration = 0
    alienStats[i][j].hypno = false
end

function GameState:applyPoison()
    for i = 1, 10 do
        for j = 1, 5 do
            if alienAlive[i][j] and alienStats[i][j].poisoned and not alienStats[i][j].immmunity and not(GameState:checkGuardian(j))  and not(allGood) then
                alienStats[i][j].health = alienStats[i][j].health - alienStats[i][j].poisonDamage * damageBuff
                if alienStats[i][j].health <= 0 then
                    GameState:resetStats(i, j)
                end
                if alienStats[i][j].name == 'OldGranny' and not alienAlive[i+1][j] and not GameState:checkGuardian(j) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alienStats[i][j])
            end
        end
    end
end

function GameState:attackTile(weapon, row,lane)
    local weaponTemp = weapon
    if attacker.name == 'Star Blast' then
        GameState:starBlast(row,lane)
    end
    if attacker.name == 'Fresh Start' then
        GameState:FreshStart(row,lane)
    end
    if attacker.name == 'Comet Strike' then
        GameState:CometStrike(row,lane)
    end
    GameState:makeDead()
        if alienAlive[row][lane] and not alienStats[row][lane].immmunity  then
            local alien = alienStats[row][lane]
            local preHealth = alien.health
            if GameState:checkGuardian(lane) then
                local g = GameState:findGuardian(lane)
                if attacker.rarity == 'common' then
                    alienStats[g][lane].health = alienStats[g][lane].health - (attacker.damageTile * damageBuff * commonBuff*targetBuff)
                elseif attacker.rarity == 'rare' then
                    alienStats[g][lane].health = alienStats[g][lane].health - (attacker.damageTile * damageBuff * rareBuff*targetBuff)
                elseif attacker.rarity == 'scarce' then
                    alienStats[g][lane].health = alienStats[g][lane].health - (attacker.damageTile * damageBuff * scarceBuff*targetBuff)
                else
                    alienStats[g][lane].health = alienStats[g][lane].health - (attacker.damageTile * damageBuff*targetBuff)
                end
            elseif weaponTemp.rarity == 'common' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff * commonBuff * targetBuff)
            elseif weaponTemp.rarity == 'rare' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*rareBuff*targetBuff)
            elseif weaponTemp.rarity == 'scarce' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*scarceBuff*targetBuff)
            else
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*targetBuff)
            end
            if weaponTemp.poison > 0 and not GameState:checkGuardian(lane) then
                GameState:checkPoison(weaponTemp.poison,lane)
            end
            if alien.health <= 0 then
                GameState:resetStats(row,lane)
            end
            if alienStats[row][lane].name == 'OldGranny' and preHealth ~= alien.health and not alienAlive[row+1][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+1,lane,row,lane)
            end
            GameState:spawnRand(alienStats[row][lane],preHealth)
        end
end

function checkStunned(row, lane)
    if alienAlive[row][lane] and alienStats[row][lane].stunned then
        if alienStats[row][lane].stunDuration <= 0 then
            alienStats[row][lane].stunned = false
            alienStats[row][lane].stunDuration = 0
        else
            alienStats[row][lane].stunDuration = alienStats[row][lane].stunDuration - 1
        end
    end
    return alienStats[row][lane].stunned
end

function GameState:stun(weapon, lane)
   local stunCounter = 0
    for i = 10, 1, -1 do
        if stunCounter < attacker.stun and not(allGood) then
            if alienAlive[i][lane] and not alienStats[i][lane].stunned and not alienStats[i][lane].immmunity  then
                stunCounter = stunCounter + 1
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = weapon.stunDuration
            end
        end
    end
end

function GameState:starBlast(row,lane)
    if alienAlive[row][lane] and not alienStats[row][lane].immmunity and not(alienStats[row][lane].name == 'Splashfest') then
        if GameState:checkGuardian(lane) then
            alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
        else
            alienStats[row][lane].health = alienStats[row][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
        end
        if alienStats[row][lane].name == 'OldGranny' and not alienAlive[row+1][lane] and not GameState:checkGuardian(lane) then
            GameState:changeStats(row+1,lane,row,lane)
        end
        GameState:spawnRand(alienStats[row][lane])
    end
    if lane -1 > 0 and not alienStats[row][lane-1].immmunity and not(alienStats[row][lane-1].name == 'Splashfest') and alienAlive[row][lane-1] then
        if alienAlive[row][lane-1] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane-1)][lane-1].health = alienStats[GameState:findGuardian(lane-1)][lane-1].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row][lane-1].health = alienStats[row][lane-1].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row][lane-1].name == 'OldGranny' and not alienAlive[row+1][lane-1] and not GameState:checkGuardian(lane-1) then
                GameState:changeStats(row+1,lane-1,row,lane-1)
            end
            GameState:spawnRand(alienStats[row][lane-1])
        end
    end
    if lane +1 < 6 and not alienStats[row][lane+1].immmunity and not(alienStats[row][lane+1].name == 'Splashfest') and alienAlive[row][lane+1] then
        if alienAlive[row][lane+1] then
            if GameState:checkGuardian(lane+1) then
                alienStats[GameState:findGuardian(lane+1)][lane+1].health = alienStats[GameState:findGuardian(lane+1)][lane+1].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row][lane+1].health = alienStats[row][lane+1].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row][lane+1].name == 'OldGranny' and not alienAlive[row+1][lane+1] and not GameState:checkGuardian(lane+1) then
                GameState:changeStats(row+1,lane+1,row,lane+1)
            end
            GameState:spawnRand(alienStats[row][lane+1])
        end
    end
    if row +1 < 11 and not alienStats[row+1][lane].immmunity and not(alienStats[row+1][lane].name == 'Splashfest') and alienAlive[row+1][lane] then
        if alienAlive[row+1][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row+1][lane].health = alienStats[row+1][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row+1][lane].name == 'OldGranny' and not alienAlive[row+2][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+2,lane,row+1,lane)
            end
            GameState:spawnRand(alienStats[row+1][lane])
        end
    end
    if row +2 < 11 and not alienStats[row+2][lane].immmunity and not(alienStats[row+2][lane].name == 'Splashfest') and alienAlive[row+2][lane] then
        if alienAlive[row+2][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row+2][lane].health = alienStats[row+2][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row+2][lane].name == 'OldGranny' and not alienAlive[row+3][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+3,lane,row+2,lane)
            end
            GameState:spawnRand(alienStats[row+2][lane])
        end
    end
    if row -1 > 0 and not alienStats[row-1][lane].immmunity and not(alienStats[row-1][lane].name == 'Splashfest') and alienAlive[row-1][lane] then
        if alienAlive[row-1][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row-1][lane].health = alienStats[row-1][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row-1][lane].name == 'OldGranny' and not alienAlive[row][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row,lane,row-1,lane)
            end
            GameState:spawnRand(alienStats[row-1][lane])
        end
    end
    if row -2 > 0 and not alienStats[row-2][lane].immmunity and not(alienStats[row-2][lane].name == 'Splashfest') and alienAlive[row-2][lane] then
        if alienAlive[row-2][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row-2][lane].health = alienStats[row-2][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row-2][lane].name == 'OldGranny' and not alienAlive[row-1][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row-1,lane,row-2,lane)
            end
            GameState:spawnRand(alienStats[row-2][lane])
        end
    end
end

function GameState:LaserKill(lane)

    for i = 10, 1, -1 do
        if alienAlive[i][lane] and alienStats[i][lane].health <= (attacker.damage * ((data.upgrades[attacker.id] * 0.1) + 1)) and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 0
        end
    end
end

function GameState:StellarBoost()
    damageBuff = damageBuff * 1.2 * ((data.upgrades[attacker.id] * 0.1) + 1)
end

function GameState:ThunderStrike(lane)
    local odds = true
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            while odds do
                local value = math.random(1,3)
                if value == 1 then
                    alienStats[i][lane].stunned = true
                    alienStats[i][lane].stunDuration = math.round(2 * ((data.upgrades[attacker.id] * 0.1) + 1))
                    break
                else
                    odds = false
                end
            end
        end
    end
end

function GameState:knockback(weapon, lane)
    local done = true
    local first = true
    local fixed = false
    for i = 10, 2, -1 do
        if alienAlive[i][lane] and done and not alienStats[i][lane].immmunity and not GameState:checkGuardian(lane) and not(allGood) then
                done = false

            if not alienAlive[i-1][lane] then
                GameState:changeStats(i-1,lane,i,lane)

                GameState:reset(i,lane)

            else
                local temp = i
                local counter = 1
                while temp > 1 and alienAlive[temp-1][lane] do
                    counter = counter + 1
                    temp = temp-1
                end
                while counter > 0 and temp > 1 do
                    GameState:changeStats(i-counter,lane,i-counter + 1,lane)
                    GameState:reset(i-counter +1,lane)
                    counter = counter -1
                end
            end


        end
    end
end

function GameState:attackFirst(lane)
    local done = true
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and done and not alienStats[i][lane].immmunity then
            done = false
            local preHealth = alienStats[i][lane].health
            if attacker.name == 'Hevalstruck' and alienStats[1][lane].hevalten then
                if GameState:checkGuardian(lane) then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * rareBuff * 2)
                else
                    alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff *rareBuff* 2)
                end
            elseif attacker.name == 'Mind Blast' then
                if GameState:checkGuardian(lane) then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * scarceBuff)
                else
                    alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*scarceBuff)
                end
                if not(allGood) then
                    if not GameState:checkGuardian(lane) then
                        if alienStats[i][lane].health > 0 then
                            alienStats[i][lane].hypno = true
                        end
                    end
                end
            elseif attacker.name == 'Hypnosis' then
                if not(allGood) then
                    if not GameState:checkGuardian(lane) then
                        alienStats[i][lane].hypno = true
                        alienStats[i][lane].health = alienStats[i][lane].health + 1
                    else
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health +1
                    end
                end
            elseif GameState:checkGuardian(lane) then
                if attacker.rarity == 'common' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * commonBuff)
                elseif attacker.rarity == 'rare' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * rareBuff)
                elseif attacker.rarity == 'scarce' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * scarceBuff)
                else
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff)
                end
            elseif attacker.rarity == 'common' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff * commonBuff)
            elseif attacker.rarity == 'rare' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*rareBuff)
            elseif attacker.rarity == 'scarce' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*scarceBuff)
            else
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff)
            end
            if alienStats[i][lane].name == 'OldGranny' and not alienAlive[i][lane] and preHealth ~= alienStats[i][lane].health and not GameState:checkGuardian(lane) then
                GameState:changeStats(i+1,lane,i,lane)
            end
            GameState:spawnRand(alienStats[i][lane],preHealth)
        end
    end
end
function GameState:Dueltroid(lane)
    local which = math.random(1,2)
    local first = true
    local second = true
    local secondCount = 0
    if which == 1 then
        for i = 10, 1, -1 do
            if alienAlive[i][lane] and first and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly and not(allGood) then
                first = false
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = math.round(5 * ((data.upgrades[attacker.id] * 0.1) + 1))
            end
        end
    else
        for i = 10, 1, -1 do
            if alienAlive[i][lane] and second and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly and not(allGood) then
                secondCount = secondCount +1
                if secondCount >= 2 then second = false end
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = math.round(3*((data.upgrades[attacker.id] * 0.1) + 1))
            end
        end
    end
end
function GameState:FreshStart(row,lane)
    row = math.max(row, 2) -- row 1 would index alienAlive[0]
    if lane == 1 then
        if row == 10 then
            for i = 10, 9,-1 do
                for j = 1, 2 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                       GameState:changeStats(i-8,j,i,j)
                        GameState:reset(i,j)
                    end
                end
            end
        else
            for i = row-1, row+1 do
                for j = 1, 2 do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                            GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    elseif lane == 5 then
        if row == 10 then
            for i = 10, 9,-1 do
                for j = 4, 5 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                        GameState:changeStats(i-8,j,i,j)
                       GameState:reset(i,j)
                    end
                end
            end
        else
            for i = row-1, row+1 do
                for j = 4, 5 do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                            GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    else
        if row == 10 then
            for i = 10, 9,-1 do
                for j = lane-1, lane+1 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                        GameState:changeStats(i-8,j,i,j)
                        GameState:reset(i,j)
                     end
                end
            end
        else
            for i =row-1,row+1 do
                for j = lane-1, lane+1  do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                                GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                                GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                                GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    end
end
function GameState:respawn(lane)
    respawnLane = lane
end
function GameState:LaserBeam(lane)

    for i = 10, 1, -1 do
        if alienAlive[i][lane] and alienStats[i][lane].health <= (attacker.damage* ((data.upgrades[attacker.id] * 0.1) + 1)) and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 0
        end
    end
end
function GameState:GrenadeLancher()
    for i = 10, 1, -9 do
        for j = 1, 5 do
            if alienAlive[i][j] and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest')  then
                local preHealth = alienStats[i][j].health
                if GameState:checkGuardian(j) then
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*scarceBuff)
                else
                    alienStats[i][j].health = alienStats[i][j].health - attacker.damage*scarceBuff*damageBuff
                end
                if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(j) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alienStats[i][j],preHealth)
            end
        end
    end
end
function GameState:DeathVirus()
    local lane = math.random(1,5)
    for i = 10,1,-1 do
        if alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly  then
            alienAlive[i][lane] = false
            GameState:resetStats(i,lane)

        end
    end

end
function GameState:CelestialDisruption(lane)
    local counter = 0
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and (not alienStats[i][lane].hevalten) and counter < 4 and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 1
            counter = counter + 1
        end
    end
end
function GameState:Offguard()
     for i = 10, 1,-1 do
        for j = 1,5 do
            if alienAlive[i][j] and not alienStats[i][j].stunned and not alienStats[i][j].immmunity and not(allGood) then
                alienStats[i][j].stunned = true
                alienStats[i][j].stunDuration = math.round(2*((data.upgrades[attacker.id] * 0.1) + 1))
            end
        end
    end
end
function GameState:CometStrike(row,lane)
    if lane == 1 then
        if row == 1 then
            for i = 1, 2 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j] and not alienStats[i][j].immmunity  and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i = row-1, row+1 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j] and not alienStats[i][j].immmunity  and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    elseif lane == 5 then
        if row == 1 then
            for i = 1, 2 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]   and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i = row-1, row+1 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    else
        if row == 1 then
            for i = 1, 2 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i =row-1,row+1 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    end
end
function GameState:MindBlast(lane)
    GameState:attackFirst(lane)
end
function GameState:Hynosis()
    GameState:attackFirst(1)
    GameState:attackFirst(2)
    GameState:attackFirst(3)
    GameState:attackFirst(5)
    GameState:attackFirst(4)
end
function GameState:makeDead()
    for i = 10,1,-1 do
        for j = 1,5 do
            if alienStats[i][j].health <= 0 and alienAlive[i][j] then
                GameState:resetStats(i,j)

            end
        end
    end
end
function GameState:changeStats(desI,desJ,norI,norJ)
    alienAlive[desI][desJ] = alienAlive[norI][norJ]
    spotTaken[desI][desJ] = spotTaken[norI][norJ]
    alienStats[desI][desJ].health = alienStats[norI][norJ].health
    alienStats[desI][desJ].speed = alienStats[norI][norJ].speed
    alienStats[desI][desJ].stunned = alienStats[norI][norJ].stunned
    alienStats[desI][desJ].hevalten = alienStats[norI][norJ].hevalten
    alienStats[desI][desJ].immmunity = alienStats[norI][norJ].immmunity
    alienStats[desI][desJ].poisoned = alienStats[norI][norJ].poisoned
    alienStats[desI][desJ].giant = alienStats[norI][norJ].giant
    alienStats[desI][desJ].morph = alienStats[norI][norJ].morph
    alienStats[desI][desJ].name = alienStats[norI][norJ].name
    alienStats[desI][desJ].fly = alienStats[norI][norJ].fly
    alienStats[desI][desJ].flyCounter = alienStats[norI][norJ].flyCounter
    alienStats[desI][desJ].poisonDamage = alienStats[norI][norJ].poisonDamage
    alienStats[desI][desJ].stunDuration = alienStats[norI][norJ].stunDuration
    alienStats[desI][desJ].hypno = alienStats[norI][norJ].hypno
end
function GameState:reset(i,j)
    alienAlive[i][j] = false
    spotTaken[i][j] = false
    alienStats[i][j].health = 0 
    alienStats[i][j].giant = 0 
    alienStats[i][j].morph = false
    alienStats[i][j].hevalten = false 
    alienStats[i][j].immmunity = false 
    alienStats[i][j].speed = 1
    alienStats[i][j].poisoned = false
    alienStats[i][j].name = ''
    alienStats[i][j].fly = false
    alienStats[i][j].flyCounter = -1
    alienStats[i][j].poisonDamage = 0 
    alienStats[i][j].stunned = false 
    alienStats[i][j].stunDuration = 0
    alienStats[i][j].hypno = false
end
function GameState:setMost(a,temp1)
    spotTaken[a][temp1] = true
    alienAlive[a][temp1] = true
    alienStats[a][temp1].morph = false
    alienStats[a][temp1].poisoned = false
    alienStats[a][temp1].giant = 0
    alienStats[a][temp1].fly = false
    alienStats[a][temp1].poisonDamage = 0
    alienStats[a][temp1].stunned = false
    alienStats[a][temp1].morph = false
    alienStats[a][temp1].stunDuration = 0
    alienStats[a][temp1].hypno = false
end
function GameState:morph(i,j)
    local temp = math.random(1,data.aliensUnlocked)
    
    local stats = {}
    stats.giant = 0
    stats.morph = true
    stats.poisoned = alienStats[i][j].poisoned
    stats.speed = 1
    stats.poisonDamage = alienStats[i][j].poisonDamage
    stats.stunned = alienStats[i][j].stunned
    stats.stunDuration = alienStats[i][j].stunDuration
    stats.stunned = alienStats[i][j].stunned
    stats.hypno = alienStats[i][j].hypno
    stats.fly = false

    stats.flyCounter = -1
    stats.immmunity = false
    for k = 1,data.aliensUnlocked do
        if temp == k then
            stats.health= (alienStats[i][j].health/Aliens[alienStats[i][j].name].health)*Aliensrand[k].health
            stats.hevalten = Aliensrand[k].hevalten
            stats.name = Aliensrand[k].name
            if stats.name == 'SpaceFence' then stats.immmunity = true end
            if stats.name == 'Spaceship' then stats.flyCounter = 0 end
        end
    end
    return stats
end
function GameState:makeAlien(row,n,health,hevalten,name)
    if name == 'SpaceFence' then
        alienStats[row][n].immmunity = true
    else
        alienStats[row][n].immmunity = false
    end
    if name == 'Spaceship' then
        alienStats[row][n].flyCounter = 0
    else
        alienStats[row][n].flyCounter = -1
    end
    if name == 'Morpher' then
        alienStats[row][n].morph = true
    else
        alienStats[row][n].morph = false
    end
    spotTaken[row][n] = true
    alienAlive[row][n] = true
    alienStats[row][n].health = health
    alienStats[row][n].hevalten = hevalten
    alienStats[row][n].speed = 1
    alienStats[row][n].poisoned = false
    alienStats[row][n].giant = 0
    alienStats[row][n].name = name
    alienStats[row][n].fly = false
    alienStats[row][n].poisonDamage = 0
    alienStats[row][n].stunned = false
    alienStats[row][n].stunDuration = 0
    alienStats[row][n].hypno = false
    if alienStats[row][n].name == 'Army' then
        damageBuff = damageBuff - 0.02
    end
    if alienStats[row][n].name == 'CommonCrippler' then
        commonBuff = commonBuff * 0.75
    end
    if alienStats[row][n].name == 'Protected' then
        targetBuff = targetBuff * .5
    end
    if alienStats[row][n].name == 'Rare' then
        rareBuff = rareBuff * 0.8
    end
    if alienStats[row][n].name == 'Scarce' then
        scarceBuff = scarceBuff * 0.85
    end
    if alienStats[row][n].name == 'GodOfSpace' then
        allGood = true
    end
end
function GameState:spawnRand(alien,preHealth)
    local temp = math.random(1,data.aliensUnlocked)
    local alive3 = false
    for i = 1,3 do
        for j = 1,5 do
            if not alienAlive[i][j] then 
                alive3 = true 
            end
        end
    end
    if preHealth == nil then preHealth = -293939238 end
    if alien.name == 'TheHevalGod' and alien.health ~= preHealth and alive3 then
        for k = 1,data.aliensUnlocked do
            if temp == k then
                local randRow = math.random(1,3)
                local randLane = math.random(1,5)
                while alienAlive[randRow][randLane] do
                    randRow = math.random(1,3)
                    randLane = math.random(1,5)
                end
                GameState:makeAlien(randRow,randLane,Aliensrand[k].health,Aliensrand[k].hevalten,Aliensrand[k].name)
            end
        end
    end
end
function GameState:upgrade()
    for num = 26,1,-1 do
        for i = 1, 10 do
            for j = 1, 5 do

                if alienAlive[i][j] and alienStats[i][j].name == Aliensrand[num].name then
                    local health = alienStats[i][j].health
                    local name = alienStats[i][j].name
                    GameState:reset(i,j)
                    GameState:makeAlien(i,j,(health/(Aliens[name].health))*Aliensrand[num+1].health,Aliensrand[num+1].hevalten,Aliensrand[num+1].name)
                end
            end
        end
    end
end
function GameState:checkGuardian(j)
    for i = 10,1,-1 do
        if alienStats[i][j].name == 'Guardian' then
            return true
        end
    end
    return false
end
function GameState:findGuardian(j)
    for i = 10,1,-1 do
        if alienStats[i][j].name == 'Guardian' then
            return i
        end
    end
end
function GameState:godRand(thingy)
    local alive3 = false
    for i = 1,3 do
        for j = 1,5 do
            if not alienAlive[i][j] then 
                alive3 = true 
            end
        end
    end
    local temp2 = math.random(1,data.aliensUnlocked)
    if thingy.name == 'GodOfSpace' and alive3 then
        for k = 1,data.aliensUnlocked do
            if temp2 == k then
                local randRow = math.random(1,3)
                local randLane = math.random(1,5)
                while alienAlive[randRow][randLane] do
                    randRow = math.random(1,3)
                    randLane = math.random(1,5)
                end
                GameState:makeAlien(randRow,randLane,Aliensrand[k].health,Aliensrand[k].hevalten,Aliensrand[k].name)
            end
        end
    end
end
function GameState:enter(item)
    if item == 'quit' then
        stage = 'first'
        GameState:switchStage()
        gStateMachine:change('home')
    end
    if item == 'bomb' then
        if stage == 'second' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('result', {won = true})
        elseif stage == 'third' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('result', {won = true})
        elseif stage == 'first' then
            stage = 'third'
            GameState:switchStage()
        end
    elseif item == 'zap' then
        local rand = math.random(1,5)
        for i = 10, 1, -1 do
            if not(allGood) then
                if alienAlive[i][rand] and not alienStats[i][rand].stunned and not alienStats[i][rand].immmunity  then
                    alienStats[i][rand].stunned = true
                    alienStats[i][rand].stunDuration = 3
                end
            end
        end
    elseif item == 'electricity' then
        for i = 10, 1, -1 do
            for j = 1,5 do
                if not(allGood) then
                    if alienAlive[i][j] and not alienStats[i][j].stunned and not alienStats[i][j].immmunity  then
                        alienStats[i][j].stunned = true
                        alienStats[i][j].stunDuration = 2
                    end
                end
            end
        end
    elseif item == 'retreat' then
        if stage == 'second' then
            stage = 'third'
            GameState:switchStage()
        elseif stage == 'third' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('result', {won = true})
        elseif stage == 'first' then
            stage = 'second'
            GameState:switchStage()
        end
    elseif item == 'teleporter' then
        local done = false
        local i = math.random(1,10)
        local j = math.random(1,5)
        local alive = false
        for a = 1,10 do
            for b =1,5 do
                if alienAlive[a][b] then
                    alive = true
                end
            end
        end
        while not alienAlive[i][j] and alive do
            i = math.random(1,10)
            j = math.random(1,5)
        end
        if alive then GameState:resetStats(i,j) end
    elseif item == 'gold' then
        data.goldBuff = 2
        saveData()
    elseif item == 'protection' then
        damageBuff = damageBuff * 1.5
    elseif item == 'walls' then
        local allLanesFull = checkAllLanesFull()

        if not allLanesFull then
            data.walls = data.walls + 1
            saveData()
        else
            local lane = math.random(1, 5)
            while not goodLane(lane) do
                lane = math.random(1, 5)
            end
            local row = math.random(2,10)
            while walls[row][lane] do
                row = math.random(2,10)
            end
            walls[row][lane] = true
        end
    end
end
function checkAllLanesFull()
    for j = 1, 5 do
        if goodLane(j) then
            return true
        end
    end
    return false
end
function goodLane(j)
    return checkLane(j) and checkWall(j)
end
function GameState:switchStage()
    weapon1Clicked = false
    weapon2Clicked = false
    weapon3Clicked = false
    alienCounter = 0
    mousePressed = true
    weapon1Cooldown = 0
    weapon2Cooldown = 0
    weapon3Cooldown = 0
    chooseLane = false
    damageBuff = 1
    scarceBuff = 1
    rareBuff = 1
    commonBuff = 1
    targetBuff = 1
    chooseTile = false
    allGood = false
    stellar = 0
    respawnLane = 0
    GameState:killAllAliens()
    GameState:resetPresentation()
end
function checkLane(j)
    for i = 1,10 do
        if alienStats[i][j].name == 'Gardener' then
            return false
        end
    end
    return true
end
function checkWall(j)
    for i = 2,10 do
        if not walls[i][j] then
            return true
        end
    end
    return false
end
function GameState:protected()
    damageBuff = damageBuff * 1.0125
end
