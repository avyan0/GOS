local json = require('src/lib/dkjson')
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
	"GodOfSpace",
	"Swarmling",
	"Shieldbearer",
	"Phaser",
	"Medic",
	"Thief",
	"Splitter",
	"Anchor",
	"Necromancer",
	"VoidTitan"
}

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
	Levels['4-29'] = newLevelObject({Morpher=19,Fusion=57,CommonCrippler=79,Splashfest=93,Virus=100},{first = 44,second = 49, third = 59})
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




-- ========================= WEAPONS =========================
-- id = save key (data.weapons / data.upgrades), name = display name, shape = icon.
-- Stat fields keep their original names so battle logic is untouched.
local function makeWeapon(id, rarity, name, shape, desc, s)
    return {
        id = id, rarity = rarity, name = name, shape = shape, specialEffect = desc,
        health = ({common = 3000, rare = 6500, scarce = 10000, god = 14500})[rarity],
        damageAll = s.all or 0, damageLane = s.lane or 0, cooldown = s.cd or 0, damageTile = s.tile or 0,
        knockback = s.knockback or 0, poison = s.poison or 0, damageRandLane = 0, stun = s.stun or 0,
        aoe = s.aoe, damage = s.dmg or 0, attack = s.attacks or 0, stunDuration = s.stunTurns or 0,
    }
end

