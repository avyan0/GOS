-- Headless rules tests:  "C:\Program Files\LOVE\lovec.exe" . --test
local B = require 'src/battle'
data = defaultSave()
weaponDictionary(); alienDictionary(); makeLevel(); applyNewSpawns()

local passed, failed = 0, 0
local current = ''
local function check(cond, msg)
    if cond then passed = passed + 1 else failed = failed + 1; print('  FAIL [' .. current .. '] ' .. msg) end
end
local function near(a, b, eps) return math.abs(a - b) <= (eps or 0.01) end
-- alien health by name, so tests survive balance changes
local hp = setmetatable({}, {__index = function(_, name) return Aliens[name].health end})

-- fresh world for each test
local function setup(opts)
    opts = opts or {}
    B.EVENT_CHANCE = 0
    data = defaultSave()
    for _, id in ipairs(WEAPON_ORDER) do data.weapons[id] = true end
    data.aliensUnlocked = opts.unlocked or 27
    data.currentLevel = opts.level or '1-1'
    data.weaponChoose1, data.weaponChoose2, data.weaponChoose3 = opts.w1 or 'AstroidRain', opts.w2 or 'PoisonArrow', opts.w3 or 'StarBlast'
    for _, id in ipairs(WEAPON_ORDER) do data.upgrades[id] = 0 end
    B.start()
    -- clear whatever the wave spawned so tests control the board
    local s = B.state()
    for i = 1, B.ROWS do for j = 1, B.LANES do s.grid[i][j] = nil end end
    s.kills = 0
    return s
end

local function put(i, j, name, health)
    return B.spawn(i, j, Aliens[name], health)
end

local function test(name, fn)
    current = name
    if os.getenv('TEST_VERBOSE') then print('> ' .. name); io.stdout:flush() end
    local ok, err = pcall(fn)
    if not ok then failed = failed + 1; print('  ERROR [' .. name .. '] ' .. tostring(err)) end
end

-- ======================================================================= content
test('Every level exists, references real aliens and its spawn table ends at 100', function()
    for p = 1, 6 do for k = 1, 30 do
        local L = Levels[p .. '-' .. k]
        check(L ~= nil, 'level ' .. p .. '-' .. k .. ' exists')
        if L then
            local top = 0
            for _, name in ipairs(alienNames) do check(Aliens[name] ~= nil, name .. ' defined'); top = math.max(top, L[name]) end
            check(top == 100, 'level ' .. p .. '-' .. k .. ' spawn table reaches 100')
            check(L.first > 0 and L.second >= L.first and L.third >= L.second, 'level ' .. p .. '-' .. k .. ' quotas ordered')
        end
    end end
    for _, id in ipairs(WEAPON_ORDER) do check(B.WEAPON_RULES[id] ~= nil, id .. ' has a rule') end
end)

-- ======================================================================= weapons
test('Asteroid Rain hits every alien for 175', function()
    local s = setup({w1 = 'AstroidRain'})
    put(3, 1, 'Joe'); put(7, 4, 'King'); put(1, 5, 'DJ')
    check(B.fire(1) == true, 'field weapon fires without aiming')
    check(near(B.alienAt(3, 1).health, hp.Joe - 175), 'joe damaged')
    check(near(B.alienAt(7, 4).health, hp.King - 175), 'king damaged')
    check(near(B.alienAt(1, 5).health, hp.DJ - 175), 'dj damaged')
    check(B.state().slots[1].used, 'slot marked used')
end)

test('Poison Arrow damages a lane and poisons it', function()
    local s = setup({w1 = 'PoisonArrow'})
    put(2, 3, 'King'); put(6, 3, 'King'); put(6, 4, 'King')
    check(B.fire(1) == 'lane', 'asks for a lane')
    B.aimLane(3)
    check(near(B.alienAt(2, 3).health, hp.King - 150) and near(B.alienAt(6, 3).health, hp.King - 150), 'both in lane took 150')
    check(near(B.alienAt(6, 4).health, hp.King), 'other lane untouched')
    check(B.alienAt(2, 3).poison == 55, 'poisoned for 55')
    B.endTurn()
    -- both moved down one row and ticked poison
    check(near(B.alienAt(3, 3).health, hp.King - 150 - 55), 'poison ticked on end turn')
end)

test('Triple Threat hits three chosen tiles, not the same tile twice', function()
    setup({w1 = 'TripleThreat'})
    put(4, 1, 'King'); put(5, 2, 'King'); put(6, 3, 'King')
    check(B.fire(1) == 'tile', 'asks for tiles')
    B.aimTile(4, 1); check(B.aimTile(4, 1) == false, 'same tile rejected'); B.aimTile(5, 2); B.aimTile(6, 3)
    check(B.state().aim == nil, 'aiming done after 3')
    check(near(B.alienAt(4, 1).health, hp.King - 200) and near(B.alienAt(5, 2).health, hp.King - 200) and near(B.alienAt(6, 3).health, hp.King - 200), 'each tile took 200')
end)

test('Cosmic Fire / Dagger Throw / Santa Axe / Galactic Beam hit whole lane', function()
    for _, c in ipairs({{'CosmicFire', 250}, {'DaggerThrow', 900}, {'SantaAxe', 2200}, {'GalacticBeam', 8000}}) do
        setup({w1 = c[1]})
        put(1, 2, 'Giant', 50000); put(9, 2, 'Giant', 50000)
        B.fire(1); B.aimLane(2)
        check(near(B.alienAt(1, 2).health, 50000 - c[2]) and near(B.alienAt(9, 2).health, 50000 - c[2]), c[1] .. ' dealt ' .. c[2])
    end
end)

test('Astrobolt stuns the two closest aliens for one turn', function()
    setup({w1 = 'Astrobolt'})
    put(2, 1, 'King'); put(5, 1, 'King'); put(8, 1, 'King')
    B.fire(1); B.aimLane(1)
    check(B.alienAt(8, 1).stun == 1 and B.alienAt(5, 1).stun == 1, 'closest two stunned')
    check(B.alienAt(2, 1).stun == 0, 'third not stunned')
    B.endTurn()
    check(B.alienAt(8, 1) ~= nil and B.alienAt(5, 1) ~= nil, 'stunned aliens did not move')
    check(B.alienAt(3, 1) ~= nil, 'unstunned alien moved')
    B.endTurn()
    check(B.alienAt(9, 1) ~= nil, 'stun wore off after one turn')
end)

