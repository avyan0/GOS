local json = require('stuff/dkjson/dkjson')
alienNames = {
	"Joe",
	"Gen57",
	"President",
	"King",
	"DJ",
	"SpaceFence",
	"Spaceship",
	"VRWorkout",
	"OldGranny",
	"Albot",
	"Jumper",
	"Giant",
	"Gardener",
	"Army",
	"Morpher",
	"Fusion",
	"CommonCrippler",
	"Splashfest",
	"Virus",
	"Guardian",
	"DarkArts",
	"Rare",
	"Protected",
	"Interdimentional",
	"Scarce",
	"TheHevalGod",
	"GodOfSpace"
}
function createNewSave(saveNumber)
	local file = love.filesystem.newFile("data.txt")
    if file then
        file:open("w")  -- Open the file in write mode to create it
        file:close()  -- Close the file
    end
	local startingWeapon = math.random(1,7)
	local startingWeapon1 = math.random(1,7)
	local startingWeapon2 = math.random(1,7)
	while startingWeapon == startingWeapon1 or startingWeapon ~= startingWeapon2 or startingWeapon2 ~= startingWeapon1 do
		startingWeapon = math.random(1,7)
		startingWeapon1 = math.random(1,7)
		startingWeapon2 = math.random(1,7)
	end
	data.gold = 0
	data.gems = 0
	data.time = '00:00'
	data.hours = 0
	data.mins = 0
	data.planet = 6
	data.name = 'testing'
	data.weaponChoose1 = ''
	data.weaponChoose2 = ''
	data.weaponChoose3 = ''
	data.currentLevel = ''
	data.weapons = {}
	if startingWeapon ==1 or startingWeapon1 ==1 or startingWeapon2 ==1 then
		data.weapons['AstroidRain'] = true
	else
		data.weapons['AstroidRain'] = false
	end
	if startingWeapon ==2 or startingWeapon1 ==2 or startingWeapon2 ==2 then
		data.weapons['PoisonArrow'] = true
	else
		data.weapons['PoisonArrow'] = false
	end
	if startingWeapon ==3 or startingWeapon1 ==3 or startingWeapon2 ==3 then
	data.weapons['TripleThreat'] = true
	else
		data.weapons['TripleThreat'] = false
	end
	if startingWeapon ==4 or startingWeapon1 ==4 or startingWeapon2 ==4 then
	data.weapons['CosmicFire'] = true
	else
		data.weapons['CosmicFire'] = false
	end
	if startingWeapon ==5 or startingWeapon1 ==5 or startingWeapon2 ==5 then
	data.weapons['Astrobolt'] = true
	else
		data.weapons['Astrobolt'] = false
	end
	if startingWeapon ==6 or startingWeapon1 ==6 or startingWeapon2 ==6 then
	data.weapons['StarBlast'] = true
	else
		data.weapons['StarBlast'] = false
	end
	if startingWeapon ==7 or startingWeapon1 ==7 or startingWeapon2 ==7 then
	data.weapons['LaserKill'] = true
	else
		data.weapons['LaserKill'] = false
	end


	data.weapons['StellarBoost'] = false
	data.weapons['ThunderStrike'] = false
	data.weapons['BattleRam'] = false
	data.weapons['ElectroJolt'] = false
	data.weapons['DaggerThrow'] = false
	data.weapons['Hevalstruck'] = false
	data.weapons['RecursiveExplosion'] = false
	data.weapons['Dueltroid'] = false
	data.weapons['FreshStart'] = false
	data.weapons['SantaAxe'] = false
	data.weapons['Respawn'] = false
	data.weapons['Offguard'] = false
	data.weapons['LaserBeam'] = false
	data.weapons['MindBlast'] = false
	data.weapons['GrenadeLauncher'] = false
	data.weapons['Protected'] = false
	data.weapons['Hypnosis'] = false
	data.weapons['ShrinkRay'] = false
	data.weapons['GalacticBeam'] = false
	data.weapons['SolarFlare'] = false
	data.weapons['CometStrike'] = false
	data.weapons['DeathVirus'] = false
	data.weapons['VoidBurst'] = false
	data.weapons['CelestialDisruption'] = false
	data.weapons['QuantumFlux'] = false
	data.aliensKilled = 0
	data.wins = 0
	data.matchesPlayed = 0
	data.level = 1
	data.brightness = 100
	data.volume = 100
	data.sfx = 100
	data.walls = 0
	data.retreat = 0
	data.zap = 0
	data.bomb = 0
	data.doubleGold = 0
	data.teleporter = 0
	data.electricity = 0
	data.protection = 0
	data.aliensUnlocked = 2
	data.goldBuff = 1
	data.profile = nil
	data.items = {}
	data.items['Wall'] = false
	data.items['Retreat'] = false
	data.items['Zap'] = false
	data.items['Bomb'] = false
	data.items['DoubleGold'] = false
	data.items['Teleporter'] = false
	data.items['Electricity'] = false
	data.items['Protection'] = false

	if saveNumber == nil then saveNumber = 1 end
	data.saveNumber = saveNumber
	data.turn = true
end

