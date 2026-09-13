Loading = Class{}

function Loading:init() self.t = 0 end

function Loading:update(dt)
    self.t = self.t + dt
    if self.t > 1.6 or ui.clickPending() or love.keyboard.wasPressed('space') then gStateMachine:change('home') end
end

function Loading:render()
    ui.background(self.t, true)
    local a = math.min(1, self.t * 1.5)
    ui.glow(VIRTUAL_WIDTH / 2, 300, 120, ui.c.accent, 0.05 * a)
    ui.text('GODS OF SPACE', 0, 260, VIRTUAL_WIDTH, 'center', 'display', 72, ui.c.text, a)
    ui.text('Defend the last worlds', 0, 350, VIRTUAL_WIDTH, 'center', 'body', 22, ui.c.muted, a)
    ui.progress(VIRTUAL_WIDTH / 2 - 120, 430, 240, 4, math.min(1, self.t / 1.5), ui.c.accent)
end
