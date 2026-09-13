-- Headless rules tests:  "C:\Program Files\LOVE\lovec.exe" . --test
local B = require 'src/battle'
data = defaultSave()
weaponDictionary(); alienDictionary(); makeLevel()

local passed, failed = 0, 0
local current = ''
local function check(cond, msg)
    if cond then passed = passed + 1 else failed = failed + 1; print('  FAIL [' .. current .. '] ' .. msg) end
end
local function near(a, b, eps) return math.abs(a - b) <= (eps or 0.01) end

-- fresh world for each test
local function setup(opts)
    opts = opts or {}
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
    check(near(B.alienAt(3, 1).health, 500 - 175), 'joe damaged')
    check(near(B.alienAt(7, 4).health, 1550 - 175), 'king damaged')
    check(near(B.alienAt(1, 5).health, 2150 - 175), 'dj damaged')
    check(B.state().slots[1].used, 'slot marked used')
end)

test('Poison Arrow damages a lane and poisons it', function()
    local s = setup({w1 = 'PoisonArrow'})
    put(2, 3, 'King'); put(6, 3, 'King'); put(6, 4, 'King')
    check(B.fire(1) == 'lane', 'asks for a lane')
    B.aimLane(3)
    check(near(B.alienAt(2, 3).health, 1400) and near(B.alienAt(6, 3).health, 1400), 'both in lane took 150')
    check(near(B.alienAt(6, 4).health, 1550), 'other lane untouched')
    check(B.alienAt(2, 3).poison == 55, 'poisoned for 55')
    B.endTurn()
    -- both moved down one row and ticked poison
    check(near(B.alienAt(3, 3).health, 1345), 'poison ticked on end turn')
end)

test('Triple Threat hits three chosen tiles, not the same tile twice', function()
    setup({w1 = 'TripleThreat'})
    put(4, 1, 'King'); put(5, 2, 'King'); put(6, 3, 'King')
    check(B.fire(1) == 'tile', 'asks for tiles')
    B.aimTile(4, 1); check(B.aimTile(4, 1) == false, 'same tile rejected'); B.aimTile(5, 2); B.aimTile(6, 3)
    check(B.state().aim == nil, 'aiming done after 3')
    check(near(B.alienAt(4, 1).health, 1350) and near(B.alienAt(5, 2).health, 1350) and near(B.alienAt(6, 3).health, 1350), 'each tile took 200')
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
    check(near(B.alienAt(5, 3).health, 1390), 'center hit')
    check(near(B.alienAt(5, 2).health, 1390) and near(B.alienAt(5, 4).health, 1390), 'sides hit')
    check(near(B.alienAt(3, 3).health, 1390) and near(B.alienAt(7, 3).health, 1390), 'two up / two down hit')
    check(near(B.alienAt(5, 1).health, 1550) and near(B.alienAt(8, 3).health, 1550), 'outside cross untouched')
end)

test('Laser Kill kills aliens at or under 375, Laser Beam under 6000, both ignore buffs', function()
    local s = setup({w1 = 'LaserKill', w2 = 'LaserBeam'})
    put(2, 1, 'Joe', 300); put(4, 1, 'Gen57', 375); put(6, 1, 'King'); put(8, 1, 'Giant', 6000); put(9, 1, 'Giant', 6001)
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
    B.endTurn(); B.endTurn(); check(s.slots[1].used, 'rain still recharging after 3')
    B.endTurn(); check(s.slots[1].used == false, 'rain ready on 4th')
end)

test('Thunder Strike deals 700 to the lane', function()
    setup({w1 = 'ThunderStrike'}); put(3, 2, 'Giant'); put(8, 2, 'Giant')
    B.fire(1); B.aimLane(2)
    check(near(B.alienAt(3, 2).health, 12000) and near(B.alienAt(8, 2).health, 12000), '700 each')
end)

test('Battle Ram hits the closest alien and knocks it back one tile', function()
    setup({w1 = 'BattleRam'}); put(2, 1, 'Giant'); put(8, 1, 'Giant')
    B.fire(1); B.aimLane(1)
    check(B.alienAt(8, 1) == nil and B.alienAt(7, 1) ~= nil, 'closest pushed back to row 7')
    check(near(B.alienAt(7, 1).health, 12700 - 1050), 'took 1050')
    check(near(B.alienAt(2, 1).health, 12700), 'far alien untouched')
end)

