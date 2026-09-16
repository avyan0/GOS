-- Pick three weapons before a level.
Loadout = Class{}

local RARITIES = {'common', 'rare', 'scarce', 'god'}
local SLOT_KEYS = {'weaponChoose1', 'weaponChoose2', 'weaponChoose3'}

function Loadout:init()
    self.t = 0
    self.tab = 'common'
    self.slot = nil        -- slot index selected for replacement
    self.preview = nil     -- weapon id shown in the detail panel
end
function Loadout:update(dt) self.t = self.t + dt end

local function slotHas(id)
    for i, k in ipairs(SLOT_KEYS) do if data[k] == id then return i end end
end

function Loadout:pick(id)
    local existing = slotHas(id)
    if existing then data[SLOT_KEYS[existing]] = ''; return end
    local target = self.slot
    if not target then
        for i, k in ipairs(SLOT_KEYS) do if data[k] == '' or not data.weapons[data[k]] then target = i; break end end
    end
    target = target or 1
    data[SLOT_KEYS[target]] = id
    self.slot = nil
end

-- shared slot strip (also used by StageSelect). Returns clicked slot index (and its weapon id) or nil.
function drawSlots(x, y, w, selectedSlot, t)
    local sw = (w - 32) / 3
    local clicked, clickedId
    for i, k in ipairs(SLOT_KEYS) do
        local sx = x + (i - 1) * (sw + 16)
        local id = data[k]
        local w_ = (id ~= '' and data.weapons[id]) and Weapons[id] or nil
        local sel = selectedSlot == i
        local hover = ui.hovered(sx, y, sw, 96)
        ui.panel(sx, y, sw, 96, {fill = sel and ui.c.panel2 or ui.c.panel, border = sel and ui.c.accent or (hover and ui.c.muted or ui.c.line), radius = 14})
        ui.text('SLOT ' .. i, sx + 16, y + 10, 100, 'left', 'hud', 13, ui.c.muted)
        if w_ then
            local color = ui.rarity[w_.rarity]
            icons.weapon(w_.shape, sx + 44, y + 58, 44, color)
            local size = ui.fitSize('display', w_.name, sw - 90, 18, 12)
            ui.text(w_.name, sx + 78, y + 36 + (18 - size) / 2, sw - 90, 'left', 'display', size)
            ui.text(ui.rarityName[w_.rarity] .. '   -   Lv ' .. (data.upgrades[id] or 0), sx + 78, y + 62, sw - 90, 'left', 'body', 14, color)
        else
            local pulse = 0.5 + 0.5 * math.sin((t or 0) * 3)
            ui.color(ui.c.accent, 0.3 + 0.3 * pulse); love.graphics.setLineWidth(2)
            love.graphics.circle('line', sx + 44, y + 58, 20)
            ui.text('Empty slot', sx + 78, y + 48, sw - 90, 'left', 'body', 15, ui.c.muted)
        end
        if ui.hit(sx, y, sw, 96) then clicked = i; clickedId = w_ and id or nil end
    end
    return clicked, clickedId
end

