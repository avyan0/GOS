-- Design system: palette, fonts, immediate-mode widgets, starfield, transitions.
-- Every screen draws with these so the whole game reads as one thing.
local ui = {}

local function hex(h, a)
    return {tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255, a or 1}
end

ui.c = {
    bg      = hex('0A0E1A'),
    bg2     = hex('0F1526'),
    panel   = hex('161E33'),
    panel2  = hex('1E2842'),
    line    = hex('2B3A5C'),
    text    = hex('EEF2FA'),
    muted   = hex('8B98B8'),
    dim     = hex('5A6684'),
    accent  = hex('4FD1FF'),
    warn    = hex('FFB547'),
    danger  = hex('FF5C6C'),
    good    = hex('5EE39A'),
    gold    = hex('FFD166'),
    black   = hex('000000'),
    white   = hex('FFFFFF'),
}
ui.rarity = {
    common = hex('5EE39A'),
    rare   = hex('4FA3FF'),
    scarce = hex('C77DFF'),
    god    = hex('FFB547'),
}
ui.rarityName = {common = 'Common', rare = 'Rare', scarce = 'Scarce', god = 'God'}

-- ---------------------------------------------------------------- fonts
-- 'body' is Orbitron (SIL Open Font License, assets/fonts/OFL.txt); 'display' and 'hud'
-- use our own pixel font (src/pixelfont.lua)
local pixelfont = require 'src/pixelfont'
local fontCache = {}
function ui.font(kind, size)
    if kind ~= 'body' then return pixelfont.get(size) end
    local key = kind .. size
    if not fontCache[key] then
        fontCache[key] = love.graphics.newFont('assets/fonts/body.otf', size)
    end
    return fontCache[key]
end

-- largest size (stepping down to min) at which str fits on one line of width w
function ui.fitSize(kind, str, w, size, min)
    while size > (min or 10) and ui.font(kind, size):getWidth(str) > w do size = size - 1 end
    return size
end

-- A name in the pixel font: one line if it fits, else wrapped onto up to maxLines at
-- the same size, else shrunk to one line. Returns lines used and the line height.
function ui.name(str, x, y, w, align, size, color, maxLines, alpha)
    local f = ui.font('display', size)
    local _, lines = f:getWrap(str, w)
    if #lines > 1 and #lines > (maxLines or 1) then
        size = ui.fitSize('display', str, w, size, 8)
        f = ui.font('display', size)
        _, lines = f:getWrap(str, w)
    end
    ui.text(str, x, y, w, align, 'display', size, color, alpha)
    return #lines, f:getHeight()
end

function ui.color(c, a)
    love.graphics.setColor(c[1], c[2], c[3], (a or 1) * (c[4] or 1))
end

local function mix(a, b, t)
    return {a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t, 1}
end
ui.mix = mix

-- ---------------------------------------------------------------- input (immediate mode)
ui.mouse = {x = -1, y = -1, down = false}
local pendingClick = nil   -- {x, y}, consumed by the first widget it lands on
local hot = {}             -- id -> hover anim (0..1)
local pressAnim = {}       -- id -> press anim (0..1)
local dt_ = 0

function ui.update(dt)
    dt_ = dt
    local x, y = push:toGame(love.mouse.getPosition())
    ui.mouse.x, ui.mouse.y = x or -1, y or -1
    ui.mouse.down = love.mouse.isDown(1)
end

function ui.click(x, y) pendingClick = {x = x, y = y} end
function ui.endFrame() pendingClick = nil end
function ui.clickPending() return pendingClick ~= nil end

