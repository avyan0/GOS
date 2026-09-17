-- Code-drawn icons. Every function draws centred at (x, y) inside an s x s box
-- using the current colour, so callers pick the rarity/faction colour.
local icons = {}
local g = love.graphics

local function seg(x1, y1, x2, y2, w) g.setLineWidth(w or 3); g.line(x1, y1, x2, y2) end
local function poly(mode, ...) g.polygon(mode, ...) end
local function ring(x, y, r, w) g.setLineWidth(w or 3); g.circle('line', x, y, r) end

-- ------------------------------------------------------------ weapons
local W = {}

W.rain = function(x, y, s)
    for i = -1, 1 do
        local dx = i * s * 0.28
        g.circle('fill', x + dx, y - s * 0.25 + (i % 2) * s * 0.18, s * 0.09)
        seg(x + dx + s * 0.06, y + s * 0.02 + (i % 2) * s * 0.18, x + dx - s * 0.06, y + s * 0.38 + (i % 2) * s * 0.18, 3)
    end
end
W.arrow = function(x, y, s)
    seg(x - s * 0.4, y + s * 0.4, x + s * 0.3, y - s * 0.3, 3)
    poly('fill', x + s * 0.4, y - s * 0.4, x + s * 0.08, y - s * 0.32, x + s * 0.32, y - s * 0.08)
    seg(x - s * 0.4, y + s * 0.4, x - s * 0.15, y + s * 0.4, 3); seg(x - s * 0.4, y + s * 0.4, x - s * 0.4, y + s * 0.15, 3)
end
W.crosshair = function(x, y, s)
    ring(x, y, s * 0.36, 3)
    for _, d in ipairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
        seg(x + d[1] * s * 0.22, y + d[2] * s * 0.22, x + d[1] * s * 0.48, y + d[2] * s * 0.48, 3)
    end
    g.circle('fill', x, y, s * 0.06)
end
W.flame = function(x, y, s)
    poly('fill', x, y - s * 0.45, x + s * 0.32, y + s * 0.05, x + s * 0.18, y + s * 0.42, x - s * 0.18, y + s * 0.42, x - s * 0.32, y + s * 0.05)
    g.setColor(0, 0, 0, 0.35)
    poly('fill', x, y - s * 0.1, x + s * 0.14, y + s * 0.18, x, y + s * 0.42, x - s * 0.14, y + s * 0.18)
end
W.bolt = function(x, y, s)
    poly('fill', x + s * 0.1, y - s * 0.48, x - s * 0.28, y + s * 0.06, x - s * 0.02, y + s * 0.06, x - s * 0.14, y + s * 0.48, x + s * 0.3, y - s * 0.1, x + s * 0.04, y - s * 0.1)