-- what this level spawns, as a row of icons with share %. Undiscovered aliens stay hidden.
-- Returns a function that draws the hover card, to call after everything else.
function drawIncoming(x, y)
    local L = Levels[data.currentLevel]
    if not L then return end
    local list, prev = {}, 0
    for _, name in ipairs(alienNames) do
        local top = L[name] or 0
        if top > prev then list[#list + 1] = {a = Aliens[name], share = top - prev}; prev = top end
    end
    table.sort(list, function(p, q) return p.share > q.share end)
    ui.text('INCOMING', x, y, 200, 'left', 'hud', 12, ui.c.muted)
    local hover
    local shown = math.min(#list, 8)
    if #list > shown then ui.text('+' .. (#list - shown) .. ' more', x + shown * 62, y + 38, 80, 'left', 'body', 13, ui.c.muted) end
    for k = 1, shown do
        local e = list[k]
        local ix = x + (k - 1) * 62
        local seen = data.seen[e.a.name]
        ui.panel(ix, y + 18, 54, 54, {fill = ui.c.bg2, border = ui.c.line, radius = 10})
        if seen then icons.alien(e.a.spec, ix + 27, y + 43, 30) else icons.lock(ix + 27, y + 45, 16, ui.c.dim) end
        ui.text(e.share .. '%', ix, y + 74, 54, 'center', 'hud', 11, ui.c.muted)
        if ui.hovered(ix, y + 18, 54, 54) then hover = {e = e, x = ix, y = y + 96} end
    end
    if not hover then return nil end
    return function()
        local a = hover.e.a
        if data.seen[a.name] then
            ui.tooltip(hover.x, hover.y, {{a.title, 'display', 15}, {(a.hevalten and 'HEVALTEN   -   ' or '') .. a.health .. ' HP', 'hud', 11, a.hevalten and ui.c.danger or ui.c.muted, gap = 6}, {a.desc, 'body', 13}}, {width = 260})
        else
            ui.tooltip(hover.x, hover.y, {{'Unknown alien', 'display', 15, ui.c.muted}, {'You have not met this one yet.', 'body', 13}}, {width = 220})
        end
    end
end

-- clicking a slot toggles it for replacement and previews what is in it
function Loadout:slotClicked(clicked, id)
    self.slot = (self.slot == clicked) and nil or clicked
    if id then self.preview = id; self.tab = Weapons[id].rarity end
end

function Loadout:ready()
    local a, b, c = data.weaponChoose1, data.weaponChoose2, data.weaponChoose3
    return a ~= '' and b ~= '' and c ~= '' and a ~= b and a ~= c and b ~= c
        and data.weapons[a] and data.weapons[b] and data.weapons[c]
end

function Loadout:render()
    ui.background(self.t)
    local planet, lvl = data.currentLevel:match('(%d+)%-(%d+)')
    if ui.header('Loadout', PLANETS[tonumber(planet)].name .. '   -   Level ' .. lvl, true) then gStateMachine:change('planetMap', tonumber(planet)) end
    local tip = drawIncoming(430, 14)

    local clicked, clickedId = drawSlots(40, 100, 760, self.slot, self.t)
    if clicked then self:slotClicked(clicked, clickedId) end

    local tx = 40
    for _, r in ipairs(RARITIES) do
        if ui.button(ui.rarityName[r], tx, 214, 150, 34, {outline = self.tab ~= r, color = ui.rarity[r], size = 16, id = 'ltab' .. r}) then self.tab = r end
        tx = tx + 160
    end

    local cw, ch, gap = 176, 118, 8
    local i = 0
    for _, id in ipairs(WEAPON_ORDER) do
        local w = Weapons[id]
        if w.rarity == self.tab then
            local col, row = i % 4, math.floor(i / 4)
            local x, y = 40 + col * (cw + gap), 258 + row * (ch + gap)
            local inSlot = slotHas(id)
            if drawWeaponCard(w, x, y, cw, ch, inSlot ~= nil, {equipped = inSlot ~= nil}) then
                self.preview = id
                if data.weapons[id] then self:pick(id) end
            end
            if ui.hovered(x, y, cw, ch) then self.preview = id end
            i = i + 1
        end
    end

    drawWeaponDetail(self.preview and Weapons[self.preview], 820, 100, 420, 480)
    local ready = self:ready()
    if ui.button(ready and 'Launch' or 'Choose 3 weapons', 820, 600, 420, 56, {size = 24, disabled = not ready, id = 'launch'}) then
        saveData()
        gStateMachine:change('battle')
    end
    if tip then tip() end
end

function Loadout:keyPressed(k)
    if k == 'escape' then gStateMachine:change('planetMap', tonumber(data.currentLevel:match('^(%d+)')))
    elseif (k == 'return' or k == 'kpenter') and self:ready() and self.t > 0.5 then saveData(); gStateMachine:change('battle') end
end
