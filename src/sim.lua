-- Balance probe: a greedy bot plays levels headless and reports win rates.
--   "C:\Program Files\LOVE\lovec.exe" . --sim [level] [w1,w2,w3] [upgrade] [games] [wave e.g. 1,2,3] [quota scale]
local B = require 'src/battle'
data = defaultSave()
weaponDictionary(); alienDictionary(); makeLevel(); applyNewSpawns()

local args = SIM_ARGS or {}
local levels = (args[1] and args[1] ~= '') and {args[1]} or {}
if #levels == 0 then for p = 1, 6 do for _, l in ipairs({1, 8, 15, 22, 30}) do levels[#levels + 1] = p .. '-' .. l end end end
local loadout = {'AstroidRain', 'CosmicFire', 'TripleThreat'}
if args[2] and args[2] ~= '' and args[2] ~= 'auto' then loadout = {}; for id in args[2]:gmatch('[^,]+') do loadout[#loadout + 1] = id end end
local upgrade = tonumber(args[3]) or 0
local games = tonumber(args[4]) or 40
if args[5] and args[5] ~= '' then B.WAVE = {}; for n in args[5]:gmatch('%d+') do B.WAVE[#B.WAVE + 1] = tonumber(n) end end
if args[6] and args[6] ~= '' then B.QUOTA_SCALE = tonumber(args[6]) end
if args[7] then HP_SCALE = tonumber(args[7]); alienDictionary(); applyNewSpawns() end

-- any player shoots spawners/supporters first; otherwise the lane whose
-- closest alien is nearest the base (ties: most total hp)
local PRIORITY = {Albot = true, Medic = true, Necromancer = true, Thief = true, TheHevalGod = true, Shieldbearer = true}
local function bestLane()
    local s = B.state()
    local best, bi, bhp = nil, -1, -1
    for j = 1, B.LANES do
        local a, i = B.firstInLane(j)
        if a then
            local hp, prio = 0, 0
            for r = 1, B.ROWS do local b = s.grid[r][j]; if b then hp = hp + b.health; if PRIORITY[b.name] then prio = 20 end end end
            if i + prio > bi or (i + prio == bi and hp > bhp) then best, bi, bhp = j, i + prio, hp end
        end
    end
    return best or math.random(B.LANES)
end

local function bestTile(rule)
    local s = B.state()
    if rule.wall then
        local lane = bestLane()
        for i = B.ROWS, 2, -1 do if B.wallAllowed(i, lane) then return i, lane end end
        for j = 1, B.LANES do for i = B.ROWS, 2, -1 do if B.wallAllowed(i, j) then return i, j end end end
        return nil
    end
    local lane = bestLane()
    local a, i = B.firstInLane(lane)
    if a then return i, lane end
    return nil
end

local function playTurn()
    for n = 1, 3 do
        local r = B.fire(n)
        if r == 'lane' then B.aimLane(bestLane())
        elseif r == 'tile' then
            local s = B.state()
            while s.aim do
                local i, j = bestTile(s.aim.rule)
                if not i then B.cancelAim(); break end
                if not B.aimTile(i, j) then
                    -- fall back to any other alien tile
                    local done = false
                    B.each(function(_, ai, aj) if not done and B.aimTile(ai, aj) then done = true end end)
                    if not done then B.cancelAim(); break end
                end
            end
        end
        B.drain()
    end
    local res = B.endTurn()
    B.drain()
    return res
end

-- what a typical player is expected to carry on each planet: {w1, w2, w3, upgrade}
local ARSENAL = {
    {'AstroidRain', 'CosmicFire', 'TripleThreat', 1},
    {'AstroidRain', 'DaggerThrow', 'BattleRam', 1},
    {'RecursiveExplosion', 'DaggerThrow', 'BattleRam', 2},
    {'SantaAxe', 'GrenadeLauncher', 'Executioner', 1},
    {'GalacticBeam', 'SantaAxe', 'Executioner', 2},
    {'GalacticBeam', 'SolarFlare', 'VoidBurst', 1},
}

local function playLevel(level)
    data.currentLevel = level
    local lo, up = loadout, upgrade
    if args[2] == 'auto' then local a = ARSENAL[tonumber(level:match('^%d+'))]; lo, up = a, a[4] end
    data.weaponChoose1, data.weaponChoose2, data.weaponChoose3 = lo[1], lo[2], lo[3]
    for _, id in ipairs(WEAPON_ORDER) do data.weapons[id] = true; data.upgrades[id] = up end
    data.gold = 0
    B.start(); B.drain()
    local turns = 0
    while turns < 400 do
        turns = turns + 1
        local r = playTurn()
        if r == 'win' then return true, turns end
        if r == 'lose' then
            if os.getenv('SIM_DEBUG') then
                local names, total = {}, 0
                B.each(function(a) names[a.name] = (names[a.name] or 0) + 1; total = total + a.health end)
                local parts = {}
                for n, c in pairs(names) do parts[#parts + 1] = n .. 'x' .. c end
                print(string.format('  lost turn %d stage %d kills %d/%d  field hp %d  %s', turns, B.state().stage, B.state().kills, B.state().needed, total, table.concat(parts, ' ')))
            end
            return false, turns
        end
    end
    return false, turns
end

print(string.format('loadout %s  upgrade +%d0%%  %d games each', table.concat(loadout, ','), upgrade, games))
for _, level in ipairs(levels) do
    local wins, turnSum = 0, 0
    for _ = 1, games do
        local won, turns = playLevel(level)
        if won then wins = wins + 1 end
        turnSum = turnSum + turns
    end
    print(string.format('%-6s win %3d%%  avg turns %5.1f', level, wins / games * 100, turnSum / games))
    io.stdout:flush()
end
