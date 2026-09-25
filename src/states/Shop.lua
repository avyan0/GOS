local wheel = require 'src/wheel'

Shop = Class{}

function Shop:init()
    self.t = 0
    self.tier = nil      -- nil = tier picker, else key into SPIN_TIERS
    self.wheel = nil
    self.result = nil    -- reward card after a spin lands
    self.resultT = 0
end
function Shop:update(dt)
    self.t = self.t + dt
    if self.wheel and self.wheel:update(dt) then
        self.result = self.prize -- granted when the spin started; the wheel only reveals it
        self.resultT = 0
    end
    if self.result then self.resultT = self.resultT + dt end
end

function Shop:tierInfo()
    for _, t in ipairs(SPIN_TIERS) do if t.key == self.tier then return t end end
end

function Shop:renderPicker()
    ui.header('Shop', 'Spend gold on prize wheels')
    ui.wallet()
    local n = #SPIN_TIERS
    local cw, ch, gap = 224, 400, 16
    local x0 = (VIRTUAL_WIDTH - (cw * n + gap * (n - 1))) / 2
    for i, t in ipairs(SPIN_TIERS) do
        local x, y = x0 + (i - 1) * (cw + gap), 130
        local color = t.rarity and ui.rarity[t.rarity] or ui.c.good
        local unlocked = t.unlock()
        local hover = unlocked and ui.hovered(x, y, cw, ch)
        ui.panel(x, y - (hover and 4 or 0), cw, ch, {border = hover and color or ui.c.line, radius = 16})
        local cy = y + 150 - (hover and 4 or 0)
        if unlocked then
            -- mini wheel
            for k = 0, 7 do
                ui.color(k % 2 == 0 and color or ui.mix(color, ui.c.bg, 0.4))
                love.graphics.arc('fill', x + cw / 2, cy, 70, k * math.pi / 4 + self.t * 0.3, (k + 1) * math.pi / 4 + self.t * 0.3)
            end
            ui.color(ui.c.bg2); love.graphics.circle('fill', x + cw / 2, cy, 14)
        else
            ui.color(ui.c.bg2, 0.6); love.graphics.circle('fill', x + cw / 2, cy, 70)
            icons.lock(x + cw / 2, cy, 44, ui.c.dim)
        end
        ui.text(t.key, x, y + 250, cw, 'center', 'display', 28, unlocked and ui.c.text or ui.c.dim)
        ui.text(t.rarity and (ui.rarityName[t.rarity] .. ' weapons & gold') or 'Battle items', x, y + 288, cw, 'center', 'body', 14, ui.c.muted)
        if unlocked then
            if ui.button(t.price .. ' Gold', x + 24, y + ch - 66, cw - 48, 44, {color = color, size = 20, id = 'buy' .. t.key, disabled = data.gold < t.price}) then
                self.tier = t.key
                self.wheel = wheel.new(t.key)
                self.result = nil
            end
        else
            local need = (t.key == 'Rare' and 'Reach Cyrene' or t.key == 'Scarce' and 'Reach Nyx' or 'Reach Solhara 15')
            ui.text(need, x, y + ch - 52, cw, 'center', 'body', 15, ui.c.dim)
        end
    end
end

function Shop:renderWheel()
    local t = self:tierInfo()
    local color = t.rarity and ui.rarity[t.rarity] or ui.c.good
    if ui.header(t.key .. ' Spin', t.price .. ' gold per spin', true) and not self.wheel.spinning then
        self.tier = nil; self.wheel = nil; self.result = nil
        return -- the wheel is gone; draw the picker next frame
    end
    ui.wallet()

    self.wheel:draw(420, 380, 230)

    local px, py, pw = 720, 130, 500
    ui.panel(px, py, pw, 470, {radius = 16})
    if self.result then
        local r = self.result
        local a = math.min(1, self.resultT * 3)
        r.icon(px + pw / 2, py + 130, 110)
        ui.text('You won', px, py + 210, pw, 'center', 'body', 18, ui.c.muted, a)
        ui.text(r.title, px, py + 236, pw, 'center', 'display', 32, r.color, a)
        if r.subtitle then ui.text(r.subtitle, px, py + 280, pw, 'center', 'body', 17, ui.c.text, a) end
    elseif self.wheel.spinning then
        ui.textBox('Spinning...', px, py, pw, 320, 'display', 30, ui.c.muted)
    else
        ui.text('Possible prizes', px + 30, py + 24, pw, 'left', 'body', 15, ui.c.muted)
        local y = py + 52
        for i, s in ipairs(self.wheel.segs) do
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local sx, sy = px + 30 + col * 230, y + row * 40
            ui.color(wheel.segColor(s, i)); love.graphics.circle('fill', sx + 8, sy + 11, 6)
            ui.text(wheel.segLabel(s), sx + 24, sy, 200, 'left', 'body', 16)
            ui.text(math.floor(s.w / self.wheel.total * 100 + 0.5) .. '%', sx + 24, sy, 190, 'right', 'hud', 16, ui.c.muted)
        end
    end
    local canSpin = not self.wheel.spinning and data.gold >= t.price
    if ui.button(self.result and 'Spin again  -  ' .. t.price .. ' Gold' or 'Spin  -  ' .. t.price .. ' Gold', px + 40, py + 470 - 76, pw - 80, 52, {color = color, size = 22, id = 'spin', disabled = not canSpin}) then
        self:spin()
    end
end

function Shop:render()
    ui.background(self.t)
    if self.tier then self:renderWheel() else self:renderPicker() end
    local nav = ui.navbar('shop')
    if nav and not (self.wheel and self.wheel.spinning) then gStateMachine:change(nav) end
end

function Shop:spin()
    local t = self:tierInfo()
    if not t or self.wheel.spinning or data.gold < t.price then return end
    data.gold = data.gold - t.price
    self.result = nil
    self.landing = wheel.roll(self.wheel.segs)
    self.prize = wheel.apply(self.wheel.segs[self.landing]) -- grant now so quitting mid-spin loses nothing
    self.wheel:spin(self.landing)
    saveData()
end

function Shop:keyPressed(k)
    if self.wheel and self.wheel.spinning then return end
    if (k == 'return' or k == 'kpenter' or k == 'space') and self.tier then self:spin(); return end
    if k ~= 'escape' then return end
    if self.tier then self.tier = nil; self.wheel = nil; self.result = nil else gStateMachine:change('home') end
end