WEAPON_ORDER = {}
function weaponDictionary()
    Weapons, WEAPON_ORDER = {}, {}
    local function add(w) Weapons[w.id] = w; WEAPON_ORDER[#WEAPON_ORDER + 1] = w.id end
    -- common
    add(makeWeapon('AstroidRain', 'common', 'Asteroid Rain', 'rain', 'Deals 175 damage to every alien on the field.', {aoe = 'all', all = 175, dmg = 175, cd = 2}))
    add(makeWeapon('PoisonArrow', 'common', 'Poison Arrow', 'arrow', 'Deals 150 damage to a lane and poisons every alien in it for 55 damage per turn.', {aoe = 'lane', lane = 150, dmg = 150, poison = 55, cd = 1}))
    add(makeWeapon('TripleThreat', 'common', 'Triple Threat', 'crosshair', 'Deals 200 damage to three tiles of your choice.', {aoe = 'tile', tile = 200, dmg = 200, attacks = 3}))
    add(makeWeapon('CosmicFire', 'common', 'Cosmic Fire', 'flame', 'Deals 250 damage to every alien in a lane.', {aoe = 'lane', lane = 250, dmg = 250}))
    add(makeWeapon('Astrobolt', 'common', 'Astrobolt', 'bolt', 'Deals 150 damage to a lane and stuns the two closest aliens for one turn.', {aoe = 'lane', lane = 150, dmg = 150, stun = 2, stunTurns = 1}))
    add(makeWeapon('StarBlast', 'common', 'Star Blast', 'star', 'Deals 160 damage in a cross around a tile of your choice.', {aoe = 'tile', dmg = 160, attacks = 1}))
    add(makeWeapon('LaserKill', 'common', 'Laser Kill', 'laser', 'Instantly kills every alien in a lane with 600 health or less. Ignores buffs.', {aoe = 'lane', dmg = 600}))
    add(makeWeapon('StellarBoost', 'common', 'Stellar Boost', 'boost', 'All weapons deal +20% damage this turn and +10% for the next two.', {aoe = 'buff', cd = 3}))
    add(makeWeapon('GravityWell', 'common', 'Gravity Well', 'well', 'Drags every alien in a lane one row back toward the top of the field.', {aoe = 'lane', cd = 2}))
    add(makeWeapon('Ricochet', 'common', 'Ricochet', 'bounce', 'Deals 300 damage to the closest alien in a lane, then bounces into a neighbouring lane for 200 more.', {aoe = 'lane', dmg = 300}))
    add(makeWeapon('Scanner', 'common', 'Scanner', 'scan', 'Marks every alien on the field. Marked aliens take 25% more damage until the end of the turn.', {aoe = 'buff', cd = 2}))
    -- rare
    add(makeWeapon('ThunderStrike', 'rare', 'Thunder Strike', 'orb', 'Deals 700 damage to a lane. 33% chance to stun the closest alien, and to keep chaining down the lane.', {aoe = 'lane', lane = 700, dmg = 700}))
    add(makeWeapon('BattleRam', 'rare', 'Battle Ram', 'ram', 'Deals 1050 damage to the closest alien in a lane and knocks it back one tile.', {aoe = 'lane', dmg = 1050, knockback = 1}))
    add(makeWeapon('ElectroJolt', 'rare', 'Electro Jolt', 'jolt', 'Stuns every alien in a lane for one turn.', {aoe = 'lane', cd = 2, stun = 10, stunTurns = 1}))
    add(makeWeapon('DaggerThrow', 'rare', 'Dagger Throw', 'dagger', 'Deals 900 damage to every alien in a lane.', {aoe = 'lane', lane = 900, dmg = 900}))
    add(makeWeapon('Hevalstruck', 'rare', 'Hevalbane', 'hammer', 'Deals 1200 damage to the closest alien in a lane. Double damage against Hevalten.', {aoe = 'lane', dmg = 1200}))
    add(makeWeapon('RecursiveExplosion', 'rare', 'Recursive Explosion', 'burst', 'Deals 500 damage to every alien on the field.', {aoe = 'all', all = 500, dmg = 500}))
    add(makeWeapon('Dueltroid', 'rare', 'Dueltroid', 'duel', 'Randomly stuns either the closest alien in a lane for 4 turns, or the two closest for 2 turns.', {aoe = 'lane'}))
    add(makeWeapon('FreshStart', 'rare', 'Fresh Start', 'restart', 'Sends a 3x3 block of aliens back to the start of the field.', {aoe = 'tile', cd = 2, attacks = 1}))
    add(makeWeapon('ChainLightning', 'rare', 'Chain Lightning', 'chain', 'Deals 800 damage to a tile, then arcs to the four nearest aliens anywhere on the field, losing 20% per jump.', {aoe = 'tile', dmg = 800, attacks = 1, cd = 1}))
    add(makeWeapon('TimeWarp', 'rare', 'Time Warp', 'clock', 'Freezes time: no alien moves at the end of this turn. Works on everything, even shielded aliens.', {aoe = 'buff', cd = 3}))
    add(makeWeapon('Barricade', 'rare', 'Barricade', 'barricade', 'Builds a reinforced wall on a tile of your choice. It takes three hits before it breaks.', {aoe = 'tile', attacks = 1, cd = 3}))
    -- scarce
    add(makeWeapon('SantaAxe', 'scarce', 'Santa Axe', 'axe', 'Deals 2200 damage to every alien in a lane.', {aoe = 'lane', lane = 2200, dmg = 2200}))
    add(makeWeapon('Respawn', 'scarce', 'Lockdown', 'block', 'Nothing can spawn in the lane you choose next turn. Hevalten ignore it.', {aoe = 'lane', cd = 2}))
    add(makeWeapon('Offguard', 'scarce', 'Off Guard', 'freeze', 'Stuns every alien on the field for one turn.', {aoe = 'all', cd = 3, stun = 10, stunTurns = 1}))
    add(makeWeapon('LaserBeam', 'scarce', 'Laser Beam', 'beam', 'Instantly kills every alien in a lane with 6000 health or less. Ignores buffs.', {aoe = 'lane', dmg = 6000}))
    add(makeWeapon('MindBlast', 'scarce', 'Mind Blast', 'brain', 'Deals 7001 damage to the closest alien in a lane. If it survives, it is hypnotised and fights for you.', {aoe = 'lane', dmg = 7001, cd = 2}))
    add(makeWeapon('GrenadeLauncher', 'scarce', 'Grenade Launcher', 'grenade', 'Deals 3950 damage to every alien in the front and back rows.', {aoe = 'row', dmg = 3950}))
    add(makeWeapon('Protected', 'scarce', 'Bulwark', 'wall', 'Deals 1500 damage to a lane and permanently raises all damage by 2.5% for the rest of the stage.', {aoe = 'lane', lane = 1500, dmg = 1500, cd = 2}))
    add(makeWeapon('Hypnosis', 'scarce', 'Hypnosis', 'eye', 'Hypnotises the closest alien in every lane. They turn and attack their own side.', {aoe = 'all', cd = 3}))
    add(makeWeapon('Plague', 'scarce', 'Plague', 'plague', 'Infects a lane with a plague that deals 400 damage per turn and spreads to every neighbouring alien each turn.', {aoe = 'lane', poison = 400, cd = 2}))
    add(makeWeapon('Overclock', 'scarce', 'Overclock', 'gear', 'Instantly readies your other two weapons, even if they are recharging.', {aoe = 'buff', cd = 3}))
    add(makeWeapon('Executioner', 'scarce', 'Executioner', 'guillotine', 'Deals 3000 damage to the closest alien in a lane. If that alien is below half health, it dies outright instead.', {aoe = 'lane', dmg = 3000, cd = 1}))
    -- god
    add(makeWeapon('GalacticBeam', 'god', 'Galactic Beam', 'blade', 'Deals 8000 damage to every alien in a lane.', {aoe = 'lane', lane = 8000, dmg = 8000}))
    add(makeWeapon('SolarFlare', 'god', 'Solar Flare', 'sun', 'Deals 3000 damage to every alien on the field.', {aoe = 'all', all = 3000, dmg = 3000}))
    add(makeWeapon('CometStrike', 'god', 'Comet Strike', 'comet', 'Deals 8000 damage to every alien in a 3x3 block.', {aoe = 'tile', dmg = 8000, attacks = 1}))
    add(makeWeapon('DeathVirus', 'god', 'Death Virus', 'skull', 'Wipes out every alien in a random lane.', {aoe = 'Random Lane', cd = 3}))
    add(makeWeapon('VoidBurst', 'god', 'Void Burst', 'cannon', 'Deals 11000 damage to three tiles of your choice.', {aoe = 'tile', tile = 11000, dmg = 11000, attacks = 3}))
    add(makeWeapon('CelestialDisruption', 'god', 'Celestial Disruption', 'ring', 'Drops four non-Hevalten aliens in a lane to 1 health.', {aoe = 'lane'}))
    add(makeWeapon('QuantumFlux', 'god', 'Quantum Flux', 'flux', 'Deals 3000 damage to every alien. Every alien it kills explodes for 1500 damage to its neighbours, which can chain.', {aoe = 'all', all = 3000, dmg = 3000}))
    add(makeWeapon('Supernova', 'god', 'Supernova', 'nova', 'Burns away 20% of the maximum health of every alien on the field.', {aoe = 'all', cd = 3}))
    add(makeWeapon('DoomsdayClock', 'god', 'Doomsday Clock', 'hourglass', 'Marks an alien for death. Two turns later it dies, no matter what protects it.', {aoe = 'tile', attacks = 1, cd = 3}))
    add(makeWeapon('MeteorStorm', 'god', 'Meteor Storm', 'meteors', 'Six meteors each hunt down a different alien for 6000 damage. Spare meteors crater empty ground.', {aoe = 'all', dmg = 6000, cd = 2}))

    -- upgrades are keyed by weapon id; migrate saves that used the old display names
    local OLD_NAMES = {AstroidRain = 'Astroid Rain', Hevalstruck = 'Hevalstruck', Respawn = 'Respawn', Offguard = 'Offguard', Protected = 'Protected'}
    for _, id in ipairs(WEAPON_ORDER) do
        local w = Weapons[id]
        if data.upgrades[id] == nil then
            data.upgrades[id] = data.upgrades[OLD_NAMES[id] or w.name] or 0
        end
    end
end

MAX_UPGRADE = 5
function upgradeMultiplier(weapon)
    return (data.upgrades[weapon.id] or 0) * 0.1 + 1
end
-- gems needed to raise a weapon one level (5, 10, 15 ...)
function upgradeCost(weapon)
    return ((data.upgrades[weapon.id] or 0) + 1) * 5
end

-- ========================= ALIENS =========================
-- key = internal name used by battle logic; title = display name; spec = icon look.
local function makeAlien(key, health, hevalten, title, desc, spec)
    spec.hevalten = hevalten
    health = math.floor(health * (HP_SCALE or 1) + 0.5) -- HP_SCALE: balance probe knob (src/sim.lua)
    return {name = key, health = health, speed = 1, hevalten = hevalten, title = title, desc = desc, spec = spec}
end

-- Order aliens were unlocked in before discovery-by-encounter existed (save migration)
OLD_ALIEN_ORDER = {'Joe','Gen57','President','King','DJ','SpaceFence','Spaceship','VRWorkout','OldGranny','Albot','Jumper','Giant','Gardener','Army','Morpher','Fusion','CommonCrippler','Splashfest','Virus','Guardian','DarkArts','Rare','Protected','Interdimentional','Scarce','TheHevalGod','GodOfSpace'}

-- New aliens are mixed into existing spawn tables: {name, first level, last level, share of spawns}
NEW_SPAWNS = {
    {'Swarmling',    '1-10', '2-12', 22},
    {'Shieldbearer', '2-8',  '3-14', 15},
    {'Phaser',       '2-22', '3-30', 15},
    {'Medic',        '3-6',  '4-18', 12},
    {'Thief',        '3-20', '5-6',  12},
    {'Splitter',     '4-4',  '5-16', 14},
    {'Anchor',       '4-20', '6-6',  12},
    {'Necromancer',  '5-10', '6-30', 10},
    {'VoidTitan',    '6-20', '6-30', 6},
}

function alienDictionary()
    Aliens, Aliensrand = {}, {}
    local function add(a) Aliens[a.name] = a; Aliensrand[#Aliensrand + 1] = a end
    add(makeAlien('Joe',              500,   false, 'Joe',            'Just a guy. No ability.',                                                          {shape = 'round',   eyes = 2, hue = 0.33}))
    add(makeAlien('Gen57',            700,   false, 'Gen-57',         'Mass-produced clone. No ability.',                                                 {shape = 'square',  eyes = 2, hue = 0.55}))
    add(makeAlien('President',        1100,  false, 'President',      'Elected, somehow. No ability.',                                                    {shape = 'round',   eyes = 2, hue = 0.62}))
    add(makeAlien('King',             1550,  false, 'King',           'Rules by birthright. No ability.',                                                 {shape = 'hex',     eyes = 2, hue = 0.12, crown = true}))
    add(makeAlien('DJ',               1600,  false, 'DJ',             'Loud. No ability.',                                                                {shape = 'round',   eyes = 1, hue = 0.85}))
    add(makeAlien('SpaceFence',       1700,  false, 'Space Fence',    'Spawns with a one-turn shield that blocks all damage.',                            {shape = 'square',  eyes = 3, hue = 0.5}))
    add(makeAlien('Spaceship',        1800,  false, 'Spaceship',      'Takes flight every second turn. While flying it is immune to almost everything.', {shape = 'diamond', eyes = 1, hue = 0.58}))
    add(makeAlien('VRWorkout',        2000,  false, 'VR Workout',     'Very fit. No ability.',                                                            {shape = 'round',   eyes = 2, hue = 0.05}))
    add(makeAlien('OldGranny',        2100,  false, 'Old Granny',     'If she was hurt this turn, lurches an extra tile forward before everyone moves.',                           {shape = 'round',   eyes = 2, hue = 0.9,  sat = 0.3}))
    add(makeAlien('Albot',            1650,  true,  'Albot',          'Hevalten. Spawns a random alien in its row every turn.',                          {shape = 'square',  eyes = 3, hue = 0.0}))
    add(makeAlien('Jumper',           3400,  false, 'Jumper',         'Leaps over any wall in its way.',                                                  {shape = 'tri',     eyes = 2, hue = 0.28}))
    add(makeAlien('Giant',            5500,  false, 'Giant',          'Enormous, but only moves every other turn.',                                       {shape = 'hex',     eyes = 2, hue = 0.08, sat = 0.5}))
    add(makeAlien('Gardener',         5000,  false, 'Gardener',       'Walls cannot be placed in any lane the Gardener occupies.',                        {shape = 'round',   eyes = 2, hue = 0.25}))
    add(makeAlien('Army',             5500,  true,  'Army',           'Hevalten. Every Army on the field lowers all of your damage by 2%.',              {shape = 'square',  eyes = 2, hue = 0.2,  sat = 0.4}))
    add(makeAlien('Morpher',          3800,  false, 'Morpher',        'Turns into a different alien every turn, keeping its health percentage.',          {shape = 'diamond', eyes = 3, hue = 0.75}))
    add(makeAlien('Fusion',           4500,  false, 'Fusion',         'On spawn, fuses two aliens into one with 1.5x their combined health.',             {shape = 'hex',     eyes = 1, hue = 0.95}))
    add(makeAlien('CommonCrippler',   6000,  false, 'Crippler',       'Common weapons deal 25% less damage while it lives.',                             {shape = 'tri',     eyes = 2, hue = 0.4}))
    add(makeAlien('Splashfest',       6500,  false, 'Splashfest',     'Immune to all splash damage.',                                                     {shape = 'round',   eyes = 3, hue = 0.52}))
    add(makeAlien('Virus',            8500,  false, 'Virus',          'Every weapon that has a cooldown takes one turn longer to recharge.',                               {shape = 'diamond', eyes = 1, hue = 0.3}))
    add(makeAlien('Guardian',         13000, true,  'Guardian',       'Hevalten. Absorbs all damage aimed at its lane. Immune to poison, knockback and hypnosis.', {shape = 'hex', eyes = 2, hue = 0.6, aura = true}))
    add(makeAlien('DarkArts',         9000,  true,  'Dark Arts',      'Hevalten. On spawn, upgrades the three aliens closest to your base into stronger ones.',        {shape = 'diamond', eyes = 2, hue = 0.78, sat = 0.9}))
    add(makeAlien('Rare',             10500,  false, 'Rarebane',       'Rare weapons deal 20% less damage while it lives.',                               {shape = 'square',  eyes = 1, hue = 0.6}))
    add(makeAlien('Protected',        11500, false, 'Bunker',         'All targeted damage against it is halved.',                                        {shape = 'square',  eyes = 2, hue = 0.1,  sat = 0.3}))
    add(makeAlien('Interdimentional', 14500, false, 'Interdimensional', 'Every one on the field reduces all damage by 7.5%.',                            {shape = 'diamond', eyes = 3, hue = 0.7}))
    add(makeAlien('Scarce',           33000, true,  'Scarcebane',     'Hevalten. Scarce weapons deal 20% less damage while it lives.',                   {shape = 'hex',     eyes = 1, hue = 0.8}))
    add(makeAlien('TheHevalGod',      42000, true,  'Heval God',      'Hevalten. If it was hurt this turn, calls a random Hevalten into the first three rows.', {shape = 'hex', eyes = 3, hue = 0.0, aura = true, crown = true}))
    add(makeAlien('GodOfSpace',       46000, true,  'God of Space',   'Hevalten. Spawns three more aliens on arrival. Immune to knockback, poison and hypnosis.', {shape = 'round', eyes = 3, hue = 0.15, aura = true, crown = true}))
    -- newer arrivals
    add(makeAlien('Swarmling',        400,   false, 'Swarmling',      'Tiny and fast: moves two rows every turn.',                                        {shape = 'tri',     eyes = 1, hue = 0.45}))
    add(makeAlien('Shieldbearer',     1900,  false, 'Shieldbearer',   'Each turn, shields the alien directly ahead of it for one turn.',                  {shape = 'square',  eyes = 2, hue = 0.13}))
    add(makeAlien('Phaser',           2300,  false, 'Phaser',         'Half damage from lane attacks. Double damage from tile and single-target attacks.', {shape = 'diamond', eyes = 2, hue = 0.5, sat = 0.9}))
    add(makeAlien('Medic',            4000,  false, 'Medic',          'Each turn, heals every other alien for 10% of its maximum health.',                 {shape = 'round',   eyes = 2, hue = 0.0, sat = 0.2}))
    add(makeAlien('Thief',            4500,  false, 'Thief',          'Steals 5 gold from you every turn it is alive.',                                     {shape = 'diamond', eyes = 2, hue = 0.16, sat = 0.9}))
    add(makeAlien('Splitter',         5000,  false, 'Splitter',       'When it dies, breaks into two Swarmlings that each carry a quarter of its health.',                       {shape = 'hex',     eyes = 4, hue = 0.35}))
    add(makeAlien('Anchor',           8000,  false, 'Anchor',         'Nothing in its lane can be knocked back, pulled or moved by your weapons.',          {shape = 'square',  eyes = 1, hue = 0.6, sat = 0.3}))
    add(makeAlien('Necromancer',      9500,  true,  'Necromancer',    'Hevalten. Every third turn, raises the last alien you killed at half health in its row.', {shape = 'diamond', eyes = 3, hue = 0.82, aura = true}))
    add(makeAlien('VoidTitan',        60000, true,  'Void Titan',     'Hevalten. No single hit can deal more than 5000 damage to it.',                     {shape = 'hex',     eyes = 3, hue = 0.68, aura = true, crown = true}))
    table.sort(Aliensrand, function(a, b) return a.health < b.health end)
    for k, a in ipairs(Aliensrand) do a.tier = k end
end

-- level key -> sortable number
function levelIndex(key)
    local p, l = key:match('(%d+)%-(%d+)')
    return tonumber(p) * 100 + tonumber(l)
end

-- Mix NEW_SPAWNS into the cumulative spawn tables, then record each alien's first level.
function applyNewSpawns()
    for key, L in pairs(Levels) do
        local idx = levelIndex(key)
        -- cumulative thresholds -> weights
        local names, weights, prev = {}, {}, 0
        for _, name in ipairs(alienNames) do
            local v = L[name] or 0
            if v > prev then names[#names + 1] = name; weights[#weights + 1] = v - prev; prev = v end
        end
        local extra = 0
        for _, ns in ipairs(NEW_SPAWNS) do
            if idx >= levelIndex(ns[2]) and idx <= levelIndex(ns[3]) then names[#names + 1] = ns[1]; weights[#weights + 1] = ns[4]; extra = extra + ns[4] end
        end
        if extra > 0 then
            local scale = (100 - extra) / (100 - 0)
            local total = 0
            for k, name in ipairs(names) do
                local w = weights[k]
                local isNew = false
                for _, ns in ipairs(NEW_SPAWNS) do if ns[1] == name then isNew = true end end
                if not isNew then w = w * scale end
                total = total + w
                L[name] = total
            end
            -- fix rounding so the last entry is exactly 100
            L[names[#names]] = 100
            for _, name in ipairs(alienNames) do if L[name] == nil then L[name] = 0 end end
        end
    end
    for _, a in ipairs(Aliensrand) do
        a.intro = 9999
        for key, L in pairs(Levels) do
            local prevMax = 0
            for _, name in ipairs(alienNames) do
                if name == a.name and (L[name] or 0) > prevMax then a.intro = math.min(a.intro, levelIndex(key)) end
                prevMax = math.max(prevMax, L[name] or 0)
            end
        end
    end
end

-- ========================= ITEMS / PLANETS / SHOP =========================
ITEMS = {
    {key = 'Wall',        stat = 'walls',       name = 'Wall',        desc = 'Places a wall on a tile you choose. Blocks an alien for one turn before it breaks through.'},
    {key = 'Zap',         stat = 'zap',         name = 'Zap',         desc = 'Stuns every alien in a random lane for three turns.'},
    {key = 'DoubleGold',  stat = 'doubleGold',  name = 'Double Gold', desc = 'Doubles the gold you earn from the current level.'},
    {key = 'Electricity', stat = 'electricity', name = 'Electricity', desc = 'Stuns every alien on the field for one turn.'},
    {key = 'Retreat',     stat = 'retreat',     name = 'Retreat',     desc = 'Skips the current stage. On the final stage, wins the level.'},
    {key = 'Bomb',        stat = 'bomb',        name = 'Bomb',        desc = 'Skips two stages. On the second or third stage, wins the level.'},
    {key = 'Teleporter',  stat = 'teleporter',  name = 'Teleporter',  desc = 'Removes one random alien from the field.'},
    {key = 'Protection',  stat = 'protection',  name = 'Protection',  desc = 'Raises all of your damage by 50% for the rest of the stage.'},
}

PLANETS = {
    {name = 'Verdanis', hue = 0.38},
    {name = 'Cyrene',   hue = 0.55, ringed = true},
    {name = 'Ossara',   hue = 0.08},
    {name = 'Nyx',      hue = 0.72},
    {name = 'Solhara',  hue = 0.12, ringed = true},
    {name = 'Hevalten', hue = 0.98},
}

SPIN_TIERS = {
    {key = 'Common', rarity = 'common', price = 25,  unlock = function() return true end},
    {key = 'Rare',   rarity = 'rare',   price = 45,  unlock = function() return data.planet >= 2 end},
    {key = 'Scarce', rarity = 'scarce', price = 100, unlock = function() return data.planet >= 4 end},
    {key = 'God',    rarity = 'god',    price = 270, unlock = function() return (data.planet == 5 and data.level >= 15) or data.planet > 5 end},
    {key = 'Item',   rarity = nil,      price = 25,  unlock = function() return true end},
}

-- ========================= SAVE SYSTEM =========================
-- Lives in LÖVE's save directory (see t.identity in conf.lua), never the
-- game folder, so it works when packaged as .love/.exe.
-- data.txt  = current save, data.bak = previous good save.
-- Every field the game reads has a default here; a save missing a key
-- (older version, hand-edited, new weapon added) gets it filled in.

SAVE_FILE = 'data.txt'
SAVE_BACKUP = 'data.bak'
SAVE_VERSION = 1

local COMMON_WEAPONS = {'AstroidRain','PoisonArrow','TripleThreat','CosmicFire','Astrobolt','StarBlast','LaserKill'}
local ALL_WEAPONS = {'AstroidRain','PoisonArrow','TripleThreat','CosmicFire','Astrobolt','StarBlast','LaserKill','StellarBoost',
	'ThunderStrike','BattleRam','ElectroJolt','DaggerThrow','Hevalstruck','RecursiveExplosion','Dueltroid','FreshStart',
	'SantaAxe','Respawn','Offguard','LaserBeam','MindBlast','GrenadeLauncher','Protected','Hypnosis',
	'GalacticBeam','SolarFlare','CometStrike','DeathVirus','VoidBurst','CelestialDisruption','QuantumFlux'}
local ITEMS = {'Wall','Retreat','Zap','Bomb','DoubleGold','Teleporter','Electricity','Protection'}

function defaultSave()
	local d = {
		version = SAVE_VERSION,
		gold = 0, gems = 0, time = '00:00', hours = 0, mins = 0,
		planet = 1, name = 'Player', currentLevel = '',
		weaponChoose1 = '', weaponChoose2 = '', weaponChoose3 = '',
		aliensKilled = 0, wins = 0, matchesPlayed = 0, level = 0,
		brightness = 100, volume = 100, sfx = 100, fullscreen = false,
		walls = 0, retreat = 0, zap = 0, bomb = 0, doubleGold = 0,
		teleporter = 0, electricity = 0, protection = 0,
		aliensUnlocked = 2, goldBuff = 1, turn = false,
		weapons = {}, items = {}, upgrades = {}, seen = {Joe = true, Gen57 = true},
	}
	for _, w in ipairs(ALL_WEAPONS) do d.weapons[w] = false end
	for _, i in ipairs(ITEMS) do d.items[i] = false end
	return d
end

-- Fill missing keys in `t` from `defaults` (recursing into tables). Never overwrites existing values.
local function fillDefaults(t, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table' then
			if type(t[k]) ~= 'table' then t[k] = {} end
			fillDefaults(t[k], v)
		elseif t[k] == nil then
			t[k] = v
		end
	end
	return t
end

function createNewSave()
	data = defaultSave()
	-- 3 distinct random common weapons + StellarBoost to start
	local pool = {unpack(COMMON_WEAPONS)}
	for n = 1, 3 do
		local id = table.remove(pool, math.random(#pool))
		data.weapons[id] = true
		data['weaponChoose' .. n] = id -- start equipped so the first battle is one click away
	end
	data.weapons['StellarBoost'] = true
end

local function readSave(name)
	if not love.filesystem.getInfo(name) then return nil end
	local text = love.filesystem.read(name)
	if not text or text == '' then return nil end
	local ok, decoded = pcall(json.decode, text)
	if ok and type(decoded) == 'table' then return decoded end
	return nil
end

function loadData()
	local loaded = readSave(SAVE_FILE) or readSave(SAVE_BACKUP)
	-- one-time import of a save left next to the game by the old system
	if not loaded then
		local f = io.open('data.txt', 'r')
		if f then
			local ok, decoded = pcall(json.decode, f:read('*a'))
			f:close()
			if ok and type(decoded) == 'table' then loaded = decoded end
		end
	end
	if loaded then
		data = fillDefaults(loaded, defaultSave())
		for k = 1, math.min(loaded.aliensUnlocked or 0, #OLD_ALIEN_ORDER) do data.seen[OLD_ALIEN_ORDER[k]] = true end
	else
		createNewSave()
	end
	saveData()
end

-- Strip userdata (images etc.) so the table is JSON-safe.
local function serializable(t)
	local out = {}
	for k, v in pairs(t) do
		if type(v) == 'table' then out[k] = serializable(v)
		elseif type(v) ~= 'userdata' and type(v) ~= 'function' then out[k] = v end
	end
	return out
end

function saveData()
	if not data then return end
	local ok, text = pcall(json.encode, serializable(data))
	if not ok or not text then return end
	-- keep the last good save as backup, then overwrite the main file
	local previous = love.filesystem.read(SAVE_FILE)
	if previous and previous ~= '' and previous ~= text then
		love.filesystem.write(SAVE_BACKUP, previous)
	end
	love.filesystem.write(SAVE_FILE, text)
end

function fileExists(filename)
	return love.filesystem.getInfo(filename) ~= nil
end
-- ===============================================================
