local json = require('stuff/dkjson/dkjson')

function createNewSave(saveNumber)
	local file = love.filesystem.newFile("data.txt")
    if file then
        file:open("w")  -- Open the file in write mode to create it
        file:close()  -- Close the file
    end
	data.gold = 100000
	data.gems = 10
	data.time = 0 -- work this out
	data.planet = 6
	data.name = 'testing'
	data.weaponChoose1 = ''
	data.weaponChoose2 = ''
	data.weaponChoose3 = ''
	data.currentLevel = ''
	data.weapons = {}
	data.weapons['AstroidRain'] = true
	data.weapons['PoisonArrow'] = true
	data.weapons['TripleThreat'] = true
	data.weapons['CosmicFire'] = true
	data.weapons['Astrobolt'] = true
	data.weapons['StarBlast'] = true
	data.weapons['LaserKill'] = true
	data.weapons['StellarBoost'] = true
	data.weapons['ThunderStrike'] = true
	data.weapons['BattleRam'] = true
	data.weapons['ElectroJolt'] = true
	data.weapons['DaggerThrow'] = true
	data.weapons['Hevalstruck'] = true
	data.weapons['RecursiveExplosion'] = true
	data.weapons['Dueltroid'] = true
	data.weapons['FreshStart'] = true
	data.weapons['SantaAxe'] = true
	data.weapons['Respawn'] = true
	data.weapons['Offguard'] = true
	data.weapons['LaserBeam'] = true
	data.weapons['MindBlast'] = true
	data.weapons['GrenadeLauncher'] = true
	data.weapons['Protected'] = true
	data.weapons['Hypnosis'] = true
	data.weapons['ShrinkRay'] = true
	data.weapons['GalacticBeam'] = true
	data.weapons['SolarFlare'] = true
	data.weapons['CometStrike'] = true
	data.weapons['DeathVirus'] = true
	data.weapons['VoidBurst'] = true
	data.weapons['CelestialDisruption'] = true
	data.weapons['QuantumFlux'] = true
	data.aliensKilled = 0
	data.wins = 0
	data.matchesPlayed = 0
	data.level = 27
	data.brightness = 100
	data.volume = 100
	data.sfx = 100
	data.walls = 1
	data.retreat = 2
	data.zap = 3
	data.bomb = 4
	data.doubleGold = 5
	data.teleporter = 6
	data.electricity = 7
	data.protection = 8
	data.aliensUnlocked = 16
	--data.profile = image
	data.items = {}
	data.items['Wall'] = true
	data.items['Retreat'] = true
	data.items['Zap'] = true
	data.items['Bomb'] = true
	data.items['DoubleGold'] = true
	data.items['Teleporter'] = true
	data.items['Electricity'] = true
	data.items['Protection'] = true

	if saveNumber == nil then saveNumber = 1 end
	data.saveNumber = saveNumber
	data.turn = true
end

function makeLevel()
	Levels = {}
	--these are stats about a certain level and we can store them as needed
	Levels['1-1'] = newLevelObject({joe = 45,gen57 = 73,president = 100,king = 1001, dj = 10001},{first = 15,second = 20, third = 30})
	Levels['1-2'] = newLevelObject({joe = 40,gen57 = 70,president = 100,king = 1000, dj = 1000},{first = 20,second = 25, third = 35})
	Levels['1-3'] = newLevelObject({joe = 30,gen57 = 70,president = 100,king = 1230, dj = 3140},{first = 21,second = 26, third = 36})
	Levels['1-4'] = newLevelObject({joe = 20,gen57 = 65,president = 95,king = 99, dj = 100},{first = 22,second = 27, third = 37})
	Levels['1-5'] = newLevelObject({joe = 10,gen57 = 45,president = 90,king = 97, dj = 100},{first = 23,second = 28, third = 38})
	Levels['1-6'] = newLevelObject({joe = 5,gen57 = 30,president = 75,king = 80, dj = 100},{first = 24,second = 29, third = 39})
	Levels['1-7'] = newLevelObject({joe = 3,gen57 = 23,president = 61,king = 84, dj = 100},{first = 25,second = 30, third = 40})
	Levels['1-8'] = newLevelObject({joe = 2,gen57 = 18,president = 54,king = 83, dj = 100},{first = 26,second = 31, third = 41})
	Levels['1-9'] = newLevelObject({joe = 1,gen57 = 15,president = 45,king = 80, dj = 100},{first = 27,second = 32, third = 42})
	Levels['1-10'] = newLevelObject({joe = -1,gen57 = 10,president = 35,king = 68, dj = 100},{first = 28,second = 33, third = 43})
	Levels['1-11'] = newLevelObject({joe = -1,gen57 = 5,president = 23,king = 55, dj = 100},{first = 29,second = 34, third = 44})
	--Levels['2-1'] = newLevelObject()
	--Levels['2-2'] = newLevelObject()