test('Electro Jolt stuns the entire lane', function()
    setup({w1 = 'ElectroJolt'}); put(1, 4, 'King'); put(5, 4, 'King'); put(9, 4, 'King'); put(5, 5, 'King')
    B.fire(1); B.aimLane(4)
    check(B.alienAt(1, 4).stun == 1 and B.alienAt(5, 4).stun == 1 and B.alienAt(9, 4).stun == 1, 'whole lane stunned')
    check(B.alienAt(5, 5).stun == 0, 'other lane fine')
end)

test('Hevalbane doubles against Hevalten', function()
    setup({w1 = 'Hevalstruck'}); put(5, 1, 'Guardian'); put(5, 2, 'King', 5000)
    B.fire(1); B.aimLane(1); check(near(B.alienAt(5, 1).health, 28800 - 2400), 'hevalten took 2400')
    B.endTurn(); B.fire(1); B.aimLane(2); check(near(B.alienAt(6, 2).health, 5000 - 1200), 'normal took 1200')
end)

test('Recursive Explosion / Solar Flare / Quantum Flux hit the field', function()
    for _, c in ipairs({{'RecursiveExplosion', 425}, {'SolarFlare', 3000}, {'QuantumFlux', 3000}}) do
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
    setup({w1 = 'Offguard'}); put(1, 1, 'King'); put(5, 3, 'Giant'); put(9, 5, 'DJ')
    B.fire(1)
    check(B.alienAt(1, 1).stun == 1 and B.alienAt(5, 3).stun == 1 and B.alienAt(9, 5).stun == 1, 'all stunned')
end)

test('Mind Blast deals 7001 and hypnotises the survivor', function()
    local s = setup({w1 = 'MindBlast'}); put(9, 1, 'Giant')
    B.fire(1); B.aimLane(1)
    local g = B.alienAt(9, 1)
    check(g and near(g.health, 12700 - 7001) and g.hypno, 'giant hypnotised')
end)

test('Hypnotised aliens fight: both lose the other health, stronger survives and advances', function()
    local s = setup({}); s.needed = 0
    local h = put(8, 1, 'Giant'); h.hypno = true; h.health = 5000
    put(5, 1, 'King') -- 1550, two rows up with a gap
    B.endTurn()
    check(B.alienAt(5, 1) == nil, 'king died')
    check(s.kills == 1, 'counts as a kill')
    local g = B.alienAt(7, 1) or B.alienAt(8, 1)
    check(g and g.hypno and near(g.health, 5000 - 1550), 'giant lost the king health and stepped up (' .. tostring(g and g.health) .. ')')
    -- weaker hypno alien dies instead
    s = setup({}); s.needed = 0
    h = put(8, 2, 'Joe'); h.hypno = true
    put(7, 2, 'King')
    B.endTurn()
    local k = B.alienAt(8, 2) or B.alienAt(7, 2)
    check(B.count() == 1 and k and not k.hypno, 'joe died')
    check(k and near(k.health, 1550 - 500), 'king weakened but alive')
    -- with nothing to fight it moves up and holds the top
    s = setup({}); s.needed = 0
    h = put(2, 3, 'Giant'); h.hypno = true
    B.endTurn(); check(B.alienAt(1, 3) and B.alienAt(1, 3).hypno, 'moved to the top')
    B.endTurn(); check(B.alienAt(1, 3) and B.alienAt(1, 3).hypno, 'stands guard at the top')
end)

test('Grenade Launcher hits front and back rows', function()
    setup({w1 = 'GrenadeLauncher'}); put(1, 1, 'Giant'); put(10, 5, 'Giant'); put(5, 3, 'Giant')
    B.fire(1)
    check(near(B.alienAt(1, 1).health, 12700 - 3950) and near(B.alienAt(10, 5).health, 12700 - 3950), 'rows 1 and 10 hit')
    check(near(B.alienAt(5, 3).health, 12700), 'middle untouched')
end)

test('Bulwark: 400 to lane and permanent +1.25%', function()
    local s = setup({w1 = 'Protected'}); put(4, 2, 'Giant')
    B.fire(1); B.aimLane(2)
    check(near(B.alienAt(4, 2).health, 12700 - 400), '400 damage (buff applied after)')
    check(near(s.buff, 1.0125), 'buff raised')
end)

test('Hypnosis hypnotises the closest alien in every lane', function()
    setup({w1 = 'Hypnosis'}); put(3, 1, 'King'); put(6, 1, 'King'); put(2, 4, 'King')
    B.fire(1)
    check(B.alienAt(6, 1).hypno and not B.alienAt(3, 1).hypno and B.alienAt(2, 4).hypno, 'closest per lane')
end)