local function inside(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end
ui.inside = inside

function ui.hovered(x, y, w, h) return inside(ui.mouse.x, ui.mouse.y, x, y, w, h) end

-- returns true on the frame a click lands inside the rect (and consumes it).
-- Every clickable thing routes through here, so this is where the click sound lives.
function ui.hit(x, y, w, h)
    if ui.hitLog then ui.hitLog[#ui.hitLog + 1] = {x, y, w, h} end -- smoke test: every clickable on screen
    if pendingClick and inside(pendingClick.x, pendingClick.y, x, y, w, h) then
        pendingClick = nil
        sfx.play('click')
        return true
    end
    return false
end

local function anim(tbl, id, target, speed)
    local v = tbl[id] or 0
    v = v + (target - v) * math.min(1, dt_ * (speed or 14))
    if math.abs(v - target) < 0.005 then v = target end
    tbl[id] = v
    return v
end

-- ---------------------------------------------------------------- primitives
function ui.rrect(mode, x, y, w, h, r)
    love.graphics.rectangle(mode, x, y, w, h, r or 10, r or 10)
end

function ui.panel(x, y, w, h, opts)
    opts = opts or {}
    ui.color(opts.fill or ui.c.panel, opts.alpha)
    ui.rrect('fill', x, y, w, h, opts.radius)
    if opts.border ~= false then
        love.graphics.setLineWidth(opts.lineWidth or 1.5)
        ui.color(opts.border or ui.c.line, opts.alpha)
        ui.rrect('line', x, y, w, h, opts.radius)
    end
end

function ui.text(str, x, y, w, align, kind, size, color, alpha)
    love.graphics.setFont(ui.font(kind or 'body', size or 18))
    ui.color(color or ui.c.text, alpha)
    love.graphics.printf(str, x, y, w or VIRTUAL_WIDTH, align or 'left')
end

function ui.label(str, x, y, kind, size, color)
    love.graphics.setFont(ui.font(kind or 'body', size or 18))
    ui.color(color or ui.c.text)
    love.graphics.print(str, x, y)
end

-- text centred vertically in a box
function ui.textBox(str, x, y, w, h, kind, size, color, align)
    local f = ui.font(kind or 'body', size or 18)
    love.graphics.setFont(f)
    local _, lines = f:getWrap(str, w)
    local th = #lines * f:getHeight()
    ui.color(color or ui.c.text)
    love.graphics.printf(str, x, y + (h - th) / 2, w, align or 'center')
end

function ui.progress(x, y, w, h, frac, color, track)
    ui.color(track or ui.c.bg2); ui.rrect('fill', x, y, w, h, h / 2)
    if frac > 0 then
        ui.color(color or ui.c.accent); ui.rrect('fill', x, y, math.max(h, w * math.min(1, frac)), h, h / 2)
    end
end

function ui.pips(x, y, n, filled, color, size, gap)
    size, gap = size or 8, gap or 5
    for i = 1, n do
        ui.color(i <= filled and (color or ui.c.accent) or ui.c.line)
        love.graphics.circle('fill', x + (i - 1) * (size + gap) + size / 2, y + size / 2, size / 2)
    end
end


-- ---------------------------------------------------------------- widgets
-- opts: color, textColor, kind, size, disabled, outline, id, icon(fn(x,y,size)), badge
function ui.button(label, x, y, w, h, opts)
    opts = opts or {}
    local id = opts.id or (label .. x .. y)
    local hoverT = anim(hot, id, (not opts.disabled and ui.hovered(x, y, w, h)) and 1 or 0)
    local pressing = ui.mouse.down and ui.hovered(x, y, w, h) and not opts.disabled
    local pressT = anim(pressAnim, id, pressing and 1 or 0, 30)

    local base = opts.color or ui.c.accent
    local lift = -3 * hoverT + 2 * pressT
    local bx, by = x, y + lift

    if opts.outline then
        ui.color(base, opts.disabled and 0.25 or 0.08 + 0.15 * hoverT); ui.rrect('fill', bx, by, w, h)
        love.graphics.setLineWidth(2)
        ui.color(base, opts.disabled and 0.3 or 0.6 + 0.4 * hoverT); ui.rrect('line', bx, by, w, h)
        ui.color(opts.textColor or base, opts.disabled and 0.4 or 1)
    else
        if hoverT > 0 and not opts.disabled then
            ui.color(base, 0.25 * hoverT); ui.rrect('fill', bx - 3, by - 3, w + 6, h + 6, 13)
        end
        ui.color(opts.disabled and ui.c.panel2 or mix(base, ui.c.white, 0.15 * hoverT)); ui.rrect('fill', bx, by, w, h)
        ui.color(opts.disabled and ui.c.dim or (opts.textColor or ui.c.bg))
    end

    local f = ui.font(opts.kind or 'display', opts.size or 22)
    love.graphics.setFont(f)
    local tx, tw = bx, w
    if opts.icon then
        local s = h * 0.55
        opts.icon(bx + 18 + s / 2, by + h / 2, s)
        tx, tw = bx + 18 + s + 10, w - 18 - s - 10 - 10
    end
    love.graphics.printf(label, tx, by + (h - f:getHeight()) / 2 + 1, tw, opts.align or 'center')

    if opts.disabled then return false end
    return ui.hit(x, y, w, h)
end

-- small icon-only round button
function ui.iconButton(id, x, y, r, drawIcon, opts)
    opts = opts or {}
    local hoverT = anim(hot, id, ui.hovered(x - r, y - r, r * 2, r * 2) and 1 or 0)
    ui.color(opts.color or ui.c.panel2, 1); love.graphics.circle('fill', x, y, r + 2 * hoverT)
    love.graphics.setLineWidth(1.5)
    ui.color(opts.border or ui.c.line, 0.6 + 0.4 * hoverT); love.graphics.circle('line', x, y, r + 2 * hoverT)
    ui.color(opts.iconColor or ui.c.text)
    drawIcon(x, y, r)
    return ui.hit(x - r, y - r, r * 2, r * 2)
end

function ui.arrowLeft(x, y, r)
    love.graphics.setLineWidth(3)
    love.graphics.line(x + r * 0.35, y, x - r * 0.35, y)
    love.graphics.line(x - r * 0.35, y, x, y - r * 0.35)
    love.graphics.line(x - r * 0.35, y, x, y + r * 0.35)
end

function ui.arrowRight(x, y, r)
    love.graphics.setLineWidth(3)
    love.graphics.line(x - r * 0.35, y, x + r * 0.35, y)
    love.graphics.line(x + r * 0.35, y, x, y - r * 0.35)
    love.graphics.line(x + r * 0.35, y, x, y + r * 0.35)
end

-- Screen header: title, optional subtitle, optional back button. Returns true when back is clicked.
function ui.header(title, subtitle, back)
    local x = 40
    if back then
        if ui.iconButton('back', 58, 52, 22, ui.arrowLeft) then return true end
        x = 100
    end
    ui.label(title, x, 30, 'display', 34)
    if subtitle then ui.label(subtitle, x + 2, 74, 'body', 17, ui.c.muted) end
    return false
end

-- top-right pill with gold + gems
function ui.wallet()
    local w, h = 240, 40
    local x, y = VIRTUAL_WIDTH - w - 30, 32
    ui.panel(x, y, w, h, {radius = 20})
    ui.color(ui.c.gold); love.graphics.circle('fill', x + 24, y + h / 2, 8)
    ui.label(tostring(data.gold), x + 40, y + 9, 'hud', 22, ui.c.text)
    ui.color(ui.c.accent)
    love.graphics.polygon('fill', x + 140, y + 12, x + 148, y + 20, x + 140, y + 28, x + 132, y + 20)
    ui.label(tostring(data.gems), x + 156, y + 9, 'hud', 22, ui.c.text)
end

-- bottom navigation. Returns the key of the tab that was clicked, or nil.
local NAV = {{'home', 'Home'}, {'aliens', 'Aliens'}, {'weapons', 'Weapons'}, {'shop', 'Shop'}, {'items', 'Items'}}
function ui.navbar(active)
    local h = 64
    local y = VIRTUAL_HEIGHT - h
    ui.color(ui.c.bg2); love.graphics.rectangle('fill', 0, y, VIRTUAL_WIDTH, h)
    ui.color(ui.c.line); love.graphics.rectangle('fill', 0, y, VIRTUAL_WIDTH, 1)
    local n = #NAV
    local w = VIRTUAL_WIDTH / n
    local result = nil
    for i, tab in ipairs(NAV) do
        local x = (i - 1) * w
        local isActive = tab[1] == active
        local hoverT = anim(hot, 'nav' .. tab[1], (ui.hovered(x, y, w, h) and not isActive) and 1 or 0)
        if isActive then
            ui.color(ui.c.accent); love.graphics.rectangle('fill', x + w * 0.3, y, w * 0.4, 3)
        end
        ui.text(tab[2], x, y + 20, w, 'center', 'display', 22, isActive and ui.c.accent or mix(ui.c.muted, ui.c.text, hoverT))
        if not isActive and ui.hit(x, y, w, h) then result = tab[1] end
    end
    return result
end

-- horizontal slider, immediate mode. Returns new value.
local dragging = nil
function ui.slider(id, x, y, w, value, min, max, color)
    local h = 6
    local t = (value - min) / (max - min)
    local kx = x + w * t
    local over = ui.hovered(x - 10, y - 14, w + 20, h + 28)
    if ui.mouse.down and (dragging == id or (over and dragging == nil)) then
        dragging = id
        t = math.max(0, math.min(1, (ui.mouse.x - x) / w))
        value = min + (max - min) * t
        kx = x + w * t
    elseif not ui.mouse.down and dragging == id then
        dragging = nil
    end
    ui.progress(x, y, w, h, t, color or ui.c.accent)
    ui.color(ui.c.text); love.graphics.circle('fill', kx, y + h / 2, dragging == id and 11 or 9)
    ui.color(color or ui.c.accent); love.graphics.circle('line', kx, y + h / 2, dragging == id and 11 or 9)
    return value
end

-- ---------------------------------------------------------------- tooltip
-- Hover card anchored near (x, y), clamped to the screen. rows: list of {text, kind, size, color}.
function ui.tooltip(x, y, rows, opts)
    opts = opts or {}
    local w = opts.width or 260
    local pad = 14
    local h = pad
    local laid = {}
    for _, r in ipairs(rows) do
        local f = ui.font(r[2] or 'body', r[3] or 14)
        local _, lines = f:getWrap(r[1], w - pad * 2)
        laid[#laid + 1] = {r = r, f = f, h = #lines * f:getHeight() + (r.gap or 4)}
        h = h + laid[#laid].h
    end
    h = h + pad - 4
    x = math.max(8, math.min(VIRTUAL_WIDTH - w - 8, x))
    y = math.max(8, math.min(VIRTUAL_HEIGHT - h - 8, y))
    ui.panel(x, y, w, h, {fill = ui.c.bg2, border = opts.color or ui.c.line, radius = 10, alpha = 0.97})
    local ty = y + pad
    for _, l in ipairs(laid) do
        love.graphics.setFont(l.f)
        ui.color(l.r[4] or ui.c.text)
        love.graphics.printf(l.r[1], x + pad, ty, w - pad * 2, 'left')
        ty = ty + l.h
    end
end

-- ---------------------------------------------------------------- background
local stars = {}
local nebula
local PX = 4 -- backdrop pixel size (nebula.png is 320x180, drawn at 4x)
function ui.initBackground()
    nebula = love.graphics.newImage('assets/img/nebula.png')
    nebula:setFilter('nearest', 'nearest')
    math.randomseed(7)
    for i = 1, 160 do
        stars[i] = {x = math.random(0, VIRTUAL_WIDTH / PX - 1) * PX, y = math.random(0, VIRTUAL_HEIGHT / PX - 1) * PX,
                    big = math.random() < 0.08, p = math.random() * 6.28, s = 0.3 + math.random() * 0.7,
                    warm = math.random() < 0.2}
    end
    math.randomseed(os.time())
end
function ui.background(t, withNebula)
    ui.color(ui.c.bg); love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    if withNebula ~= false and nebula then
        ui.color(ui.c.white, 0.85)
        love.graphics.draw(nebula, 0, 0, 0, VIRTUAL_WIDTH / nebula:getWidth(), VIRTUAL_HEIGHT / nebula:getHeight())
    end
    -- stars are single grid pixels that twinkle in steps; a few bright ones get a cross
    for _, s in ipairs(stars) do
        local a = 0.3 + 0.6 * math.floor((0.5 + 0.5 * math.sin(t * s.s + s.p)) * 3 + 0.5) / 3
        ui.color(s.warm and ui.c.gold or ui.c.white, a)
        love.graphics.rectangle('fill', s.x, s.y, PX / 2, PX / 2)
        if s.big then
            ui.color(s.warm and ui.c.gold or ui.c.white, a * 0.5)
            love.graphics.rectangle('fill', s.x - PX / 2, s.y, PX / 2, PX / 2); love.graphics.rectangle('fill', s.x + PX / 2, s.y, PX / 2, PX / 2)
            love.graphics.rectangle('fill', s.x, s.y - PX / 2, PX / 2, PX / 2); love.graphics.rectangle('fill', s.x, s.y + PX / 2, PX / 2, PX / 2)
        end
    end
end

-- brightness overlay from settings
function ui.brightness()
    ui.color(ui.c.black, 1 - data.brightness / 100)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

-- ---------------------------------------------------------------- transitions
local fade = 0
function ui.fadeIn() fade = 1 end
function ui.drawFade()
    if fade > 0 then
        fade = math.max(0, fade - dt_ * 4)
        ui.color(ui.c.bg, fade)
        love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    end
end

-- ---------------------------------------------------------------- toasts / popups
local toasts = {}
function ui.toast(msg, color)
    sfx.play('notify')
    table.insert(toasts, {msg = msg, color = color or ui.c.accent, t = 2.4})
end
function ui.drawToasts()
    for i = #toasts, 1, -1 do
        local tt = toasts[i]
        tt.t = tt.t - dt_
        if tt.t <= 0 then table.remove(toasts, i) else
            local a = math.min(1, tt.t * 2)
            local w = 420
            ui.panel(VIRTUAL_WIDTH / 2 - w / 2, 90 + (#toasts - i) * 50, w, 40, {alpha = a, border = tt.color})
            ui.text(tt.msg, VIRTUAL_WIDTH / 2 - w / 2, 99 + (#toasts - i) * 50, w, 'center', 'body', 18, tt.color, a)
        end
    end
end

return ui