end

function newLevelObject(spawn,stage)
	local level = {}
	level.joe = spawn.joe
	level.gen57 = spawn.gen57
	level.president = spawn.president
	level.king = spawn.king
	level.dj = spawn.dj
	level.first = stage.first
	level.second = stage.second
	level.third = stage.third

	return level
end

function loadData()
    if love.filesystem.getInfo("data.txt") then
        local file = io.open("data.txt", "r")
        if file then
            local dataString = file:read("*a")
            file:close()
            data = json.decode(dataString)
        end
    else
        createNewSave()
        saveData()
    end
end


function makeWeapon(health,rarity,damageAll,damageLane,cooldown,damageTile,knockback,poison,damageRandLane,stun,name,aoe,damage,attack,specialEffect,image,stunDuration)
	local self = {}
	self.name = name
	self.damage = damage
	self.aoe = aoe
	self.cooldown = cooldown
	self.health = health
	self.rarity = rarity
	self.damageAll = damageAll
	self.damageLane = damageLane
	self.damageTile = damageTile
	self.knockback = knockback
	self.poison = poison
	self.damageRandLane = damageRandLane
	self.stun = stun
	self.attack = attack
	self.specialEffect = specialEffect
	self.image = image
	if stunDuration == nil then
		self.stunDuration = 0
	else
		self.stunDuration = stunDuration
	end
	return self
end

