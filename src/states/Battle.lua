-- Battle screen: rendering + input. Rules live in src/battle.lua, animation in src/fx.lua.
local B = require 'src/battle'
local fx = require 'src/fx'

GameState = Class{}

local FIELD_X, FIELD_Y, LANE_W, ROW_H = fx.FIELD_X, fx.FIELD_Y, fx.LANE_W, fx.ROW_H
local SIDE_X, SIDE_W = 1000, 240
local KEYS = {'A', 'S', 'D'}
local ITEM_LABEL = {walls = 'Wall', zap = 'Zap', gold = 'Double Gold', electricity = 'Electricity', retreat = 'Retreat', bomb = 'Bomb', teleporter = 'Teleporter', protection = 'Protection'}
local TARGET_LABEL = {field = 'Field', lane = 'Lane', tile = 'Tile', self = 'Buff'}

local active = false      -- a battle is in progress (survives Pause round-trips)
local pendingResult = nil -- result to apply once animations finish

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
    if item == 'quit' then
        active = false
        gStateMachine:change('home')
        return
    end
    if not active then
        B.start()
        fx.reset()
        fx.sync(B.drain())
        active = true
    else
        B.reloadSlots()
        fx.sync(B.drain())
    end
    if item then
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
    if fx.busy() then return end
    local r = B.endTurn()
    animate(r)
end

function GameState:update(dt)
    fx.update(dt)
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
    icons.alien(def.spec, x, y + bob, 40, alpha * (a.fly and 0.7 or 1))
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
    if a.immune > 0 then ui.text('SHLD', gx, y + 18, 40, 'left', 'hud', 10, ui.c.gold, alpha) end
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
                ui.color(ui.c.warn, 0.9); love.graphics.rectangle('fill', x + 6, y + ROW_H - 14, LANE_W - 12, 8, 3, 3)
                ui.color(ui.c.bg, 0.5); for k = 0, 3 do love.graphics.rectangle('fill', x + 12 + k * 44, y + ROW_H - 12, 2, 4) end
            end
            if aiming and s.aim.kind == 'wall' then
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
    if aiming and s.aim.kind == 'tile' and hoverLane and hoverRow then
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

    local busy = fx.busy()
    for n, slot in ipairs(s.slots) do
        local w = Weapons[slot.id]
        local y = 124 + (n - 1) * 118
        local color = w and ui.rarity[w.rarity] or ui.c.dim
        local ready = w and not slot.used and not s.aim and not busy
        local isAiming = s.aim and s.aim.slot == n
        local hover = ui.hovered(SIDE_X + 12, y, SIDE_W - 24, 108)
        ui.panel(SIDE_X + 12, y, SIDE_W - 24, 108, {fill = (ready or isAiming) and ui.c.panel2 or ui.c.bg2, border = isAiming and ui.c.accent or ((hover and ready and not dimmed) and color or ui.c.line), radius = 10})
        if w then
            local rule = B.WEAPON_RULES[w.id]
            local lit = ready or isAiming
            icons.weapon(w.shape, SIDE_X + 40, y + 34, 38, lit and color or ui.c.dim)
            local nameSize = ui.font('display', 15):getWidth(w.name) > SIDE_W - 90 and 12 or 15
            ui.text(w.name, SIDE_X + 68, y + 14 + (15 - nameSize), SIDE_W - 90, 'left', 'display', nameSize, lit and ui.c.text or ui.c.dim)
            local dmg = w.damage > 0 and ('   -   ' .. math.round(w.damage * ((data.upgrades[w.id] or 0) * 0.1 + 1))) or ''
            ui.text((TARGET_LABEL[rule.kind] or rule.kind) .. dmg, SIDE_X + 68, y + 38, SIDE_W - 90, 'left', 'body', 13, ui.c.muted)
            local status
            if isAiming then status = 'AIMING'
            elseif not slot.used then status = 'READY   -   ' .. KEYS[n]
            elseif w.cooldown > 0 then status = 'RECHARGING ' .. slot.cd .. '/' .. w.cooldown
            else status = 'USED THIS TURN' end
            ui.text(status, SIDE_X + 24, y + 80, SIDE_W - 48, 'left', 'hud', 12, lit and color or ui.c.dim)
            if w.cooldown > 0 then ui.pips(SIDE_X + SIDE_W - 24 - w.cooldown * 12, y + 84, w.cooldown, slot.used and slot.cd or w.cooldown, color, 7, 5) end
        end
        if not dimmed and ready and ui.hit(SIDE_X + 12, y, SIDE_W - 24, 108) then fire(n) end
    end

    local py = 124 + 3 * 118 + 4
    if s.aim and not busy then
        local isWall = s.aim.kind == 'wall'
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = isWall and ui.c.warn or ui.c.accent, border = false, radius = 10})
        local msg
        if isWall then msg = 'Place the wall'
        elseif s.aim.kind == 'lane' then msg = 'Click a lane'
        else
            local shots = s.aim.rule.shots or 1
            msg = 'Click a tile' .. (shots > 1 and ('  (' .. (shots - s.aim.remaining + 1) .. '/' .. shots .. ')') or '')
        end
        ui.textBox(msg, SIDE_X + 12, py, SIDE_W - 24, 40, 'display', 17, ui.c.bg)
        ui.textBox('Esc to cancel', SIDE_X + 12, py + 34, SIDE_W - 24, 24, 'body', 12, ui.c.bg)
    elseif busy then
        ui.panel(SIDE_X + 12, py, SIDE_W - 24, 64, {fill = ui.c.bg2, radius = 10})
        local spot = select(2, fx.spotlight())
        ui.textBox(spot and 'Alien ability' or 'Resolving...', SIDE_X + 12, py, SIDE_W - 24, 64, 'display', 17, ui.c.muted)
    else
        if ui.button('End turn', SIDE_X + 12, py, SIDE_W - 24, 64, {size = 22, id = 'endturn', disabled = dimmed}) and not dimmed then endTurn() end
    end
    if not dimmed and ui.button('Pause', SIDE_X + 12, py + 74, SIDE_W - 24, 40, {outline = true, size = 16, id = 'pausebtn', color = ui.c.muted, disabled = busy}) then gStateMachine:change('pause') end
end
