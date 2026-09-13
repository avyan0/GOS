-- Battle animation: turns rule events into a timeline, keeps a lagging visual
-- copy of every alien (position/health tweens), draws weapon and status effects.
local B = require 'src/battle'
local fx = {}
local g = love.graphics

fx.FIELD_X, fx.FIELD_Y, fx.LANE_W, fx.ROW_H = 40, 12, 188, 58
local function cellCenter(i, j) return fx.FIELD_X + (j - 0.5) * fx.LANE_W, fx.FIELD_Y + (i - 0.5) * fx.ROW_H end
fx.cellCenter = cellCenter
local function alienPos(i, j) local cx, cy = cellCenter(i, j); return cx - 56, cy - 2 end

local function ease(t) t = math.max(0, math.min(1, t)); return 1 - (1 - t) ^ 3 end
local function easeInOut(t) t = math.max(0, math.min(1, t)); return t < 0.5 and 4 * t * t * t or 1 - (-2 * t + 2) ^ 3 / 2 end

-- ---------------------------------------------------------------- visual state
fx.vis = {}          -- uid -> visual alien
local clips = {}     -- queued timeline clips
local current = nil
local popups = {}    -- floating text
local sparks = {}    -- short-lived particle bursts
local lines = {}     -- redirect lines etc.
local shake = 0
local onIdle = nil   -- callback when the timeline empties

function fx.reset()
    fx.vis, clips, current, popups, sparks, lines, shake, onIdle = {}, {}, nil, {}, {}, {}, 0, nil
end

function fx.busy() return current ~= nil or #clips > 0 end

