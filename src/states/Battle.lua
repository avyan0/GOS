-- Battle screen: rendering + input only. Rules live in src/battle.lua.
local B = require 'src/battle'

GameState = Class{}

local FIELD_X, FIELD_Y, LANE_W, ROW_H = 40, 12, 188, 58
local SIDE_X, SIDE_W = 1000, 240
local KEYS = {'A', 'S', 'D'}
local ITEM_LABEL = {walls = 'Wall', zap = 'Zap', gold = 'Double Gold', electricity = 'Electricity', retreat = 'Retreat', bomb = 'Bomb', teleporter = 'Teleporter', protection = 'Protection'}

local popups = {}
local lastHP = {}
local active = false   -- a battle is in progress (survives Pause round-trips)

local function laneAt(x) if x < FIELD_X or x > FIELD_X + LANE_W * 5 then return nil end return math.floor((x - FIELD_X) / LANE_W) + 1 end
local function rowAt(y) if y < FIELD_Y or y > FIELD_Y + ROW_H * 10 then return nil end return math.floor((y - FIELD_Y) / ROW_H) + 1 end
local function cellCenter(i, j) return FIELD_X + (j - 0.5) * LANE_W, FIELD_Y + (i - 0.5) * ROW_H end

local function resetPresentation()
    popups = {}
    lastHP = {}
end

local function finish(result)
    if result == 'lose' then active = false; gStateMachine:change('result', {won = false})
    elseif result == 'win' then active = false; gStateMachine:change('result', {won = true})
    elseif result == 'stage' then resetPresentation(); gStateMachine:change('stageSelect', {stage = B.state().stage}) end
end

function GameState:enter(item)
    if item == 'quit' then
        active = false
        gStateMachine:change('home')
        return
    end
    if not active then
        B.start()
        resetPresentation()
        active = true
    else
        B.reloadSlots()
    end
    if item then
        local r = B.useItem(item)
        if r == false then
            for _, it in ipairs(ITEMS) do if ITEM_LABEL[item] == it.name then data[it.stat] = data[it.stat] + 1 end end
            ui.toast('No room for a ' .. ITEM_LABEL[item], ui.c.warn)
        else
            ui.toast(ITEM_LABEL[item] .. ' used', ui.c.good)
            finish(r)
        end
    end
end

function GameState:update(dt)
    if love.keyboard.wasPressed('a') then B.fire(1)
    elseif love.keyboard.wasPressed('s') then B.fire(2)
    elseif love.keyboard.wasPressed('d') then B.fire(3)
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('kpenter') then finish(B.endTurn())
    end
    local s = B.state()
    if s.aim and s.aim.kind == 'lane' then
        for l = 1, 5 do if love.keyboard.wasPressed(tostring(l)) then B.aimLane(l) end end
    end
end

function GameState:keyPressed(key)
    local s = B.state()
    if key == 'escape' and s.aim then B.cancelAim()
    elseif key == 'escape' or key == 'p' then gStateMachine:change('pause') end
end

function GameState:mousePressed(x, y)
    local s = B.state()
    local lane, row = laneAt(x), rowAt(y)
    if s.aim and lane and row then
        if s.aim.kind == 'lane' then B.aimLane(lane) else B.aimTile(row, lane) end
    end
end

