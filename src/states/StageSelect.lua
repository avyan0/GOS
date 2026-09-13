-- Between stages: same loadout UI, different framing.
StageSelect = Class{__includes = Loadout}

function StageSelect:enter(params)
    self.stageNum = (params and params.stage) or 2
    -- start on the tab of the first equipped weapon
    local w = Weapons[data.weaponChoose1]
    if w then self.tab = w.rarity end
end

function StageSelect:render()
    ui.background(self.t)
    ui.header('Stage ' .. (self.stageNum - 1) .. ' cleared', 'Adjust your loadout before stage ' .. self.stageNum .. ' of 3')

    local clicked = drawSlots(40, 100, 760, self.slot, self.t)
    if clicked then self.slot = (self.slot == clicked) and nil or clicked end

    local tx = 40
    for _, r in ipairs({'common', 'rare', 'scarce', 'god'}) do
        if ui.button(ui.rarityName[r], tx, 214, 150, 34, {outline = self.tab ~= r, color = ui.rarity[r], size = 16, id = 'stab' .. r}) then self.tab = r end
        tx = tx + 160
    end

    local cw, ch, gap = 176, 118, 8
    local i = 0
    for _, id in ipairs(WEAPON_ORDER) do
        local w = Weapons[id]
        if w.rarity == self.tab then
            local col, row = i % 4, math.floor(i / 4)
            local x, y = 40 + col * (cw + gap), 258 + row * (ch + gap)
            local inSlot = data.weaponChoose1 == id or data.weaponChoose2 == id or data.weaponChoose3 == id
            if drawWeaponCard(w, x, y, cw, ch, inSlot, {equipped = inSlot}) then
                self.preview = id
                if data.weapons[id] then self:pick(id) end
            end
            if ui.hovered(x, y, cw, ch) then self.preview = id end
            i = i + 1
        end
    end

    drawWeaponDetail(self.preview and Weapons[self.preview], 820, 100, 420, 480)
    local ready = self:ready()
    if ui.button(ready and ('Start stage ' .. self.stageNum) or 'Choose 3 weapons', 820, 600, 420, 56, {size = 24, disabled = not ready, id = 'cont'}) then
        saveData()
        gStateMachine:change('battle')
    end
end