test('Star Blast hits a cross around the tile', function()
    setup({w1 = 'StarBlast'})
    put(5, 3, 'King'); put(5, 2, 'King'); put(5, 4, 'King'); put(3, 3, 'King'); put(7, 3, 'King'); put(5, 1, 'King'); put(8, 3, 'King')
    B.fire(1); B.aimTile(5, 3)
    check(near(B.alienAt(5, 3).health, hp.King - 160), 'center hit')
    check(near(B.alienAt(5, 2).health, hp.King - 160) and near(B.alienAt(5, 4).health, hp.King - 160), 'sides hit')
    check(near(B.alienAt(3, 3).health, hp.King - 160) and near(B.alienAt(7, 3).health, hp.King - 160), 'two up / two down hit')
    check(near(B.alienAt(5, 1).health, hp.King) and near(B.alienAt(8, 3).health, hp.King), 'outside cross untouched')
end)

test('Laser Kill kills aliens at or under 600, Laser Beam under 6000, both ignore buffs', function()
    local s = setup({w1 = 'LaserKill', w2 = 'LaserBeam'})
    put(2, 1, 'Joe', 500); put(4, 1, 'Gen57', 600); put(6, 1, 'King'); put(8, 1, 'Giant', 6000); put(9, 1, 'Giant', 6001)
    s.buff = 0.1
    B.fire(1); B.aimLane(1)
    check(B.alienAt(2, 1) == nil and B.alienAt(4, 1) == nil, 'weak aliens killed')
    check(B.alienAt(6, 1) ~= nil, 'king survived')
    check(s.kills == 2, 'kills counted')
    B.fire(2); B.aimLane(1)
    check(B.alienAt(6, 1) == nil and B.alienAt(8, 1) == nil, 'laser beam killed <= 6000')
    check(B.alienAt(9, 1) ~= nil, '6001 survived')
end)

test('Stellar Boost: +20% this turn then +10% for two turns', function()
    local s = setup({w1 = 'StellarBoost', w2 = 'CosmicFire'})
    put(1, 1, 'Giant', 50000)
    B.fire(1)
    check(near(B.damageMultiplier(Weapons.CosmicFire), 1.2), 'x1.2 now')
    B.endTurn(); check(near(B.damageMultiplier(Weapons.CosmicFire), 1.1), 'x1.1 next turn')
    B.endTurn(); check(near(B.damageMultiplier(Weapons.CosmicFire), 1.1), 'x1.1 turn after')
    B.endTurn(); check(near(B.damageMultiplier(Weapons.CosmicFire), 1.0), 'back to x1')
    check(s.slots[1].used, 'still recharging (cooldown 3)')
end)

test('Cooldowns: 3-turn weapon is back on the 4th turn; 0-cooldown weapon back next turn', function()
    local s = setup({w1 = 'AstroidRain', w2 = 'CosmicFire'})
    put(1, 1, 'Giant', 50000)
    B.fire(1); B.fire(2); B.aimLane(1)
    B.endTurn(); check(s.slots[2].used == false, 'cosmic fire ready next turn'); check(s.slots[1].used, 'rain recharging 1')
    B.endTurn(); check(s.slots[1].used, 'rain still recharging after 2')
    B.endTurn(); check(s.slots[1].used == false, 'rain ready on 3rd')
end)

test('Thunder Strike deals 700 to the lane', function()
    setup({w1 = 'ThunderStrike'}); put(3, 2, 'Giant', 50000); put(8, 2, 'Giant', 50000)
    B.fire(1); B.aimLane(2)
    check(near(B.alienAt(3, 2).health, 49300) and near(B.alienAt(8, 2).health, 49300), '700 each')
end)

test('Battle Ram hits the closest alien and knocks it back one tile', function()
    setup({w1 = 'BattleRam'}); put(2, 1, 'Giant', 50000); put(8, 1, 'Giant', 50000)
    B.fire(1); B.aimLane(1)
    check(B.alienAt(8, 1) == nil and B.alienAt(7, 1) ~= nil, 'closest pushed back to row 7')
    check(near(B.alienAt(7, 1).health, 50000 - 1050), 'took 1050')
    check(near(B.alienAt(2, 1).health, 50000), 'far alien untouched')
end)

test('Electro Jolt stuns the entire lane', function()
    setup({w1 = 'ElectroJolt'}); put(1, 4, 'King'); put(5, 4, 'King'); put(9, 4, 'King'); put(5, 5, 'King')
    B.fire(1); B.aimLane(4)
    check(B.alienAt(1, 4).stun == 1 and B.alienAt(5, 4).stun == 1 and B.alienAt(9, 4).stun == 1, 'whole lane stunned')
    check(B.alienAt(5, 5).stun == 0, 'other lane fine')
end)

test('Hevalbane doubles against Hevalten', function()
    setup({w1 = 'Hevalstruck'}); put(5, 1, 'Guardian'); put(5, 2, 'King', 5000)
    B.fire(1); B.aimLane(1); check(near(B.alienAt(5, 1).health, hp.Guardian - 2400), 'hevalten took 2400')
    B.endTurn(); B.fire(1); B.aimLane(2); check(near(B.alienAt(6, 2).health, 5000 - 1200), 'normal took 1200')
end)

test('Recursive Explosion / Solar Flare / Quantum Flux hit the field', function()
    for _, c in ipairs({{'RecursiveExplosion', 500}, {'SolarFlare', 3000}, {'QuantumFlux', 3000}}) do
        setup({w1 = c[1]}); put(1, 1, 'Giant', 50000); put(10, 5, 'Giant', 50000)
        B.fire(1)
        check(near(B.alienAt(1, 1).health, 50000 - c[2]) and near(B.alienAt(10, 5).health, 50000 - c[2]), c[1])
    end
end)

test('Dueltroid stuns 1 for 4 or 2 for 2', function()
    setup({w1 = 'Dueltroid'}); put(3, 1, 'King'); put(6, 1, 'King'); put(9, 1, 'King')
    B.fire(1); B.aimLane(1)
    local a, b, c = B.alienAt(9, 1).stun, B.alienAt(6, 1).stun, B.alienAt(3, 1).stun
    check((a == 4 and b == 0) or (a == 2 and b == 2), 'one of the two patterns: ' .. a .. ',' .. b)
    check(c == 0, 'third never stunned')
end)

