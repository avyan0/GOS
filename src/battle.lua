-- Battle rules. Pure logic, no rendering, so it can be unit-tested headless.
-- Grid: 5 lanes x 10 rows. Aliens spawn at row 1 and march to row 10; reaching row 11 loses.
local B = {}

B.LANES, B.ROWS = 5, 10
local STARTER_TIERS = 9      -- Albot spawns from the first 9 alien types

local s -- current battle state

local function newState()
    local grid, walls = {}, {}
    for i = 1, B.ROWS + 1 do grid[i], walls[i] = {}, {} end
    return {
        grid = grid, walls = walls,
        stage = 1, kills = 0, needed = 0, turn = 1,
        slots = {}, buff = 1, stellar = nil, targetBuff = 1,
        rarityBuff = {common = 1, rare = 1, scarce = 1, god = 1},
        aim = nil, lockedLane = nil, result = nil,
    }
end

function B.state() return s end

-- ---------------------------------------------------------------- helpers
local function alienAt(i, j) return s.grid[i] and s.grid[i][j] end
B.alienAt = alienAt

local function each(fn) -- rows 10 -> 1 so an alien moved forward is not visited twice
    for i = B.ROWS, 1, -1 do for j = 1, B.LANES do local a = s.grid[i][j]; if a then fn(a, i, j) end end end
end
B.each = each

local function count()
    local n = 0; each(function() n = n + 1 end); return n
end
B.count = count

