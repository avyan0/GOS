Pause = Class{}

local ITEM_ACTION = {Wall = 'walls', Zap = 'zap', DoubleGold = 'gold', Electricity = 'electricity',
                     Retreat = 'retreat', Bomb = 'bomb', Teleporter = 'teleporter', Protection = 'protection'}

function Pause:init() self.t = 0 end
function Pause:update(dt) self.t = self.t + dt end
function Pause:keyPressed(k) if k == 'p' or k == 'escape' then gStateMachine:change('battle') end end

function Pause:render()
    -- battle underneath, dimmed
    GameState.render(nil, true)
    ui.color(ui.c.bg, 0.82); love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

    ui.text('Paused', 0, 40, VIRTUAL_WIDTH, 'center', 'display', 44)

    -- left: actions + settings
    if ui.button('Resume', 60, 120, 320, 54, {size = 22, id = 'resume'}) then gStateMachine:change('battle') end
    if ui.button('Quit to home', 60, 186, 320, 46, {outline = true, color = ui.c.danger, size = 18, id = 'quit'}) then gStateMachine:change('battle', 'quit') end
    drawSettingsPanel(60, 256, 320)

    -- right: items
    local px, py, pw, ph = 420, 120, 800, 500
    ui.panel(px, py, pw, ph, {radius = 16})
    ui.text('Items', px + 30, py + 22, 300, 'left', 'display', 22)
    ui.text('One use each. Takes effect immediately.', px + 30, py + 52, 500, 'left', 'body', 14, ui.c.muted)
    local cw, ch, gap = 176, 186, 14
    for i, it in ipairs(ITEMS) do
        local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
        local x, y = px + 30 + col * (cw + gap), py + 84 + row * (ch + gap)
        local count = data[it.stat] or 0
        local has = count > 0
        ui.panel(x, y, cw, ch, {fill = ui.c.bg2, border = has and ui.c.line or ui.c.bg2, radius = 12})
        icons.item(it.key, x + cw / 2, y + 44, 40, has and ui.c.good or ui.c.dim)
        ui.text(it.name, x, y + 78, cw, 'center', 'display', 15, has and ui.c.text or ui.c.dim)
        ui.text(it.desc, x + 10, y + 100, cw - 20, 'center', 'body', 11, has and ui.c.muted or ui.c.dim)
        if ui.button(has and ('Use  (' .. count .. ')') or 'None', x + 12, y + ch - 34, cw - 24, 26, {size = 14, disabled = not has, id = 'use' .. it.key, color = ui.c.good}) then
            data[it.stat] = count - 1
            saveData()
            gStateMachine:change('battle', ITEM_ACTION[it.key])
        end
    end
end
