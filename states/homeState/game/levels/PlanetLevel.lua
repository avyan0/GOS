-- Level-select map for one planet: 30 nodes on a serpentine path.
-- Replaces the six near-identical P1Level..P6Level files.
PlanetLevel = Class{__includes = BaseState}

local NODE_R = 36
local TRACK = { -- the grey path segments
    {158,594,1121,594}, {1121,594,1121,472}, {158,472,1121,472}, {121,472,121,350},
    {158,350,1121,350}, {1121,350,1121,228}, {158,228,1121,228}, {121,228,121,106},
    {158,106,1121,106},
}
local WHEELS = {{1000,579},{200,457},{1000,335},{200,213},{1000,91}} -- spin-reward markers

-- node k (1..30): rows of 6, alternating left-to-right / right-to-left, bottom to top
local function nodePos(k)
    local row, col = math.floor((k - 1) / 6), (k - 1) % 6
    local x = (row % 2 == 0) and (121 + col * 200) or (1121 - col * 200)
    return x, 594 - row * 122
end

function PlanetLevel:enter(planet)
    self.planet = planet
    self.background = gTextures['p' .. planet .. 'Background']
end

function PlanetLevel:render()
    push:apply('start')
    local wb, hb = self.background:getWidth(), self.background:getHeight()
    love.graphics.draw(self.background, 0, 0, 0, VIRTUAL_WIDTH / (wb - 1), VIRTUAL_HEIGHT / (hb - 1))
    love.drawBack()

    love.graphics.setLineWidth(8)
    setColor(89/255, 89/255, 89/255)
    for _, l in ipairs(TRACK) do love.graphics.line(unpack(l)) end

    setColor(20/255, 93/255, 40/255)
    if data.planet == self.planet then
        for k = 1, math.min(data.level, 29) do
            local x1, y1 = nodePos(k)
            local x2, y2 = nodePos(k + 1)
            love.graphics.line(x1, y1, x2, y2)
        end
    elseif data.planet > self.planet then
        for _, l in ipairs(TRACK) do love.graphics.line(unpack(l)) end
    end

    love.graphics.setFont(gFonts['game'])
    for k = 1, 30 do
        local x, y = nodePos(k)
        setColor(238/255, 238/255, 238/255)
        love.graphics.circle('fill', x, y, NODE_R)
        setColor(0, 0, 0)
        love.graphics.printf(tostring(k), x - NODE_R, y - 16, NODE_R * 2, 'center')
    end

    setColor(1, 1, 1)
    local w, h = gTextures['wheel']:getWidth(), gTextures['wheel']:getHeight()
    for _, p in ipairs(WHEELS) do
        love.graphics.draw(gTextures['wheel'], p[1], p[2], 0, 30 / (w - 1), 30 / (h - 1))
    end

    love.setBright()
    push:apply('end')
end

function PlanetLevel:mousePressed(x, y)
    if love.clicked(x, y, 0, 320, 0, 90) then
        gStateMachine:change('home')
        return
    end
    if data.planet < self.planet then return end -- locked planet
    for k = 1, 30 do
        local nx, ny = nodePos(k)
        local unlocked = data.planet > self.planet or data.level >= k - 1
        if unlocked and love.clicked(x, y, nx - NODE_R, nx + NODE_R, ny - NODE_R, ny + NODE_R) then
            data.currentLevel = self.planet .. '-' .. k
            saveData()
            gStateMachine:change('weaponSelect')
            return
        end
    end
end