test('Fresh Start sends a 3x3 block back to the top rows', function()
    setup({w1 = 'FreshStart'}); put(8, 2, 'King'); put(9, 3, 'King'); put(7, 4, 'King'); put(9, 5, 'King')
    B.fire(1); B.aimTile(8, 3)
    check(B.alienAt(1, 2) ~= nil and B.alienAt(1, 3) ~= nil and B.alienAt(1, 4) ~= nil, 'three moved to row 1')
    check(B.alienAt(9, 5) ~= nil, 'outside block stayed')
end)

test('Lockdown blocks spawning in a lane for one turn (Hevalten ignore)', function()
    local s = setup({w1 = 'Respawn', level = '1-1'})
    for _ = 1, 20 do
        s = setup({w1 = 'Respawn'})
        for j = 1, B.LANES do if j ~= 3 then put(1, j, 'Joe') end end -- only lane 3 free
        s.needed = 50
        B.fire(1); B.aimLane(3)
        B.endTurn()
        check(B.alienAt(1, 3) == nil, 'nothing spawned in locked lane')
    end
end)

test('Off Guard stuns everything for one turn', function()
    setup({w1 = 'Offguard'}); put(1, 1, 'King'); put(5, 3, 'Giant', 50000); put(9, 5, 'DJ')
    B.fire(1)
    check(B.alienAt(1, 1).stun == 1 and B.alienAt(5, 3).stun == 1 and B.alienAt(9, 5).stun == 1, 'all stunned')
end)

test('Mind Blast deals 7001 and hypnotises the survivor', function()
    local s = setup({w1 = 'MindBlast'}); put(9, 1, 'Giant', 50000)
    B.fire(1); B.aimLane(1)
    local g = B.alienAt(9, 1)
    check(g and near(g.health, 50000 - 7001) and g.hypno, 'giant hypnotised')
end)

test('Hypnotised aliens fight: both lose the other health, stronger survives and advances', function()
    local s = setup({}); s.needed = 0
    local h = put(8, 1, 'Giant', 50000); h.hypno = true; h.health = 5000
    put(5, 1, 'King') -- hp.King, two rows up with a gap
    put(1, 5, 'Joe').stun = 99 -- a hostile somewhere so the stage does not end
    B.endTurn()
    check(B.alienAt(5, 1) == nil, 'king died')
    check(s.kills == 1, 'counts as a kill')
    local g = B.alienAt(7, 1) or B.alienAt(8, 1)
    check(g and g.hypno and near(g.health, 5000 - hp.King), 'giant lost the king health and stepped up (' .. tostring(g and g.health) .. ')')
    -- weaker hypno alien dies instead
    s = setup({}); s.needed = 0
    h = put(8, 2, 'Joe'); h.hypno = true
    put(7, 2, 'King')
    B.endTurn()
    local k = B.alienAt(8, 2) or B.alienAt(7, 2)
    check(B.count() == 1 and k and not k.hypno, 'joe died')
    check(k and near(k.health, hp.King - hp.Joe), 'king weakened but alive')
    -- with nothing to fight it moves up and holds the top
    s = setup({}); s.needed = 0
    h = put(2, 3, 'Giant', 50000); h.hypno = true
    put(1, 5, 'Joe').stun = 99
    B.endTurn(); check(B.alienAt(1, 3) and B.alienAt(1, 3).hypno, 'moved to the top')
    B.endTurn(); check(B.alienAt(1, 3) and B.alienAt(1, 3).hypno, 'stands guard at the top')
end)

test('Grenade Launcher hits front and back rows', function()
    setup({w1 = 'GrenadeLauncher'}); put(1, 1, 'Giant', 50000); put(10, 5, 'Giant', 50000); put(5, 3, 'Giant', 50000)
    B.fire(1)
    check(near(B.alienAt(1, 1).health, 50000 - 3950) and near(B.alienAt(10, 5).health, 50000 - 3950), 'rows 1 and 10 hit')
    check(near(B.alienAt(5, 3).health, 50000), 'middle untouched')
end)

test('Bulwark: 1500 to lane and permanent +2.5%', function()
    local s = setup({w1 = 'Protected'}); put(4, 2, 'Giant', 50000)
    B.fire(1); B.aimLane(2)
    check(near(B.alienAt(4, 2).health, 50000 - 1500), '1500 damage (buff applied after)')
    check(near(s.buff, 1.025), 'buff raised')
end)

test('Hypnosis hypnotises the closest alien in every lane', function()
    setup({w1 = 'Hypnosis'}); put(3, 1, 'King'); put(6, 1, 'King'); put(2, 4, 'King')
    B.fire(1)
    check(B.alienAt(6, 1).hypno and not B.alienAt(3, 1).hypno and B.alienAt(2, 4).hypno, 'closest per lane')
end)

test('Comet Strike hits a 3x3 block', function()
    setup({w1 = 'CometStrike'})
    for i = 4, 6 do for j = 2, 4 do put(i, j, 'Giant', 50000) end end
    put(4, 5, 'Giant', 50000)
    B.fire(1); B.aimTile(5, 3)
    for i = 4, 6 do for j = 2, 4 do check(near(B.alienAt(i, j).health, 50000 - 8000), 'cell ' .. i .. ',' .. j) end end
    check(near(B.alienAt(4, 5).health, 50000), 'outside untouched')
end)

test('Death Virus wipes one random lane', function()
    local s = setup({w1 = 'DeathVirus'})
    for j = 1, 5 do put(3, j, 'Giant'); put(7, j, 'Giant') end
    B.fire(1)
    check(s.kills == 2 and B.count() == 8, 'exactly one lane (2 aliens) killed')
end)

test('Void Burst: 11000 to three tiles', function()
    setup({w1 = 'VoidBurst'}); put(2, 2, 'Giant', 50000); put(4, 4, 'Giant', 50000)
    B.fire(1); B.aimTile(2, 2); B.aimTile(4, 4); B.aimTile(9, 1)
    check(near(B.alienAt(2, 2).health, 39000) and near(B.alienAt(4, 4).health, 39000), 'two hit, third empty tile fine')
    check(B.state().aim == nil, 'done')
end)

test('Celestial Disruption drops four non-Hevalten to 1 hp', function()
    setup({w1 = 'CelestialDisruption'})
    put(1, 1, 'Giant', 50000); put(3, 1, 'Giant', 50000); put(5, 1, 'Giant', 50000); put(7, 1, 'Giant', 50000); put(9, 1, 'Giant', 50000); put(8, 1, 'Guardian')
    B.fire(1); B.aimLane(1)
    check(B.alienAt(9, 1).health == 1 and B.alienAt(7, 1).health == 1 and B.alienAt(5, 1).health == 1 and B.alienAt(3, 1).health == 1, 'four closest normals at 1')
    check(near(B.alienAt(1, 1).health, 50000), 'fifth untouched')
    check(near(B.alienAt(8, 1).health, hp.Guardian), 'hevalten untouched')
end)