local function popup(x, y, text, color, size)
    popups[#popups + 1] = {x = x, y = y, text = text, color = color or ui.c.warn, t = 0, size = size or 20}
end
fx.popup = popup

local function burst(x, y, color, n, speed, life, size)
    for _ = 1, n or 10 do
        local a = math.random() * math.pi * 2
        local v = (speed or 120) * (0.5 + math.random())
        sparks[#sparks + 1] = {x = x, y = y, vx = math.cos(a) * v, vy = math.sin(a) * v, t = 0, life = life or 0.5, color = color, size = size or 3}
    end
end
fx.burst = burst

-- ---------------------------------------------------------------- applying events to the visual state
local function ensureVis(uid, a, i, j)
    local v = fx.vis[uid]
    if not v then
        local x, y = alienPos(i, j)
        v = {a = a, x = x, y = y, hp = a.health, alpha = 1, scale = 1, flash = 0, born = 0}
        fx.vis[uid] = v
    end
    return v
end

local function apply(ev, instant)
    local v = ev.uid and fx.vis[ev.uid]
    if ev.type == 'spawn' then
        v = ensureVis(ev.uid, ev.a, ev.i, ev.j)
        v.x, v.y = alienPos(ev.i, ev.j)
        v.scale = instant and 1 or 0
        v.hp = ev.a.health
        if not instant then burst(v.x, v.y, ui.c.accent, 8, 80, 0.4, 2) end
    elseif ev.type == 'move' and v then
        local tx, ty = alienPos(ev.to[1], ev.to[2])
        if instant then v.x, v.y = tx, ty
        else v.move = {fx = v.x, fy = v.y, tx = tx, ty = ty, t = 0, dur = 0.35, arc = ev.arc} end
    elseif ev.type == 'jump' and v then
        v.jumpNext = true
    elseif ev.type == 'hit' and v then
        if instant then v.hp = v.a.health
        else
            v.hpTarget = (v.hpTarget or v.hp) - ev.amount
            v.flash = 1
            popup(v.x + 60 + math.random(-10, 10), v.y - 14, '-' .. math.round(ev.amount), ev.poison and ui.c.good or ui.c.warn, ev.poison and 16 or 20)
            burst(v.x, v.y, ev.poison and ui.c.good or ui.c.warn, ev.poison and 4 or 7, 90, 0.35, 2)
            if not ev.poison then shake = math.max(shake, 3) end
        end
    elseif ev.type == 'kill' and v then
        if instant then fx.vis[ev.uid] = nil
        else v.dying = 0; burst(v.x, v.y, ui.c.danger, 16, 160, 0.6, 3); shake = math.max(shake, 4) end
    elseif ev.type == 'remove' and v and not v.dying then
        if instant then fx.vis[ev.uid] = nil else v.fading = 0 end
    elseif ev.type == 'status' and v and not instant then
        v.statusPulse = {kind = ev.kind, t = 0}
        local c = ({stun = ui.c.warn, poison = ui.c.good, hypno = ui.rarity.scarce})[ev.kind]
        burst(v.x, v.y, c, 10, 70, 0.45, 2)
    elseif ev.type == 'blocked' and v and not instant then
        popup(v.x + 60, v.y - 14, ev.text:upper(), ui.c.muted, 14)
        v.statusPulse = {kind = 'block', t = 0}
    elseif ev.type == 'redirect' and not instant then
        local x1, y1 = cellCenter(ev.from[1], ev.from[2]); local x2, y2 = cellCenter(ev.to[1], ev.to[2])
        lines[#lines + 1] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2, t = 0, color = ui.c.gold}
    elseif ev.type == 'wall' and not instant then
        local cx, cy = cellCenter(ev.i, ev.j); burst(cx, cy + 20, ui.c.warn, 12, 60, 0.4, 3)
    elseif ev.type == 'wallbreak' and not instant then
        local cx, cy = cellCenter(ev.i, ev.j); burst(cx, cy + 20, ui.c.warn, 18, 140, 0.6, 3); shake = math.max(shake, 3)
    elseif ev.type == 'fight' and not instant then
        local va, vb = fx.vis[ev.a], fx.vis[ev.b]
        if va and vb then
            local mx, my = (va.x + vb.x) / 2, (va.y + vb.y) / 2
            va.lunge = {tx = mx, ty = my, t = 0}; vb.lunge = {tx = mx, ty = my, t = 0}
            burst(mx, my, ui.c.white, 14, 160, 0.4, 3); burst(mx, my, ui.rarity.scarce, 10, 120, 0.5, 2)
            lines[#lines + 1] = {x1 = va.x, y1 = va.y, x2 = vb.x, y2 = vb.y, t = 0, color = ui.rarity.scarce}
            shake = math.max(shake, 5)
        end
    elseif ev.type == 'morphed' and v and not instant then
        burst(v.x, v.y, ui.rarity.scarce, 14, 100, 0.5, 2)
        v.scale = 0.2
    end
end

-- ---------------------------------------------------------------- timeline
local WEAPON_DUR, WEAPON_HIT_AT = 0.7, 0.32
local ABILITY_DUR, ABILITY_HIT_AT = 1.1, 0.55
local PHASE = {poison = {0.5, 0.05}, abilities = {0, 0}, move = {0.45, 0.02}, spawn = {0.4, 0.05}}

function fx.play(events, cb)
    local cur
    local function newClip(kind, ev, dur, hitAt)
        cur = {kind = kind, ev = ev, dur = dur, hitAt = hitAt or 0, fx = {}, t = 0, applied = false}
        clips[#clips + 1] = cur
    end
    for _, ev in ipairs(events) do
        if ev.type == 'weapon' then newClip('weapon', ev, WEAPON_DUR, WEAPON_HIT_AT)
        elseif ev.type == 'ability' or ev.type == 'rest' then newClip('ability', ev, ABILITY_DUR, ABILITY_HIT_AT)
        elseif ev.type == 'phase' then local p = PHASE[ev.name]; newClip(ev.name, ev, p[1], p[2])
        elseif ev.type == 'item' then newClip('item', ev, 0.8, 0.35)
        elseif ev.type == 'lose' then newClip('lose', ev, 0.8, 0)
        else
            if not cur then newClip('misc', nil, 0.4, 0) end
            cur.fx[#cur.fx + 1] = ev
        end
    end
    -- drop empty phase markers
    for k = #clips, 1, -1 do
        local c = clips[k]
        if (c.kind == 'abilities' or c.kind == 'poison' or c.kind == 'move' or c.kind == 'spawn' or c.kind == 'misc') and #c.fx == 0 then table.remove(clips, k) end
    end
    onIdle = cb
    if #clips == 0 and cb then cb() end
end

-- apply everything immediately (entering a battle, resuming)
function fx.sync(events)
    for _, ev in ipairs(events) do apply(ev, true) end
end

function fx.update(dt)
    if not current and #clips > 0 then current = table.remove(clips, 1) end
    if current then
        current.t = current.t + dt
        if not current.applied and current.t >= current.hitAt then
            current.applied = true
            for _, ev in ipairs(current.fx) do apply(ev, false) end
        end
        if current.t >= current.dur then current = nil end
    end
    if not current and #clips == 0 and onIdle then local cb = onIdle; onIdle = nil; cb() end

    for uid, v in pairs(fx.vis) do
        if v.move then
            v.move.t = v.move.t + dt
            local p = easeInOut(v.move.t / v.move.dur)
            v.x = v.move.fx + (v.move.tx - v.move.fx) * p
            v.y = v.move.fy + (v.move.ty - v.move.fy) * p
            v.hop = math.sin(p * math.pi) * (v.jumpNext and 26 or 6)
            if v.move.t >= v.move.dur then v.move = nil; v.hop = 0; v.jumpNext = nil end
        end
        if v.lunge then
            v.lunge.t = v.lunge.t + dt
            local p = math.sin(math.min(1, v.lunge.t / 0.35) * math.pi)
            v.lungeX, v.lungeY = (v.lunge.tx - v.x) * 0.6 * p, (v.lunge.ty - v.y) * 0.6 * p
            if v.lunge.t >= 0.35 then v.lunge = nil; v.lungeX, v.lungeY = 0, 0 end
        end
        if v.scale < 1 then v.scale = math.min(1, v.scale + dt * 5) end
        v.flash = math.max(0, v.flash - dt * 6)
        if v.hpTarget then v.hp = v.hp + (v.hpTarget - v.hp) * math.min(1, dt * 10); if math.abs(v.hp - v.hpTarget) < 1 then v.hp = v.hpTarget; v.hpTarget = nil end end
        if v.dying then v.dying = v.dying + dt; v.alpha = 1 - v.dying / 0.4; if v.dying >= 0.4 then fx.vis[uid] = nil end end
        if v.fading then v.fading = v.fading + dt; v.alpha = 1 - v.fading / 0.3; if v.fading >= 0.3 then fx.vis[uid] = nil end end
        if v.statusPulse then v.statusPulse.t = v.statusPulse.t + dt; if v.statusPulse.t > 0.6 then v.statusPulse = nil end end
    end
    for k = #popups, 1, -1 do local p = popups[k]; p.t = p.t + dt; if p.t > 1.2 then table.remove(popups, k) end end
    for k = #sparks, 1, -1 do
        local sp = sparks[k]; sp.t = sp.t + dt; sp.x = sp.x + sp.vx * dt; sp.y = sp.y + sp.vy * dt; sp.vy = sp.vy + 140 * dt
        if sp.t > sp.life then table.remove(sparks, k) end
    end
    for k = #lines, 1, -1 do local l = lines[k]; l.t = l.t + dt; if l.t > 0.5 then table.remove(lines, k) end end
    shake = math.max(0, shake - dt * 14)
end

function fx.shakeOffset()
    if shake <= 0 then return 0, 0 end
    return (math.random() - 0.5) * shake * 2, (math.random() - 0.5) * shake * 2
end

function fx.spotlight() -- uid of the alien currently performing an ability, plus its text
    if current and current.kind == 'ability' then return current.ev.uid, current.ev.text, current.t / current.dur end
end

-- ---------------------------------------------------------------- status visuals
local S = {}
S.stun = function(x, y, t, c)
    for k = 0, 2 do
        local a = t * 5 + k * 2.094
        ui.color(c, 0.9); g.circle('fill', x + math.cos(a) * 22, y - 8 + math.sin(a) * 8, 3)
        ui.color(c, 0.35); g.circle('fill', x + math.cos(a - 0.5) * 22, y - 8 + math.sin(a - 0.5) * 8, 2)
    end
end
S.poison = function(x, y, t, c)
    ui.color(c, 0.12); g.circle('fill', x, y, 22)
    for k = 0, 2 do
        local p = (t * 0.7 + k / 3) % 1
        ui.color(c, 1 - p); g.circle('fill', x - 12 + k * 12 + math.sin(t * 3 + k) * 3, y + 14 - p * 40, 3 - p)
    end
end
S.hypno = function(x, y, t, c)
    g.setLineWidth(2.5)
    for k = 0, 2 do
        local a = -t * 2.5 + k * 2.094
        ui.color(c, 0.85); g.arc('line', 'open', x, y, 25, a, a + 1.2)
    end
    ui.color(c, 0.5); g.circle('line', x, y, 25 + math.sin(t * 4) * 2)
end
S.immune = function(x, y, t, c)
    local pts = {}
    for k = 0, 5 do local a = k * math.pi / 3 - math.pi / 6; pts[#pts + 1] = x + math.cos(a) * 28; pts[#pts + 1] = y + math.sin(a) * 28 end
    ui.color(c, 0.12 + 0.06 * math.sin(t * 6)); g.polygon('fill', pts)
    g.setLineWidth(2); ui.color(c, 0.7 + 0.3 * math.sin(t * 6)); g.polygon('line', pts)
end
S.fly = function(x, y, t, c)
    ui.color(ui.c.black, 0.35); g.ellipse('fill', x, y + 24, 16, 5)
end
fx.status = S

function fx.drawStatuses(v, t)
    local a = v.a
    if a.fly then S.fly(v.x, v.y, t, ui.c.accent) end
    if a.stun > 0 then S.stun(v.x, v.y, t, ui.c.warn) end
    if a.poison > 0 then S.poison(v.x, v.y, t, ui.c.good) end
    if a.hypno then S.hypno(v.x, v.y, t, ui.rarity.scarce) end
    if a.immune > 0 then S.immune(v.x, v.y, t, ui.c.gold) end
    if v.statusPulse then
        local p = v.statusPulse.t / 0.6
        local c = ({stun = ui.c.warn, poison = ui.c.good, hypno = ui.rarity.scarce, block = ui.c.muted})[v.statusPulse.kind]
        g.setLineWidth(3 * (1 - p)); ui.color(c, 1 - p); g.circle('line', v.x, v.y, 16 + p * 30)
    end
end

-- ---------------------------------------------------------------- weapon effects
local STYLE = {rain = 'streaks', sun = 'rays', flux = 'rays', ring = 'rays', burst = 'rings', skull = 'lanefall', freeze = 'rings', eye = 'rays',
               arrow = 'projectile', dagger = 'projectile', axe = 'projectile', hammer = 'projectile', ram = 'projectile',
               bolt = 'lightning', jolt = 'lightning', orb = 'lightning',
               laser = 'beam', beam = 'beam', blade = 'beam', block = 'lock', comet = 'impact', cannon = 'impact', star = 'cross',
               restart = 'lift', crosshair = 'target', brain = 'wave', grenade = 'rows', wall = 'sweep', duel = 'lightning', boost = 'rays'}

local function laneRect(lane) return fx.FIELD_X + (lane - 1) * fx.LANE_W, fx.FIELD_Y, fx.LANE_W, fx.ROW_H * B.ROWS end
local lightningSeed = 0

local function drawLightning(x1, y1, x2, y2, c, w)
    local segs = 9
    local pts = {x1, y1}
    for k = 1, segs - 1 do
        local p = k / segs
        pts[#pts + 1] = x1 + (x2 - x1) * p + (math.random() - 0.5) * 40
        pts[#pts + 1] = y1 + (y2 - y1) * p + (math.random() - 0.5) * 12
    end
    pts[#pts + 1] = x2; pts[#pts + 1] = y2
    g.setLineWidth(w or 3); ui.color(c, 0.9); g.line(pts)
    g.setLineWidth((w or 3) * 3); ui.color(c, 0.2); g.line(pts)
end

function fx.drawWeapon(t)
    if not current or current.kind ~= 'weapon' then return end
    local ev = current.ev
    local w = Weapons[ev.id]
    local c = ui.rarity[w.rarity]
    local p = current.t / current.dur
    local style = STYLE[w.shape] or 'sweep'
    local fxX, fxY, fxW, fxH = fx.FIELD_X, fx.FIELD_Y, fx.LANE_W * B.LANES, fx.ROW_H * B.ROWS
    local cxF, cyF = fxX + fxW / 2, fxY + fxH / 2

    if ev.kind == 'field' or ev.kind == 'self' then
        ui.color(c, 0.28 * (1 - p)); g.rectangle('fill', fxX, fxY, fxW, fxH, 8, 8)
        if style == 'streaks' then
            for k = 1, 40 do
                local sx = fxX + ((k * 97) % 100) / 100 * fxW
                local sy = fxY + ((((k * 53) % 100) / 100 + p * 1.6) % 1) * fxH
                g.setLineWidth(2); ui.color(c, 0.8 * (1 - p)); g.line(sx, sy, sx - 10, sy + 34)
            end
        elseif style == 'rays' then
            for k = 0, 15 do
                local a = k * math.pi / 8 + p * 1.5
                local r = fxH * 0.9 * ease(p)
                g.setLineWidth(6 * (1 - p)); ui.color(c, 0.7 * (1 - p)); g.line(cxF, cyF, cxF + math.cos(a) * r, cyF + math.sin(a) * r)
            end
            ui.color(c, 0.9 * (1 - p)); g.circle('fill', cxF, cyF, 30 + 60 * ease(p))
        elseif style == 'rings' then
            for k = 0, 2 do
                local q = math.max(0, math.min(1, (p - k * 0.15) / 0.7))
                g.setLineWidth(8 * (1 - q)); ui.color(c, 0.8 * (1 - q)); g.circle('line', cxF, cyF, q * fxW * 0.6)
            end
        elseif style == 'lanefall' then
            for lane = 1, B.LANES do
                local x, y, lw, lh = laneRect(lane)
                ui.color(ui.c.black, 0.5 * math.sin(p * math.pi)); g.rectangle('fill', x, y, lw, lh * ease(p))
            end
        elseif style == 'rows' then
            for _, row in ipairs({1, B.ROWS}) do
                local y = fxY + (row - 1) * fx.ROW_H
                ui.color(c, 0.6 * (1 - p)); g.rectangle('fill', fxX, y, fxW * ease(math.min(1, p * 1.5)), fx.ROW_H)
            end
        end
    elseif ev.kind == 'lane' then
        local x, y, lw, lh = laneRect(ev.lane)
        local cx = x + lw / 2
        ui.color(c, 0.18 * (1 - p)); g.rectangle('fill', x, y, lw, lh, 6, 6)
        if style == 'projectile' then
            local q = math.min(1, p / 0.45)
            local py = y + lh - q * lh
            g.setLineWidth(5); ui.color(c, 0.95); g.line(cx, py, cx, py + 40)
            ui.color(c, 0.35); g.line(cx, py + 40, cx, py + 90)
            ui.color(ui.c.white, 0.9); g.circle('fill', cx, py, 5)
        elseif style == 'lightning' then
            if p < 0.6 then drawLightning(cx, y + lh, cx, y, c, 3) end
        elseif style == 'beam' then
            local q = math.sin(math.min(1, p / 0.7) * math.pi)
            ui.color(c, 0.35 * q); g.rectangle('fill', cx - 18, y, 36, lh)
            ui.color(ui.c.white, 0.95 * q); g.rectangle('fill', cx - 3, y, 6, lh)
        elseif style == 'lock' then
            g.setLineWidth(4); ui.color(ui.rarity.scarce, 0.8 * (1 - p)); g.rectangle('line', x + 6, y + 6, lw - 12, lh - 12, 8, 8)
            for k = 0, 4 do ui.color(ui.rarity.scarce, 0.5 * (1 - p)); g.line(x + 6, y + 6 + k * lh / 5, x + lw - 6, y + 6 + k * lh / 5) end
        elseif style == 'wave' then
            for k = 0, 3 do
                local q = ((p * 1.5) + k * 0.25) % 1
                g.setLineWidth(3); ui.color(c, (1 - q) * 0.8); g.arc('line', 'open', cx, y + lh - q * lh, 40, math.pi * 1.2, math.pi * 1.8)
            end
        else -- sweep
            local q = ease(math.min(1, p / 0.6))
            local h = lh * q
            ui.color(c, 0.45); g.rectangle('fill', x + 4, y + lh - h, lw - 8, h, 6, 6)
            ui.color(ui.c.white, 0.8); g.rectangle('fill', x + 4, y + lh - h, lw - 8, 4)
        end
    elseif ev.kind == 'tile' then
        local cx, cy = cellCenter(ev.row, ev.lane)
        if style == 'lift' then
            for k = 0, 2 do
                local q = ((p * 1.2) + k * 0.33) % 1
                ui.color(c, (1 - q) * 0.9); g.polygon('fill', cx, cy - 40 - q * 60, cx + 14, cy - 22 - q * 60, cx - 14, cy - 22 - q * 60)
            end
            ui.color(c, 0.25 * (1 - p)); g.rectangle('fill', cx - fx.LANE_W * 1.5, cy - fx.ROW_H * 1.5, fx.LANE_W * 3, fx.ROW_H * 3, 8, 8)
        elseif style == 'cross' then
            local q = ease(math.min(1, p / 0.5))
            ui.color(c, 0.6 * (1 - p)); g.rectangle('fill', cx - fx.LANE_W * 1.5 * q, cy - fx.ROW_H / 2, fx.LANE_W * 3 * q, fx.ROW_H)
            ui.color(c, 0.6 * (1 - p)); g.rectangle('fill', cx - fx.LANE_W / 2, cy - fx.ROW_H * 2.5 * q, fx.LANE_W, fx.ROW_H * 5 * q)
            ui.color(ui.c.white, 0.9 * (1 - p)); g.circle('fill', cx, cy, 12 + 20 * q)
        elseif style == 'target' then
            local q = math.min(1, p / 0.4)
            g.setLineWidth(3); ui.color(c, 1 - p * 0.5); g.circle('line', cx, cy, 40 - 22 * q)
            g.line(cx - 30, cy, cx + 30, cy); g.line(cx, cy - 25, cx, cy + 25)
            if p > 0.4 then ui.color(ui.c.white, (1 - p)); g.circle('fill', cx, cy, 18 * (p - 0.4)) end
        else -- impact (default tile): flash + ring + shards
            local q = ease(p)
            local big = style == 'impact' and 1.6 or 1
            ui.color(ui.c.white, 0.9 * (1 - p)); g.circle('fill', cx, cy, 10 + 30 * q * big)
            g.setLineWidth(6 * (1 - p)); ui.color(c, 0.9 * (1 - p)); g.circle('line', cx, cy, 70 * q * big)
            for k = 0, 7 do
                local a = k * math.pi / 4 + 0.3
                ui.color(c, 1 - p); g.circle('fill', cx + math.cos(a) * 80 * q * big, cy + math.sin(a) * 50 * q * big, 4)
            end
        end
    end
end

function fx.drawItem()
    if not current or current.kind ~= 'item' then return end
    local ev = current.ev
    local p = current.t / current.dur
    if ev.key == 'zap' then
        local x, y, lw, lh = laneRect(ev.lane)
        if p < 0.6 then drawLightning(x + lw / 2, y, x + lw / 2, y + lh, ui.c.warn, 4) end
    elseif ev.key == 'electricity' then
        ui.color(ui.c.warn, 0.3 * (1 - p)); g.rectangle('fill', fx.FIELD_X, fx.FIELD_Y, fx.LANE_W * B.LANES, fx.ROW_H * B.ROWS, 8, 8)
        for lane = 1, B.LANES do local x, y, lw, lh = laneRect(lane); if p < 0.5 then drawLightning(x + lw / 2, y, x + lw / 2, y + lh, ui.c.warn, 2) end end
    elseif ev.key == 'teleporter' then
        local cx, cy = cellCenter(ev.i, ev.j)
        for k = 0, 2 do
            local a = p * 12 + k * 2.09
            g.setLineWidth(3); ui.color(ui.c.accent, 1 - p); g.arc('line', 'open', cx - 56, cy, 30 * (1 - p) + 6, a, a + 1.5)
        end
    end
end

-- particles, popups, lines: drawn above aliens
function fx.drawOverlay()
    for _, sp in ipairs(sparks) do
        local a = 1 - sp.t / sp.life
        ui.color(sp.color, a); g.circle('fill', sp.x, sp.y, sp.size * a)
    end
    for _, l in ipairs(lines) do
        local a = 1 - l.t / 0.5
        g.setLineWidth(3); ui.color(l.color, a); g.line(l.x1, l.y1, l.x2, l.y2)
        ui.color(l.color, a); g.circle('fill', l.x2, l.y2, 6)
    end
    for _, p in ipairs(popups) do
        local a = math.min(1, (1.2 - p.t) * 2.5)
        ui.text(p.text, p.x - 60, p.y - ease(p.t) * 34, 120, 'center', 'hud', p.size, p.color, a)
    end
end

return fx