function weaponDictionary()
	Weapons = {}
	Weapons['AstroidRain'] = makeWeapon(3000,'common',250,0,2,0,0,0,0,0,'Astroid Rain','all',250,0,'Attakcs all aliens in all lanes',gWeapons['AsteroidRain']) --works
	Weapons['PoisonArrow'] = makeWeapon(3000,'common',0,150,1,0,0,75,0,0,'Posion Arrow','lane',150,0,'Attacks a whole lane and poisons all aliens',gWeapons['PoisonDart']) --works
	Weapons['TripleThreat'] = makeWeapon(3000,'common',0,0,0,275,0,0,0,0,'Triple Threat','tile',275,3,'Attacks 3 specifc tiles of your choosing',gWeapons['Targeted']) --works
	Weapons['CosmicFire'] = makeWeapon(3000,'common',0,250,0,0,0,0,0,0,'Cosmic Fire','lane',250,0,'Attacks all aliens in a lane',gWeapons['RazorThrower']) --works
	Weapons['Astrobolt'] = makeWeapon(3000,'common',0,100,0,0,0,0,0,2,'Astrobolt','lane',100,0,'Attacks all aliens in a lane and stuns the first two for one turn',gWeapons['Lightning'],1) -- works
	Weapons['StarBlast'] = makeWeapon(3000,'common',0,0,0,0,0,0,0,0,'Star Blast','tile',125,1,'Attacks in a cross shapped pattern from a center point of your choice',gWeapons['StarBlast']) -- works
	Weapons['LaserKill'] = makeWeapon(3000,'common',0,0,0,0,0,0,0,0,'Laser Kill','lane',0,0,'Kills all aliens below 375 health in a lane, if they are above 375 health, Laser Kill does no damage',gWeapons['LaserKill']) -- works
	Weapons['StellarBoost'] = makeWeapon(3000,'common',0,0,3,0,0,0,0,0,'Stellar Boost','buff',0,0,'Buffs all your weapons damage by 20 percent this turn and 10 percent for the next 2 turns',gWeapons['Buffer']) -- works

	Weapons['ThunderStrike'] = makeWeapon(6500,'rare',0,700,0,0,0,0,0,0,'Thunder Strike','lane',700,0,'Attacks a lane for 700 damage and has a 33% chance to stun the first alien, if sucsessful, the stun keeps going with the same chance',gWeapons['ElectricBall'])-- doen
	Weapons['BattleRam'] = makeWeapon(6500,'rare',0,0,0,0,1,0,0,0,'Battle Ram','lane',1050,0,'Attacks the first alien in a lane for 1400 damage and knocks them back 1 tile',gWeapons['SwordShield'])
	Weapons['ElectroJolt'] = makeWeapon(6500,'rare',0,0,2,0,0,0,0,10,'Electric Jolt','lane',0,0,'Stuns the whole lane for 1 turn',gWeapons['ElectroShock'],1) -- record
	Weapons['DaggerThrow'] =  makeWeapon(6500,'rare',0,900,0,0,0,0,0,0,'Dagger Throw','lane',900,0,'Does 900 damage to the lane',gWeapons['PiercingSword']) -- record
	Weapons['Hevalstruck'] = makeWeapon(6500,'rare',0,0,0,0,0,0,0,0,'Hevalstruck','lane',1200,0,'Does 1200 to the first alien in the lane, does double the damage if the alien is a hevalten',gWeapons['Hevalstruck']) -- record
	Weapons['RecursiveExplosion'] =  makeWeapon(6500,'rare',425,0,0,0,0,0,0,0,'Recursive Explosion','all',425,0,'Does 425 damage to all aliens',gWeapons['RecursiveExplosion']) -- record
	Weapons['Dueltroid'] = makeWeapon(6500,'rare',0,0,0,0,0,0,0,0,'Dueltroid','lane',0,0,'Randomly stuns either the first alien in a row for 4 turns or the first 2 aliens for 2 turns',gWeapons['Dueltroid']) -- record
	Weapons['FreshStart'] =  makeWeapon(6500,'rare',0,0,2,0,0,0,0,0,'Fresh Start','tile',0,1,'Sends a 3x3 box of aliens to the start',gWeapons['FreshStart']) -- record

	Weapons['SantaAxe'] = makeWeapon(10000,'scarce',0,2200,0,0,0,0,0,0,'Santa Axe','lane',2200,0,'Does 2200 damage to an entire lane',gWeapons['SantaAxe']) -- record
	Weapons['Respawn'] =  makeWeapon(10000,'scarce',0,0,2,0,0,0,0,0,'Respawn','lane',0,0,'Stops all aliens except Hevaltens from spawning in the lane you choose for 1 turn',gWeapons['Respawn']) -- record
	Weapons['Offguard'] =  makeWeapon(10000,'scarce',0,0,3,0,0,0,0,10,'Offguard','all',0,0,'Stuns the whole game for 1 turn',gWeapons['Offguard'],1) -- record
	Weapons['LaserBeam'] = makeWeapon(10000,'scarce',0,0,0,0,0,0,0,0,'Laser Beam','lane',6000,0,'Kills all aliens in a lane who have less than 6000 health',gWeapons['LaserDeath']) -- Record
	Weapons['MindBlast'] = makeWeapon(10000,'scarce',0,0,2,0,0,0,0,0,'Mind Blast','lane',7001,0,'Does 7001 damage to the first alien in a lane, if it survives then it will hypnotise that alien',gWeapons['MagicGun']) -- record
	Weapons['GrenadeLauncher'] =  makeWeapon(10000,'scarce',0,0,0,0,0,0,0,0,'Grenade Launcher','row',3950,0,'Does 3950 damage to the first and last row of aliens',gWeapons['Grenade']) -- record
	Weapons['WallBuilder'] = makeWeapon()
	Weapons['Hypnosis'] =  makeWeapon(10000,'scarce',0,0,3,0,0,0,0,0,'Hypnosis','all',0,0,'Hypnotises the first alien in all lanes',gWeapons['MindControl']) -- record

	Weapons['GalacticBeam'] =  makeWeapon(14500,'god',0,8000,0,0,0,0,0,0,'Galactic Beam','lane',8000,0,'Does 8000 damage a lane',gWeapons['RazorBlade']) -- record
	Weapons['SolarFlare'] =  makeWeapon(14500,'god',3000,0,0,0,0,0,0,0,'Solar Flare','all',3000,0,'Does 3000 damage to all aliens',gWeapons['Fireball']) -- record
	Weapons['CometStrike'] = makeWeapon(14500,'god',0,0,0,0,0,0,0,0,'Comet Strike','tile',8000,1,'Does 8000 damage to all aliens in a 3x3 box',gWeapons['Fireball']) -- record
	Weapons['DeathVirus'] = makeWeapon(14500,'god',0,0,3,0,0,0,0,0,'Death Virus','Random Lane',0,0,'Kills all aliens in a random lane',gWeapons['DeathVirus']) -- record
	Weapons['VoidBurst'] = makeWeapon(14500,'god',0,0,0,11000,0,0,0,0,'Void Burst','tile',11000,3,'Does 11000 to 3 tiles of your choice',gWeapons['Cannon']) -- record
	Weapons['CelestialDisruption'] = makeWeapon(14500,'god',0,0,0,0,0,0,0,0,'Celestial Disruption','lane',0,0,'Makes 4 non-hevaltens go to 1 health in that row',gWeapons['Wipeout']) -- record
	Weapons['QuantumFlux'] = makeWeapon(14500,'god',0,0,0,0,0,0,0,0,'Solar Flare','all',3000,0,'Does 3000 damage to all aliens',gWeapons['Fireball']) -- record
end


