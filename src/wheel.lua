-- Prize wheel: reward tables per tier + an animated wheel widget.
local wheel = {}

local function weaponSegs(rarity)
    local out = {}
    for _, id in ipairs(WEAPON_ORDER) do
        if Weapons[id].rarity == rarity then out[#out + 1] = {w = 10, kind = 'weapon', id = id} end
    end
    return out
end

local function concat(...)
    local out = {}
    for _, list in ipairs({...}) do for _, v in ipairs(list) do out[#out + 1] = v end end
    return out
end

function wheel.table(tier)
    if tier == 'Common' then
        return concat({{w = 20, kind = 'gold', min = 15, max = 35}}, weaponSegs('common'))
    elseif tier == 'Rare' then
        return concat({{w = 10, kind = 'gold', min = 27, max = 63}}, weaponSegs('rare'), {{w = 10, kind = 'gold', min = 27, max = 63}})
    elseif tier == 'Scarce' then
        return concat({{w = 10, kind = 'gold', min = 60, max = 140}}, weaponSegs('scarce'), {{w = 10, kind = 'gems', min = 3, max = 7}})
    elseif tier == 'God' then
        return concat(weaponSegs('god'), {{w = 10, kind = 'gold', min = 162, max = 378}, {w = 20, kind = 'gems', min = 12, max = 28}})
    else -- Item
        return {
            {w = 20, kind = 'item', id = 'Retreat', min = 1, max = 3}, {w = 30, kind = 'item', id = 'Wall', min = 1, max = 6},
            {w = 10, kind = 'item', id = 'Zap', min = 1, max = 3},     {w = 5,  kind = 'item', id = 'Bomb', min = 1, max = 2},
            {w = 10, kind = 'item', id = 'DoubleGold', min = 1, max = 3}, {w = 5, kind = 'item', id = 'Teleporter', min = 1, max = 2},
            {w = 10, kind = 'item', id = 'Electricity', min = 1, max = 2}, {w = 10, kind = 'item', id = 'Protection', min = 1, max = 2},
        }
    end
end

function wheel.roll(segs)
    local total = 0
    for _, s in ipairs(segs) do total = total + s.w end
    local r = math.random() * total
    for i, s in ipairs(segs) do
        r = r - s.w
        if r <= 0 then return i end
    end
    return #segs
end

-- applies the reward to `data` and returns {title, subtitle, color, icon(fn)}
function wheel.apply(seg)
    if seg.kind == 'gold' then
        local n = math.random(seg.min, seg.max); data.gold = data.gold + n
        return {title = n .. ' Gold', color = ui.c.gold, icon = function(x, y, s) ui.color(ui.c.gold); love.graphics.circle('fill', x, y, s * 0.4) end}
    elseif seg.kind == 'gems' then
        local n = math.random(seg.min, seg.max); data.gems = data.gems + n
        return {title = n .. ' Gems', color = ui.c.accent, icon = function(x, y, s) ui.color(ui.c.accent); love.graphics.polygon('fill', x, y - s * 0.45, x + s * 0.4, y, x, y + s * 0.45, x - s * 0.4, y) end}
    elseif seg.kind == 'item' then
        local n = math.random(seg.min, seg.max)
        local item
        for _, it in ipairs(ITEMS) do if it.key == seg.id then item = it end end
        data.items[seg.id] = true
        data[item.stat] = data[item.stat] + n
        return {title = n .. 'x ' .. item.name, color = ui.c.good, icon = function(x, y, s) icons.item(seg.id, x, y, s, ui.c.good) end}
    else
        local w = Weapons[seg.id]
        local color = ui.rarity[w.rarity]
        local sub
        if data.weapons[seg.id] and (data.upgrades[seg.id] or 0) >= MAX_UPGRADE then
            local n = ({common = 25, rare = 45, scarce = 100, god = 270})[w.rarity]
            data.gold = data.gold + n
            sub = 'Already at max level  -  ' .. n .. ' gold instead'
        elseif data.weapons[seg.id] then
            data.upgrades[seg.id] = (data.upgrades[seg.id] or 0) + 1
            sub = 'Upgraded to level ' .. data.upgrades[seg.id]
        else
            data.weapons[seg.id] = true
            sub = 'New weapon unlocked'
        end
        return {title = w.name, subtitle = sub, color = color, icon = function(x, y, s) if not icons.weaponArt(w.id, x, y, s) then icons.weapon(w.shape, x, y, s, color) end end}
    end
end

function wheel.segLabel(seg)
    if seg.kind == 'gold' then return 'Gold' elseif seg.kind == 'gems' then return 'Gems'
    elseif seg.kind == 'item' then return seg.id else return Weapons[seg.id].name end
end

function wheel.segColor(seg, i)
    if seg.kind == 'gold' then return ui.c.gold elseif seg.kind == 'gems' then return ui.c.accent
    elseif seg.kind == 'item' then return (i % 2 == 0) and ui.c.good or ui.mix(ui.c.good, ui.c.bg, 0.35)
    else
        local c = ui.rarity[Weapons[seg.id].rarity]
        return (i % 2 == 0) and c or ui.mix(c, ui.c.bg, 0.35)
    end
end

-- ------------------------------------------------------------ widget
local Wheel = {}
Wheel.__index = Wheel

function wheel.new(tier)
    local self = setmetatable({}, Wheel)
    self.segs = wheel.table(tier)
    self.total = 0
    for _, s in ipairs(self.segs) do self.total = self.total + s.w end
    self.angle = 0
    self.spinning = false
    self.t = 0
    return self
end

-- start spinning toward segment index; lands after ~3.2s
function Wheel:spin(index)
    local start = 0
    for i = 1, index - 1 do start = start + self.segs[i].w end
    local mid = (start + self.segs[index].w * (0.3 + math.random() * 0.4)) / self.total * math.pi * 2
    -- pointer is at the top (-pi/2); the wheel rotates so that `mid` ends up under it
    self.from = self.angle % (math.pi * 2)
    self.to = self.from + math.pi * 2 * 5 + ((-math.pi / 2 - mid - self.from) % (math.pi * 2))
    self.t = 0
    self.dur = 3.2
    self.spinning = true
end

function Wheel:update(dt)
    if not self.spinning then return false end
    self.t = self.t + dt
    local p = math.min(1, self.t / self.dur)
    local e = 1 - (1 - p) ^ 3
    self.angle = self.from + (self.to - self.from) * e
    -- click as each segment edge passes the pointer
    local seg = math.floor((( -math.pi / 2 - self.angle) % (math.pi * 2)) / (math.pi * 2) * 48)
    if seg ~= self.lastSeg then self.lastSeg = seg; sfx.play('tick', {vol = 0.6, gap = 0.01}) end
    if p >= 1 then self.spinning = false; sfx.play('chime'); return true end
    return false
end

function Wheel:draw(x, y, r)
    local g = love.graphics
    ui.glow(x, y, r, ui.c.accent, 0.05)
    local a = self.angle
    for i, s in ipairs(self.segs) do
        local sweep = s.w / self.total * math.pi * 2
        ui.color(wheel.segColor(s, i))
        g.arc('fill', x, y, r, a, a + sweep)
        ui.color(ui.c.bg, 0.6); g.setLineWidth(2); g.arc('line', 'open', x, y, r, a, a + sweep)
        g.line(x, y, x + math.cos(a) * r, y + math.sin(a) * r)
        -- label
        local m = a + sweep / 2
        g.push(); g.translate(x + math.cos(m) * r * 0.62, y + math.sin(m) * r * 0.62); g.rotate(m + (math.cos(m) < 0 and math.pi or 0))
        love.graphics.setFont(ui.font('display', 13)); ui.color(ui.c.bg, 0.9)
        local label = wheel.segLabel(s)
        g.printf(label, -r * 0.3, -8, r * 0.6, 'center')
        g.pop()
        a = a + sweep
    end
    ui.color(ui.c.bg2); g.circle('fill', x, y, r * 0.16)
    ui.color(ui.c.line); g.setLineWidth(3); g.circle('line', x, y, r)
    -- pointer
    ui.color(ui.c.text)
    g.polygon('fill', x - 14, y - r - 14, x + 14, y - r - 14, x, y - r + 12)
end

return wheel
