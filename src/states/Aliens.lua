AliensScreen = Class{}

function AliensScreen:init()
    self.t = 0; self.selected = 1
    for k, a in ipairs(Aliensrand) do if data.seen[a.name] then self.selected = k; break end end
end
function AliensScreen:update(dt) self.t = self.t + dt end

function AliensScreen:render()
    ui.background(self.t)
    local seenCount = 0
    for _, a in ipairs(Aliensrand) do if data.seen[a.name] then seenCount = seenCount + 1 end end
    ui.header('Aliens', seenCount .. ' of ' .. #Aliensrand .. ' discovered')
    ui.wallet()

    -- grid: 7 columns x 4 rows
    local cols, size, gap = 9, 78, 8
    local gx, gy = 40, 118
    local hint
    for k, a in ipairs(Aliensrand) do
        local col, row = (k - 1) % cols, math.floor((k - 1) / cols)
        local x, y = gx + col * (size + gap), gy + row * (size + gap)
        local unlocked = data.seen[a.name] == true
        local sel = self.selected == k
        ui.panel(x, y, size, size, {fill = sel and ui.c.panel2 or ui.c.panel, border = sel and ui.c.accent or ((ui.hovered(x, y, size, size) and unlocked) and ui.c.muted or ui.c.line), radius = 12})
        if unlocked then
            icons.alien(a.spec, x + size / 2, y + size / 2 - 7, 48)
            ui.text(a.title, x - 4, y + size - 18, size + 8, 'center', 'body', ui.fitSize('body', a.title, size + 6, 10, 7), ui.c.muted)
        else
            icons.lock(x + size / 2, y + size / 2, 24, ui.c.dim)
            if ui.hovered(x, y, size, size) and a.intro and a.intro < 9999 then hint = {a = a, x = x, y = y + size + 6} end
        end
        if unlocked and ui.hit(x, y, size, size) then self.selected = k end
    end

    -- detail panel
    local a = Aliensrand[self.selected]
    local px, py, pw, ph = 830, 118, 410, 420
    ui.panel(px, py, pw, ph, {radius = 16})
    local hcol = {icons.hsl(a.spec.hue, a.spec.sat or 0.7, 0.55)}
    ui.glow(px + pw / 2, py + 110, 60, hcol, 0.06)
    icons.alien(a.spec, px + pw / 2, py + 110, 150)
    ui.text(a.title, px, py + 205, pw, 'center', 'display', 30)
    local tag = a.hevalten and 'HEVALTEN' or 'STANDARD'
    ui.text(tag, px, py + 245, pw, 'center', 'hud', 16, a.hevalten and ui.c.danger or ui.c.muted)
    ui.text('Health', px + 30, py + 285, 120, 'left', 'body', 15, ui.c.muted)
    ui.text(tostring(a.health), px + 30, py + 303, 200, 'left', 'hud', 28)
    ui.text('Ability', px + 30, py + 345, 200, 'left', 'body', 15, ui.c.muted)
    ui.text(a.desc, px + 30, py + 365, pw - 60, 'left', 'body', 16)

    if hint then
        local p, l = math.floor(hint.a.intro / 100), hint.a.intro % 100
        ui.tooltip(hint.x, hint.y, {
            {'Undiscovered', 'display', 15, ui.c.muted},
            {'First appears on ' .. PLANETS[p].name .. ' level ' .. l .. '. Meet it in battle to add it here.', 'body', 13},
        }, {width = 240})
    end

    local nav = ui.navbar('aliens')
    if nav then gStateMachine:change(nav) end
end
