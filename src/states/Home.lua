Home = Class{}

function Home:init() self.t = 0 end
function Home:update(dt) self.t = self.t + dt end

local function currentPlanet() return math.min(6, data.planet) end

function Home:render()
    ui.background(self.t)

    -- title + profile
    ui.label('GODS OF SPACE', 40, 30, 'display', 34)
    ui.label('Choose a world to defend', 42, 74, 'body', 17, ui.c.muted)
    ui.wallet()
    if ui.button(data.name, VIRTUAL_WIDTH - 30 - 240, 80, 160, 36, {outline = true, size = 18, id = 'profile', color = ui.c.muted}) then gStateMachine:change('profile') end
    if ui.iconButton('settings', VIRTUAL_WIDTH - 52, 98, 18, function(x, y, r)
        love.graphics.setLineWidth(3); love.graphics.circle('line', x, y, r * 0.45)
        for i = 0, 7 do local a = i * math.pi / 4; love.graphics.line(x + math.cos(a) * r * 0.55, y + math.sin(a) * r * 0.55, x + math.cos(a) * r * 0.8, y + math.sin(a) * r * 0.8) end
    end) then gStateMachine:change('settings') end

    -- planets
    local n = #PLANETS
    local gap = VIRTUAL_WIDTH / n
    for i, p in ipairs(PLANETS) do
        local cx, cy = gap * (i - 0.5), 300
        local locked = data.planet < i
        local hover = not locked and ui.hovered(cx - 80, cy - 90, 160, 200)
        local r = 56 + (hover and 5 or 0) + math.sin(self.t * 1.3 + i) * 1.5
        if not icons.planetArt(i, cx, cy, r, locked) then icons.planet(cx, cy, r, p.hue, p.ringed, locked) end
        if locked then icons.lock(cx, cy, 34, ui.c.muted) end
        ui.text(p.name, cx - 90, cy + 74, 180, 'center', 'display', 22, locked and ui.c.dim or ui.c.text)
        local cleared = i < data.planet or (i == data.planet and data.level >= 30)
        local sub = locked and 'Locked' or (cleared and 'Cleared' or ('Level ' .. (data.level + 1) .. ' / 30'))
        ui.text(sub, cx - 90, cy + 102, 180, 'center', 'body', 15, locked and ui.c.dim or (cleared and ui.c.good or ui.c.accent))
        if not locked and ui.hit(cx - 80, cy - 90, 160, 220) then gStateMachine:change('planetMap', i) end
    end

    -- continue
    local cp = currentPlanet()
    local label = 'Continue   -   ' .. PLANETS[cp].name .. ' ' .. math.min(30, data.level + 1)
    if ui.button(label, VIRTUAL_WIDTH / 2 - 300, 500, 600, 62, {size = 24}) then gStateMachine:change('planetMap', cp) end

    local nav = ui.navbar('home')
    if nav then gStateMachine:change(nav) end
end
