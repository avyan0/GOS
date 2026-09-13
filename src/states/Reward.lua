-- Free bonus wheel after milestone levels.
local wheel = require 'src/wheel'

Reward = Class{}

function Reward:init() self.t = 0 end
function Reward:update(dt)
    self.t = self.t + dt
    if self.wheel and self.wheel:update(dt) then
        self.result = wheel.apply(self.wheel.segs[self.landing])
        self.resultT = 0
        saveData()
    end
    if self.result then self.resultT = self.resultT + dt end
end

function Reward:enter(params)
    self.tier = params.tier
    self.wheel = wheel.new(self.tier)
    self.spun = false
end

function Reward:render()
    ui.background(self.t)
    local color = ui.rarity[self.tier:lower()] or ui.c.good
    ui.text('Bonus ' .. self.tier .. ' Wheel', 0, 36, VIRTUAL_WIDTH, 'center', 'display', 40, color)
    ui.text('A free spin for clearing a milestone level', 0, 86, VIRTUAL_WIDTH, 'center', 'body', 17, ui.c.muted)

    self.wheel:draw(420, 400, 230)

    local px, py, pw, ph = 720, 150, 500, 420
    ui.panel(px, py, pw, ph, {radius = 16})
    if self.result then
        local r = self.result
        local a = math.min(1, self.resultT * 3)
        ui.glow(px + pw / 2, py + 120, 60, r.color, 0.08 * a)
        r.icon(px + pw / 2, py + 120, 110)
        ui.text('You won', px, py + 200, pw, 'center', 'body', 18, ui.c.muted, a)
        ui.text(r.title, px, py + 226, pw, 'center', 'display', 32, r.color, a)
        if r.subtitle then ui.text(r.subtitle, px, py + 270, pw, 'center', 'body', 17, ui.c.text, a) end
        if ui.button('Continue', px + 40, py + ph - 76, pw - 80, 52, {size = 22, id = 'cont'}) then
            if data.level > 0 then data.currentLevel = data.planet .. '-' .. (data.level + 1) end
            gStateMachine:change('planetMap', data.planet)
        end
    elseif self.wheel.spinning then
        ui.textBox('Spinning...', px, py, pw, ph, 'display', 30, ui.c.muted)
    else
        ui.textBox('Press spin to claim your prize', px + 30, py, pw - 60, ph - 100, 'body', 20, ui.c.text)
        if ui.button('Spin', px + 40, py + ph - 76, pw - 80, 52, {size = 22, color = color, id = 'spin'}) then
            self.landing = wheel.roll(self.wheel.segs)
            self.wheel:spin(self.landing)
        end
    end
end