function makeLevel()
	Levels = {}
	Levels['1-1'] = newLevelObject({Joe = 80,Gen57 = 100},{first = 15,second = 20, third = 30})
	Levels['1-2'] = newLevelObject({Joe = 76,Gen57 = 100},{first = 15,second = 20, third = 30})
	Levels['1-3'] = newLevelObject({Joe = 72,Gen57 = 100},{first = 16,second = 21, third = 31})
	Levels['1-4'] = newLevelObject({Joe = 68,Gen57 = 100},{first = 16,second = 21, third = 31})
	Levels['1-5'] = newLevelObject({Joe = 64,Gen57 = 100},{first = 17,second = 22, third = 32 })
	Levels['1-6'] = newLevelObject({Joe = 60,Gen57 = 100},{first = 17,second = 22, third = 32})
	Levels['1-7'] = newLevelObject({Joe = 55,Gen57 = 97,President = 100},{first = 18,second = 23, third = 33}) 
	Levels['1-8'] = newLevelObject({Joe = 50,Gen57 = 94,President = 100},{first = 18,second = 23, third = 33})
	Levels['1-9'] = newLevelObject({Joe = 45,Gen57 = 91,President = 100},{first = 19,second = 24, third = 34})
	Levels['1-10'] = newLevelObject({Joe = 40,Gen57 = 88,President = 100},{first = 19,second = 24, third = 34})
	Levels['1-11'] = newLevelObject({Joe = 35,Gen57 = 85,President = 100},{first = 20,second = 25, third = 35})
	Levels['1-12'] = newLevelObject({Joe = 30,Gen57 = 82,President = 100},{first = 20,second = 25, third = 35})
	Levels['1-13'] = newLevelObject({Joe = 25,Gen57 = 79,President = 100},{first = 21,second = 26, third = 36})
	Levels['1-14'] = newLevelObject({Joe = 15,Gen57 = 71,President = 96,King = 100},{first = 21,second = 26, third = 36})
	Levels['1-15'] = newLevelObject({Joe = 10,Gen57 = 63,President = 92,King = 100},{first = 22,second = 27, third = 37})
	Levels['1-16'] = newLevelObject({Joe = 5,Gen57 = 55,President = 88,King = 100},{first = 22,second = 27, third = 37})
	Levels['1-17'] = newLevelObject({Joe = 4,Gen57 = 50,President = 85,King = 100},{first = 23,second = 28, third = 38})
	Levels['1-18'] = newLevelObject({Joe = 3,Gen57 = 45,President = 82,King = 100},{first = 23,second = 28, third = 38})
	Levels['1-19'] = newLevelObject({Joe = 2,Gen57 = 40,President = 79,King = 100},{first = 24,second = 29, third = 39})
	Levels['1-20'] = newLevelObject({Joe = 1,Gen57 = 35,President = 76,King = 100},{first = 24,second = 29, third = 39})
	Levels['1-21'] = newLevelObject({Gen57 = 28,President = 71,King = 96, DJ = 100},{first = 25,second = 30, third = 40})
	Levels['1-22'] = newLevelObject({Gen57 = 22,President = 66,King = 93, DJ = 100},{first = 25,second = 30, third = 40})
	Levels['1-23'] = newLevelObject({Gen57 = 17,President = 59,King = 90, DJ = 100},{first = 26,second = 31, third = 41})
	Levels['1-24'] = newLevelObject({Gen57 = 12,President = 52,King = 87, DJ = 100},{first = 26,second = 31, third = 41})
	Levels['1-25'] = newLevelObject({Gen57 = 7,President = 44,King = 84, DJ = 100},{first = 27,second = 32, third = 42})
	Levels['1-26'] = newLevelObject({Gen57 = 3,President = 37,King = 80, DJ = 100},{first = 27,second = 32, third = 42})
	Levels['1-27'] = newLevelObject({Gen57 = 1,President = 32,King = 76, DJ = 100},{first = 28,second = 33, third = 43})
	Levels['1-28'] = newLevelObject({President = 25,King = 71, DJ = 97,SpaceFence = 100},{first = 28,second = 33, third = 43})
	Levels['1-29'] = newLevelObject({President = 19,King = 67, DJ = 95,SpaceFence = 100},{first = 29,second = 34, third = 44})
	Levels['1-30'] = newLevelObject({President = 14,King = 61, DJ = 92,SpaceFence = 100},{first = 31,second = 36, third = 46})

	Levels['2-1'] = newLevelObject({President = 9,King = 54, DJ = 89,SpaceFence = 100},{first = 20,second = 25, third = 35})
	Levels['2-2'] = newLevelObject({President = 4,King = 46, DJ = 86,SpaceFence = 100},{first = 20,second = 25, third = 35})
	Levels['2-3'] = newLevelObject({President = 3,King = 41, DJ = 84,SpaceFence = 100},{first = 21,second = 26, third = 36})
	Levels['2-4'] = newLevelObject({President = 1,King = 35, DJ = 82,SpaceFence = 100},{first = 21,second = 26, third = 36})
	Levels['2-5'] = newLevelObject({King = 28, DJ = 77,SpaceFence = 98,Spaceship = 100},{first = 22,second = 27, third = 37})
	Levels['2-6'] = newLevelObject({King = 22, DJ = 69,SpaceFence = 94,Spaceship = 100},{first = 22,second = 27, third = 37})
	Levels['2-7'] = newLevelObject({King = 17, DJ = 62,SpaceFence = 91,Spaceship = 100},{first = 23,second = 28, third = 38})
	Levels['2-8'] = newLevelObject({King = 12, DJ = 54,SpaceFence = 87,Spaceship = 100},{first = 23,second = 28, third = 38})
	Levels['2-9'] = newLevelObject({King = 7, DJ = 46,SpaceFence = 83,Spaceship = 100},{first = 24,second = 29, third = 39})
	Levels['2-10'] = newLevelObject({King = 5, DJ = 41,SpaceFence = 81,Spaceship = 100},{first = 24,second = 29, third = 39})
	Levels['2-11'] = newLevelObject({King = 3, DJ = 36,SpaceFence = 79,Spaceship = 100},{first = 25,second = 30, third = 40})
	Levels['2-12'] = newLevelObject({King = 1, DJ = 28,SpaceFence = 75,Spaceship = 98,VRWorkout = 100},{first = 25,second = 30, third = 40})
	Levels['2-13'] = newLevelObject({DJ = 22,SpaceFence = 71,Spaceship = 96,VRWorkout = 100},{first = 26,second = 31, third = 41})
	Levels['2-14'] = newLevelObject({DJ = 17,SpaceFence = 67,Spaceship = 94,VRWorkout = 100},{first = 26,second = 31, third = 41})
	Levels['2-15'] = newLevelObject({DJ = 12,SpaceFence = 60,Spaceship = 90,VRWorkout = 100},{first = 27,second = 32, third = 42})
	Levels['2-16'] = newLevelObject({DJ = 7,SpaceFence = 53,Spaceship = 86,VRWorkout = 100},{first = 27,second = 32, third = 42})
	Levels['2-17'] = newLevelObject({DJ = 5,SpaceFence = 48,Spaceship = 84,VRWorkout = 100},{first = 28,second = 33, third = 43})
	Levels['2-18'] = newLevelObject({DJ = 3,SpaceFence = 43,Spaceship = 81,VRWorkout = 100},{first = 28,second = 33, third = 43})
	Levels['2-19'] = newLevelObject({DJ = 1,SpaceFence = 35,Spaceship = 76,VRWorkout = 97,OldGranny = 100},{first = 29,second = 34, third = 44})
	Levels['2-20'] = newLevelObject({SpaceFence = 28,Spaceship = 72,VRWorkout = 95,OldGranny = 100},{first = 29,second = 34, third = 44})
	Levels['2-21'] = newLevelObject({SpaceFence = 23,Spaceship = 69,VRWorkout = 93,OldGranny = 100},{first = 30,second = 35, third = 45})
	Levels['2-22'] = newLevelObject({SpaceFence = 18,Spaceship = 66,VRWorkout = 91,OldGranny = 100},{first = 30,second = 35, third = 45})
	Levels['2-23'] = newLevelObject({SpaceFence = 13,Spaceship = 63,VRWorkout = 89,OldGranny = 100},{first = 31,second = 36, third = 46})
	Levels['2-24'] = newLevelObject({SpaceFence = 8,Spaceship = 55,VRWorkout = 86,OldGranny = 100},{first = 31,second = 36, third = 46})
	Levels['2-25'] = newLevelObject({SpaceFence = 3,Spaceship = 46,VRWorkout = 82,OldGranny = 100},{first = 32,second = 37, third = 47})
	Levels['2-26'] = newLevelObject({SpaceFence = 1,Spaceship = 38,VRWorkout = 77,OldGranny = 97, Albot = 100},{first = 32,second = 37, third = 47})
	Levels['2-27'] = newLevelObject({Spaceship = 31,VRWorkout = 73,OldGranny = 95, Albot = 100},{first = 33,second = 38, third = 48})
	Levels['2-28'] = newLevelObject({Spaceship = 26,VRWorkout = 71,OldGranny = 94, Albot = 100},{first = 33,second = 38, third = 48})
	Levels['2-29'] = newLevelObject({Spaceship = 21,VRWorkout = 69,OldGranny = 93, Albot = 100},{first = 34,second = 39, third = 49})
	Levels['2-30'] = newLevelObject({Spaceship = 16,VRWorkout = 66,OldGranny = 92, Albot = 100},{first = 36,second = 41, third = 51})

	Levels['3-1'] = newLevelObject({Spaceship = 11,VRWorkout = 57,OldGranny = 88, Albot = 100},{first = 25,second = 30, third = 40})
	Levels['3-2'] = newLevelObject({Spaceship = 6,VRWorkout = 49,OldGranny = 83, Albot = 100},{first = 25,second = 30, third = 40})
	Levels['3-3'] = newLevelObject({Spaceship = 3,VRWorkout = 40,OldGranny = 77, Albot = 97, Jumper = 100},{first = 26,second = 31, third = 41})
	Levels['3-4'] = newLevelObject({Spaceship = 1,VRWorkout = 32,OldGranny = 72, Albot = 95, Jumper = 100},{first = 26,second = 31, third = 41})
	Levels['3-5'] = newLevelObject({VRWorkout = 26,OldGranny = 69, Albot = 94, Jumper = 100},{first = 27,second = 32, third = 42})
	Levels['3-6'] = newLevelObject({VRWorkout = 21,OldGranny = 67, Albot = 93, Jumper = 100},{first = 27,second = 32, third = 42})
	Levels['3-7'] = newLevelObject({VRWorkout = 16,OldGranny = 64, Albot = 92, Jumper = 100},{first = 28,second = 33, third = 43})
	Levels['3-8'] = newLevelObject({VRWorkout = 11,OldGranny = 61, Albot = 90, Jumper = 100},{first = 28,second = 33, third = 43})
	Levels['3-9'] = newLevelObject({VRWorkout = 6,OldGranny = 51, Albot = 85, Jumper = 100},{first = 29,second = 34, third = 44})
	Levels['3-10'] = newLevelObject({VRWorkout = 3,OldGranny = 42, Albot = 79, Jumper = 97,Giant = 100},{first = 29,second = 34, third = 44})
	Levels['3-11'] = newLevelObject({VRWorkout = 1,OldGranny = 34, Albot = 74, Jumper = 95,Giant = 100},{first = 30,second = 35, third = 45})
	Levels['3-12'] = newLevelObject({OldGranny = 28, Albot = 70, Jumper = 93,Giant = 100},{first = 30,second = 35, third = 45})
	Levels['3-13'] = newLevelObject({OldGranny = 23, Albot = 67, Jumper = 92,Giant = 100},{first = 31,second = 36, third = 46})
	Levels['3-14'] = newLevelObject({OldGranny = 18, Albot = 64, Jumper = 91,Giant = 100},{first = 31,second = 36, third = 46})
	Levels['3-15'] = newLevelObject({OldGranny = 13, Albot = 61, Jumper = 90,Giant = 100},{first = 32,second = 37, third = 47})
	Levels['3-16'] = newLevelObject({OldGranny = 8, Albot = 58, Jumper = 89,Giant = 100},{first = 32,second = 37, third = 47})
	Levels['3-17'] = newLevelObject({OldGranny = 3, Albot = 50, Jumper = 84,Giant = 97,Gardener=100},{first = 33,second = 38, third = 48})
	Levels['3-18'] = newLevelObject({OldGranny = 1, Albot = 42, Jumper = 79,Giant = 95,Gardener=100},{first = 33,second = 38, third = 48})
	Levels['3-19'] = newLevelObject({ Albot = 35, Jumper = 75,Giant = 93,Gardener=100},{first = 34,second = 39, third = 49})
	Levels['3-20'] = newLevelObject({ Albot = 30, Jumper = 73,Giant = 92,Gardener=100},{first = 34,second = 39, third = 49})
	Levels['3-21'] = newLevelObject({ Albot = 25, Jumper = 71,Giant = 91,Gardener=100},{first = 35,second = 40, third = 50})
	Levels['3-22'] = newLevelObject({ Albot = 20, Jumper = 69,Giant = 90,Gardener=100},{first = 35,second = 40, third = 50})
	Levels['3-23'] = newLevelObject({ Albot = 15, Jumper = 65,Giant = 88,Gardener=100},{first = 36,second = 41, third = 51})
	Levels['3-24'] = newLevelObject({ Albot = 10, Jumper = 57,Giant = 83,Gardener=97,Army=100},{first = 36,second = 41, third = 51})
	Levels['3-25'] = newLevelObject({ Albot = 5, Jumper = 49,Giant = 78,Gardener=94,Army=100},{first = 37,second = 42, third = 52})
	Levels['3-26'] = newLevelObject({Jumper = 41,Giant = 73,Gardener=91,Army=100},{first = 37,second = 42, third = 52})
	Levels['3-27'] = newLevelObject({Jumper = 35,Giant = 70,Gardener=89,Army=100},{first = 38,second = 43, third = 53})
	Levels['3-28'] = newLevelObject({Jumper = 29,Giant = 67,Gardener=88,Army=100},{first = 38,second = 43, third = 53})
	Levels['3-29'] = newLevelObject({Jumper = 24,Giant = 64,Gardener=87,Army=100},{first = 39,second = 44, third = 54})
	Levels['3-30'] = newLevelObject({Jumper = 19,Giant = 62,Gardener=95,Army=100},{first = 41,second = 46, third = 56})
	
	Levels['4-1'] = newLevelObject({Jumper = 14,Giant = 58,Gardener=82,Army=97,Morpher=100},{first = 30,second = 35, third = 45})
	Levels['4-2'] = newLevelObject({Jumper = 9,Giant = 55,Gardener=80,Army=96,Morpher=100},{first = 30,second = 35, third = 45})
	Levels['4-3'] = newLevelObject({Jumper = 4,Giant = 52,Gardener=78,Army=95,Morpher=100},{first = 31,second = 36, third = 46})
	Levels['4-4'] = newLevelObject({Giant = 50,Gardener=77,Army=95,Morpher=100},{first = 31,second = 36, third = 46})
	Levels['4-5'] = newLevelObject({Giant = 44,Gardener=74,Army=94,Morpher=100},{first = 32,second = 37, third = 47})
	Levels['4-6'] = newLevelObject({Giant = 38,Gardener=71,Army=93,Morpher=100},{first = 32,second = 37, third = 47})
	Levels['4-7'] = newLevelObject({Giant = 32,Gardener=68,Army=91,Morpher=100},{first = 33,second = 38, third = 48})
	Levels['4-8'] = newLevelObject({Giant = 26,Gardener=63,Army=87,Morpher=97,Fusion=100},{first = 33,second = 38, third = 48})
	Levels['4-9'] = newLevelObject({Giant = 20,Gardener=60,Army=85,Morpher=96,Fusion=100},{first = 34,second = 39, third = 49})
	Levels['4-10'] = newLevelObject({Giant = 14,Gardener=57,Army=83,Morpher=95,Fusion=100},{first = 34,second = 39, third = 49})
	Levels['4-11'] = newLevelObject({Giant = 8,Gardener=53,Army=80,Morpher=93,Fusion=100},{first = 35,second = 40, third = 50})
	Levels['4-12'] = newLevelObject({Giant = 4,Gardener=43,Army=74,Morpher=90,Fusion=100},{first = 35,second = 40, third = 50})
	Levels['4-13'] = newLevelObject({Gardener=33,Army=68,Morpher=87,Fusion=100},{first = 36,second = 41, third = 51})
	Levels['4-14'] = newLevelObject({Gardener=27,Army=63,Morpher=83,Fusion=97,CommonCrippler=100},{first = 36,second = 41, third = 51})
	Levels['4-15'] = newLevelObject({Gardener=21,Army=59,Morpher=80,Fusion=95,CommonCrippler=100},{first = 37,second = 42, third = 52})
	Levels['4-16'] = newLevelObject({Gardener=15,Army=56,Morpher=78,Fusion=94,CommonCrippler=100},{first = 37,second = 42, third = 52})
	Levels['4-17'] = newLevelObject({Gardener=9,Army=53,Morpher=76,Fusion=93,CommonCrippler=100},{first = 38,second = 43, third = 53})
	Levels['4-18'] = newLevelObject({Gardener=3,Army=48,Morpher=73,Fusion=91,CommonCrippler=100},{first = 38,second = 43, third = 53})
	Levels['4-19'] = newLevelObject({Army=39,Morpher=67,Fusion=88,CommonCrippler=100},{first = 39,second = 44, third = 54})
	Levels['4-20'] = newLevelObject({Army=33,Morpher=62,Fusion=84,CommonCrippler=97,Splashfest=100},{first = 39,second = 44, third = 54})
	Levels['4-21'] = newLevelObject({Army=27,Morpher=58,Fusion=81,CommonCrippler=96,Splashfest=100},{first = 40,second = 45, third = 55})
	Levels['4-22'] = newLevelObject({Army=21,Morpher=55,Fusion=79,CommonCrippler=94,Splashfest=100},{first = 40,second = 45, third = 55})
	Levels['4-23'] = newLevelObject({Army=15,Morpher=52,Fusion=77,CommonCrippler=93,Splashfest=100},{first = 41,second = 46, third = 56})
	Levels['4-24'] = newLevelObject({Army=9,Morpher=49,Fusion=75,CommonCrippler=92,Splashfest=100},{first = 41,second = 46, third = 56})
	Levels['4-25'] = newLevelObject({Army=3,Morpher=48,Fusion=74,CommonCrippler=91,Splashfest=100},{first = 42,second = 47, third = 57})
	Levels['4-26'] = newLevelObject({Morpher=38,Fusion=67,CommonCrippler=86,Splashfest=97,Virus=100},{first = 42,second = 47, third = 57})
	Levels['4-27'] = newLevelObject({Morpher=31,Fusion=63,CommonCrippler=83,Splashfest=95,Virus=100},{first = 43,second = 48, third = 58})
	Levels['4-28'] = newLevelObject({Morpher=25,Fusion=60,CommonCrippler=81,Splashfest=94,Virus=100},{first = 43,second = 48, third = 58})
	Levels['4-40'] = newLevelObject({Morpher=19,Fusion=57,CommonCrippler=79,Splashfest=93,Virus=100},{first = 44,second = 49, third = 59})
	Levels['4-30'] = newLevelObject({Morpher=13,Fusion=54,CommonCrippler=77,Splashfest=92,Virus=100},{first = 46,second = 51, third = 61})

	Levels['5-1'] = newLevelObject({Morpher=7,Fusion=51,CommonCrippler=75,Splashfest=91,Virus=100},{first = 35,second = 40, third = 50})
	Levels['5-2'] = newLevelObject({Fusion=40,CommonCrippler=67,Splashfest=86,Virus=97,Guardian=100},{first = 35,second = 40, third = 50})
	Levels['5-3'] = newLevelObject({Fusion=33,CommonCrippler=63,Splashfest=83,Virus=95,Guardian=100},{first = 36,second = 41, third = 51})
	Levels['5-4'] = newLevelObject({Fusion=26,CommonCrippler=60,Splashfest=81,Virus=94,Guardian=100},{first = 36,second = 41, third = 51})
	Levels['5-5'] = newLevelObject({Fusion=20,CommonCrippler=57,Splashfest=79,Virus=93,Guardian=100},{first = 37,second = 42, third = 52})
	Levels['5-6'] = newLevelObject({Fusion=14,CommonCrippler=54,Splashfest=77,Virus=92,Guardian=100},{first = 37,second = 42, third = 52})
	Levels['5-7'] = newLevelObject({Fusion=8,CommonCrippler=51,Splashfest=75,Virus=91,Guardian=100},{first = 38,second = 43, third = 53})
	Levels['5-8'] = newLevelObject({CommonCrippler=44,Splashfest=70,Virus=87,Guardian=97,DarkArts=100},{first = 38,second = 43, third = 53})
	Levels['5-9'] = newLevelObject({CommonCrippler=37,Splashfest=66,Virus=84,Guardian=95,DarkArts=100},{first = 39,second = 44, third = 54})
	Levels['5-10'] = newLevelObject({CommonCrippler=30,Splashfest=62,Virus=81,Guardian=94,DarkArts=100},{first = 39,second = 44, third = 54})
	Levels['5-11'] = newLevelObject({CommonCrippler=23,Splashfest=58,Virus=79,Guardian=93,DarkArts=100},{first = 40,second = 45, third = 55})
	Levels['5-12'] = newLevelObject({CommonCrippler=17,Splashfest=55,Virus=77,Guardian=92,DarkArts=100},{first = 40,second = 45, third = 55})
	Levels['5-13'] = newLevelObject({CommonCrippler=11,Splashfest=52,Virus=75,Guardian=91,DarkArts=100},{first = 41,second = 46, third = 56})
	Levels['5-14'] = newLevelObject({CommonCrippler=5,Splashfest=48,Virus=72,Guardian=88,DarkArts=97,Rare=100},{first = 41,second = 46, third = 56})
	Levels['5-15'] = newLevelObject({Splashfest=39,Virus=66,Guardian=84,DarkArts=95,Rare=100},{first = 42,second = 47, third = 57})
	Levels['5-16'] = newLevelObject({Splashfest=32,Virus=61,Guardian=81,DarkArts=94,Rare=100},{first = 42,second = 47, third = 57})
	Levels['5-17'] = newLevelObject({Splashfest=25,Virus=56,Guardian=77,DarkArts=92,Rare=100},{first = 43,second = 48, third = 58})
	Levels['5-18'] = newLevelObject({Splashfest=18,Virus=51,Guardian=74,DarkArts=90,Rare=100},{first = 43,second = 48, third = 58})
	Levels['5-19'] = newLevelObject({Splashfest=11,Virus=46,Guardian=71,DarkArts=89,Rare=100},{first = 44,second = 49, third = 59})
	Levels['5-20'] = newLevelObject({Splashfest=5,Virus=42,Guardian=68,DarkArts=86,Rare=97,Protected=100},{first = 44,second = 49, third = 59})
	Levels['5-21'] = newLevelObject({Virus=40,Guardian=67,DarkArts=86,Rare=97,Protected=100},{first = 45,second = 50, third = 60})
	Levels['5-22'] = newLevelObject({Virus=43,Guardian=69,DarkArts=87,Rare=97,Protected=100},{first = 45,second = 50, third = 60})
	Levels['5-23'] = newLevelObject({Virus=36,Guardian=64,DarkArts=84,Rare=96,Protected=100},{first = 46,second = 51, third = 61})
	Levels['5-24'] = newLevelObject({Virus=29,Guardian=60,DarkArts=82,Rare=85,Protected=100},{first = 46,second = 51, third = 61})
	Levels['5-25'] = newLevelObject({Virus=22,Guardian=56,DarkArts=80,Rare=94,Protected=100},{first = 47,second = 52, third = 62})
	Levels['5-26'] = newLevelObject({Virus=15,Guardian=50,DarkArts=75,Rare=90,Protected=97,Interdimentional=100},{first = 47,second = 52, third = 62})
	Levels['5-27'] = newLevelObject({Virus=8,Guardian=47,DarkArts=73,Rare=89,Protected=97,Interdimentional=100},{first = 48,second = 53, third = 63})
	Levels['5-28'] = newLevelObject({Guardian=42,DarkArts=69,Rare=86,Protected=95,Interdimentional=100},{first = 48,second = 53, third = 63})
	Levels['5-29'] = newLevelObject({Guardian=35,DarkArts=64,Rare=83,Protected=94,Interdimentional=100},{first = 49,second = 54, third = 64})
	Levels['5-30'] = newLevelObject({Guardian=28,DarkArts=60,Rare=80,Protected=93,Interdimentional=100},{first = 51,second = 56, third = 66})

	Levels['6-1'] = newLevelObject({Guardian=21,DarkArts=56,Rare=77,Protected=91,Interdimentional=100},{first = 40,second = 45, third = 55})
	Levels['6-2'] = newLevelObject({Guardian=14,DarkArts=50,Rare=72,Protected=87,Interdimentional=97,Scarce=100},{first = 40,second = 45, third = 55})
	Levels['6-3'] = newLevelObject({Guardian=7,DarkArts=46,Rare=69,Protected=85,Interdimentional=96,Scarce=100},{first = 41,second = 46, third = 56})
	Levels['6-4'] = newLevelObject({DarkArts=42,Rare=66,Protected=83,Interdimentional=95,Scarce=100},{first = 41,second = 46, third = 56})
	Levels['6-5'] = newLevelObject({DarkArts=34,Rare=60,Protected=79,Interdimentional=93,Scarce=100},{first = 42,second = 47, third = 57})
	Levels['6-6'] = newLevelObject({DarkArts=26,Rare=55,Protected=76,Interdimentional=92,Scarce=100},{first = 42,second = 47, third = 57})
	Levels['6-7'] = newLevelObject({DarkArts=19,Rare=51,Protected=74,Interdimentional=91,Scarce=100},{first = 43,second = 48, third = 58})
	Levels['6-8'] = newLevelObject({DarkArts=12,Rare=47,Protected=71,Interdimentional=88,Scarce=97,TheHevalGod=100},{first = 43,second = 48, third = 58})
	Levels['6-9'] = newLevelObject({DarkArts=5,Rare=44,Protected=69,Interdimentional=87,Scarce=97,TheHevalGod=100},{first = 44,second = 49, third = 59})
	Levels['6-10'] = newLevelObject({Rare=42,Protected=67,Interdimentional=85,Scarce=95,TheHevalGod=100},{first = 44,second = 49, third = 59})
	Levels['6-11'] = newLevelObject({Rare=34,Protected=61,Interdimentional=81,Scarce=93,TheHevalGod=100},{first = 45,second = 50, third = 60})
	Levels['6-12'] = newLevelObject({Rare=26,Protected=57,Interdimentional=79,Scarce=92,TheHevalGod=100},{first = 45,second = 50, third = 60})
	Levels['6-13'] = newLevelObject({Rare=18,Protected=53,Interdimentional=77,Scarce=91,TheHevalGod=100},{first = 46,second = 51, third = 61})
	Levels['6-14'] = newLevelObject({Rare=10,Protected=47,Interdimentional=72,Scarce=87,TheHevalGod=97,GodOfSpace=100},{first = 46,second = 51, third = 61})
	Levels['6-15'] = newLevelObject({Protected=41,Interdimentional=68,Scarce=84,TheHevalGod=95,GodOfSpace=100},{first = 47,second = 52, third = 62})
	Levels['6-16'] = newLevelObject({Protected=33,Interdimentional=62,Scarce=80,TheHevalGod=93,GodOfSpace=100},{first = 47,second = 52, third = 62})
	Levels['6-17'] = newLevelObject({Protected=25,Interdimentional=56,Scarce=76,TheHevalGod=91,GodOfSpace=100},{first = 48,second = 53, third = 63})
	Levels['6-18'] = newLevelObject({Protected=17,Interdimentional=50,Scarce=72,TheHevalGod=89,GodOfSpace=100},{first = 48,second = 53, third = 63})
	Levels['6-19'] = newLevelObject({Protected=9,Interdimentional=44,Scarce=68,TheHevalGod=87,GodOfSpace=100},{first = 49,second = 54, third = 64})
	Levels['6-20'] = newLevelObject({Protected=1,Interdimentional=38,Scarce=64,TheHevalGod=85,GodOfSpace=100},{first = 49,second = 54, third = 64})
	Levels['6-21'] = newLevelObject({Interdimentional=34,Scarce=60,TheHevalGod=82,GodOfSpace=100},{first = 50,second = 55, third = 65})
	Levels['6-22'] = newLevelObject({Interdimentional=27,Scarce=55,TheHevalGod=87,GodOfSpace=100},{first = 50,second = 55, third = 65})
	Levels['6-23'] = newLevelObject({Interdimentional=20,Scarce=50,TheHevalGod=76,GodOfSpace=100},{first = 51,second = 56, third = 66})
	Levels['6-24'] = newLevelObject({Interdimentional=16,Scarce=47,TheHevalGod=75,GodOfSpace=100},{first = 51,second = 56, third = 66})
	Levels['6-25'] = newLevelObject({Joe=1,Gen57=2,President=3,King=4,DJ=5,SpaceFence=7,Spaceship=9,VRWorkout=11,OldGranny=13,Albot=15,Jumper=18,Giant=21,Gardener=24,Army=27,Morpher=30,Fusion=34,CommonCrippler=38,Splashfest=42,Virus=47,Guardian=52,DarkArts=57,Rare=63,Protected=69,Interdimentional=75,Scarce=82,TheHevalGod=90,GodOfSpace=100},{first = 52,second = 57, third = 67})
	Levels['6-26'] = newLevelObject({Joe=1,Gen57=2,President=3,King=4,DJ=5,SpaceFence=7,Spaceship=9,VRWorkout=11,OldGranny=13,Albot=15,Jumper=18,Giant=21,Gardener=24,Army=27,Morpher=30,Fusion=34,CommonCrippler=38,Splashfest=42,Virus=47,Guardian=52,DarkArts=57,Rare=63,Protected=69,Interdimentional=75,Scarce=82,TheHevalGod=90,GodOfSpace=100},{first = 52,second = 57, third = 67})
	Levels['6-27'] = newLevelObject({Joe=1,Gen57=2,President=3,King=4,DJ=5,SpaceFence=7,Spaceship=9,VRWorkout=11,OldGranny=13,Albot=15,Jumper=18,Giant=21,Gardener=24,Army=27,Morpher=30,Fusion=34,CommonCrippler=38,Splashfest=42,Virus=47,Guardian=52,DarkArts=57,Rare=63,Protected=69,Interdimentional=75,Scarce=82,TheHevalGod=90,GodOfSpace=100},{first = 53,second = 58, third = 68})
	Levels['6-28'] = newLevelObject({Joe=1,Gen57=2,President=3,King=4,DJ=5,SpaceFence=7,Spaceship=9,VRWorkout=11,OldGranny=13,Albot=15,Jumper=18,Giant=21,Gardener=24,Army=27,Morpher=30,Fusion=34,CommonCrippler=38,Splashfest=42,Virus=47,Guardian=52,DarkArts=57,Rare=63,Protected=69,Interdimentional=75,Scarce=82,TheHevalGod=90,GodOfSpace=100},{first = 53,second = 58, third = 68})
	Levels['6-29'] = newLevelObject({Morpher=7,Splashfest=19,Virus=31,Guardian=37,DarkArts=50,Protected=56,Interdimentional=68,Scarce=74,TheHevalGod=87,GodOfSpace=100},{first = 54,second = 59, third = 69})
	Levels['6-30'] = newLevelObject({Morpher=7,Splashfest=19,Virus=31,Guardian=37,DarkArts=50,Protected=56,Interdimentional=68,Scarce=74,TheHevalGod=87,GodOfSpace=100},{first = 56,second = 61, third = 71})


























