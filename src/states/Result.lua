-- Win / lose screen. Applies level rewards on win.
Result = Class{}

local GOLD_RANGE = {{7, 13}, {10, 20}, {15, 29}, {21, 39}, {27, 49}, {34, 62}}
-- which prize wheel a level milestone awards, per planet
local SPIN_AT = {
    {[5] = 'Common', [11] = 'Common', [17] = 'Common', [23] = 'Common', [29] = 'Common'},
    {[5] = 'Rare', [11] = 'Common', [17] = 'Rare', [23] = 'Common', [29] = 'Rare'},
    {[5] = 'Common', [11] = 'Rare', [17] = 'Rare', [23] = 'Rare', [29] = 'Scarce'},
    {[5] = 'Common', [11] = 'Rare', [17] = 'Scarce', [23] = 'Rare', [29] = 'Scarce'},
    {[5] = 'Rare', [11] = 'Scarce', [17] = 'Scarce', [23] = 'Scarce', [29] = 'God'},
    {[5] = 'Scarce', [11] = 'Scarce', [17] = 'God', [23] = 'Scarce', [29] = 'God'},
}
function Result:init() self.t = 0 end
function Result:update(dt) self.t = self.t + dt end

function Result:enter(params)
    self.won = params and params.won
    self.planet = tonumber(data.currentLevel:match('(%d+)')) or 1
    self.levelNum = tonumber(data.currentLevel:match('%-(%d+)')) or 1
    data.matchesPlayed = data.matchesPlayed + 1
    self.newAlien, self.spin, self.advanced, self.newPlanet, self.complete = nil, nil, false, nil, false
    if self.won then self:applyWin() end
    sfx.play(self.won and 'win' or 'lose')
    data.goldBuff = 1 -- Double Gold only covers the level it was used in
    saveData()
end

function Result:applyWin()
    local r = GOLD_RANGE[self.planet]
    self.gold = math.random(r[1], r[2]) * data.goldBuff
    data.goldBuff = 1
    data.gold = data.gold + self.gold
    data.wins = data.wins + 1

    -- progression only when beating the next uncleared level on the current planet
    if self.levelNum == data.level + 1 and self.planet == data.planet then
        data.level = data.level + 1
        self.advanced = true
        local p, l = data.planet, data.level
        self.spin = SPIN_AT[p] and SPIN_AT[p][l]
        if data.level >= 30 then
            if data.planet < 6 then data.level = 0; data.planet = data.planet + 1; self.newPlanet = PLANETS[data.planet]
            else self.complete = true end -- final world cleared: keep the 30/30 record
        end
    end
end

function Result:render()
    ui.background(self.t)
    local a = math.min(1, self.t * 2)
    local color = self.won and ui.c.good or ui.c.danger
    ui.text(self.won and 'VICTORY' or 'DEFEAT', 0, 70, VIRTUAL_WIDTH, 'center', 'display', 64, color, a)
    ui.text(PLANETS[self.planet].name .. '   -   Level ' .. self.levelNum, 0, 150, VIRTUAL_WIDTH, 'center', 'body', 20, ui.c.muted, a)

    local px, py, pw, ph = 340, 210, 600, 300
    ui.panel(px, py, pw, ph, {radius = 18})
    if self.won then
        ui.text('Rewards', px, py + 22, pw, 'center', 'body', 15, ui.c.muted)
        ui.color(ui.c.gold); love.graphics.circle('fill', px + pw / 2 - 60, py + 78, 14)
        ui.text('+' .. self.gold .. ' Gold', px + pw / 2 - 36, py + 62, 300, 'left', 'hud', 34)
        local y = py + 130
        local function line(txt, c)
            ui.text(txt, px, y, pw, 'center', 'body', 18, c or ui.c.text); y = y + 34
        end
        if self.newPlanet then line('New world unlocked: ' .. self.newPlanet.name, ui.c.accent) end
        if self.complete then line('Every world defended. You are a god of space.', ui.c.gold) end
        if self.spin then line('Bonus ' .. self.spin .. ' prize wheel earned!', ui.c.gold) end
        if not self.advanced then line('Replayed level  -  no progress change', ui.c.muted) end
    else
        ui.textBox('The aliens broke through.\nTry a different loadout, or use an item from the pause menu.', px + 40, py, pw - 80, ph, 'body', 20, ui.c.text)
    end

    local by = 540
    if self.won and self.spin then
        if ui.button('Spin the ' .. self.spin .. ' wheel', VIRTUAL_WIDTH / 2 - 200, by, 400, 56, {size = 22, color = ui.c.gold, id = 'spin'}) then
            gStateMachine:change('reward', {tier = self.spin})
        end
        by = by + 70
    end
    local nextLabel = self.won and (self.complete and 'Play again' or 'Next level') or 'Try again'
    if ui.button(nextLabel, VIRTUAL_WIDTH / 2 - 310, by, 300, 50, {size = 20, id = 'again', outline = self.spin ~= nil}) then
        if self.won and self.advanced then data.currentLevel = data.planet .. '-' .. math.min(30, data.level + 1) end
        gStateMachine:change('loadout')
    end
    if ui.button('Home', VIRTUAL_WIDTH / 2 + 10, by, 300, 50, {size = 20, outline = true, id = 'home'}) then gStateMachine:change('home') end
end

function Result:keyPressed(k)
    if self.t < 1 then return end -- so mashing Enter through the last turn does not skip the summary
    if k == 'return' or k == 'space' then
        if self.won and self.advanced then data.currentLevel = data.planet .. '-' .. math.min(30, data.level + 1) end
        gStateMachine:change(self.spin and 'reward' or 'loadout', self.spin and {tier = self.spin} or nil)
    elseif k == 'escape' then gStateMachine:change('home') end
end