local function freeCells(rowMax)
    local out = {}
    for i = 1, rowMax or B.ROWS do for j = 1, B.LANES do if not s.grid[i][j] then out[#out + 1] = {i, j} end end end
    return out
end

local function firstInLane(lane) -- closest to the base
    for i = B.ROWS, 1, -1 do if s.grid[i][lane] then return s.grid[i][lane], i end end
end
B.firstInLane = firstInLane

local function guardianIn(lane)
    for i = B.ROWS, 1, -1 do local a = s.grid[i][lane]; if a and a.name == 'Guardian' then return a, i end end
end
B.guardianIn = guardianIn

local function anyNamed(name)
    local found = false
    each(function(a) if a.name == name then found = true end end)
    return found
end

local function upgrade(w) return (data.upgrades[w.id] or 0) * 0.1 + 1 end

-- ---------------------------------------------------------------- buffs from aliens
local BUFF = {
    Army = function(on) s.buff = s.buff + (on and -0.02 or 0.02) end,
    Interdimentional = function(on) s.buff = on and s.buff * 0.925 or s.buff / 0.925 end,
    CommonCrippler = function(on) s.rarityBuff.common = on and s.rarityBuff.common * 0.75 or s.rarityBuff.common / 0.75 end,
    Rare = function(on) s.rarityBuff.rare = on and s.rarityBuff.rare * 0.8 or s.rarityBuff.rare / 0.8 end,
    Scarce = function(on) s.rarityBuff.scarce = on and s.rarityBuff.scarce * 0.85 or s.rarityBuff.scarce / 0.85 end,
}

function B.damageMultiplier(weapon)
    return upgrade(weapon) * s.buff * (s.stellar and s.stellar.mult or 1) * s.rarityBuff[weapon.rarity]
end

-- ---------------------------------------------------------------- spawning / removal
local function place(i, j, def, health)
    local a = {
        name = def.name, hevalten = def.hevalten, health = health or def.health, maxHealth = def.health,
        stun = 0, poison = 0, hypno = false, immune = 0, fly = false, giantWait = false, morph = def.name == 'Morpher',
    }
    s.grid[i][j] = a
    if BUFF[def.name] then BUFF[def.name](true) end
    return a
end

local function remove(i, j)
    local a = s.grid[i][j]
    if not a then return end
    s.grid[i][j] = nil
    if BUFF[a.name] then BUFF[a.name](false) end
    return a
end

local function kill(i, j)
    local a = remove(i, j)
    if not a then return end
    s.kills = s.kills + 1
    data.aliensKilled = data.aliensKilled + 1
end
B.kill = kill

local function move(fi, fj, ti, tj)
    s.grid[ti][tj] = s.grid[fi][fj]
    s.grid[fi][fj] = nil
end

local function randomUnlocked(hevaltenOnly)
    local pool = {}
    for k = 1, math.min(data.aliensUnlocked, #Aliensrand) do
        local d = Aliensrand[k]
        if not hevaltenOnly or (d.hevalten and d.name ~= 'TheHevalGod' and d.name ~= 'GodOfSpace') then pool[#pool + 1] = d end
    end
    if #pool == 0 then pool[1] = Aliensrand[1] end
    return pool[math.random(#pool)]
end

-- promote every other alien one tier, keeping its health percentage
local function upgradeAll(exceptI, exceptJ)
    each(function(a, i, j)
        if i == exceptI and j == exceptJ then return end
        for k = 1, #Aliensrand - 1 do
            if Aliensrand[k].name == a.name then
                local pct = a.health / a.maxHealth
                local keep = {stun = a.stun, poison = a.poison, hypno = a.hypno}
                remove(i, j)
                local n = place(i, j, Aliensrand[k + 1], Aliensrand[k + 1].health * pct)
                n.stun, n.poison, n.hypno = keep.stun, keep.poison, keep.hypno
                return
            end
        end
    end)
end

-- fuse two other aliens into one bigger one (Fusion's spawn ability)
local function fuse(selfI, selfJ)
    local others = {}
    each(function(a, i, j) if not (i == selfI and j == selfJ) then others[#others + 1] = {i, j, a} end end)
    if #others < 2 then return end
    local x = table.remove(others, math.random(#others))
    local y = table.remove(others, math.random(#others))
    local hp = (x[3].health + y[3].health) * 1.5
    local def = Aliensrand[#Aliensrand]
    for k = 1, #Aliensrand do if Aliensrand[k].health >= hp then def = Aliensrand[k]; break end end
    remove(x[1], x[2]); remove(y[1], y[2])
    place(x[1], x[2], def, math.min(hp, def.health))
end

-- spawn a new alien of type `def` somewhere free in rows 1..rowMax
local function spawnInto(def, rowMax)
    local cells = freeCells(rowMax or 3)
    if #cells == 0 then return end
    local c = cells[math.random(#cells)]
    return B.spawn(c[1], c[2], def)
end

function B.spawn(i, j, def, health)
    local a = place(i, j, def, health)
    if def.name == 'SpaceFence' then a.immune = 1 end
    if def.name == 'DarkArts' then upgradeAll(i, j) end
    if def.name == 'Fusion' then fuse(i, j) end
    if def.name == 'GodOfSpace' then for _ = 1, 3 do spawnInto(randomUnlocked(false), 3) end end
    return a
end

-- ---------------------------------------------------------------- damage
-- kind: 'field' | 'lane' | 'first' | 'tile' | 'splash'
-- opts: ignoreBuffs (Laser weapons), fixed (set health), noRedirect
local function hit(i, j, amount, weapon, kind, opts)
    opts = opts or {}
    local a = s.grid[i][j]
    if not a then return 0 end
    if a.immune > 0 then return 0 end
    if a.fly and kind ~= 'field' then return 0 end
    if a.name == 'Splashfest' and (kind == 'field' or kind == 'splash') then return 0 end

    -- Guardian soaks everything aimed at its lane
    if not opts.noRedirect and a.name ~= 'Guardian' then
        local g, gi = guardianIn(j)
        if g then return hit(gi, j, amount, weapon, kind, {noRedirect = true, ignoreBuffs = opts.ignoreBuffs}) end
    end

    local dmg = amount
    if not opts.ignoreBuffs then
        dmg = dmg * B.damageMultiplier(weapon)
        if (kind == 'tile' or kind == 'splash' or kind == 'first') and a.name == 'Protected' then dmg = dmg * 0.5 end
    end
    if dmg <= 0 then return 0 end
    a.health = a.health - dmg
    if a.health <= 0 then
        kill(i, j)
        return dmg
    end
    -- reactions
    if a.name == 'OldGranny' and i < B.ROWS and not s.grid[i + 1][j] then move(i, j, i + 1, j) end
    if a.name == 'TheHevalGod' then spawnInto(randomUnlocked(true), 3) end
    return dmg
end
B.hit = hit

local function hitLane(lane, amount, weapon, kind, opts)
    for i = B.ROWS, 1, -1 do if s.grid[i][lane] then hit(i, lane, amount, weapon, kind or 'lane', opts) end end
end

local function hitField(amount, weapon, opts)
    each(function(_, i, j) hit(i, j, amount, weapon, 'field', opts) end)
end

local function hitBox(row, lane, amount, weapon)
    for i = math.min(B.ROWS, row + 1), math.max(1, row - 1), -1 do
        for j = math.max(1, lane - 1), math.min(B.LANES, lane + 1) do
            if s.grid[i][j] then hit(i, j, amount, weapon, (i == row and j == lane) and 'tile' or 'splash') end
        end
    end
end

local function canStun(a) return a.name ~= 'GodOfSpace' end
local function canPoison(a) return a.name ~= 'GodOfSpace' and a.name ~= 'Guardian' end
local function canHypno(a) return a.name ~= 'GodOfSpace' and a.name ~= 'Guardian' end

local function stunLane(lane, n, turns)
    local c = 0
    for i = B.ROWS, 1, -1 do
        local a = s.grid[i][lane]
        if a and c < n and a.immune == 0 and not a.fly and canStun(a) then a.stun = math.max(a.stun, turns); c = c + 1 end
    end
end

local function knockback(lane)
    local a, i = firstInLane(lane)
    if not a or a.name == 'GodOfSpace' or a.immune > 0 or guardianIn(lane) then return end
    if i > 1 and not s.grid[i - 1][lane] then
        move(i, lane, i - 1, lane)
    elseif i > 1 then
        -- push the whole contiguous column back by one if there is room at the top
        local top = i
        while top > 1 and s.grid[top - 1][lane] do top = top - 1 end
        if top > 1 then for r = top, i do move(r, lane, r - 1, lane) end end
    end
end

-- ---------------------------------------------------------------- weapons
local W = {}
W.AstroidRain = {kind = 'field', run = function(w) hitField(w.damage, w) end}
W.PoisonArrow = {kind = 'lane', run = function(w, lane)
    hitLane(lane, w.damageLane, w)
    for i = 1, B.ROWS do local a = s.grid[i][lane]; if a and canPoison(a) and a.immune == 0 then a.poison = w.poison * upgrade(w) end end
end}
W.TripleThreat = {kind = 'tile', shots = 3, run = function(w, row, lane) hit(row, lane, w.damageTile, w, 'tile') end}
W.CosmicFire = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w) end}
W.Astrobolt = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w); stunLane(lane, 2, 1) end}
W.StarBlast = {kind = 'tile', shots = 1, run = function(w, row, lane)
    local cells = {{row, lane, 'tile'}, {row, lane - 1}, {row, lane + 1}, {row + 1, lane}, {row + 2, lane}, {row - 1, lane}, {row - 2, lane}}
    table.sort(cells, function(a, b) return a[1] > b[1] end)
    for _, c in ipairs(cells) do
        if c[1] >= 1 and c[1] <= B.ROWS and c[2] >= 1 and c[2] <= B.LANES and s.grid[c[1]][c[2]] then hit(c[1], c[2], w.damage, w, c[3] or 'splash') end
    end
end}
W.LaserKill = {kind = 'lane', run = function(w, lane)
    local cap = w.damage * upgrade(w)
    for i = B.ROWS, 1, -1 do local a = s.grid[i][lane]; if a and a.health <= cap and a.immune == 0 and not a.fly then kill(i, lane) end end
end}
W.StellarBoost = {kind = 'self', run = function(w) s.stellar = {turns = 3, mult = 1.2 * upgrade(w)} end}

W.ThunderStrike = {kind = 'lane', run = function(w, lane)
    hitLane(lane, w.damageLane, w)
    for i = B.ROWS, 1, -1 do
        local a = s.grid[i][lane]
        if a and a.immune == 0 and not a.fly then
            if math.random(3) == 1 and canStun(a) then a.stun = math.max(a.stun, math.round(2 * upgrade(w))) else break end
        end
    end
end}
W.BattleRam = {kind = 'lane', run = function(w, lane)
    local a, i = firstInLane(lane)
    if a then hit(i, lane, w.damage, w, 'first') end
    knockback(lane)
end}
W.ElectroJolt = {kind = 'lane', run = function(w, lane) stunLane(lane, 99, 1) end}
W.DaggerThrow = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w) end}
W.Hevalstruck = {kind = 'lane', run = function(w, lane)
    local a, i = firstInLane(lane)
    if a then hit(i, lane, w.damage * (a.hevalten and 2 or 1), w, 'first') end
end}
W.RecursiveExplosion = {kind = 'field', run = function(w) hitField(w.damage, w) end}
W.Dueltroid = {kind = 'lane', run = function(w, lane)
    if math.random(2) == 1 then stunLane(lane, 1, math.round(4 * upgrade(w))) else stunLane(lane, 2, math.round(2 * upgrade(w))) end
end}
W.FreshStart = {kind = 'tile', shots = 1, run = function(w, row, lane)
    for i = math.max(1, row - 1), math.min(B.ROWS, row + 1) do
        for j = math.max(1, lane - 1), math.min(B.LANES, lane + 1) do
            local a = s.grid[i][j]
            if a and a.name ~= 'Guardian' and a.name ~= 'GodOfSpace' and i > 3 then
                for r = 1, 3 do if not s.grid[r][j] then move(i, j, r, j); break end end
            end
        end
    end
end}

W.SantaAxe = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w) end}
W.Respawn = {kind = 'lane', run = function(w, lane) s.lockedLane = lane end}
W.Offguard = {kind = 'field', run = function(w) each(function(a) if a.immune == 0 and canStun(a) then a.stun = math.max(a.stun, 1) end end) end}
W.LaserBeam = {kind = 'lane', run = function(w, lane)
    local cap = w.damage * upgrade(w)
    for i = B.ROWS, 1, -1 do local a = s.grid[i][lane]; if a and a.health <= cap and a.immune == 0 and not a.fly then kill(i, lane) end end
end}
W.MindBlast = {kind = 'lane', run = function(w, lane)
    local a, i = firstInLane(lane)
    if not a then return end
    hit(i, lane, w.damage, w, 'first')
    local still = s.grid[i][lane]
    if still == a and canHypno(a) and not guardianIn(lane) then a.hypno = true end
end}
W.GrenadeLauncher = {kind = 'field', run = function(w)
    for _, i in ipairs({B.ROWS, 1}) do for j = 1, B.LANES do if s.grid[i][j] then hit(i, j, w.damage, w, 'splash') end end end
end}
W.Protected = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w); s.buff = s.buff * 1.0125 end}
W.Hypnosis = {kind = 'field', run = function(w)
    for lane = 1, B.LANES do
        local a = firstInLane(lane)
        if a and a.immune == 0 and canHypno(a) and not guardianIn(lane) then a.hypno = true end
    end
end}

W.GalacticBeam = {kind = 'lane', run = function(w, lane) hitLane(lane, w.damageLane, w) end}
W.SolarFlare = {kind = 'field', run = function(w) hitField(w.damage, w) end}
W.CometStrike = {kind = 'tile', shots = 1, run = function(w, row, lane) hitBox(row, lane, w.damage, w) end}
W.DeathVirus = {kind = 'field', run = function(w)
    local lane = math.random(B.LANES)
    for i = B.ROWS, 1, -1 do local a = s.grid[i][lane]; if a and a.immune == 0 and not a.fly then kill(i, lane) end end
end}
W.VoidBurst = {kind = 'tile', shots = 3, run = function(w, row, lane) hit(row, lane, w.damageTile, w, 'tile') end}
W.CelestialDisruption = {kind = 'lane', run = function(w, lane)
    local n = 0
    for i = B.ROWS, 1, -1 do
        local a = s.grid[i][lane]
        if a and n < 4 and not a.hevalten and a.immune == 0 and not a.fly then a.health = 1; n = n + 1 end
    end
end}
W.QuantumFlux = {kind = 'field', run = function(w) hitField(w.damage, w) end}
B.WEAPON_RULES = W

-- ---------------------------------------------------------------- turn structure
local SLOT_KEYS = {'weaponChoose1', 'weaponChoose2', 'weaponChoose3'}

local function loadSlots()
    s.slots = {}
    for n, k in ipairs(SLOT_KEYS) do s.slots[n] = {id = data[k], used = false, cd = 0} end
end

function B.needed()
    local L = assert(Levels[data.currentLevel], 'no level ' .. tostring(data.currentLevel))
    return ({L.first, L.second, L.third})[s.stage]
end

function B.start()
    s = newState()
    loadSlots()
    s.needed = B.needed()
    B.spawnWave()
end

-- re-read loadout after StageSelect / Pause; keeps cooldowns of unchanged slots
function B.reloadSlots()
    for n, k in ipairs(SLOT_KEYS) do
        if not s.slots[n] or s.slots[n].id ~= data[k] then s.slots[n] = {id = data[k], used = false, cd = 0} end
    end
end

-- pick which alien spawns this turn from the level's spawn table
local function rollAlien()
    local L = Levels[data.currentLevel]
    local r = math.random(100)
    for _, name in ipairs(alienNames) do if r <= L[name] then return Aliens[name] end end
    return Aliens[alienNames[1]]
end

function B.spawnWave()
    if s.kills + count() >= s.needed then return end -- enough on the field already
    local def = rollAlien()
    local lanes = {}
    for j = 1, B.LANES do
        if not s.grid[1][j] and (def.hevalten or j ~= s.lockedLane) then lanes[#lanes + 1] = j end
    end
    s.lockedLane = nil
    if #lanes == 0 then return end
    B.spawn(1, lanes[math.random(#lanes)], def)
end

-- fire a slot. Returns 'lane' / 'tile' when aiming is required, true when fired, false when unavailable.
function B.fire(n)
    if s.aim or s.result then return false end
    local slot = s.slots[n]
    local w = Weapons[slot.id]
    if not w or slot.used then return false end
    local rule = W[w.id]
    slot.used = true
    if rule.kind == 'lane' or rule.kind == 'tile' then
        s.aim = {kind = rule.kind, weapon = w, rule = rule, slot = n, remaining = rule.shots or 1, last = nil}
        return rule.kind
    end
    rule.run(w)
    return true
end

function B.cancelAim()
    if not s.aim then return end
    if s.aim.remaining == (s.aim.rule.shots or 1) then s.slots[s.aim.slot].used = false end -- nothing fired yet
    s.aim = nil
end

function B.aimLane(lane)
    if not s.aim or s.aim.kind ~= 'lane' then return false end
    local a = s.aim; s.aim = nil
    a.rule.run(a.weapon, lane)
    return true
end

function B.aimTile(row, lane)
    if not s.aim or s.aim.kind ~= 'tile' then return false end
    if s.aim.last and s.aim.last[1] == row and s.aim.last[2] == lane then return false end
    s.aim.rule.run(s.aim.weapon, row, lane)
    s.aim.last = {row, lane}
    s.aim.remaining = s.aim.remaining - 1
    if s.aim.remaining <= 0 then s.aim = nil end
    return true
end

local function albotSpawns()
    each(function(a, i, j)
        if a.name == 'Albot' then
            local free = {}
            for c = 1, B.LANES do if not s.grid[i][c] then free[#free + 1] = c end end
            if #free > 0 then
                local def = Aliensrand[math.random(math.min(STARTER_TIERS, #Aliensrand))]
                B.spawn(i, free[math.random(#free)], def)
            end
        end
    end)
end

local function hypnoTurn()
    for j = 1, B.LANES do
        for i = 1, B.ROWS do -- top to bottom so a hypno alien moves at most once
            local a = s.grid[i][j]
            if a and a.hypno then
                if i == 1 then
                    remove(i, j) -- walked off the top
                else
                    local e = s.grid[i - 1][j]
                    if not e then
                        move(i, j, i - 1, j)
                    elseif not e.hypno then
                        local ah, eh = a.health, e.health
                        a.health, e.health = ah - eh, eh - ah
                        if e.health <= 0 then kill(i - 1, j) end
                        if a.health <= 0 then remove(i, j)
                        elseif not s.grid[i - 1][j] then move(i, j, i - 1, j) end
                    end
                end
            end
        end
    end
end

local function advance()
    -- returns true if an alien reached the base
    local lost = false
    for i = B.ROWS, 1, -1 do
        for j = 1, B.LANES do
            local a = s.grid[i][j]
            if a and not a.hypno then
                local blocked = a.stun > 0
                if a.name == 'Giant' then
                    a.giantWait = not a.giantWait
                    if a.giantWait then blocked = true end
                end
                if a.fly then blocked = false end
                if not blocked then
                    local dest = i + 1
                    if dest > B.ROWS then
                        lost = true
                    elseif not s.grid[dest][j] then
                        if s.walls[dest][j] then
                            if a.name == 'Jumper' then
                                local r = dest
                                while r <= B.ROWS and s.walls[r][j] do r = r + 1 end
                                if r > B.ROWS then lost = true elseif not s.grid[r][j] then move(i, j, r, j) end
                            else
                                s.walls[dest][j] = false -- wall absorbs the move
                            end
                        else
                            move(i, j, dest, j)
                        end
                    end
                end
            end
        end
    end
    return lost
end

local function tickStatuses()
    each(function(a)
        if a.stun > 0 then a.stun = a.stun - 1 end
        if a.immune > 0 then a.immune = a.immune - 1 end
        if a.name == 'Spaceship' then a.fly = not a.fly end
    end)
end

local function applyPoison()
    each(function(a, i, j)
        if a.poison > 0 and a.immune == 0 and not guardianIn(j) then
            a.health = a.health - a.poison * s.buff
            if a.health <= 0 then kill(i, j) end
        end
    end)
end

local function morphs()
    each(function(a, i, j)
        if a.morph then
            local def = randomUnlocked(false)
            local pct = a.health / a.maxHealth
            local keep = {stun = a.stun, poison = a.poison, hypno = a.hypno}
            remove(i, j)
            local n = place(i, j, def, def.health * pct)
            n.morph, n.stun, n.poison, n.hypno = true, keep.stun, keep.poison, keep.hypno
        end
    end)
end

local function tickCooldowns()
    local virus = anyNamed('Virus') and 1 or 0
    for _, slot in ipairs(s.slots) do
        local w = Weapons[slot.id]
        if slot.used then
            slot.cd = slot.cd + 1
            if slot.cd > (w and w.cooldown or 0) + virus then slot.used = false; slot.cd = 0 end
        end
    end
end

-- Ends the turn. Returns 'lose' | 'stage' | 'win' | nil
function B.endTurn()
    if s.aim then B.cancelAim() end
    s.turn = s.turn + 1
    applyPoison()
    if s.stellar then
        s.stellar.turns = s.stellar.turns - 1
        if s.stellar.turns == 2 then s.stellar.mult = 1.1 * (s.stellar.mult / 1.2) end
        if s.stellar.turns <= 0 then s.stellar = nil end
    end
    albotSpawns()
    hypnoTurn()
    if advance() then s.result = 'lose'; return 'lose' end
    tickStatuses()
    B.spawnWave()
    morphs()
    tickCooldowns()
    return B.checkStage()
end

function B.checkStage()
    if s.kills >= s.needed and count() == 0 then
        if s.stage >= 3 then s.result = 'win'; return 'win' end
        s.stage = s.stage + 1
        B.newStage()
        return 'stage'
    end
end

function B.newStage()
    local stage = s.stage
    s = newState()
    s.stage = stage
    loadSlots()
    s.needed = B.needed()
    B.spawnWave()
end

-- ---------------------------------------------------------------- items
function B.useItem(key)
    if key == 'zap' then
        local lane = math.random(B.LANES)
        for i = 1, B.ROWS do local a = s.grid[i][lane]; if a and canStun(a) and a.immune == 0 then a.stun = math.max(a.stun, 3) end end
    elseif key == 'electricity' then
        each(function(a) if canStun(a) and a.immune == 0 then a.stun = math.max(a.stun, 1) end end)
    elseif key == 'teleporter' then
        local cells = {}
        each(function(a, i, j) if a.name ~= 'GodOfSpace' then cells[#cells + 1] = {i, j} end end)
        if #cells > 0 then local c = cells[math.random(#cells)]; kill(c[1], c[2]) end
    elseif key == 'gold' then
        data.goldBuff = 2
    elseif key == 'protection' then
        s.buff = s.buff * 1.5
    elseif key == 'walls' then
        local lanes = {}
        for j = 1, B.LANES do
            local ok = true
            for i = 1, B.ROWS do local a = s.grid[i][j]; if a and a.name == 'Gardener' then ok = false end end
            if ok then lanes[#lanes + 1] = j end
        end
        local spots = {}
        for _, j in ipairs(lanes) do for i = 2, B.ROWS do if not s.walls[i][j] and not s.grid[i][j] then spots[#spots + 1] = {i, j} end end end
        if #spots == 0 then return false end
        local c = spots[math.random(#spots)]
        s.walls[c[1]][c[2]] = true
    elseif key == 'retreat' then
        if s.stage >= 3 then s.result = 'win'; return 'win' end
        s.stage = s.stage + 1; B.newStage(); return 'stage'
    elseif key == 'bomb' then
        if s.stage >= 2 then s.result = 'win'; return 'win' end
        s.stage = 3; B.newStage(); return 'stage'
    end
    return true
end

return B