end

function newLevelObject(spawn,stage)
	local level = {}
	for _, alienName in ipairs(alienNames) do
		if spawn[alienName] == nil then
			level[alienName] = 0
		else
			level[alienName] = spawn[alienName]
		end
	end
	level.first = stage.first
	level.second = stage.second
	level.third = stage.third

	return level
end

function loadData()
	local startingWeapon = math.random(1, 7)
		local startingWeapon1 = math.random(1, 7)
		local startingWeapon2 = math.random(1, 7)

		while startingWeapon == startingWeapon1 or startingWeapon == startingWeapon2 or startingWeapon2 == startingWeapon1 do
			startingWeapon = math.random(1, 7)
			startingWeapon1 = math.random(1, 7)
			startingWeapon2 = math.random(1, 7)
		end

		local datatemp = {
			gold = 0,
			gems = 0,
			time = '00:00',
			hours = 0,
			mins = 0,
			planet = 1,
			name = 'testing',
			weaponChoose1 = '',
			weaponChoose2 = '',
			weaponChoose3 = '',
			currentLevel = '',
			weapons = {
				AstroidRain = (startingWeapon == 1 or startingWeapon1 == 1 or startingWeapon2 == 1),
				PoisonArrow = (startingWeapon == 2 or startingWeapon1 == 2 or startingWeapon2 == 2),
				TripleThreat = (startingWeapon == 3 or startingWeapon1 == 3 or startingWeapon2 == 3),
				CosmicFire = (startingWeapon == 4 or startingWeapon1 == 4 or startingWeapon2 == 4),
				Astrobolt = (startingWeapon == 5 or startingWeapon1 == 5 or startingWeapon2 == 5),
				StarBlast = (startingWeapon == 6 or startingWeapon1 == 6 or startingWeapon2 == 6),
				LaserKill = (startingWeapon == 7 or startingWeapon1 == 7 or startingWeapon2 == 7),
				StellarBoost = false,
				ThunderStrike = false,
				BattleRam = false,
				ElectroJolt = false,
				DaggerThrow = false,
				Hevalstruck = false,
				RecursiveExplosion = false,
				Dueltroid = false,
				FreshStart = false,
				SantaAxe = false,
				Respawn = false,
				Offguard = false,
				LaserBeam = false,
				MindBlast = false,
				GrenadeLauncher = false,
				Protected = false,
				Hypnosis = false,
				ShrinkRay = false,
				GalacticBeam = false,
				SolarFlare = false,
				CometStrike = false,
				DeathVirus = false,
				VoidBurst = false,
				CelestialDisruption = false,
				QuantumFlux = false
			},
			aliensKilled = 0,
			wins = 0,
			matchesPlayed = 0,
			level = 0,
			brightness = 100,
			volume = 100,
			sfx = 100,
			walls = 0,
			retreat = 0,
			zap = 0,
			bomb = 0,
			doubleGold = 0,
			teleporter = 0,
			electricity = 0,
			protection = 0,
			aliensUnlocked = 2,
			goldBuff = 1,
			profile = nil,
			items = {
				Wall = false,
				Retreat = false,
				Zap = false,
				Bomb = false,
				DoubleGold = false,
				Teleporter = false,
				Electricity = false,
				Protection = false
			},
			saveNumber = saveNumber,
			turn = true
		}
		local filteredData = filterUserData(datatemp)  -- Filter out userdata
		local file = io.open("data.txt", "w")  -- Open the file in write mode
		if file then
			local dataString = json.encode(filteredData)  -- Convert the filtered data table to a JSON string
			file:write(dataString)  -- Write the data string to the file
			file:close()  -- Close the file
		end
		
	if fileExists('data.txt') then
		local file = io.open("data.txt", "r")  -- Open the file in read mode
		if file then
			local dataString = file:read("*a")  -- Read the entire content of the file
			file:close()  -- Close the file

			-- Attempt to decode the JSON string
			local success, decodedData = pcall(json.decode, dataString)
			if success then
				data = decodedData
			end
		end
	else
		love.filesystem.write("data.txt", jsonText)
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
	Weapons['PoisonArrow'] = makeWeapon(3000,'common',0,150,1,0,0,75,0,0,'Posion Arrow','lane',150,0,'Attacks a whole lane and poisons all aliens for 75 damage',gWeapons['PoisonDart']) --works
	Weapons['TripleThreat'] = makeWeapon(3000,'common',0,0,0,275,0,0,0,0,'Triple Threat','tile',275,3,'Attacks 3 specifc tiles of your choosing',gWeapons['Targeted']) --works
	Weapons['CosmicFire'] = makeWeapon(3000,'common',0,250,0,0,0,0,0,0,'Cosmic Fire','lane',250,0,'Attacks all aliens in a lane',gWeapons['RazorThrower']) --works
	Weapons['Astrobolt'] = makeWeapon(3000,'common',0,100,0,0,0,0,0,2,'Astrobolt','lane',100,0,'Attacks all aliens in a lane and stuns the first two for one turn',gWeapons['Lightning'],1) -- works
	Weapons['StarBlast'] = makeWeapon(3000,'common',0,0,0,0,0,0,0,0,'Star Blast','tile',125,1,'Attacks in a cross shapped pattern from a center point of your choice',gWeapons['StarBlast']) -- works
	Weapons['LaserKill'] = makeWeapon(3000,'common',0,0,0,0,0,0,0,0,'Laser Kill','lane',0,0,'Kills all aliens below 375 health in a lane, if they are above 375 health, Laser Kill does no damage',gWeapons['LaserKill']) -- works
	Weapons['StellarBoost'] = makeWeapon(3000,'common',0,0,3,0,0,0,0,0,'Stellar Boost','buff',0,0,'Buffs all your weapons damage by 20 percent this turn and 10 percent for the next 2 turns',gWeapons['Buffer']) -- works

	Weapons['ThunderStrike'] = makeWeapon(6500,'rare',0,700,0,0,0,0,0,0,'Thunder Strike','lane',700,0,'Attacks a lane for 700 damage and has a 33% chance to stun the first alien, if sucsessful, the stun keeps going with the same chance',gWeapons['ElectricBall'])-- doen
	Weapons['BattleRam'] = makeWeapon(6500,'rare',0,0,0,0,1,0,0,0,'Battle Ram','lane',1050,0,'Attacks the first alien in a lane for 1050 damage and knocks them back 1 tile',gWeapons['SwordShield'])
	Weapons['ElectroJolt'] = makeWeapon(6500,'rare',0,0,2,0,0,0,0,10,'Electric Jolt','lane',0,0,'Stuns the whole lane for 1 turn',gWeapons['ElectroShock'],1) -- record
	Weapons['DaggerThrow'] =  makeWeapon(6500,'rare',0,900,0,0,0,0,0,0,'Dagger Throw','lane',900,0,'Does 900 damage to the lane',gWeapons['PiercingSword']) -- record
	Weapons['Hevalstruck'] = makeWeapon(6500,'rare',0,0,0,0,0,0,0,0,'Hevalstruck','lane',1200,0,'Does 1200 to the first alien in the lane, does double the damage if the alien is a hevalten',gWeapons['Hevalstruck']) -- record
	Weapons['RecursiveExplosion'] =  makeWeapon(6500,'rare',425,0,0,0,0,0,0,0,'Recursive Explosion','all',425,0,'Does 425 damage to all aliens',gWeapons['RecursiveExplosion']) -- record
	Weapons['Dueltroid'] = makeWeapon(6500,'rare',0,0,0,0,0,0,0,0,'Dueltroid','lane',0,0,'Randomly stuns either the first alien in a row for 4 turns or the first 2 aliens for 2 turns',gWeapons['Dueltroid']) -- record
	Weapons['FreshStart'] =  makeWeapon(6500,'rare',0,0,2,0,0,0,0,0,'Fresh Start','tile',0,1,'Sends a 3x3 box of aliens to the start',gWeapons['FreshStart']) -- record

	Weapons['SantaAxe'] = makeWeapon(10000,'scarce',0,2200,0,0,0,0,0,0,'Santa Axe','lane',2200,0,'Does 2200 damage to an entire lane',gWeapons['SantaAxe']) -- record
	Weapons['Respawn'] =  makeWeapon(10000,'scarce',0,0,2,0,0,0,0,0,'Respawn','lane',0,0,'Stops all aliens except Hevaltens from spawning in the lane you choose for 1 turn',gWeapons['Respawn']) -- record
	Weapons['Offguard'] =  makeWeapon(10000,'scarce',0,0,3,0,0,0,0,10,'Offguard','all',0,0,'Stuns the whole game for 1 turn',gWeapons['Offguard'],1) -- record
	Weapons['LaserBeam'] = makeWeapon(10000,'scarce',0,0,0,0,0,0,0,0,'Laser Beam','lane',0,0,'Kills all aliens in a lane who have less than 6000 health',gWeapons['LaserDeath']) -- Record
	Weapons['MindBlast'] = makeWeapon(10000,'scarce',0,0,2,0,0,0,0,0,'Mind Blast','lane',7001,0,'Does 7001 damage to the first alien in a lane, if it survives then it will hypnotise that alien',gWeapons['MagicGun']) -- record
	Weapons['GrenadeLauncher'] =  makeWeapon(10000,'scarce',0,0,0,0,0,0,0,0,'Grenade Launcher','row',3950,0,'Does 3950 damage to the first and last row of aliens',gWeapons['Grenade']) -- record
	Weapons['Protected'] = makeWeapon(10000,'scarce',0,400,2,0,0,0,0,0,'Protected','lane',400,0,'Buffs all damage by 1.25% for the rest of the stage and does 400 damage to a lane',gWeapons['Walls']) -- Record
	Weapons['Hypnosis'] =  makeWeapon(10000,'scarce',0,0,3,0,0,0,0,0,'Hypnosis','all',0,0,'Hypnotises the first alien in all lanes',gWeapons['MindControl']) -- record

	Weapons['GalacticBeam'] =  makeWeapon(14500,'god',0,8000,0,0,0,0,0,0,'Galactic Beam','lane',8000,0,'Does 8000 damage a lane',gWeapons['RazorBlade']) -- record
	Weapons['SolarFlare'] =  makeWeapon(14500,'god',3000,0,0,0,0,0,0,0,'Solar Flare','all',3000,0,'Does 3000 damage to all aliens',gWeapons['Fireball']) -- record
	Weapons['CometStrike'] = makeWeapon(14500,'god',0,0,0,0,0,0,0,0,'Comet Strike','tile',8000,1,'Does 8000 damage to all aliens in a 3x3 box',gWeapons['Fireball']) -- record
	Weapons['DeathVirus'] = makeWeapon(14500,'god',0,0,3,0,0,0,0,0,'Death Virus','Random Lane',0,0,'Kills all aliens in a random lane',gWeapons['DeathVirus']) -- record
	Weapons['VoidBurst'] = makeWeapon(14500,'god',0,0,0,11000,0,0,0,0,'Void Burst','tile',11000,3,'Does 11000 to 3 tiles of your choice',gWeapons['Cannon']) -- record
	Weapons['CelestialDisruption'] = makeWeapon(14500,'god',0,0,0,0,0,0,0,0,'Celestial Disruption','lane',0,0,'Makes 4 non-hevaltens go to 1 health in that row',gWeapons['Wipeout']) -- record
	Weapons['QuantumFlux'] = makeWeapon(14500,'god',3000,0,0,0,0,0,0,0,'Quantum Flux','all',3000,0,'Does 3000 damage to all aliens',gWeapons['Transformer']) -- record
