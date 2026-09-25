-- Battle screen: rendering + input. Rules live in src/battle.lua, animation in src/fx.lua.
local B = require 'src/battle'
local fx = require 'src/fx'

GameState = Class{}

local FIELD_X, FIELD_Y, LANE_W, ROW_H = fx.FIELD_X, fx.FIELD_Y, fx.LANE_W, fx.ROW_H
local SIDE_X, SIDE_W = 1000, 240
local KEYS = {'A', 'S', 'D'}
local ITEM_LABEL = {walls = 'Wall', zap = 'Zap', gold = 'Double Gold', electricity = 'Electricity', retreat = 'Retreat', bomb = 'Bomb', teleporter = 'Teleporter', protection = 'Protection'}
local TARGET_LABEL = {field = 'Field', lane = 'Lane', tile = 'Tile', self = 'Buff'}

-- what each status means, for the hover card
local function statusRows(a)
    local rows = {}
    local function add(txt, c) rows[#rows + 1] = {txt, 'body', 13, c} end
    if a.stun > 0 then add('Stunned - cannot move for ' .. a.stun .. ' more turn' .. (a.stun == 1 and '' or 's'), ui.c.warn) end
    if a.poison > 0 then add('Poisoned - takes damage every turn', ui.c.good) end
    if a.plague and a.plague > 0 then add('Plagued - poison that spreads to neighbours', ui.rarity.scarce) end
    if a.hypno then add('Hypnotised - attacks the closest alien ahead of it', ui.rarity.scarce) end
    if a.immune > 0 then add('Shielded - immune to damage and effects this turn', ui.c.gold) end
    if a.marked then add('Scanned - takes 25% more damage this turn', ui.c.accent) end
    if a.doom then add('Doomed - dies in ' .. a.doom .. ' turn' .. (a.doom == 1 and '' or 's'), ui.c.danger) end
    if a.fly then add('Flying - only field-wide weapons can hit it', ui.c.muted) end
    if a.giantWait then add('Resting - moves every other turn', ui.c.muted) end
    return rows
end

local function alienTooltip(a, x, y)
    local def = Aliens[a.name]
    local rows = {
        {def.title, 'display', 17},
        {(a.hevalten and 'HEVALTEN   -   ' or '') .. math.max(0, math.round(a.health)) .. ' / ' .. a.maxHealth .. ' HP', 'hud', 12, a.hevalten and ui.c.danger or ui.c.muted, gap = 8},
        {def.desc, 'body', 14},
    }
    local st = statusRows(a)
    if #st > 0 then rows[#rows].gap = 10 end
    for _, r in ipairs(st) do rows[#rows + 1] = r end
    ui.tooltip(x, y, rows, {color = a.hevalten and ui.c.danger or ui.c.line, width = 280})
end

local function weaponTooltip(w, x, y)
    local rule = B.WEAPON_RULES[w.id]
    local color = ui.rarity[w.rarity]
    local stats = ui.rarityName[w.rarity]:upper() .. '   -   ' .. (TARGET_LABEL[rule.kind] or rule.kind):upper()
    if w.damage > 0 then stats = stats .. '   -   ' .. math.round(w.damage * upgradeMultiplier(w)) .. ' DMG' end
    if w.cooldown > 0 then stats = stats .. '   -   ' .. w.cooldown .. ' TURN CD' end
    ui.tooltip(x, y, {
        {w.name, 'display', 17, color},
        {stats, 'hud', 11, ui.c.muted, gap = 8},
        {w.specialEffect, 'body', 14},
    }, {color = color, width = 300})
end

local active = false      -- a battle is in progress (survives Pause round-trips)
local alienTurn = false    -- the end-of-turn animation is playing
local queuedEnd = false    -- End Turn pressed while a weapon animation was still playing

local function laneAt(x) if x < FIELD_X or x > FIELD_X + LANE_W * 5 then return nil end return math.floor((x - FIELD_X) / LANE_W) + 1 end
local function rowAt(y) if y < FIELD_Y or y > FIELD_Y + ROW_H * 10 then return nil end return math.floor((y - FIELD_Y) / ROW_H) + 1 end

local function finish(result)
    if result == 'lose' then active = false; gStateMachine:change('result', {won = false})
    elseif result == 'win' then active = false; gStateMachine:change('result', {won = true})
    elseif result == 'stage' then
        fx.reset(); fx.sync(B.drain())
        gStateMachine:change('stageSelect', {stage = B.state().stage})
    end
end

local function refundItem(key)
    for _, it in ipairs(ITEMS) do if ITEM_LABEL[key] == it.name then data[it.stat] = data[it.stat] + 1 end end
end

-- run the animation for whatever just happened, then apply the result
local function animate(result)
    fx.play(B.drain(), function() if result then finish(result) end end)
end

function GameState:enter(item)
    queuedEnd = false
    if item == 'quit' then
        active = false
        gStateMachine:change('home')
        return
    end
    if not active then
        B.start()
        fx.reset()
        alienTurn = false
        fx.sync(B.drain())
        active = true
    else
        B.reloadSlots()
        fx.sync(B.drain())
    end
    if item then
        if B.cancelAim() == 'wall' then refundItem('walls') end
        local r = B.useItem(item)
        if r == false then
            refundItem(item)
            ui.toast('No room for a ' .. ITEM_LABEL[item], ui.c.warn)
        elseif r == 'aim' then
            ui.toast('Choose a tile for the wall', ui.c.accent)
        else
            ui.toast(ITEM_LABEL[item] .. ' used', ui.c.good)
            animate(r)
        end
    end
end

local function fire(n)
    if fx.busy() then return end
    local r = B.fire(n)
    if r == true then animate() end
end

local function endTurn()
    if fx.busy() then
        if not alienTurn then queuedEnd = true end -- finish the shot, then end the turn
        return
    end
    sfx.play('turn')
    alienTurn = true
    local r = B.endTurn()
    fx.play(B.drain(), function() alienTurn = false; if r then finish(r) end end)
end

function GameState:update(dt)
    -- hold Space (or the mouse button) to fast-forward animations
    local fast = fx.busy() and (love.keyboard.isDown('space') or love.mouse.isDown(1))
    fx.update(dt * (fast and 3 or 1))
    if queuedEnd and not fx.busy() then
        queuedEnd = false
        if not B.state().aim then endTurn() end
    end
    if love.keyboard.wasPressed('a') then fire(1)
    elseif love.keyboard.wasPressed('s') then fire(2)
    elseif love.keyboard.wasPressed('d') then fire(3)
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('kpenter') then endTurn()
    end
    local s = B.state()
    if s.aim and s.aim.kind == 'lane' and not fx.busy() then
        for l = 1, 5 do if love.keyboard.wasPressed(tostring(l)) then if B.aimLane(l) then animate() end end end
    end
end

function GameState:keyPressed(key)
    local s = B.state()
    if DEBUG and key == 'f9' and not fx.busy() then B.forceEvent(B.EVENTS[math.random(#B.EVENTS)].key); animate(); return end
    if key == 'escape' and s.aim then
        if B.cancelAim() == 'wall' then refundItem('walls') end
    elseif key == 'escape' or key == 'p' then gStateMachine:change('pause') end
end

function GameState:mousePressed(x, y)
    local s = B.state()
    if fx.busy() then return end
    local lane, row = laneAt(x), rowAt(y)
    if s.aim and lane and row then
        if s.aim.kind == 'lane' then
            if B.aimLane(lane) then animate() end
        else
            if B.aimTile(row, lane) then animate() end
        end
    end
end

-- ---------------------------------------------------------------- render
local function drawAlien(v, t, spotUid)
    local a = v.a
    local def = Aliens[a.name]
    local alpha = v.alpha
    if spotUid and spotUid ~= a.uid then alpha = alpha * 0.45 end
    local x, y = v.x + (v.lungeX or 0), v.y - (v.hop or 0) + (v.lungeY or 0)
    local bob = a.fly and math.sin(t * 6 + v.x) * 3 or 0
    love.graphics.push()
    love.graphics.translate(x, y + bob)
    love.graphics.scale(v.scale, v.scale)
    love.graphics.translate(-x, -(y + bob))
    fx.drawStatuses({a = a, x = x, y = y + bob, statusPulse = v.statusPulse}, t)
    if not icons.alienArt(a.name, x, y + bob, 40, alpha * (a.fly and 0.7 or 1)) then icons.alien(def.spec, x, y + bob, 40, alpha * (a.fly and 0.7 or 1)) end
    if v.flash > 0 then ui.color(ui.c.white, v.flash * 0.8); love.graphics.circle('fill', x, y + bob, 20) end
    love.graphics.pop()
    -- name + hp
    ui.text(def.title, x + 26, y - 24, LANE_W - 60, 'left', 'body', 12, ui.c.muted, alpha)
    ui.text(tostring(math.max(0, math.round(v.hp))), x + 26, y - 10, LANE_W - 60, 'left', 'hud', 16, ui.c.text, alpha)
    ui.color(ui.c.bg, alpha); ui.rrect('fill', x + 26, y + 12, LANE_W - 70, 5, 2)
    local frac = math.max(0, math.min(1, v.hp / a.maxHealth))
    if frac > 0 then ui.color(a.hevalten and ui.c.danger or ui.c.good, alpha); ui.rrect('fill', x + 26, y + 12, math.max(5, (LANE_W - 70) * frac), 5, 2) end
    local gx = x + 26
    if a.stun > 0 then ui.text('STUN ' .. a.stun, gx, y + 18, 60, 'left', 'hud', 10, ui.c.warn, alpha); gx = gx + 42 end
    if a.poison > 0 then ui.text('PSN', gx, y + 18, 30, 'left', 'hud', 10, ui.c.good, alpha); gx = gx + 26 end
    if a.hypno then ui.text('HYP', gx, y + 18, 30, 'left', 'hud', 10, ui.rarity.scarce, alpha); gx = gx + 26 end
    if a.immune > 0 then ui.text('SHLD', gx, y + 18, 40, 'left', 'hud', 10, ui.c.gold, alpha); gx = gx + 34 end
    if a.plague and a.plague > 0 then ui.text('PLG', gx, y + 18, 30, 'left', 'hud', 10, ui.rarity.scarce, alpha); gx = gx + 26 end
    if a.doom then ui.text('DOOM ' .. a.doom, gx, y + 18, 50, 'left', 'hud', 10, ui.c.danger, alpha) end
end

function GameState:render(dimmed)
    local s = B.state()
    if not s then return end
    local t = love.timer.getTime()
    ui.background(t, false)

    local sx, sy = 0, 0
    if not dimmed then sx, sy = fx.shakeOffset() end
    love.graphics.push()
    love.graphics.translate(sx, sy)

    -- field
    ui.color(ui.c.bg2); ui.rrect('fill', FIELD_X - 4, FIELD_Y - 4, LANE_W * 5 + 8, ROW_H * 10 + 8, 10)
    local hoverLane, hoverRow = laneAt(ui.mouse.x), rowAt(ui.mouse.y)
    local aiming = s.aim and not fx.busy() and not dimmed
    for j = 1, 5 do
        for i = 1, 10 do
            local x, y = FIELD_X + (j - 1) * LANE_W, FIELD_Y + (i - 1) * ROW_H
            ui.color(ui.c.panel, ((i + j) % 2 == 0) and 0.8 or 0.55)
            love.graphics.rectangle('fill', x + 1, y + 1, LANE_W - 2, ROW_H - 2, 4, 4)
            if s.walls[i][j] then
                local hp = tonumber(s.walls[i][j]) or 1
                local wc = hp > 1 and ui.rarity.rare or ui.c.warn
                ui.color(wc, 0.9); love.graphics.rectangle('fill', x + 6, y + ROW_H - 10 - hp * 3, LANE_W - 12, 6 + hp * 3, 3, 3)
                ui.color(ui.c.bg, 0.5); for k = 0, 3 do love.graphics.rectangle('fill', x + 12 + k * 44, y + ROW_H - 12, 2, 4) end
                if hp > 1 then ui.pips(x + LANE_W / 2 - 12, y + ROW_H - 26, 3, hp, wc, 5, 3) end
            end
            if aiming and (s.aim.kind == 'wall' or (s.aim.rule and s.aim.rule.wall)) then
                local ok = B.wallAllowed(i, j)
                if hoverLane == j and hoverRow == i then
                    ui.color(ok and ui.c.good or ui.c.danger, 0.3); love.graphics.rectangle('fill', x, y, LANE_W, ROW_H, 4, 4)
                elseif ok then
                    ui.color(ui.c.good, 0.06); love.graphics.rectangle('fill', x, y, LANE_W, ROW_H, 4, 4)
                end
            end
        end
        if s.lockedLane == j then
            ui.color(ui.rarity.scarce, 0.12); love.graphics.rectangle('fill', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
            ui.text('LOCKED', FIELD_X + (j - 1) * LANE_W, FIELD_Y + 4, LANE_W, 'center', 'hud', 11, ui.rarity.scarce)
        end
        if aiming and s.aim.kind == 'lane' and hoverLane == j then
            ui.color(ui.c.accent, 0.18); love.graphics.rectangle('fill', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
            ui.color(ui.c.accent, 0.9); love.graphics.setLineWidth(2); love.graphics.rectangle('line', FIELD_X + (j - 1) * LANE_W, FIELD_Y, LANE_W, ROW_H * 10, 6, 6)
        end
    end
    if aiming and s.aim.kind == 'tile' and not s.aim.rule.wall and hoverLane and hoverRow then
        local x, y = FIELD_X + (hoverLane - 1) * LANE_W, FIELD_Y + (hoverRow - 1) * ROW_H
        ui.color(ui.c.accent, 0.25); love.graphics.rectangle('fill', x, y, LANE_W, ROW_H, 4, 4)
        ui.color(ui.c.accent); love.graphics.setLineWidth(2); love.graphics.rectangle('line', x, y, LANE_W, ROW_H, 4, 4)
    end
    for j = 1, 5 do ui.text(tostring(j), FIELD_X + (j - 1) * LANE_W, FIELD_Y + ROW_H * 10 + 6, LANE_W, 'center', 'hud', 14, ui.c.dim) end
    ui.color(ui.c.danger, 0.7); love.graphics.rectangle('fill', FIELD_X, FIELD_Y + ROW_H * 10 + 26, LANE_W * 5, 4, 2, 2)
    ui.text('BASE', FIELD_X, FIELD_Y + ROW_H * 10 + 34, LANE_W * 5, 'center', 'hud', 14, ui.c.danger)

    -- weapon / item effects under the aliens
    if not dimmed then fx.drawWeapon(t); fx.drawItem() end

    -- aliens (sorted by y so lower rows draw on top)
    local list = {}
    for _, v in pairs(fx.vis) do list[#list + 1] = v end
    table.sort(list, function(p, q) return p.y < q.y end)
    local spotUid, spotText, spotP = fx.spotlight()
    for _, v in ipairs(list) do if v.a.uid ~= spotUid then drawAlien(v, t, spotUid) end end
    if spotUid and fx.vis[spotUid] then
        local v = fx.vis[spotUid]
        local pulse = 0.5 + 0.5 * math.sin(t * 10)
        ui.color(ui.c.accent, 0.15 + 0.1 * pulse); love.graphics.circle('fill', v.x, v.y, 34 + pulse * 4)
        love.graphics.setLineWidth(2.5); ui.color(ui.c.accent, 0.9); love.graphics.circle('line', v.x, v.y, 30 + pulse * 3)
        drawAlien(v, t, nil)
        -- label
        local def = Aliens[v.a.name]
        local label = def.title .. '  ' .. spotText
        local f = ui.font('display', 15); love.graphics.setFont(f)
        local w = f:getWidth(label) + 28
        local lx = math.max(FIELD_X, math.min(FIELD_X + LANE_W * 5 - w, v.x - w / 2 + 40))
        local ly = v.y - 56
        if ly < FIELD_Y + 4 then ly = v.y + 34 end
        local a = math.min(1, spotP * 4)
        ui.panel(lx, ly, w, 30, {fill = ui.c.accent, border = false, radius = 15, alpha = a})
        ui.text(label, lx, ly + 7, w, 'center', 'display', 15, ui.c.bg, a)
    end

    if not dimmed then fx.drawOverlay() end
    love.graphics.pop()

    -- sidebar
    local tipEvent = false
    ui.panel(SIDE_X, FIELD_Y - 4, SIDE_W, 700, {radius = 12})
    local planet, lvl = data.currentLevel:match('(%d+)%-(%d+)')
    ui.text(PLANETS[tonumber(planet)].name, SIDE_X + 16, 16, SIDE_W - 32, 'left', 'display', 20)
    ui.text('Level ' .. lvl .. '   -   Turn ' .. s.turn, SIDE_X + 16, 44, SIDE_W - 32, 'left', 'body', 14, ui.c.muted)
    ui.text('Stage ' .. s.stage .. ' of 3', SIDE_X + 16, 70, 110, 'left', 'body', 15)
    local mult = s.buff * (s.stellar and s.stellar.mult or 1) * (s.evt and s.evt.mult or 1)
    if math.abs(mult - 1) > 0.001 then
        ui.text(string.format('Damage x%.2f', mult), SIDE_X + 16, 70, SIDE_W - 32, 'right', 'hud', 13, mult > 1 and ui.c.good or ui.c.danger)
    end
    -- the random event affecting this turn
    if s.evt then
        local ec = s.evt.good and ui.c.good or ui.c.danger
        ui.panel(SIDE_X + 12, 92, SIDE_W - 24, 26, {fill = ec, border = false, radius = 8, alpha = 0.18})
        ui.text(s.evt.name:upper() .. (s.evt.detail and ('   ' .. s.evt.detail) or ''), SIDE_X + 12, 98, SIDE_W - 24, 'center', 'hud', ui.fitSize('hud', s.evt.name:upper() .. (s.evt.detail and ('   ' .. s.evt.detail) or ''), SIDE_W - 36, 12, 9), ec)
        if ui.hovered(SIDE_X + 12, 92, SIDE_W - 24, 26) then tipEvent = true end
    end

    local busy = fx.busy()
    local tipWeapon, tipY
    for n, slot in ipairs(s.slots) do
        local w = Weapons[slot.id]
        local y = 124 + (n - 1) * 118
        local color = w and ui.rarity[w.rarity] or ui.c.dim
        local ready = w and not slot.used and not s.aim and not busy
        local isAiming = s.aim and s.aim.slot == n
        local hover = ui.hovered(SIDE_X + 12, y, SIDE_W - 24, 108)
        if hover and w and not dimmed then tipWeapon, tipY = w, y end
        ui.panel(SIDE_X + 12, y, SIDE_W - 24, 108, {fill = (ready or isAiming) and ui.c.panel2 or ui.c.bg2, border = isAiming and ui.c.accent or ((hover and ready and not dimmed) and color or ui.c.line), radius = 10})
        if w then
            local rule = B.WEAPON_RULES[w.id]
            local lit = ready or isAiming
            if not icons.weaponArt(w.id, SIDE_X + 40, y + 34, 38, lit and 1 or 0.35) then icons.weapon(w.shape, SIDE_X + 40, y + 34, 38, lit and color or ui.c.dim) end
            local nameSize = ui.fitSize('display', w.name, SIDE_W - 90, 15, 11)
            ui.text(w.name, SIDE_X + 68, y + 14 + (15 - nameSize), SIDE_W - 90, 'left', 'display', nameSize, lit and ui.c.text or ui.c.dim)
            local dmg = w.damage > 0 and ('   -   ' .. math.round(w.damage * ((data.upgrades[w.id] or 0) * 0.1 + 1))) or ''
            ui.text((TARGET_LABEL[rule.kind] or rule.kind) .. dmg, SIDE_X + 68, y + 38, SIDE_W - 90, 'left', 'body', 13, ui.c.muted)
            local status
            if isAiming then status = 'AIMING'
            elseif not slot.used then status = 'READY   -   ' .. KEYS[n]
            elseif w.cooldown > 0 and slot.cd > 0 then
                local left = math.max(1, w.cooldown - slot.cd + 1)
                status = 'RECHARGING - ' .. left .. (left == 1 and ' TURN' or ' TURNS')
            else status = 'USED THIS TURN' end
            ui.text(status, SIDE_X + 24, y + 80, SIDE_W - 48, 'left', 'hud', 12, lit and color or ui.c.dim)
            if w.cooldown > 0 then ui.pips(SIDE_X + SIDE_W - 24 - w.cooldown * 12, y + 84, w.cooldown, slot.used and math.max(0, slot.cd - 1) or w.cooldown, color, 7, 5) end
        end
        if not dimmed and ready and ui.hit(SIDE_X + 12, y, SIDE_W - 24, 108) then fire(n) end
    end

    local py = 124 + 3 * 118 + 4
    if s.aim and not busy then
        local isWall = s.aim.kind == 'wall' or (s.aim.rule and s.aim.rule.wall)
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = isWall and ui.c.warn or ui.c.accent, border = false, radius = 10})
        local msg
        if isWall then msg = s.aim.kind == 'wall' and 'Place the wall' or 'Place the barricade'
        elseif s.aim.kind == 'lane' then msg = 'Click a lane'
        else
            local shots = s.aim.rule.shots or 1
            msg = 'Click a tile' .. (shots > 1 and ('  (' .. (shots - s.aim.remaining + 1) .. '/' .. shots .. ')') or '')
        end
        ui.textBox(msg, SIDE_X + 12, py, SIDE_W - 24, 40, 'display', ui.fitSize('display', msg, SIDE_W - 44, 17, 12), ui.c.bg)
        ui.textBox('Esc to cancel', SIDE_X + 12, py + 34, SIDE_W - 24, 24, 'body', 12, ui.c.bg)
    elseif busy then
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = ui.c.bg2, radius = 10})
        local spot = select(2, fx.spotlight())
        ui.textBox(fx.eventPlaying() and 'Random event' or spot and 'Alien ability' or (fx.frozen() and 'Time frozen') or 'Resolving...', SIDE_X + 12, py, SIDE_W - 24, 44, 'display', 17, (fx.frozen() or fx.eventPlaying()) and ui.c.accent or ui.c.muted)
        ui.textBox('Hold Space to fast-forward', SIDE_X + 12, py + 36, SIDE_W - 24, 24, 'body', 12, ui.c.dim)
    else
        if ui.button('End turn', SIDE_X + 12, py, SIDE_W - 24, 64, {size = 22, id = 'endturn', disabled = dimmed}) and not dimmed then endTurn() end
    end
    if not dimmed and ui.button('Pause', SIDE_X + 12, py + 74, SIDE_W - 24, 40, {outline = true, size = 16, id = 'pausebtn', color = ui.c.muted, disabled = busy}) then gStateMachine:change('pause') end

    -- hover cards: weapon in the sidebar, alien or wall on the field
    if dimmed then return end
    if tipEvent and s.evt then
        ui.tooltip(SIDE_X - 312, 80, {{s.evt.name, 'display', 17, s.evt.good and ui.c.good or ui.c.danger}, {'RANDOM EVENT   -   THIS TURN', 'hud', 11, ui.c.muted, gap = 8}, {s.evt.desc, 'body', 14}}, {color = s.evt.good and ui.c.good or ui.c.danger, width = 300})
    elseif tipWeapon then
        weaponTooltip(tipWeapon, SIDE_X - 312, tipY)
    elseif hoverLane and hoverRow then
        local best, bestD
        for _, v in pairs(fx.vis) do
            if not v.dying and not v.fading then
                local ci, cj = math.floor((v.y + 2 - FIELD_Y) / ROW_H) + 1, math.floor((v.x + 56 - FIELD_X) / LANE_W) + 1
                if ci == hoverRow and cj == hoverLane then
                    local d = math.abs(v.x + 56 - ui.mouse.x) + math.abs(v.y - ui.mouse.y)
                    if not bestD or d < bestD then best, bestD = v, d end
                end
            end
        end
        if best then
            alienTooltip(best.a, ui.mouse.x + 18, ui.mouse.y + 18)
        elseif s.walls[hoverRow][hoverLane] then
            local hp = tonumber(s.walls[hoverRow][hoverLane]) or 1
            ui.tooltip(ui.mouse.x + 18, ui.mouse.y + 18, {
                {hp > 1 and 'Barricade' or 'Wall', 'display', 17, hp > 1 and ui.rarity.rare or ui.c.warn},
                {'Stops aliens marching past. Breaks after ' .. hp .. ' more hit' .. (hp == 1 and '' or 's') .. '.', 'body', 14},
            }, {color = hp > 1 and ui.rarity.rare or ui.c.warn})
        end
    end
end