test('Upgrades add +10% damage per level', function()
    setup({w1 = 'CosmicFire'}); data.upgrades.CosmicFire = 3
    put(2, 1, 'Giant', 50000); B.fire(1); B.aimLane(1)
    check(near(B.alienAt(2, 1).health, 50000 - 325), 'lane weapon upgraded (250 * 1.3)')
end)

test('Cancel aiming refunds the shot', function()
    local s = setup({w1 = 'CosmicFire'}); put(2, 1, 'Giant', 50000)
    B.fire(1); B.cancelAim()
    check(s.slots[1].used == false and s.aim == nil, 'slot ready again')
end)

-- ======================================================================= aliens
test('Space Fence is immune for its first turn', function()
    local s = setup({w1 = 'SolarFlare'}); put(1, 1, 'SpaceFence')
    B.fire(1); check(near(B.alienAt(1, 1).health, hp.SpaceFence), 'shielded')
    B.endTurn()
    setup({w1 = 'SolarFlare'}); local a = put(1, 1, 'SpaceFence'); a.immune = 0
    B.fire(1); check(B.alienAt(1, 1) == nil, 'killed once shield is down')
end)

test('Spaceship alternates flying; flying ignores lane/tile damage but not field', function()
    local s = setup({w1 = 'CosmicFire', w2 = 'SolarFlare'}); local a = put(1, 1, 'Spaceship'); a.fly = true
    B.fire(1); B.aimLane(1); check(near(a.health, hp.Spaceship), 'lane attack missed while flying')
    B.fire(2); check(near(a.health, 0) or B.alienAt(1, 1) == nil, 'field attack hit while flying')
    setup({}); a = put(1, 1, 'Spaceship'); B.endTurn(); check(B.alienAt(2, 1).fly == true, 'toggles flight each turn')
end)

test('Old Granny lurches at end of turn when hurt, not mid-turn', function()
    local s = setup({w1 = 'AstroidRain'}); put(4, 2, 'OldGranny'); s.needed = 0
    B.fire(1)
    check(B.alienAt(4, 2) ~= nil, 'still in place after the shot')
    B.endTurn()
    check(B.alienAt(6, 2) ~= nil, 'lurched then marched: row 6')
    check(B.count() == 1, 'exactly one granny')
    check(near(B.alienAt(6, 2).health, hp.OldGranny - 175), 'hit once only')
    B.endTurn()
    check(B.alienAt(7, 2) ~= nil, 'unhurt turn: normal single step')
end)

test('Albot spawns a random alien in its row every turn', function()
    local s = setup({}); put(4, 3, 'Albot'); s.needed = 0
    B.endTurn()
    local n = 0
    for j = 1, 5 do if B.alienAt(5, j) or B.alienAt(4, j) then n = n + 1 end end
    check(B.count() == 2 or (B.count() == 3 and (function() local n = 0; B.each(function(a) if a.name == 'Albot' then n = n + 1 end end); return n end)() == 2), 'one extra alien spawned (' .. B.count() .. ')')
end)

test('Jumper leaps walls, others break them', function()
    local s = setup({}); s.needed = 0
    put(3, 1, 'Jumper'); put(3, 2, 'King')
    s.walls[4][1] = true; s.walls[5][1] = true; s.walls[4][2] = true
    B.endTurn()
    check(B.alienAt(6, 1) ~= nil, 'jumper landed past both walls')
    check(B.alienAt(3, 2) ~= nil and s.walls[4][2] == false, 'king stayed and broke the wall')
    B.endTurn(); check(B.alienAt(4, 2) ~= nil, 'king moved next turn')
end)

test('Giant moves every other turn', function()
    local s = setup({}); s.needed = 0; put(2, 1, 'Giant', 50000)
    B.endTurn(); local r1 = B.alienAt(2, 1) and 2 or 3
    B.endTurn(); local r2 = B.alienAt(r1, 1) and r1 or r1 + 1
    check(r2 == 3, 'moved once in two turns (row ' .. r2 .. ')')
end)

test('Gardener blocks walls in its lane', function()
    local s = setup({}); for j = 1, 5 do put(3, j, 'Gardener') end
    check(B.useItem('walls') == false, 'no wall possible anywhere')
end)

test('Army lowers damage by 2% each; restored on death', function()
    local s = setup({}); put(2, 1, 'Army'); put(2, 2, 'Army')
    check(near(s.buff, 0.96), 'two armies: -4%')
    B.endTurn(); check(near(s.buff, 0.96), 'does not compound per turn')
    B.kill(3, 1); check(near(s.buff, 0.98), 'restored on death')
end)

test('Crippler / Rarebane / Scarcebane / Interdimensional reduce the right damage', function()
    local s = setup({}); put(2, 1, 'CommonCrippler'); put(2, 2, 'Rare'); put(2, 3, 'Scarce'); put(2, 4, 'Interdimentional')
    check(near(B.damageMultiplier(Weapons.CosmicFire), 0.75 * 0.925), 'common')
    check(near(B.damageMultiplier(Weapons.DaggerThrow), 0.8 * 0.925), 'rare')
    check(near(B.damageMultiplier(Weapons.SantaAxe), 0.85 * 0.925), 'scarce')
    check(near(B.damageMultiplier(Weapons.SolarFlare), 0.925), 'god only interdimensional')
    B.kill(2, 4); check(near(B.damageMultiplier(Weapons.SolarFlare), 1), 'restored')
end)

test('Morpher changes type every turn keeping health percentage', function()
    local s = setup({}); s.needed = 0; local a = put(2, 1, 'Morpher'); a.health = a.maxHealth / 2 -- 50%
    B.endTurn()
    local m = B.alienAt(3, 1)
    check(m ~= nil and m.morph, 'still a morpher')
    check(near(m.health / m.maxHealth, 0.5), 'kept 50% health')
end)

test('Fusion fuses two aliens on spawn into one bigger one', function()
    local s = setup({level = '4-10'}); put(5, 1, 'King'); put(6, 2, 'King')
    put(1, 3, 'Fusion')
    check(B.count() == 2, 'two aliens became one')
    local big
    B.each(function(a) if a.name ~= 'Fusion' then big = a end end)
    check(big and big.health >= hp.King * 2 * 1.5 - 1, 'fused health >= 1.5x combined (' .. (big and big.health or 'nil') .. ')')
end)

