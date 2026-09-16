Items = Class{}

function Items:init() self.t = 0 end
function Items:update(dt) self.t = self.t + dt end

function Items:render()
    ui.background(self.t)
    ui.header('Items', 'One-use boosts. Use them from the pause menu in battle')
    ui.wallet()

    local cw, ch, gap = 290, 232, 16
    local x0, y0 = 40, 118
    for i, it in ipairs(ITEMS) do
        local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
        local x, y = x0 + col * (cw + gap), y0 + row * (ch + gap)
        local count = data[it.stat] or 0
        local owned = count > 0
        ui.panel(x, y, cw, ch, {radius = 14, border = owned and ui.c.line or ui.c.bg2})
        ui.color(owned and ui.c.good or ui.c.dim, 0.12); ui.rrect('fill', x + 16, y + 16, 64, 64, 12)
        if owned then icons.item(it.key, x + 48, y + 48, 40, ui.c.good) else icons.lock(x + 48, y + 48, 26, ui.c.dim) end
        ui.text(it.name, x + 96, y + 22, cw - 110, 'left', 'display', 20, owned and ui.c.text or ui.c.dim)
        ui.text(owned and ('x' .. count .. ' owned') or 'None owned', x + 96, y + 50, cw - 110, 'left', 'hud', 16, owned and ui.c.good or ui.c.dim)
        ui.text(it.desc, x + 16, y + 100, cw - 32, 'left', 'body', 15, owned and ui.c.text or ui.c.muted)
    end

    local nav = ui.navbar('items')
    if nav then gStateMachine:change(nav) end
end

function Items:keyPressed(k) if k == 'escape' then gStateMachine:change('home') end end