end
W.star = function(x, y, s)
    local pts = {}
    for i = 0, 9 do
        local r = (i % 2 == 0) and s * 0.48 or s * 0.2
        local a = -math.pi / 2 + i * math.pi / 5
        pts[#pts + 1] = x + math.cos(a) * r; pts[#pts + 1] = y + math.sin(a) * r
    end
    poly('fill', pts)
end
W.laser = function(x, y, s)
    seg(x - s * 0.45, y + s * 0.3, x + s * 0.45, y - s * 0.3, 6)
    g.circle('fill', x - s * 0.45, y + s * 0.3, s * 0.12)
    ring(x + s * 0.3, y - s * 0.2, s * 0.2, 2)
end
W.boost = function(x, y, s)
    poly('fill', x, y - s * 0.45, x + s * 0.4, y, x + s * 0.15, y, x + s * 0.15, y + s * 0.45, x - s * 0.15, y + s * 0.45, x - s * 0.15, y, x - s * 0.4, y)
end
W.orb = function(x, y, s)
    g.circle('fill', x, y, s * 0.3)
    ring(x, y, s * 0.45, 2)
    for i = 0, 3 do
        local a = i * math.pi / 2 + math.pi / 4
        seg(x + math.cos(a) * s * 0.32, y + math.sin(a) * s * 0.32, x + math.cos(a) * s * 0.5, y + math.sin(a) * s * 0.5, 2)
    end
end
W.ram = function(x, y, s)
    poly('fill', x - s * 0.4, y - s * 0.4, x + s * 0.4, y - s * 0.4, x + s * 0.4, y + s * 0.05, x, y + s * 0.45, x - s * 0.4, y + s * 0.05)
    g.setColor(0, 0, 0, 0.35); seg(x, y - s * 0.3, x, y + s * 0.3, 4)
end
W.jolt = function(x, y, s)
    for i = -1, 1 do
        local dx = i * s * 0.3
        seg(dx + x, y - s * 0.45, dx + x - s * 0.1, y - s * 0.05, 3); seg(dx + x - s * 0.1, y - s * 0.05, dx + x + s * 0.1, y + s * 0.05, 3); seg(dx + x + s * 0.1, y + s * 0.05, dx + x, y + s * 0.45, 3)
    end
end
W.dagger = function(x, y, s)
    poly('fill', x, y - s * 0.48, x + s * 0.12, y + s * 0.15, x - s * 0.12, y + s * 0.15)
    seg(x - s * 0.25, y + s * 0.18, x + s * 0.25, y + s * 0.18, 4)
    seg(x, y + s * 0.18, x, y + s * 0.45, 5)
end
W.hammer = function(x, y, s)
    seg(x - s * 0.3, y + s * 0.42, x + s * 0.15, y - s * 0.05, 5)
    g.rectangle('fill', x + s * 0.02, y - s * 0.45, s * 0.42, s * 0.3, 4, 4)
end
W.burst = function(x, y, s)
    for i = 0, 7 do
        local a = i * math.pi / 4
        seg(x + math.cos(a) * s * 0.15, y + math.sin(a) * s * 0.15, x + math.cos(a) * s * 0.48, y + math.sin(a) * s * 0.48, 3)
    end
    g.circle('fill', x, y, s * 0.14)
end
W.duel = function(x, y, s)
    g.arc('fill', x, y, s * 0.45, math.pi / 2, math.pi * 1.5)
    ring(x, y, s * 0.45, 2)
    g.circle('fill', x, y - s * 0.22, s * 0.1)
    g.setColor(0, 0, 0, 0.5); g.circle('fill', x, y + s * 0.22, s * 0.1)
end
W.restart = function(x, y, s)
    g.setLineWidth(4); g.arc('line', 'open', x, y, s * 0.36, -math.pi * 0.2, math.pi * 1.5)
    poly('fill', x + s * 0.36, y - s * 0.34, x + s * 0.5, y - s * 0.05, x + s * 0.2, y - s * 0.08)
end
W.axe = function(x, y, s)
    seg(x - s * 0.35, y + s * 0.45, x + s * 0.2, y - s * 0.2, 5)
    poly('fill', x + s * 0.05, y - s * 0.45, x + s * 0.48, y - s * 0.25, x + s * 0.42, y + s * 0.1, x + s * 0.1, y - s * 0.05)
end
W.block = function(x, y, s)
    ring(x, y, s * 0.42, 4)
    seg(x - s * 0.3, y - s * 0.3, x + s * 0.3, y + s * 0.3, 4)
end
W.shield = function(x, y, s)
    poly('fill', x - s * 0.38, y - s * 0.35, x + s * 0.38, y - s * 0.35, x + s * 0.32, y + s * 0.1, x, y + s * 0.45, x - s * 0.32, y + s * 0.1)
end
W.freeze = function(x, y, s)
    for i = 0, 2 do
        local a = i * math.pi / 3
        seg(x + math.cos(a) * s * 0.45, y + math.sin(a) * s * 0.45, x - math.cos(a) * s * 0.45, y - math.sin(a) * s * 0.45, 3)
    end
    g.circle('fill', x, y, s * 0.1)
end
W.beam = function(x, y, s)
    g.rectangle('fill', x - s * 0.48, y - s * 0.08, s * 0.96, s * 0.16, 3, 3)
    g.setColor(0, 0, 0, 0.3); g.rectangle('fill', x - s * 0.48, y - s * 0.02, s * 0.96, s * 0.04)
end
W.brain = function(x, y, s)
    g.circle('fill', x - s * 0.14, y, s * 0.28); g.circle('fill', x + s * 0.14, y, s * 0.28)
    g.setColor(0, 0, 0, 0.35); seg(x, y - s * 0.26, x, y + s * 0.26, 3)
end
W.grenade = function(x, y, s)
    g.circle('fill', x, y + s * 0.08, s * 0.34)
    g.rectangle('fill', x - s * 0.12, y - s * 0.42, s * 0.24, s * 0.16, 3, 3)
    g.setColor(0, 0, 0, 0.35); seg(x - s * 0.2, y + s * 0.08, x + s * 0.2, y + s * 0.08, 3)
end
W.wall = function(x, y, s)
    for r = 0, 2 do
        for c = 0, 1 do
            local off = (r % 2) * s * 0.2
            g.rectangle('fill', x - s * 0.42 + c * s * 0.44 + off, y - s * 0.4 + r * s * 0.28, s * 0.38, s * 0.22, 2, 2)
        end
    end
end
W.eye = function(x, y, s)
    poly('fill', x - s * 0.48, y, x - s * 0.2, y - s * 0.3, x + s * 0.2, y - s * 0.3, x + s * 0.48, y, x + s * 0.2, y + s * 0.3, x - s * 0.2, y + s * 0.3)
    g.setColor(0, 0, 0, 0.6); g.circle('fill', x, y, s * 0.14)
end
W.blade = function(x, y, s)
    g.setLineWidth(3)
    for i = 0, 2 do
        local a = i * math.pi * 2 / 3
        g.arc('line', 'open', x + math.cos(a) * s * 0.12, y + math.sin(a) * s * 0.12, s * 0.34, a, a + math.pi * 0.9)
    end
    g.circle('fill', x, y, s * 0.1)
end
W.sun = function(x, y, s)
    g.circle('fill', x, y, s * 0.26)
    for i = 0, 11 do
        local a = i * math.pi / 6
        seg(x + math.cos(a) * s * 0.33, y + math.sin(a) * s * 0.33, x + math.cos(a) * s * 0.48, y + math.sin(a) * s * 0.48, 2)
    end
end
W.comet = function(x, y, s)
    g.circle('fill', x + s * 0.2, y + s * 0.2, s * 0.2)
    poly('fill', x + s * 0.05, y + s * 0.35, x + s * 0.35, y + s * 0.05, x - s * 0.48, y - s * 0.48)
end
W.skull = function(x, y, s)
    g.circle('fill', x, y - s * 0.08, s * 0.32)
    g.rectangle('fill', x - s * 0.18, y + s * 0.1, s * 0.36, s * 0.24, 3, 3)
    g.setColor(0, 0, 0, 0.6); g.circle('fill', x - s * 0.12, y - s * 0.1, s * 0.08); g.circle('fill', x + s * 0.12, y - s * 0.1, s * 0.08)
end
W.cannon = function(x, y, s)
    g.rectangle('fill', x - s * 0.48, y - s * 0.12, s * 0.7, s * 0.24, 4, 4)
    g.circle('fill', x - s * 0.3, y + s * 0.25, s * 0.14)
    g.circle('fill', x + s * 0.32, y, s * 0.16)
end
W.ring = function(x, y, s)
    ring(x, y, s * 0.42, 5)
    g.setColor(0, 0, 0, 0.35); ring(x, y, s * 0.42, 1)
    g.circle('fill', x, y, s * 0.1)
end
W.flux = function(x, y, s)
    g.setLineWidth(4)
    g.arc('line', 'open', x - s * 0.2, y, s * 0.2, 0, math.pi)
    g.arc('line', 'open', x + s * 0.2, y, s * 0.2, math.pi, math.pi * 2)
    ring(x, y, s * 0.46, 2)
end
W.spin = function(x, y, s)
    g.circle('fill', x, y, s * 0.1)
    for i = 0, 5 do
        local a = i * math.pi / 3
        g.setLineWidth(3)
        g.arc('line', 'open', x, y, s * 0.42, a, a + 0.7)
    end
end

W.well = function(x, y, s)
    for k = 3, 1, -1 do ring(x, y, s * 0.15 * k, 2) end
    for i = 0, 3 do local a = i * math.pi / 2; poly('fill', x + math.cos(a) * s * 0.48, y + math.sin(a) * s * 0.48, x + math.cos(a + 0.25) * s * 0.3, y + math.sin(a + 0.25) * s * 0.3, x + math.cos(a - 0.25) * s * 0.3, y + math.sin(a - 0.25) * s * 0.3) end
end
W.bounce = function(x, y, s)
    seg(x - s * 0.45, y + s * 0.4, x - s * 0.05, y - s * 0.35, 3); seg(x - s * 0.05, y - s * 0.35, x + s * 0.2, y + s * 0.2, 3); seg(x + s * 0.2, y + s * 0.2, x + s * 0.45, y - s * 0.3, 3)
    g.circle('fill', x + s * 0.45, y - s * 0.3, s * 0.08)
end
W.scan = function(x, y, s)
    ring(x, y, s * 0.42, 2); ring(x, y, s * 0.22, 2)
    g.setLineWidth(4); g.arc('line', 'open', x, y, s * 0.42, -0.6, 0.6)
    seg(x, y, x + s * 0.4, y - s * 0.25, 2)
end
W.chain = function(x, y, s)
    seg(x - s * 0.45, y - s * 0.35, x - s * 0.15, y + s * 0.05, 3); seg(x - s * 0.15, y + s * 0.05, x + s * 0.1, y - s * 0.2, 3); seg(x + s * 0.1, y - s * 0.2, x + s * 0.45, y + s * 0.4, 3)
    for _, p in ipairs({{-0.45, -0.35}, {-0.15, 0.05}, {0.1, -0.2}, {0.45, 0.4}}) do g.circle('fill', x + p[1] * s, y + p[2] * s, s * 0.07) end
end
W.clock = function(x, y, s)
    ring(x, y, s * 0.42, 3)
    seg(x, y, x, y - s * 0.28, 3); seg(x, y, x + s * 0.2, y + s * 0.1, 3)
    g.circle('fill', x, y, s * 0.05)
end
W.barricade = function(x, y, s)
    for r = 0, 2 do g.rectangle('fill', x - s * 0.45 + (r % 2) * s * 0.1, y - s * 0.4 + r * s * 0.28, s * 0.9 - (r % 2) * s * 0.2, s * 0.22, 2, 2) end
    g.setColor(0, 0, 0, 0.3); seg(x - s * 0.45, y - s * 0.45, x + s * 0.45, y + s * 0.45, 3)
end
W.plague = function(x, y, s)
    g.circle('fill', x, y, s * 0.24)
    for i = 0, 5 do local a = i * math.pi / 3; g.circle('fill', x + math.cos(a) * s * 0.4, y + math.sin(a) * s * 0.4, s * 0.1); seg(x + math.cos(a) * s * 0.24, y + math.sin(a) * s * 0.24, x + math.cos(a) * s * 0.4, y + math.sin(a) * s * 0.4, 2) end
end
W.gear = function(x, y, s)
    for i = 0, 7 do local a = i * math.pi / 4; g.rectangle('fill', x + math.cos(a) * s * 0.36 - s * 0.07, y + math.sin(a) * s * 0.36 - s * 0.07, s * 0.14, s * 0.14) end
    g.circle('fill', x, y, s * 0.3); g.setColor(0, 0, 0, 0.5); g.circle('fill', x, y, s * 0.12)
end
W.guillotine = function(x, y, s)
    seg(x - s * 0.35, y - s * 0.45, x - s * 0.35, y + s * 0.45, 3); seg(x + s * 0.35, y - s * 0.45, x + s * 0.35, y + s * 0.45, 3)
    poly('fill', x - s * 0.3, y - s * 0.3, x + s * 0.3, y - s * 0.3, x + s * 0.3, y + s * 0.05, x - s * 0.3, y - s * 0.12)
end
W.nova = function(x, y, s)
    g.circle('fill', x, y, s * 0.18)
    for i = 0, 7 do local a = i * math.pi / 4; local r = (i % 2 == 0) and s * 0.5 or s * 0.32; seg(x + math.cos(a) * s * 0.22, y + math.sin(a) * s * 0.22, x + math.cos(a) * r, y + math.sin(a) * r, 3) end
end
W.hourglass = function(x, y, s)
    poly('fill', x - s * 0.3, y - s * 0.45, x + s * 0.3, y - s * 0.45, x, y - s * 0.02)
    poly('fill', x - s * 0.3, y + s * 0.45, x + s * 0.3, y + s * 0.45, x, y + s * 0.02)
    seg(x - s * 0.36, y - s * 0.45, x + s * 0.36, y - s * 0.45, 3); seg(x - s * 0.36, y + s * 0.45, x + s * 0.36, y + s * 0.45, 3)
end
W.meteors = function(x, y, s)
    for _, m in ipairs({{-0.3, 0.1, 0.16}, {0.2, 0.3, 0.13}, {0.3, -0.25, 0.1}}) do
        g.circle('fill', x + m[1] * s, y + m[2] * s, m[3] * s)
        seg(x + m[1] * s, y + m[2] * s, x + m[1] * s + s * 0.3, y + m[2] * s - s * 0.35, 3)
    end
end

function icons.weapon(shape, x, y, s, color)
    if color then g.setColor(color) end
    local f = W[shape] or W.orb
    f(x, y, s)
end

-- ------------------------------------------------------------ aliens
-- spec: {shape='round'|'square'|'hex'|'diamond'|'tri', eyes=n, hue=0..1, sat=, horns=bool, crown=bool, aura=bool}
local function hsl(h, s, l)
    local function f(n)
        local k = (n + h * 12) % 12
        local a = s * math.min(l, 1 - l)
        return l - a * math.max(-1, math.min(k - 3, 9 - k, 1))
    end
    return f(0), f(8), f(4)
end
icons.hsl = hsl

local function body(shape, x, y, r)
    if shape == 'round' then g.circle('fill', x, y, r)
    elseif shape == 'square' then g.rectangle('fill', x - r, y - r, r * 2, r * 2, r * 0.3, r * 0.3)
    elseif shape == 'diamond' then poly('fill', x, y - r * 1.05, x + r * 1.05, y, x, y + r * 1.05, x - r * 1.05, y)
    elseif shape == 'tri' then poly('fill', x, y - r * 1.1, x + r * 1.05, y + r * 0.8, x - r * 1.05, y + r * 0.8)
    else -- hex
        local pts = {}
        for i = 0, 5 do local a = i * math.pi / 3 - math.pi / 6; pts[#pts + 1] = x + math.cos(a) * r * 1.08; pts[#pts + 1] = y + math.sin(a) * r * 1.08 end
        poly('fill', pts)
    end
end

function icons.alien(spec, x, y, s, alpha)
    alpha = alpha or 1
    local r = s * 0.36
    local cr, cg, cb = hsl(spec.hue, spec.sat or 0.7, 0.55)
    if spec.aura then
        for i = 3, 1, -1 do g.setColor(cr, cg, cb, 0.08 * alpha); g.circle('fill', x, y, r + i * r * 0.28) end
    end
    if spec.horns then
        g.setColor(cr * 0.6, cg * 0.6, cb * 0.6, alpha)
        poly('fill', x - r * 0.7, y - r * 0.5, x - r * 1.05, y - r * 1.25, x - r * 0.25, y - r * 0.85)
        poly('fill', x + r * 0.7, y - r * 0.5, x + r * 1.05, y - r * 1.25, x + r * 0.25, y - r * 0.85)
    end
    g.setColor(cr, cg, cb, alpha)
    body(spec.shape or 'round', x, y, r)
    g.setColor(0, 0, 0, 0.18 * alpha)
    body(spec.shape or 'round', x, y + r * 0.12, r * 0.8)
    -- eyes
    local n = spec.eyes or 2
    g.setColor(0.04, 0.05, 0.1, alpha)
    for i = 1, n do
        local ex = x + (i - (n + 1) / 2) * r * 0.55
        g.circle('fill', ex, y - r * 0.1, r * 0.17)
        g.setColor(1, 1, 1, 0.9 * alpha); g.circle('fill', ex + r * 0.05, y - r * 0.15, r * 0.06)
        g.setColor(0.04, 0.05, 0.1, alpha)
    end
    if spec.crown then
        g.setColor(1, 0.82, 0.35, alpha)
        poly('fill', x - r * 0.6, y - r * 0.85, x - r * 0.6, y - r * 1.35, x - r * 0.25, y - r * 1.0, x, y - r * 1.45, x + r * 0.25, y - r * 1.0, x + r * 0.6, y - r * 1.35, x + r * 0.6, y - r * 0.85)
    end
end

-- planet: banded disc with optional ring
function icons.planet(x, y, r, hue, ringed, locked)
    local a = locked and 0.35 or 1
    local cr, cg, cb = hsl(hue, 0.6, 0.5)
    for i = 3, 1, -1 do g.setColor(cr, cg, cb, 0.06 * a); g.circle('fill', x, y, r + i * r * 0.18) end
    g.setColor(cr, cg, cb, a); g.circle('fill', x, y, r)
    local dr, dg, db = hsl(hue, 0.6, 0.38)
    g.setColor(dr, dg, db, a)
    g.setLineWidth(r * 0.12)
    g.arc('line', 'open', x, y, r * 0.75, 0.3, 1.4)
    g.arc('line', 'open', x, y, r * 0.5, 2.6, 3.6)
    g.setColor(0, 0, 0, 0.25 * a); g.arc('fill', x, y, r, math.pi * 1.15, math.pi * 1.85)
    if ringed then
        g.setColor(1, 1, 1, 0.5 * a); g.setLineWidth(r * 0.1)
        g.ellipse('line', x, y, r * 1.55, r * 0.45)
    end
end

-- ---------------------------------------------------------------- rendered art (assets/img), with code-drawn fallbacks
local imgCache = {}
local function image(path)
    if imgCache[path] == nil then
        local ok, img = pcall(g.newImage, path)
        imgCache[path] = ok and img or false
    end
    return imgCache[path] or nil
end
icons.image = image

-- planet `index` drawn so its sphere has radius r (the PNG sphere spans `sphere` of the image width)
local PLANET_SPHERE = {0.745, 0.495, 0.745, 0.745, 0.487, 0.73}
function icons.planetArt(index, x, y, r, locked)
    local img = image('assets/img/planets/' .. index .. '.png')
    if not img then return false end
    local w = img:getWidth()
    local scale = (r * 2) / (w * (PLANET_SPHERE[index] or 0.745))
    local a = locked and 0.3 or 1
    g.setColor(a, a, a, 1)
    g.draw(img, x, y, 0, scale, scale, w / 2, img:getHeight() / 2)
    g.setColor(1, 1, 1, 1)
    return true
end

-- weapon icon `id` centred at x,y; s matches the size the code-drawn icons use
function icons.weaponArt(id, x, y, s, alpha)
    local img = image('assets/img/weapons/' .. id .. '.png')
    if not img then return false end
    local sc = s * 1.45 / img:getHeight()
    g.setColor(1, 1, 1, alpha or 1)
    g.draw(img, x, y, 0, sc, sc, img:getWidth() / 2, img:getHeight() / 2)
    g.setColor(1, 1, 1, 1)
    return true
end

-- alien portrait `key` centred at x,y
function icons.alienArt(key, x, y, s, alpha)
    local img = image('assets/img/aliens/' .. key .. '.png')
    if not img then return false end
    local sc = s * 1.3 / img:getHeight()
    g.setColor(1, 1, 1, alpha or 1)
    g.draw(img, x, y, 0, sc, sc, img:getWidth() / 2, img:getHeight() / 2)
    g.setColor(1, 1, 1, 1)
    return true
end

function icons.lock(x, y, s, color)
    if color then g.setColor(color) end
    g.setLineWidth(s * 0.12)
    g.arc('line', 'open', x, y - s * 0.12, s * 0.22, math.pi, math.pi * 2)
    g.rectangle('fill', x - s * 0.3, y - s * 0.1, s * 0.6, s * 0.46, s * 0.08, s * 0.08)
end

function icons.check(x, y, s, color)
    if color then g.setColor(color) end
    seg(x - s * 0.3, y, x - s * 0.08, y + s * 0.25, s * 0.14)
    seg(x - s * 0.08, y + s * 0.25, x + s * 0.34, y - s * 0.28, s * 0.14)
end

-- items
local I = {}
I.Wall = W.wall
I.Zap = W.bolt
I.DoubleGold = function(x, y, s) g.circle('fill', x - s * 0.15, y + s * 0.05, s * 0.28); g.setColor(0, 0, 0, 0.3); g.circle('fill', x - s * 0.15, y + s * 0.05, s * 0.16); g.setColor(1, 1, 1, 1); ring(x + s * 0.18, y - s * 0.1, s * 0.28, 3) end
I.Electricity = W.jolt
I.Retreat = function(x, y, s) seg(x + s * 0.4, y, x - s * 0.4, y, 4); poly('fill', x - s * 0.48, y, x - s * 0.15, y - s * 0.3, x - s * 0.15, y + s * 0.3) end
I.Bomb = W.grenade
I.Teleporter = W.flux
I.Protection = W.shield
function icons.item(key, x, y, s, color)
    if color then g.setColor(color) end
    (I[key] or W.orb)(x, y, s)
end

return icons