test('Splashfest ignores field and splash damage', function()
    setup({w1 = 'SolarFlare', w2 = 'CosmicFire'}); put(3, 1, 'Splashfest')
    B.fire(1); check(near(B.alienAt(3, 1).health, hp.Splashfest), 'field ignored')
    B.fire(2); B.aimLane(1); check(near(B.alienAt(3, 1).health, hp.Splashfest - 250), 'lane hits')
end)

test('Virus makes cooldowns one turn longer, but leaves cooldown-free weapons alone', function()
    local s = setup({w1 = 'PoisonArrow', w2 = 'CosmicFire'}); s.needed = 0; put(1, 1, 'Virus')
    B.fire(1); B.aimLane(3); B.fire(2); B.aimLane(3)
    B.endTurn(); check(s.slots[1].used, 'poison arrow (cd 1) still used one turn later')
    check(not s.slots[2].used, 'cosmic fire (no cd) ready as usual')
    B.endTurn(); check(s.slots[1].used, 'normally ready now, but the virus adds a turn')
    B.endTurn(); check(not s.slots[1].used, 'ready after the extra turn')
end)

test('Guardian absorbs lane damage and is immune to poison/knockback/hypno', function()
    local s = setup({w1 = 'PoisonArrow', w2 = 'BattleRam', w3 = 'Hypnosis'})
    put(3, 1, 'Guardian'); put(8, 1, 'King')
    B.fire(1); B.aimLane(1)
    check(near(B.alienAt(8, 1).health, hp.King), 'king untouched')
    check(near(B.alienAt(3, 1).health, hp.Guardian - 300), 'guardian took both hits')
    check(B.alienAt(3, 1).poison == 0, 'guardian not poisoned')
    B.fire(2); B.aimLane(1); check(B.alienAt(8, 1) ~= nil, 'king not knocked back (guardian absorbed)')
    B.fire(3); check(not B.alienAt(8, 1).hypno, 'no hypno in guarded lane')
end)

test('Dark Arts upgrades the three closest aliens one tier, never past the level', function()
    setup({level = '5-10'}); put(5, 1, 'Joe'); put(6, 2, 'King', 775)
    put(1, 3, 'DarkArts')
    check(B.alienAt(5, 1).name == 'Gen57', 'joe -> gen57')
    check(B.alienAt(6, 2).name == 'DJ' and near(B.alienAt(6, 2).health, hp.DJ * 775 / hp.King), 'king -> dj keeping health %')
    check(B.alienAt(1, 3).name == 'DarkArts', 'dark arts itself unchanged')
    setup({level = '1-1'}); put(5, 1, 'King'); put(1, 3, 'DarkArts')
    check(B.alienAt(5, 1).name == 'King', 'no promotion past what level 1-1 can spawn')
    setup({level = '5-10'}); for j = 1, 5 do put(j + 2, j, 'Joe') end; put(1, 1, 'DarkArts')
    local promoted = 0; B.each(function(a) if a.name == 'Gen57' then promoted = promoted + 1 end end)
    check(promoted == 3, 'only three promoted (' .. promoted .. ')')
end)

test('Bunker halves targeted damage', function()
    setup({w1 = 'TripleThreat', w2 = 'CosmicFire'}); put(4, 1, 'Protected')
    B.fire(1); B.aimTile(4, 1); B.aimTile(1, 1); B.aimTile(2, 2)
    check(near(B.alienAt(4, 1).health, hp.Protected - 100), 'tile damage halved')
    B.fire(2); B.aimLane(1); check(near(B.alienAt(4, 1).health, hp.Protected - 100 - 250), 'lane damage full')
end)

test('Heval God spawns a Hevalten in the first three rows at end of a turn it was hurt', function()
    local s = setup({w1 = 'CosmicFire', level = '6-1'}); put(8, 1, 'TheHevalGod'); s.needed = 0
    B.fire(1); B.aimLane(1)
    check(B.count() == 1, 'no summon mid-turn')
    B.endTurn()
    local spawned
    B.each(function(a, i) if a.name ~= 'TheHevalGod' then spawned = {a, i} end end)
    check(spawned and spawned[1].hevalten and spawned[2] <= 4, 'hevalten spawned up top (then marched once)')
end)

test('God of Space spawns three aliens and is immune to poison/knockback/hypno but not damage', function()
    local s = setup({w1 = 'PoisonArrow', w2 = 'BattleRam', w3 = 'MindBlast'})
    put(9, 2, 'GodOfSpace')
    check(B.count() == 4, 'three extra aliens (' .. B.count() .. ')')
    for i = 1, 3 do for j = 1, 5 do if B.alienAt(i, j) then s.grid[i][j] = nil end end end
    put(9, 1, 'King')
    B.fire(1); B.aimLane(2); check(B.alienAt(9, 2).poison == 0 and near(B.alienAt(9, 2).health, hp.GodOfSpace - 150), 'damaged, not poisoned')
    B.fire(2); B.aimLane(2); check(B.alienAt(9, 2) ~= nil, 'not knocked back')
    B.fire(3); B.aimLane(2); check(not B.alienAt(9, 2).hypno, 'not hypnotised')
    check(B.alienAt(9, 1).stun == 0, 'other aliens still affected normally? (poison arrow lane 2 only)')
end)

-- ======================================================================= items
test('Items: zap, electricity, teleporter, protection, gold, walls', function()
    local s = setup({}); for j = 1, 5 do put(4, j, 'King') end
    B.useItem('zap'); local n = 0; B.each(function(a) if a.stun == 3 then n = n + 1 end end); check(n == 1, 'zap stunned one lane for 3')
    B.useItem('electricity'); n = 0; B.each(function(a) if a.stun >= 1 then n = n + 1 end end); check(n == 5, 'electricity stunned all')
    B.useItem('teleporter'); check(B.count() == 4 and s.kills == 1, 'teleporter removed one')
    B.useItem('protection'); check(near(s.buff, 1.5), 'protection +50%')
    B.useItem('gold'); check(data.goldBuff == 2, 'double gold flag')
    check(B.useItem('walls') == 'aim', 'wall asks for a tile')
    local occ; for j = 1, 5 do if B.alienAt(4, j) then occ = j end end
    check(B.aimTile(4, occ) == false, 'cannot place on an alien'); check(B.aimTile(1, 2) == false, 'cannot place on row 1')
    check(B.aimTile(6, 2) == true and s.walls[6][2] == 1 and s.aim == nil, 'wall placed where chosen')
    s = setup({}); s.needed = 0; put(3, 1, 'King'); s.walls[4][1] = true
    B.drain(); B.endTurn()
    local sawBreak = false
    for _, e in ipairs(B.drain()) do if e.type == 'wallbreak' then sawBreak = true end end
    check(sawBreak and s.walls[4][1] == false and B.alienAt(3, 1) ~= nil, 'wall absorbed the move and broke')
end)