local function trackDamage()
    for i = 1, B.ROWS do
        lastHP[i] = lastHP[i] or {}
        for j = 1, B.LANES do
            local a = B.alienAt(i, j)
            local hp = a and a.health or nil
            local last = lastHP[i][j]
            if hp and last and hp < last - 0.5 then
                local cx, cy = cellCenter(i, j)
                popups[#popups + 1] = {x = cx + math.random(-16, 16), y = cy - 12, text = '-' .. math.round(last - hp), t = 0, color = ui.c.warn}
            end
            lastHP[i][j] = hp
        end
    end
end

local TARGET_LABEL = {field = 'Field', lane = 'Lane', tile = 'Tile', self = 'Buff'}

function GameState:render(dimmed)
    local s = B.state()
    if not s then return end
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
            ui.color(ui.c.panel, ((i + j) % 2 == 0) and 0.8 or 0.55)
            love.graphics.rectangle('fill', x + 1, y + 1, LANE_W - 2, ROW_H - 2, 4, 4)
            if s.walls[i][j] then
                ui.color(ui.c.warn, 0.85); love.graphics.rectangle('fill', x + 6, y + ROW_H - 12, LANE_W - 12, 6, 3, 3)
            end
        end
        if s.lockedLane == j then
            ui.color(ui.rarity.scarce, 0.12); love.graphics.rectangle('fill', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
        end
        if s.aim and s.aim.kind == 'lane' and hoverLane == j and not dimmed then
            ui.color(ui.c.accent, 0.18); love.graphics.rectangle('fill', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
            ui.color(ui.c.accent, 0.9); love.graphics.setLineWidth(2); love.graphics.rectangle('line', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
        end
    end
    if s.aim and s.aim.kind == 'tile' and hoverLane and hoverRow and not dimmed then
        local x, y = FIELD_X + (hoverLane - 1) * LANE_W, FIELD_Y + (hoverRow - 1) * ROW_H
        ui.color(ui.c.accent, 0.25); love.graphics.rectangle('fill', x, y, LANE_W, ROW_H, 4, 4)
        ui.color(ui.c.accent); love.graphics.setLineWidth(2); love.graphics.rectangle('line', x, y, LANE_W, ROW_H, 4, 4)
    end
    for j = 1, 5 do ui.text(tostring(j), FIELD_X + (j - 1) * LANE_W, FIELD_Y + ROW_H * 10 + 6, LANE_W, 'center', 'hud', 14, ui.c.dim) end
    ui.color(ui.c.danger, 0.7); love.graphics.rectangle('fill', FIELD_X, FIELD_Y + ROW_H * 10 + 26, LANE_W * 5, 4, 2, 2)
    ui.text('BASE', FIELD_X, FIELD_Y + ROW_H * 10 + 34, LANE_W * 5, 'center', 'hud', 14, ui.c.danger)

    -- aliens
    B.each(function(a, i, j)
        local def = Aliens[a.name]
        local cx, cy = cellCenter(i, j)
        local bob = a.fly and math.sin(t * 6 + i + j) * 3 or 0
        local ax = cx - 56
        icons.alien(def.spec, ax, cy - 2 + bob, 40, a.fly and 0.55 or 1)
        love.graphics.setLineWidth(2)
        if a.stun > 0 then ui.color(ui.c.warn); love.graphics.circle('line', ax, cy - 2, 20) end
        if a.hypno then ui.color(ui.rarity.scarce); love.graphics.circle('line', ax, cy - 2, 23) end
        if a.immune > 0 then ui.color(ui.c.gold); love.graphics.circle('line', ax, cy - 2, 25) end
        ui.text(def.title, ax + 26, cy - 24, LANE_W - 60, 'left', 'body', 12, ui.c.muted)
        ui.text(tostring(math.max(0, math.round(a.health))), ax + 26, cy - 10, LANE_W - 60, 'left', 'hud', 16)
        ui.progress(ax + 26, cy + 12, LANE_W - 70, 5, math.max(0, math.min(1, a.health / a.maxHealth)), a.hevalten and ui.c.danger or ui.c.good, ui.c.bg)
        local gx = ax + 26
        if a.poison > 0 then ui.text('P', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.good); gx = gx + 14 end
        if a.stun > 0 then ui.text('S' .. a.stun, gx, cy + 18, 30, 'left', 'hud', 11, ui.c.warn); gx = gx + 20 end
        if a.hypno then ui.text('H', gx, cy + 18, 20, 'left', 'hud', 11, ui.rarity.scarce); gx = gx + 14 end
        if a.immune > 0 then ui.text('I', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.gold); gx = gx + 14 end
        if a.fly then ui.text('F', gx, cy + 18, 20, 'left', 'hud', 11, ui.c.accent) end
    end)

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
    ui.text('Level ' .. lvl .. '   -   Turn ' .. s.turn, SIDE_X + 16, 44, SIDE_W - 32, 'left', 'body', 14, ui.c.muted)
    ui.text('Stage ' .. s.stage .. ' of 3', SIDE_X + 16, 70, 110, 'left', 'body', 15)
    ui.text(s.kills .. ' / ' .. s.needed, SIDE_X + 16, 68, SIDE_W - 32, 'right', 'hud', 18, ui.c.accent)
    ui.progress(SIDE_X + 16, 98, SIDE_W - 32, 6, s.needed > 0 and s.kills / s.needed or 0, ui.c.accent)
    local mult = s.buff * (s.stellar and s.stellar.mult or 1)
    if math.abs(mult - 1) > 0.001 then
        ui.text(string.format('Damage x%.2f', mult), SIDE_X + 16, 108, SIDE_W - 32, 'right', 'hud', 12, mult > 1 and ui.c.good or ui.c.danger)
    end

    -- weapon cards
    for n, slot in ipairs(s.slots) do
        local w = Weapons[slot.id]
        local y = 124 + (n - 1) * 118
        local color = w and ui.rarity[w.rarity] or ui.c.dim
        local ready = w and not slot.used and not s.aim
        local aiming = s.aim and s.aim.slot == n
        local hover = ui.hovered(SIDE_X + 12, y, SIDE_W - 24, 108)
        ui.panel(SIDE_X + 12, y, SIDE_W - 24, 108, {fill = (ready or aiming) and ui.c.panel2 or ui.c.bg2, border = aiming and ui.c.accent or ((hover and ready and not dimmed) and color or ui.c.line), radius = 10})
        if w then
            local rule = B.WEAPON_RULES[w.id]
            icons.weapon(w.shape, SIDE_X + 40, y + 34, 38, (ready or aiming) and color or ui.c.dim)
            ui.text(w.name, SIDE_X + 68, y + 14, SIDE_W - 90, 'left', 'display', 15, (ready or aiming) and ui.c.text or ui.c.dim)
            local dmg = w.damage > 0 and ('   -   ' .. math.round(w.damage * ((data.upgrades[w.id] or 0) * 0.1 + 1))) or ''
            ui.text((TARGET_LABEL[rule.kind] or rule.kind) .. dmg, SIDE_X + 68, y + 38, SIDE_W - 90, 'left', 'body', 13, ui.c.muted)
            local status
            if aiming then status = 'AIMING'
            elseif not slot.used then status = 'READY   -   ' .. KEYS[n]
            elseif w.cooldown > 0 then status = 'RECHARGING ' .. slot.cd .. '/' .. w.cooldown
            else status = 'USED THIS TURN' end
            ui.text(status, SIDE_X + 24, y + 80, SIDE_W - 48, 'left', 'hud', 12, (ready or aiming) and color or ui.c.dim)
            if w.cooldown > 0 then ui.pips(SIDE_X + SIDE_W - 24 - w.cooldown * 12, y + 84, w.cooldown, slot.used and slot.cd or w.cooldown, color, 7, 5) end
        end
        if not dimmed and ready and ui.hit(SIDE_X + 12, y, SIDE_W - 24, 108) then B.fire(n) end
    end

    local py = 124 + 3 * 118 + 4
    if s.aim then
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = ui.c.accent, border = false, radius = 10})
        local shots = s.aim.rule.shots or 1
        local msg = s.aim.kind == 'lane' and 'Click a lane' or ('Click a tile' .. (shots > 1 and ('  (' .. (shots - s.aim.remaining + 1) .. '/' .. shots .. ')') or ''))
        ui.textBox(msg, SIDE_X + 12, py, SIDE_W - 24, 40, 'display', 17, ui.c.bg)
        ui.textBox('Esc to cancel', SIDE_X + 12, py + 34, SIDE_W - 24, 24, 'body', 12, ui.c.bg)
    else
        if ui.button('End turn', SIDE_X + 12, py, SIDE_W - 24, 64, {size = 22, id = 'endturn', disabled = dimmed}) and not dimmed then finish(B.endTurn()) end
    end
    if not dimmed and ui.button('Pause', SIDE_X + 12, py + 74, SIDE_W - 24, 40, {outline = true, size = 16, id = 'pausebtn', color = ui.c.muted}) then gStateMachine:change('pause') end
end
