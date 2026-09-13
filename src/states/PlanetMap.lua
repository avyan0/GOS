-- Level select for one planet: 30 nodes on a serpentine path.
PlanetMap = Class{}

local NODE_R = 26
local SPIN_LEVELS = {[5] = true, [11] = true, [17] = true, [23] = true, [29] = true}

-- node k (1..30): rows of 6, alternating direction, bottom to top
local function nodePos(k)
    local row, col = math.floor((k - 1) / 6), (k - 1) % 6
    local x = (row % 2 == 0) and (200 + col * 176) or (1080 - col * 176)
    return x, 600 - row * 108
end

function PlanetMap:init() self.t = 0 end
function PlanetMap:update(dt) self.t = self.t + dt end

function PlanetMap:enter(planet)
    self.planet = planet or math.min(6, data.planet)
    self.info = PLANETS[self.planet]
end

-- levels completed on this planet
function PlanetMap:done()
    if data.planet > self.planet then return 30 end
    if data.planet < self.planet then return -1 end
    return data.level
end

function PlanetMap:render()
    ui.background(self.t)
    local done = self:done()
    if ui.header(self.info.name, done >= 30 and 'All 30 levels cleared' or ('Level ' .. (done + 1) .. ' of 30'), true) then gStateMachine:change('home') end
    ui.wallet()

    -- planet in the corner
    icons.planet(VIRTUAL_WIDTH - 90, 130, 36, self.info.hue, self.info.ringed)

    -- path
    love.graphics.setLineWidth(6)
    for k = 1, 29 do
        local x1, y1 = nodePos(k); local x2, y2 = nodePos(k + 1)
        ui.color(k <= done and ui.c.accent or ui.c.line, k <= done and 0.9 or 0.6)
        love.graphics.line(x1, y1, x2, y2)
    end

    -- nodes
    for k = 1, 30 do
        local x, y = nodePos(k)
        local state = (k <= done) and 'done' or (k == done + 1) and 'current' or 'locked'
        local hover = state ~= 'locked' and ui.hovered(x - NODE_R, y - NODE_R, NODE_R * 2, NODE_R * 2)
        local r = NODE_R + (hover and 3 or 0)
        if state == 'current' then
            local pulse = 0.5 + 0.5 * math.sin(self.t * 4)
            ui.color(ui.c.accent, 0.25 + 0.2 * pulse); love.graphics.circle('fill', x, y, r + 10 + pulse * 4)
        end
        ui.color(state == 'done' and ui.c.accent or state == 'current' and ui.c.panel2 or ui.c.bg2)
        love.graphics.circle('fill', x, y, r)
        love.graphics.setLineWidth(2.5)
        ui.color(state == 'locked' and ui.c.line or ui.c.accent)
        love.graphics.circle('line', x, y, r)
        if state == 'done' then
            icons.check(x, y, 22, ui.c.bg)
        else
            ui.text(tostring(k), x - 30, y - 11, 60, 'center', 'hud', 20, state == 'locked' and ui.c.dim or ui.c.text)
        end
        if SPIN_LEVELS[k] then
            ui.color(state == 'locked' and ui.c.dim or ui.c.gold)
            love.graphics.circle('fill', x + r * 0.8, y - r * 0.8, 7)
            ui.color(ui.c.bg); love.graphics.circle('fill', x + r * 0.8, y - r * 0.8, 3)
        end
        if state ~= 'locked' and ui.hit(x - NODE_R, y - NODE_R, NODE_R * 2, NODE_R * 2) then
            data.currentLevel = self.planet .. '-' .. k
            saveData()
            gStateMachine:change('loadout')
        end
    end

    ui.color(ui.c.gold); love.graphics.circle('fill', 52, 690, 6)
    ui.text('Bonus prize wheel on clearing this level', 66, 680, 500, 'left', 'body', 14, ui.c.muted)

    -- launch current
    if done < 30 then
        if ui.button('Play level ' .. (done + 1), VIRTUAL_WIDTH - 300, 660, 260, 46, {size = 20}) then
            data.currentLevel = self.planet .. '-' .. (done + 1)
            saveData()
            gStateMachine:change('loadout')
        end
    end
end