test('Items: retreat / bomb skip stages, win on the last', function()
    local s = setup({}); check(B.useItem('retreat') == 'stage' and B.state().stage == 2, 'retreat -> stage 2')
    check(B.useItem('bomb') == 'win', 'bomb on stage 2 wins')
    s = setup({}); check(B.useItem('bomb') == 'stage' and B.state().stage == 3, 'bomb on stage 1 -> stage 3')
    check(B.useItem('retreat') == 'win', 'retreat on stage 3 wins')
end)

-- ======================================================================= new weapons
test('Gravity Well drags a lane back one row; Anchor blocks it', function()
    setup({w1 = 'GravityWell'}); put(4, 1, 'King'); put(5, 1, 'King'); put(9, 1, 'King'); put(1, 1, 'King')
    B.fire(1); B.aimLane(1)
    check(B.alienAt(1, 1) ~= nil and B.alienAt(3, 1) ~= nil and B.alienAt(4, 1) ~= nil and B.alienAt(8, 1) ~= nil and B.count() == 4, 'everything that could move went up one')
    setup({w1 = 'GravityWell'}); put(6, 2, 'Anchor'); put(9, 2, 'King')
    B.fire(1); B.aimLane(2); check(B.alienAt(9, 2) ~= nil, 'anchored lane did not move')
end)

test('Ricochet hits the closest alien then bounces to a neighbouring lane', function()
    setup({w1 = 'Ricochet'}); put(7, 3, 'Giant', 50000); put(5, 2, 'Giant', 50000); put(9, 4, 'Giant', 50000)
    B.fire(1); B.aimLane(3)
    check(near(B.alienAt(7, 3).health, 50000 - 300), 'primary took 300')
    check(near(B.alienAt(9, 4).health, 50000 - 200), 'bounced to the closest neighbour (lane 4)')
    check(near(B.alienAt(5, 2).health, 50000), 'other neighbour untouched')
end)

test('Scanner marks aliens for +25% damage until end of turn', function()
    setup({w1 = 'Scanner', w2 = 'CosmicFire'}); put(3, 1, 'Anchor')
    B.fire(1); B.fire(2); B.aimLane(1)
    check(near(B.alienAt(3, 1).health, hp.Anchor - 312.5), 'marked alien took 250 * 1.25')
    B.endTurn(); check(not B.alienAt(4, 1).marked, 'mark cleared next turn')
end)

test('Chain Lightning arcs to the four nearest aliens losing 20% per jump', function()
    setup({w1 = 'ChainLightning'}); put(5, 3, 'Giant', 50000); put(5, 4, 'Giant', 50000); put(6, 3, 'Giant', 50000); put(9, 1, 'Giant', 50000); put(1, 5, 'Giant', 50000); put(2, 1, 'Giant', 50000)
    B.fire(1); B.aimTile(5, 3)
    check(near(B.alienAt(5, 3).health, 50000 - 800), 'target 800')
    local hit = 0
    B.each(function(a) if a.health < 50000 then hit = hit + 1 end end)
    check(hit == 5, 'target + 4 jumps (' .. hit .. ')')
    check(near(B.alienAt(5, 4).health, 50000 - 640) or near(B.alienAt(6, 3).health, 50000 - 640), 'first jump 640')
end)

test('Time Warp stops every alien moving for one turn', function()
    local s = setup({w1 = 'TimeWarp'}); s.needed = 0; put(3, 1, 'King'); put(3, 2, 'Swarmling'); put(3, 3, 'Giant', 50000)
    B.fire(1); B.endTurn()
    check(B.alienAt(3, 1) and B.alienAt(3, 2) and B.alienAt(3, 3), 'nobody moved')
    B.endTurn(); check(B.alienAt(4, 1) ~= nil, 'moving again next turn')
end)

test('Barricade is a 3-hit wall', function()
    local s = setup({w1 = 'Barricade'}); s.needed = 0; put(3, 1, 'King')
    B.fire(1)
    check(B.aimTile(3, 1) == false and B.aimTile(1, 1) == false and s.aim ~= nil, 'occupied and top-row tiles refused, still aiming')
    B.aimTile(4, 1); check(s.walls[4][1] == 3, 'placed with 3 hits')
    B.endTurn(); B.endTurn(); B.endTurn()
    check(B.alienAt(3, 1) ~= nil and s.walls[4][1] == false, 'held for three turns then broke')
    B.endTurn(); check(B.alienAt(4, 1) ~= nil, 'moved through afterwards')
end)

test('Plague spreads to neighbours each turn', function()
    local s = setup({w1 = 'Plague'}); s.needed = 0
    put(5, 2, 'Anchor'); put(5, 3, 'Anchor'); put(5, 4, 'Anchor')
    B.fire(1); B.aimLane(2)
    B.endTurn()
    check(near(B.alienAt(6, 2).health, hp.Anchor - 400), 'infected alien took 400')
    check(B.alienAt(6, 3).plague == 400 and not B.alienAt(6, 4).plague, 'spread one step')
    B.endTurn(); check(B.alienAt(7, 4).plague == 400, 'spread another step')
end)

test('Overclock readies the other two weapons', function()
    local s = setup({w1 = 'AstroidRain', w2 = 'Overclock', w3 = 'SolarFlare'}); put(1, 1, 'Giant', 50000)
    B.fire(1); B.fire(3); check(s.slots[1].used and s.slots[3].used, 'both used')
    B.fire(2); check(not s.slots[1].used and not s.slots[3].used and s.slots[2].used, 'others readied, overclock spent')
end)

test('Executioner kills below half health, otherwise 3000', function()
    setup({w1 = 'Executioner'}); put(8, 1, 'Giant', 2000); put(8, 2, 'Giant', 50000)
    B.fire(1); B.aimLane(1); check(B.alienAt(8, 1) == nil, 'executed')
    B.state().slots[1].used = false
    B.fire(1); B.aimLane(2); check(near(B.alienAt(8, 2).health, 50000 - 3000), '3000 when healthy')
end)