test('Comet Strike hits a 3x3 block', function()
    setup({w1 = 'CometStrike'})
    for i = 4, 6 do for j = 2, 4 do put(i, j, 'Giant') end end
    put(4, 5, 'Giant')
    B.fire(1); B.aimTile(5, 3)
    for i = 4, 6 do for j = 2, 4 do check(near(B.alienAt(i, j).health, 12700 - 8000), 'cell ' .. i .. ',' .. j) end end
    check(near(B.alienAt(4, 5).health, 12700), 'outside untouched')
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
    put(1, 1, 'Giant'); put(3, 1, 'Giant'); put(5, 1, 'Giant'); put(7, 1, 'Giant'); put(9, 1, 'Giant'); put(8, 1, 'Guardian')
    B.fire(1); B.aimLane(1)
    check(B.alienAt(9, 1).health == 1 and B.alienAt(7, 1).health == 1 and B.alienAt(5, 1).health == 1 and B.alienAt(3, 1).health == 1, 'four closest normals at 1')
    check(near(B.alienAt(1, 1).health, 12700), 'fifth untouched')
    check(near(B.alienAt(8, 1).health, 28800), 'hevalten untouched')
end)

test('Upgrades add +10% damage per level', function()
    setup({w1 = 'CosmicFire'}); data.upgrades.CosmicFire = 3
    put(2, 1, 'Giant'); B.fire(1); B.aimLane(1)
    check(near(B.alienAt(2, 1).health, 12700 - 325), 'lane weapon upgraded (250 * 1.3)')
end)

test('Cancel aiming refunds the shot', function()
    local s = setup({w1 = 'CosmicFire'}); put(2, 1, 'Giant')
    B.fire(1); B.cancelAim()
    check(s.slots[1].used == false and s.aim == nil, 'slot ready again')
end)

-- ======================================================================= aliens
test('Space Fence is immune for its first turn', function()
    local s = setup({w1 = 'SolarFlare'}); put(1, 1, 'SpaceFence')
    B.fire(1); check(near(B.alienAt(1, 1).health, 2950), 'shielded')
    B.endTurn()
    setup({w1 = 'SolarFlare'}); local a = put(1, 1, 'SpaceFence'); a.immune = 0
    B.fire(1); check(B.alienAt(1, 1) == nil, 'killed once shield is down')
end)

test('Spaceship alternates flying; flying ignores lane/tile damage but not field', function()
    local s = setup({w1 = 'CosmicFire', w2 = 'SolarFlare'}); local a = put(1, 1, 'Spaceship'); a.fly = true
    B.fire(1); B.aimLane(1); check(near(a.health, 3000), 'lane attack missed while flying')
    B.fire(2); check(near(a.health, 0) or B.alienAt(1, 1) == nil, 'field attack hit while flying')
    setup({}); a = put(1, 1, 'Spaceship'); B.endTurn(); check(B.alienAt(2, 1).fly == true, 'toggles flight each turn')
end)

test('Old Granny steps forward when hurt, without cloning', function()
    local s = setup({w1 = 'AstroidRain'}); put(4, 2, 'OldGranny')
    B.fire(1)
    check(B.alienAt(4, 2) == nil and B.alienAt(5, 2) ~= nil, 'moved to row 5')
    check(B.count() == 1, 'exactly one granny')
    check(near(B.alienAt(5, 2).health, 3700 - 175), 'hit once only')
end)

test('Albot spawns a random alien in its row every turn', function()
    local s = setup({}); put(4, 3, 'Albot'); s.needed = 0
    B.endTurn()
    local n = 0
    for j = 1, 5 do if B.alienAt(5, j) or B.alienAt(4, j) then n = n + 1 end end
    check(B.count() == 2, 'one extra alien spawned (' .. B.count() .. ')')
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
    local s = setup({}); s.needed = 0; put(2, 1, 'Giant')
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
    local s = setup({}); s.needed = 0; local a = put(2, 1, 'Morpher'); a.health = 2850 -- 50%
    B.endTurn()
    local m = B.alienAt(3, 1)
    check(m ~= nil and m.morph, 'still a morpher')
    check(near(m.health / m.maxHealth, 0.5), 'kept 50% health')
end)

