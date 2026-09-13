AliensScreen = Class{}

function AliensScreen:init() self.t = 0; self.selected = 1 end
function AliensScreen:update(dt) self.t = self.t + dt end

function AliensScreen:render()
    ui.background(self.t)
    ui.header('Aliens', data.aliensUnlocked .. ' of ' .. #Aliensrand .. ' discovered')
    ui.wallet()

    -- grid: 7 columns x 4 rows
    local cols, size, gap = 7, 96, 12
    local gx, gy = 40, 118
    for k, a in ipairs(Aliensrand) do
        local col, row = (k - 1) % cols, math.floor((k - 1) / cols)
        local x, y = gx + col * (size + gap), gy + row * (size + gap)
        local unlocked = data.aliensUnlocked >= k
        local sel = self.selected == k
        ui.panel(x, y, size, size, {fill = sel and ui.c.panel2 or ui.c.panel, border = sel and ui.c.accent or ((ui.hovered(x, y, size, size) and unlocked) and ui.c.muted or ui.c.line), radius = 12})
        if unlocked then
            icons.alien(a.spec, x + size / 2, y + size / 2 - 6, 62)
            ui.text(a.title, x, y + size - 22, size, 'center', 'body', 12, ui.c.muted)
        else
            icons.lock(x + size / 2, y + size / 2, 28, ui.c.dim)
        end
        if unlocked and ui.hit(x, y, size, size) then self.selected = k end
    end

    -- detail panel
    local a = Aliensrand[self.selected]
    local px, py, pw, ph = 820, 118, 420, 420
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

    local nav = ui.navbar('aliens')
    if nav then gStateMachine:change(nav) end
end