test('Supernova burns 20% max health, ignores buffs, respects the Void Titan cap', function()
    local s = setup({w1 = 'Supernova'}); put(3, 1, 'Giant', 50000); put(3, 2, 'King'); put(3, 3, 'VoidTitan')
    s.buff = 0.5
    B.fire(1)
    check(near(B.alienAt(3, 1).health, 50000 * 0.8) and near(B.alienAt(3, 2).health, hp.King * 0.8), '20% of max each')
    check(near(B.alienAt(3, 3).health, hp.VoidTitan - 5000), 'titan capped at 5000')
end)

test('Doomsday Clock kills two turns later no matter what', function()
    local s = setup({w1 = 'DoomsdayClock'}); s.needed = 0; put(5, 1, 'Guardian'); put(6, 1, 'GodOfSpace')
    for i = 1, 3 do for j = 1, 5 do if B.alienAt(i, j) then s.grid[i][j] = nil end end end
    B.fire(1); B.aimTile(6, 1)
    B.endTurn(); check(B.count() == 2, 'still alive after one turn')
    B.endTurn(); local god; B.each(function(a) if a.name == 'GodOfSpace' then god = a end end)
    check(B.count() == 1 and god == nil, 'god of space dead, guardian could not save it')
end)

test('Meteor Storm strikes six random tiles', function()
    local s = setup({w1 = 'MeteorStorm'})
    for i = 1, 10 do for j = 1, 5 do put(i, j, 'Giant', 50000) end end
    B.fire(1)
    local hits = 0
    B.each(function(a) hits = hits + math.round((50000 - a.health) / 6000) end)
    check(hits == 6, 'six meteors landed (' .. hits .. ')')
    s = setup({w1 = 'MeteorStorm'}); put(3, 1, 'Giant', 50000); put(7, 4, 'Giant', 50000)
    B.fire(1)
    check(near(B.alienAt(3, 1).health, 44000) and near(B.alienAt(7, 4).health, 44000), 'meteors seek out each alien once')
end)

test('Quantum Flux kills chain-explode into neighbours', function()
    local s = setup({w1 = 'QuantumFlux'})
    put(5, 3, 'Joe'); put(5, 2, 'King'); put(5, 4, 'Giant', 50000); put(4, 2, 'Joe')
    B.fire(1)
    check(s.kills >= 3, 'joe died, exploded into king (dies), king exploded into neighbour joe (' .. s.kills .. ')')
    check(near(B.alienAt(5, 4).health, 50000 - 3000 - 1500), 'giant took the flux plus one explosion')
end)

-- ======================================================================= new aliens
test('Swarmling moves two rows per turn', function()
    local s = setup({}); s.needed = 0; put(2, 1, 'Swarmling'); B.endTurn(); check(B.alienAt(4, 1) ~= nil, 'moved two')
end)

test('Shieldbearer shields the alien ahead of it', function()
    local s = setup({w1 = 'SolarFlare'}); s.needed = 0; put(3, 1, 'Shieldbearer'); put(4, 1, 'King')
    B.endTurn()
    local k = B.alienAt(5, 1); check(k and k.immune > 0, 'king shielded')
end)

test('Phaser: half from lane, double from tile', function()
    setup({w1 = 'CosmicFire', w2 = 'TripleThreat'}); put(4, 1, 'Phaser')
    B.fire(1); B.aimLane(1); check(near(B.alienAt(4, 1).health, hp.Phaser - 125), 'lane halved')
    B.fire(2); B.aimTile(4, 1); check(near(B.alienAt(4, 1).health, hp.Phaser - 125 - 400), 'tile doubled')
end)

test('Medic heals every other alien 10% per turn', function()
    local s = setup({}); s.needed = 0; put(3, 1, 'Medic'); put(3, 2, 'Anchor', 5000)
    B.endTurn(); check(near(B.alienAt(4, 2).health, 5000 + hp.Anchor * 0.1), 'healed 10% of max')
end)

test('Thief steals 5 gold per turn', function()
    local s = setup({}); s.needed = 0; data.gold = 12; put(3, 1, 'Thief')
    B.endTurn(); check(data.gold == 7, 'stole 5'); B.endTurn(); check(data.gold == 2, 'stole 5 more'); B.endTurn(); check(data.gold == 0, 'cannot go negative')
end)

test('Splitter splits into two weaker aliens on death', function()
    local s = setup({w1 = 'VoidBurst'}); put(5, 3, 'Splitter', 5000)
    B.fire(1); B.aimTile(5, 3); B.cancelAim()
    check(B.count() == 2, 'two children (' .. B.count() .. ')')
    local child; B.each(function(a) child = a end)
    check(child and child.name == 'Swarmling' and near(child.health, hp.Splitter * 0.25), 'swarmling children at a quarter health')
end)

test('Anchor stops knockback in its lane', function()
    setup({w1 = 'BattleRam'}); put(3, 1, 'Anchor'); put(8, 1, 'King')
    B.fire(1); B.aimLane(1); check(B.alienAt(8, 1) ~= nil, 'not knocked back')
end)

test('Necromancer raises the last kill every third turn', function()
    local s = setup({w1 = 'GalacticBeam'}); s.needed = 0
    put(2, 5, 'Giant', 5000); put(1, 1, 'Necromancer')
    B.fire(1); B.aimLane(5); check(B.count() == 1, 'giant dead')
    B.endTurn(); B.endTurn(); check(B.count() == 1, 'nothing yet')
    B.endTurn()
    local raised; B.each(function(a) if a.name == 'Giant' then raised = a end end)
    check(raised and near(raised.health, hp.Giant * 0.5), 'giant raised at half health')
end)

test('Void Titan caps every hit at 5000', function()
    setup({w1 = 'VoidBurst'}); put(5, 1, 'VoidTitan')
    B.fire(1); B.aimTile(5, 1); B.aimTile(1, 1); B.aimTile(2, 2)
    check(near(B.alienAt(5, 1).health, hp.VoidTitan - 5000), '11000 became 5000')
end)

test('Hypnotised survivors do not block the stage or spawns', function()
    local s = setup({w1 = 'Hypnosis'}); s.needed = 1; s.kills = 1
    put(1, 1, 'King'); B.fire(1)
    check(B.alienAt(1, 1).hypno, 'hypnotised')
    check(B.endTurn() == 'stage', 'stage cleared with only a hypnotised alien left')
    s = setup({w1 = 'Hypnosis'}); s.needed = 3; s.kills = 0
    put(5, 1, 'Thief'); B.fire(1); data.gold = 10
    B.endTurn(); check(data.gold == 10, 'hypnotised thief steals nothing')
    check(B.count() >= 2, 'waves keep coming despite the hypnotised alien (' .. B.count() .. ')')
end)

