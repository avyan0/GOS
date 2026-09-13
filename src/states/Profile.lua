Profile = Class{}

local NAME_MAX = 12

function Profile:init() self.t = 0; self.editing = false end
function Profile:update(dt) self.t = self.t + dt end

function Profile:keyPressed(key)
    if not self.editing then return end
    if key == 'return' or key == 'escape' then self.editing = false; saveData()
    elseif key == 'backspace' then data.name = data.name:sub(1, -2)
    elseif #key == 1 and #data.name < NAME_MAX then
        local ch = key
        if love.keyboard.isDown('lshift', 'rshift') then ch = ch:upper() end
        if ch:match('[%w]') then data.name = data.name .. ch end
    elseif key == 'space' and #data.name < NAME_MAX then data.name = data.name .. ' ' end
end

function Profile:render()
    ui.background(self.t)
    if ui.header('Profile', nil, true) then gStateMachine:change('home') end

    -- name card
    local px, py, pw, ph = 40, 110, 380, 200
    ui.panel(px, py, pw, ph, {radius = 16})
    ui.glow(px + 70, py + 70, 34, ui.c.accent, 0.06)
    ui.color(ui.c.accent); love.graphics.circle('fill', px + 70, py + 70, 40)
    ui.color(ui.c.bg); love.graphics.circle('fill', px + 70, py + 56, 14); love.graphics.arc('fill', px + 70, py + 104, 28, math.pi, math.pi * 2)
    ui.text('Commander', px + 130, py + 42, 220, 'left', 'body', 15, ui.c.muted)
    local shown = data.name .. ((self.editing and math.floor(self.t * 2) % 2 == 0) and '_' or '')
    ui.text(shown, px + 130, py + 62, 230, 'left', 'display', 28)
    if ui.button(self.editing and 'Done' or 'Rename', px + 30, py + 136, pw - 60, 42, {outline = true, size = 18}) then
        self.editing = not self.editing
        if not self.editing then saveData() end
    end

    -- stats
    local stats = {
        {'Wins', data.wins}, {'Matches played', data.matchesPlayed},
        {'Aliens defeated', data.aliensKilled}, {'Time played', data.time},
        {'Planet reached', PLANETS[math.min(6, data.planet)].name}, {'Aliens discovered', data.aliensUnlocked .. ' / ' .. #Aliensrand},
    }
    local sx, sy, sw, sh = 460, 110, 380, 92
    for i, s in ipairs(stats) do
        local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
        local x, y = sx + col * (sw + 20), sy + row * (sh + 16)
        ui.panel(x, y, sw, sh, {radius = 14})
        ui.text(s[1], x + 24, y + 18, sw - 48, 'left', 'body', 15, ui.c.muted)
        ui.text(tostring(s[2]), x + 24, y + 40, sw - 48, 'left', 'hud', 30)
    end

    -- weapons owned
    local owned, total = 0, #WEAPON_ORDER
    for _, id in ipairs(WEAPON_ORDER) do if data.weapons[id] then owned = owned + 1 end end
    ui.panel(40, 330, 380, 110, {radius = 16})
    ui.text('Arsenal', 64, 348, 300, 'left', 'body', 15, ui.c.muted)
    ui.text(owned .. ' / ' .. total .. ' weapons', 64, 370, 300, 'left', 'hud', 26)
    ui.progress(64, 412, 332, 8, owned / total, ui.c.accent)
end
