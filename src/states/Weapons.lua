-- Weapons is the data table; this screen is WeaponsScreen.
WeaponsScreen = Class{}

local RARITIES = {'common', 'rare', 'scarce', 'god'}

function WeaponsScreen:init()
    self.t = 0
    self.tab = 'common'
    self.selected = nil
end
function WeaponsScreen:update(dt) self.t = self.t + dt end

function WeaponsScreen:enter(params)
    if params and params.tab then self.tab = params.tab end
    if params and params.id then self.selected = params.id end
end

-- Shared weapon card. Returns true when clicked.
function drawWeaponCard(w, x, y, cw, ch, selected, opts)
    opts = opts or {}
    local owned = data.weapons[w.id]
    local color = ui.rarity[w.rarity]
    local hover = ui.hovered(x, y, cw, ch)
    ui.panel(x, y, cw, ch, {fill = selected and ui.c.panel2 or ui.c.panel, border = selected and color or (hover and ui.c.muted or ui.c.line), radius = 14})
    if owned then
        ui.color(color, 0.12); ui.rrect('fill', x + 12, y + 12, cw - 24, ch * 0.5, 10)
        if not icons.weaponArt(w.id, x + cw / 2, y + 12 + ch * 0.25, ch * 0.36) then icons.weapon(w.shape, x + cw / 2, y + 12 + ch * 0.25, ch * 0.36, color) end
        ui.text(w.name, x + 6, y + ch * 0.5 + 16, cw - 12, 'center', 'display', ui.fitSize('display', w.name, cw - 12, 14, 10))
        ui.pips(x + cw / 2 - 26, y + ch - 16, 5, data.upgrades[w.id] or 0, color, 6, 4)
        if opts.equipped then
            ui.color(color); love.graphics.circle('fill', x + cw - 14, y + 14, 6)
        end
    else
        ui.color(ui.c.bg2, 0.6); ui.rrect('fill', x + 12, y + 12, cw - 24, ch * 0.5, 10)
        icons.lock(x + cw / 2, y + 12 + ch * 0.25, 30, ui.c.dim)
        ui.text(w.name, x + 6, y + ch * 0.5 + 16, cw - 12, 'center', 'display', ui.fitSize('display', w.name, cw - 12, 14, 10), ui.c.dim)
    end
    return ui.hit(x, y, cw, ch)
end

-- Shared detail panel used by Weapons and Loadout.
function drawWeaponDetail(w, px, py, pw, ph)
    ui.panel(px, py, pw, ph, {radius = 16})
    if not w then
        ui.textBox('Select a weapon to see its stats', px + 20, py, pw - 40, ph, 'body', 18, ui.c.muted)
        return
    end
    local color = ui.rarity[w.rarity]
    local owned = data.weapons[w.id]
    if owned then if not icons.weaponArt(w.id, px + pw / 2, py + 90, 110) then icons.weapon(w.shape, px + pw / 2, py + 90, 110, color) end else icons.lock(px + pw / 2, py + 90, 60, ui.c.dim) end
    ui.text(w.name, px, py + 165, pw, 'center', 'display', 28)
    ui.text(ui.rarityName[w.rarity]:upper(), px, py + 202, pw, 'center', 'hud', 16, color)

    local mult = upgradeMultiplier(w)
    local statY = py + 240
    local function stat(label, value, x)
        ui.text(label, x, statY, 120, 'left', 'body', 14, ui.c.muted)
        ui.text(value, x, statY + 18, 130, 'left', 'hud', 26)
    end
    stat('Damage', w.damage > 0 and tostring(math.round(w.damage * mult)) or '-', px + 30)
    stat('Cooldown', w.cooldown > 0 and (w.cooldown .. ' turns') or 'None', px + 160)
    local target = ({all = 'Field', lane = 'Lane', tile = 'Tile', row = 'Rows', buff = 'Buff', ['Random Lane'] = 'Random'})[w.aoe] or w.aoe
    stat('Target', target, px + 300)

    ui.text(w.specialEffect, px + 30, py + 300, pw - 60, 'left', 'body', 16)

    local lvl = data.upgrades[w.id] or 0
    local foot = owned and ('Level ' .. lvl .. '/' .. MAX_UPGRADE .. '   +' .. (lvl * 10) .. '% dmg') or 'Not yet unlocked - win it from a spin'
    ui.text(foot, px + 30, py + ph - 60, pw - 230, 'left', 'body', 14, owned and color or ui.c.muted)
    ui.pips(px + 30, py + ph - 34, MAX_UPGRADE, lvl, color, 10, 6)
    -- gems buy upgrades directly
    if owned and lvl < MAX_UPGRADE then
        local cost = upgradeCost(w)
        local bx, bw = px + pw - 190, 160
        local can = data.gems >= cost
        ui.color(ui.c.accent, can and 1 or 0.4); love.graphics.polygon('fill', bx + 8, py + ph - 76, bx + 14, py + ph - 70, bx + 8, py + ph - 64, bx + 2, py + ph - 70)
        ui.text(cost .. ' gems', bx + 20, py + ph - 80, bw - 20, 'left', 'hud', 13, can and ui.c.accent or ui.c.dim)
        if ui.button('Upgrade', bx, py + ph - 58, bw, 36, {size = 15, outline = true, color = ui.c.accent, id = 'upg' .. w.id, disabled = not can}) then
            data.gems = data.gems - cost
            data.upgrades[w.id] = lvl + 1
            saveData()
            ui.toast(w.name .. ' upgraded to level ' .. (lvl + 1), color)
        end
    elseif owned then
        ui.text('MAX', px + pw - 90, py + ph - 56, 60, 'right', 'hud', 18, color)
    end
end

function WeaponsScreen:render()
    ui.background(self.t)
    ui.header('Weapons', 'Collect and upgrade your arsenal')
    ui.wallet()

    -- rarity tabs
    local tx = 40
    for _, r in ipairs(RARITIES) do
        local active = self.tab == r
        local owned, total = 0, 0
        for _, id in ipairs(WEAPON_ORDER) do
            if Weapons[id].rarity == r then total = total + 1; if data.weapons[id] then owned = owned + 1 end end
        end
        if ui.button(ui.rarityName[r] .. '  ' .. owned .. '/' .. total, tx, 112, 170, 38, {outline = not active, color = ui.rarity[r], size = 17, id = 'tab' .. r}) then
            self.tab = r; self.selected = nil
        end
        tx = tx + 182
    end

    -- grid 4 x 2
    local cw, ch, gap = 176, 148, 10
    local gx, gy = 40, 162
    local i = 0
    for _, id in ipairs(WEAPON_ORDER) do
        local w = Weapons[id]
        if w.rarity == self.tab then
            local col, row = i % 4, math.floor(i / 4)
            local x, y = gx + col * (cw + gap), gy + row * (ch + gap)
            local equipped = data.weaponChoose1 == id or data.weaponChoose2 == id or data.weaponChoose3 == id
            if drawWeaponCard(w, x, y, cw, ch, self.selected == id, {equipped = equipped}) then self.selected = id end
            i = i + 1
        end
    end

    drawWeaponDetail(self.selected and Weapons[self.selected], 820, 112, 420, 490)

    local nav = ui.navbar('weapons')
    if nav then gStateMachine:change(nav) end
end

function WeaponsScreen:keyPressed(k) if k == 'escape' then gStateMachine:change('home') end end