test('Every random event runs on a busy field without errors', function()
    for _, e in ipairs(B.EVENTS) do
        local s = setup({w1 = 'CosmicFire', w2 = 'AstroidRain', w3 = 'Barricade', level = '6-25'}); s.needed = 100
        put(2, 1, 'Joe'); put(5, 2, 'King'); put(8, 3, 'Guardian'); put(9, 4, 'Giant'); put(3, 5, 'Albot'); put(6, 1, 'Spaceship')
        s.walls[7][2] = 1
        B.fire(1); B.aimLane(1)
        local ok, err = pcall(B.forceEvent, e.key)
        check(ok, e.key .. ' ran (' .. tostring(err) .. ')')
        check(s.evt and s.evt.key == e.key, e.key .. ' recorded as the active event')
        local evs = B.drain()
        local seen = false
        for _, ev in ipairs(evs) do if ev.type == 'event' and ev.key == e.key then seen = true end end
        check(seen, e.key .. ' emitted an event banner')
        ok, err = pcall(B.endTurn)
        check(ok, e.key .. ' turn completed (' .. tostring(err) .. ')')
        check(s.evt == nil, e.key .. ' modifiers expired at the next end turn')
    end
end)

test('Event modifiers: overcharge, fog, resonance and bounty', function()
    local s = setup({w1 = 'CosmicFire', w2 = 'AstroidRain'}); s.needed = 100
    put(5, 1, 'Giant', 50000)
    B.forceEvent('overcharge'); B.fire(1); B.aimLane(1)
    check(near(B.alienAt(5, 1).health, 50000 - 375), 'overcharge x1.5')
    s = setup({w1 = 'CosmicFire', w2 = 'AstroidRain'}); s.needed = 100; put(5, 1, 'Giant', 50000)
    B.forceEvent('fog'); B.fire(1); B.aimLane(1); B.fire(2)
    check(near(B.alienAt(5, 1).health, 50000 - 125 - 175), 'fog halves lane damage but not field')
    s = setup({w1 = 'CosmicFire'}); s.needed = 100; put(5, 1, 'Giant', 50000)
    B.forceEvent('raritysurge'); B.fire(1); B.aimLane(1)
    check(near(B.alienAt(5, 1).health, 50000 - 500), 'the only rarity resonates: x2')
    s = setup({w1 = 'LaserKill'}); s.needed = 100; data.gold = 0; put(5, 1, 'Joe', 500)
    B.forceEvent('bounty'); B.fire(1); B.aimLane(1)
    check(data.gold == 5, 'bounty paid on kill')
end)

test('Events never fire before turn 3 and respect the gap', function()
    local s = setup({}); s.needed = 100
    B.EVENT_CHANCE = 1
    B.endTurn(); check(s.evt == nil, 'no event on turn 2')
    B.endTurn(); check(s.evt ~= nil, 'event on turn 3')
    B.endTurn(); check(s.evt == nil, 'gap turn 4'); B.endTurn(); check(s.evt == nil, 'gap turn 5')
    B.endTurn(); check(s.evt ~= nil, 'event again on turn 6')
    B.EVENT_CHANCE = 0.14
end)

test('Discovery: aliens are marked seen when they first appear', function()
    setup({}); data.seen = {}
    put(3, 1, 'Medic'); check(data.seen.Medic == true, 'medic seen')
end)

-- ======================================================================= events
test('End turn emits abilities before moves before spawns', function()
    local s = setup({}); s.needed = 5
    put(4, 1, 'Albot'); put(6, 2, 'King'); put(5, 3, 'Spaceship')
    B.drain(); B.endTurn()
    local order = {}
    for _, e in ipairs(B.drain()) do
        if e.type == 'phase' then order[#order + 1] = e.name
        elseif e.type == 'ability' or e.type == 'move' or e.type == 'spawn' then order[#order + 1] = e.type end
    end
    local seq = table.concat(order, ' ')
    check(seq:find('abilities ability spawn') ~= nil, 'albot ability then its spawn: ' .. seq)
    check(seq:find('abilities.*ability.*move.*move') ~= nil and not seq:find('move.*abilities'), 'all abilities before moves: ' .. seq)
    check(seq:find('move.*spawn spawn') ~= nil or seq:find('move.*spawn$') ~= nil, 'wave spawn after moves: ' .. seq)
end)

-- ======================================================================= flow
test('Stage clears when enough aliens are killed and the field is empty; level wins after 3', function()
    local s = setup({w1 = 'SolarFlare', level = '1-1'})
    for st = 1, 3 do
        s = B.state()
        local r
        for _ = 1, 200 do
            B.fire(1); r = B.endTurn()
            if r then break end
            -- ready the weapon again for the test
            s.slots[1].used = false
        end
        if st < 3 then check(r == 'stage' and B.state().stage == st + 1, 'stage ' .. st .. ' cleared -> ' .. tostring(r))
        else check(r == 'win', 'level won -> ' .. tostring(r)) end
    end
end)

test('Reaching the base loses', function()
    local s = setup({}); s.needed = 0; put(10, 3, 'King')
    check(B.endTurn() == 'lose', 'lose when an alien passes row 10')
end)

test('Full random simulation never errors', function()
    for run = 1, 30 do
        local s = setup({w1 = WEAPON_ORDER[math.random(#WEAPON_ORDER)], w2 = WEAPON_ORDER[math.random(#WEAPON_ORDER)], w3 = WEAPON_ORDER[math.random(#WEAPON_ORDER)], level = math.random(6) .. '-' .. math.random(30)})
        for turn = 1, 60 do
            for n = 1, 3 do
                local r = B.fire(n)
                if r == 'lane' then B.aimLane(math.random(5))
                elseif r == 'tile' then for _ = 1, 3 do B.aimTile(math.random(10), math.random(5)) end; if B.state().aim then B.cancelAim() end end
            end
            if math.random(6) == 1 then B.useItem(({'zap', 'electricity', 'teleporter', 'walls', 'protection'})[math.random(5)]) end
            local r = B.endTurn()
            if r == 'lose' or r == 'win' then break end
        end
    end
    check(true, 'simulations ran')
end)

print(string.format('\n%d passed, %d failed', passed, failed))
if failed > 0 then os.exit(1) end