test('Fusion fuses two aliens on spawn into one bigger one', function()
    local s = setup({}); put(5, 1, 'King'); put(6, 2, 'King')
    put(1, 3, 'Fusion')
    check(B.count() == 2, 'two aliens became one')
    local big
    B.each(function(a) if a.name ~= 'Fusion' then big = a end end)
    check(big and big.health >= 1550 * 2 * 1.5 - 1, 'fused health >= 1.5x combined (' .. (big and big.health or 'nil') .. ')')
end)

test('Splashfest ignores field and splash damage', function()
    setup({w1 = 'SolarFlare', w2 = 'CosmicFire'}); put(3, 1, 'Splashfest')
    B.fire(1); check(near(B.alienAt(3, 1).health, 15500), 'field ignored')
    B.fire(2); B.aimLane(1); check(near(B.alienAt(3, 1).health, 15500 - 250), 'lane hits')
end)

test('Virus makes cooldowns one turn longer', function()
    local s = setup({w1 = 'CosmicFire'}); s.needed = 0; put(1, 1, 'Virus')
    B.fire(1); B.aimLane(3)
    B.endTurn(); check(s.slots[1].used, 'still used one turn later')
    B.endTurn(); check(not s.slots[1].used, 'ready after the extra turn')
end)

test('Guardian absorbs lane damage and is immune to poison/knockback/hypno', function()
    local s = setup({w1 = 'PoisonArrow', w2 = 'BattleRam', w3 = 'Hypnosis'})
    put(3, 1, 'Guardian'); put(8, 1, 'King')
    B.fire(1); B.aimLane(1)
    check(near(B.alienAt(8, 1).health, 1550), 'king untouched')
    check(near(B.alienAt(3, 1).health, 28800 - 300), 'guardian took both hits')
    check(B.alienAt(3, 1).poison == 0, 'guardian not poisoned')
    B.fire(2); B.aimLane(1); check(B.alienAt(8, 1) ~= nil, 'king not knocked back (guardian absorbed)')
    B.fire(3); check(not B.alienAt(8, 1).hypno, 'no hypno in guarded lane')
end)

test('Dark Arts upgrades every other alien one tier', function()
    setup({}); put(5, 1, 'Joe'); put(6, 2, 'King', 775)
    put(1, 3, 'DarkArts')
    check(B.alienAt(5, 1).name == 'Gen57', 'joe -> gen57')
    check(B.alienAt(6, 2).name == 'DJ' and near(B.alienAt(6, 2).health, 2150 * 0.5), 'king -> dj at 50%')
    check(B.alienAt(1, 3).name == 'DarkArts', 'dark arts itself unchanged')
end)

test('Bunker halves targeted damage', function()
    setup({w1 = 'TripleThreat', w2 = 'CosmicFire'}); put(4, 1, 'Protected')
    B.fire(1); B.aimTile(4, 1); B.aimTile(1, 1); B.aimTile(2, 2)
    check(near(B.alienAt(4, 1).health, 26000 - 100), 'tile damage halved')
    B.fire(2); B.aimLane(1); check(near(B.alienAt(4, 1).health, 26000 - 100 - 250), 'lane damage full')
end)

test('Heval God spawns a Hevalten in the first three rows when hurt', function()
    setup({w1 = 'CosmicFire'}); put(8, 1, 'TheHevalGod')
    B.fire(1); B.aimLane(1)
    local spawned
    B.each(function(a, i) if a.name ~= 'TheHevalGod' then spawned = {a, i} end end)
    check(spawned and spawned[1].hevalten and spawned[2] <= 3, 'hevalten spawned up top')
end)

test('God of Space spawns three aliens and is immune to poison/knockback/hypno but not damage', function()
    local s = setup({w1 = 'PoisonArrow', w2 = 'BattleRam', w3 = 'MindBlast'})
    put(9, 2, 'GodOfSpace')
    check(B.count() == 4, 'three extra aliens (' .. B.count() .. ')')
    for i = 1, 3 do for j = 1, 5 do if B.alienAt(i, j) then s.grid[i][j] = nil end end end
    put(9, 1, 'King')
    B.fire(1); B.aimLane(2); check(B.alienAt(9, 2).poison == 0 and near(B.alienAt(9, 2).health, 50000 - 150), 'damaged, not poisoned')
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
    check(B.aimTile(4, 1) == false, 'cannot place on an alien'); check(B.aimTile(1, 2) == false, 'cannot place on row 1')
    check(B.aimTile(6, 2) == true and s.walls[6][2] == true and s.aim == nil, 'wall placed where chosen')
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