function saveData()
    local file = io.open("data.txt", "w")  -- Open the file in write mode
    if file then
        local dataString = json.encode(data)  -- Convert the data table to a JSON string
        file:write(dataString)  -- Write the data string to the file
        file:close()  -- Close the file
    end
end

function alienDictionary()
	Aliens = {}
	Aliens['Joe'] = makeAlien(500,1,false,false,'Joe')
	Aliens['Gen57'] = makeAlien(700,1,false,false,'Gen57')
	Aliens['President'] = makeAlien(1100,1,false,false,'President')
	Aliens['King'] = makeAlien(1550,1,false,false,'King')
	Aliens['DJ'] = makeAlien(2150,1,false,false,'DJ')
	Aliens['SpaceFence'] = makeAlien(2950,1,false,true,'SpaceFence') -- record
	Aliens['Spaceship'] = makeAlien(3000,1,false,true,'Spaceship') -- record
	Aliens['VRWorkout'] = makeAlien(3500,1,false,false,'VRWorkout') -- record
	Aliens['OldGranny'] = makeAlien(3700,1,false,true,'OldGranny') -- record
	Aliens['Albot'] = makeAlien(3000,1,true,false,'Albot') -- record
	Aliens['Jumper'] = makeAlien(4900,1,false,true,'Jumper') -- WALLS
	Aliens['Giant'] = makeAlien(12700,1,false,false,'Giant') -- recrd
	Aliens['Gardener'] = makeAlien(8200,1,false,false,'Gardener') -- walls can not be placed in the lane the gardener is in
	Aliens['Army'] = makeAlien(9400,1,true,false,'Army') -- record
	Aliens['Morpher'] = makeAlien(5700,1,false,true,'Morpher') -- record
	Aliens['Fusion'] = makeAlien(10000,1,false,true,'Fusion') -- record
	Aliens['CommonCrippler'] = makeAlien(13300,1,false,true,'CommonCrippler') -- record
	Aliens['Splashfest'] = makeAlien(15500,1,false,false,'Splashfest') -- done
	Aliens['Virus'] = makeAlien(17600,1,false,true,'Virus') -- record
	Aliens['Guardian'] = makeAlien(28800,1,true,false,'Guardian') -- record
	Aliens['DarkArts'] = makeAlien(20000,1,true,false,'DarkArts') -- record
	Aliens['Rare'] = makeAlien(23000,1,false,false,'Rare') -- record
	Aliens['Protected'] = makeAlien(26000,1,false,false,'Protected') -- record
	Aliens['Interdimentional'] = makeAlien(34200,1,false,false,'Interdimentional') -- record
	Aliens['Scarce'] = makeAlien(40000,1,true,false,'Scarce') -- record
	Aliens['TheHevalGod'] = makeAlien(46700,1,true,true,'TheHevalGod') -- record
	Aliens['GodOfSpace'] = makeAlien(50000,1,true,true,'GodOfSpace') -- all aliens are immune to every special effect, when spawned spawn 3 more aliens in the first 3 rows
	
	Aliensrand = {}
	Aliensrand[1] = Aliens['Joe']
	Aliensrand[2] = Aliens['Gen57']
	Aliensrand[3] = Aliens['President']
	Aliensrand[4] = Aliens['King']
	Aliensrand[5] = Aliens['DJ']
	Aliensrand[6] = Aliens['SpaceFence']
	Aliensrand[7] = Aliens['Spaceship']
	Aliensrand[8] = Aliens['VRWorkout']
	Aliensrand[9] = Aliens['OldGranny']
	Aliensrand[10] = Aliens['Albot']
	Aliensrand[11] = Aliens['Jumper']
	Aliensrand[12] = Aliens['Giant']
	Aliensrand[13] = Aliens['Gardener']
	Aliensrand[14] = Aliens['Army']
	Aliensrand[15] = Aliens['Morpher']
	Aliensrand[16] = Aliens['Fusion']
	Aliensrand[17] = Aliens['CommonCrippler']
	Aliensrand[18] = Aliens['Splashfest']
	Aliensrand[19] = Aliens['Virus']
	Aliensrand[20] = Aliens['Guardian']
	Aliensrand[21] = Aliens['DarkArts']
	Aliensrand[22] = Aliens['Rare']
	Aliensrand[23] = Aliens['Protected']
	Aliensrand[24] = Aliens['Interdimentional']
	Aliensrand[25] = Aliens['Scarce']
	Aliensrand[26] = Aliens['TheHevalGod']
	Aliensrand[27] = Aliens['GodOfSpace']
end

function makeAlien(health,speed, heval,ability,name)

	local temp = {}
	temp.health = health
	temp.speed = speed
	temp.hevalten = heval
	temp.ability = ability
	temp.name = name
	return temp
end
