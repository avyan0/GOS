HowToPlay = Class{}

local PAGES = {
    {title = 'The field', lines = {
        'Aliens spawn at the top of five lanes and march toward your base at the bottom.',
        'If any alien reaches the bottom row, you lose the level.',
        'Each level has three stages. Clear the required number of aliens in each stage to win.',
        'Hover over anything in battle - an alien, a weapon, a wall - to see exactly what it does.'}},
    {title = 'Your turn', lines = {
        'Bring three weapons into every battle. Fire each one once per turn by clicking it or pressing A, S or D.',
        'Lane weapons ask you to click a lane (or press 1-5). Tile weapons ask you to click one or more tiles. Esc cancels.',
        'Some weapons need a few turns to recharge after firing - watch the pips under each weapon.',
        'Press End Turn (or Enter) when you are done.'}},
    {title = 'The alien turn', lines = {
        'Aliens with abilities act first, one at a time under a spotlight, so you can see what each one does.',
        'Reactive aliens like Old Granny and the Heval God respond at the end of any turn you hurt them in.',
        'Then everyone marches one row and a new alien spawns at the top.',
        'Walls stop an alien for a turn before breaking; a Barricade takes three hits. Jumpers leap straight over.'}},
    {title = 'Status effects', lines = {
        'Stunned aliens cannot move. Poison ticks every turn; Plague is poison that spreads to neighbours.',
        'Hypnotised aliens turn around and attack the closest alien ahead of them - both lose health equal to the other.',
        'Shielded aliens ignore damage and effects for a turn. Scanned aliens take 25% more damage.',
        'A Doomed alien dies two turns later, no matter what protects it.'}},
    {title = 'Progression', lines = {
        'Winning levels earns gold. Spend it in the Shop on prize wheels for new weapons and items.',
        'Winning a weapon you already own upgrades it: +10% damage per level, up to level 5.',
        'Gems from the Scarce and God wheels buy upgrades directly on the Weapons screen.',
        'Items are one-use boosts. Open the pause menu during a battle to use them.'}},
}

function HowToPlay:init() self.t = 0; self.page = 1 end
function HowToPlay:update(dt) self.t = self.t + dt end

function HowToPlay:render()
    ui.background(self.t)
    if ui.header('How to play', 'Page ' .. self.page .. ' of ' .. #PAGES, true) then gStateMachine:change('settings') end

    local p = PAGES[self.page]
    local px, py, pw, ph = 140, 130, 1000, 420
    ui.panel(px, py, pw, ph, {radius = 18})
    ui.text(p.title, px + 50, py + 40, pw - 100, 'left', 'display', 34, ui.c.accent)
    for i, line in ipairs(p.lines) do
        local y = py + 100 + (i - 1) * 74
        ui.color(ui.c.accent); love.graphics.circle('fill', px + 62, y + 12, 5)
        ui.text(line, px + 86, y, pw - 140, 'left', 'body', 19)
    end

    -- dots
    for i = 1, #PAGES do
        ui.color(i == self.page and ui.c.accent or ui.c.line)
        love.graphics.circle('fill', VIRTUAL_WIDTH / 2 + (i - (#PAGES + 1) / 2) * 22, 590, 6)
    end
    if self.page > 1 and ui.button('Previous', 140, 620, 200, 48, {outline = true, size = 18, id = 'prev'}) then self.page = self.page - 1 end
    if self.page < #PAGES then
        if ui.button('Next', 940, 620, 200, 48, {size = 18, id = 'next'}) then self.page = self.page + 1 end
    elseif ui.button('Done', 940, 620, 200, 48, {size = 18, id = 'done'}) then gStateMachine:change('home') end
end

function HowToPlay:keyPressed(k)
    if k == 'escape' then gStateMachine:change('settings')
    elseif k == 'right' and self.page < #PAGES then self.page = self.page + 1
    elseif k == 'left' and self.page > 1 then self.page = self.page - 1 end
end
