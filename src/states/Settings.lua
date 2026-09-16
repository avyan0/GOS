Settings = Class{}

function Settings:init() self.t = 0 end
function Settings:update(dt) self.t = self.t + dt end

-- Shared settings panel (also used inside Pause). Returns nothing.
function drawSettingsPanel(x, y, w)
    ui.panel(x, y, w, 190, {radius = 16})
    local function row(label, value, ry, setter, color)
        ui.text(label, x + 30, ry, 200, 'left', 'body', 17)
        ui.text(math.floor(value) .. '%', x + w - 110, ry, 80, 'right', 'hud', 18, ui.c.muted)
        local v = ui.slider(label, x + 30, ry + 36, w - 60, value, label == 'Brightness' and 5 or 0, 100, color)
        setter(math.floor(v))
    end
    row('Brightness', data.brightness, y + 24, function(v) data.brightness = v end, ui.c.warn)
    row('Sound volume', data.volume, y + 98, function(v)
        if v ~= data.volume then data.volume = v; sfx.play('click', {gap = 0.15}) end
    end, ui.c.accent)
end

function Settings:render()
    ui.background(self.t)
    if ui.header('Settings', nil, true) then saveData(); gStateMachine:change('home') end

    drawSettingsPanel(40, 110, 600)

    local px, py, pw = 680, 110, 560
    ui.panel(px, py, pw, 190, {radius = 16})
    ui.text('Help', px + 30, py + 24, 200, 'left', 'body', 15, ui.c.muted)
    if ui.button('How to play', px + 30, py + 52, pw - 60, 48, {outline = true, size = 20}) then gStateMachine:change('howToPlay') end
    ui.text('Controls', px + 30, py + 118, 200, 'left', 'body', 15, ui.c.muted)
    ui.text('A / S / D fire   -   1-5 pick a lane   -   Enter ends the turn   -   Space fast-forwards   -   P pauses   -   F11 fullscreen', px + 30, py + 140, pw - 60, 'left', 'body', 15)
    ui.panel(40, 320, 1200, 110, {radius = 16})
    ui.text('Gods of Space   -   made by Avyan Mahajan', 70, 345, 800, 'left', 'body', 16, ui.c.muted)
    ui.text('Built with LÖVE   -   progress is saved automatically', 70, 370, 800, 'left', 'body', 14, ui.c.dim)
    if ui.button(love.window.getFullscreen() and 'Windowed' or 'Fullscreen', 770, 345, 210, 50, {outline = true, size = 20, id = 'fs'}) then toggleFullscreen() end
    if ui.button('Quit game', 1000, 345, 210, 50, {outline = true, color = ui.c.danger, size = 20}) then love.event.quit() end
end