end


function saveData()
    local filteredData = filterUserData(data)  -- Filter out userdata
    local file = io.open("data.txt", "w")  -- Open the file in write mode
    if file then
        local dataString = json.encode(filteredData)  -- Convert the filtered data table to a JSON string
        file:write(dataString)  -- Write the data string to the file
        file:close()  -- Close the file
    end
end

function filterUserData(data)
    local filteredData = {}
    for key, value in pairs(data) do
        if type(value) ~= "userdata" then
            filteredData[key] = value
        end
    end
    return filteredData
end

function alienDictionary()
	Aliens = {}
	Aliens['Joe'] = makeAlien(500,1,false,false,'Joe','No Ability')
	Aliens['Gen57'] = makeAlien(700,1,false,false,'Gen57','No Ability')
	Aliens['President'] = makeAlien(1100,1,false,false,'President','No Ability')
	Aliens['King'] = makeAlien(1550,1,false,false,'King','No Ability')
	Aliens['DJ'] = makeAlien(2150,1,false,false,'DJ','No Ability')
	Aliens['SpaceFence'] = makeAlien(2950,1,false,true,'SpaceFence','Has a 1 turn immunity shield when spawned') -- record
	Aliens['Spaceship'] = makeAlien(3000,1,false,true,'Spaceship','Flies every 2 turns, when flying, Spaceship is immune to almost all damage') -- record
	Aliens['VRWorkout'] = makeAlien(3500,1,false,false,'VRWorkout','No Ability') -- record
	Aliens['OldGranny'] = makeAlien(3700,1,false,true,'OldGranny','When hurt, moves one space forward') -- record
	Aliens['Albot'] = makeAlien(3000,1,true,false,'Albot','Every turn, Albot spawns a random alien in its row') -- record
	Aliens['Jumper'] = makeAlien(4900,1,false,true,'Jumper','Jumps over all walls infront of it') -- DONENENENE
	Aliens['Giant'] = makeAlien(12700,1,false,false,'Giant','Moves every other turn') -- done
	Aliens['Gardener'] = makeAlien(8200,1,false,false,'Gardener','Walls can not be placed in a lane the gardener is in') -- DONE
	Aliens['Army'] = makeAlien(9400,1,true,false,'Army','Makes all weapons do 2% less damage of their original damage') -- record
	Aliens['Morpher'] = makeAlien(5700,1,false,true,'Morpher','Transforms into a random alien every turn and keeps the same percentage of health') -- record
	Aliens['Fusion'] = makeAlien(10000,1,false,true,'Fusion','When spawned, combines 2 aliens into 1 with atleast 1.5 times the combined health') -- record
	Aliens['CommonCrippler'] = makeAlien(13300,1,false,true,'CommonCrippler','All common weapons do 25% less damage') -- record
	Aliens['Splashfest'] = makeAlien(15500,1,false,false,'Splashfest','Immune to all splash damage') -- done
	Aliens['Virus'] = makeAlien(17600,1,false,true,'Virus','Makes all weapon cooldowns 1 turn longer') -- record
	Aliens['Guardian'] = makeAlien(28800,1,true,false,'Guardian','Immune to poison damage, knockback, and hypnosis. Takes all the damage in the lane') -- record
	Aliens['DarkArts'] = makeAlien(20000,1,true,false,'DarkArts','When spawned, transform all aliens into a better alien') -- record
	Aliens['Rare'] = makeAlien(23000,1,false,false,'Rare','All rare weapons do 20% less damage') -- record
	Aliens['Protected'] = makeAlien(26000,1,false,false,'Protected','All targeted damage is reduced by 50%') -- record
	Aliens['Interdimentional'] = makeAlien(34200,1,false,false,'Interdimentional','All damage is reduced by 7.5%') -- record
	Aliens['Scarce'] = makeAlien(40000,1,true,false,'Scarce','Scarce weapons do 20% less damage') -- record
	Aliens['TheHevalGod'] = makeAlien(46700,1,true,true,'TheHevalGod','When hurt, spawn a random Hevalten in one of the first 3 rows') -- record
	Aliens['GodOfSpace'] = makeAlien(50000,1,true,true,'GodOfSpace','When spawned, spawn 3 other random aliens. Immune to all knockback, poison, and hypnosis') -- done
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

function makeAlien(health,speed, heval,ability,name,desc)

	local temp = {}
	temp.health = health
	temp.speed = speed
	temp.hevalten = heval
	temp.ability = ability
	temp.name = name
	temp.desc = desc
	return temp
end

function fileExists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end
