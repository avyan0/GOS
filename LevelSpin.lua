LevelSpin = Class{__includes = BaseState}
local name = nil
function LevelSpin:render()
	push:apply('start')

	love.graphics.setColor(70/255,20/255,200/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

	love.graphics.getFont(gFonts['game'])
	love.graphics.setColor(192/255,192/255,192/255)
		love.graphics.printf('You won '.. name ..'!',400,300,400,'center')


	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')
end

function LevelSpin:enter(spin)
	typeSpin = spin
    com = math.random(1,100)
    name = LevelSpin:getChance()
end
function LevelSpin:getChance()
	if typeSpin == 'Common' then
		if com >= 1 and com<=20 then
			data.gold = data.gold + 10
			
			saveData()
			return '10 Gold'
			
		end
		if com >= 21 and com <= 30 then
			data.weapons['AstroidRain'] = true
			
			saveData()
			return 'Astroid Rain'
		end
		if com >=31 and com <= 40 then
			data.weapons['TripleThreat'] = true
			
			saveData()
			return 'Triple Threat'
		end 
		if com >=41 and com <= 50 then
			data.weapons['PoisonArrow'] = true
			
			saveData()
			return 'Poison Arrow'
		end 
		if com >=51 and com <= 60 then
			data.weapons['CosmicFire'] = true
			
			saveData()
			return 'Cosmic Fire'
		end 
		if com >=61 and com <= 70 then
			data.weapons['Astrobolt'] = true
			
			saveData()
			return 'Astrobolt'
		end 
		if com >=71 and com <= 80 then
			data.weapons['StarBlast'] = true
			
			saveData()
			return 'Star Blast'
		end
		if com >=81 and com <= 90 then
			data.weapons['LaserKill'] = true
			
			saveData()
			return 'Laser Kill'
		end
		if com >=91 and com <= 100 then
			data.weapons['StellarBoost'] = true
			
			saveData()
			return 'Stellar Boost'
		end 
	end

	if typeSpin == 'Rare' then
		if com >= 1 and com <= 10 then
		    data.gold = data.gold + 50
		    
			saveData()
		    return '50 Gold'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['ThunderStrike'] = true
		    
			saveData()
		    return 'Thunder Strike'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['Battle am'] = true
		    
			saveData()
		    return 'Battle Ram'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['ElectroJolt'] = true
		    
			saveData()
		    return 'Electro Jolt'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['DaggerThrow'] = true
		    
			saveData()
		    return 'Dagger Throw'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['Hevalstruck'] = true
		    
			saveData()
		    return 'Hevalstruck'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['RecursiveExplosion'] = true
		    
			saveData()
		    return 'RecursiveExplosion'
		end

		if com >= 71 and com <= 80 then
		    data.weapons['Dueltroid'] = true
		    
			saveData()
		    return 'Dueltroid'
		end

		if com >= 81 and com <= 90 then
		    data.weapons['FreshStart'] = true
		    
			saveData()
		    return 'FreshStart'
		end

		if com >= 91 and com <= 100 then
			data.gold = data.gold + 50
			
			saveData()
			return '50 Gold'
		end
	end

	if typeSpin == 'Scarce' then
		if com >= 1 and com <= 10 then
		    data.gold = data.gold + 75
		    
			saveData()
		    return '75 Gold'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['SantaAxe'] = true
		    
			saveData()
		    return 'Santa Axe'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['Respawn'] = true
		    
			saveData()
		    return 'Respawn'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['Offguard'] = true
		    
			saveData()
		    return 'Offguard'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['LaserBeam'] = true
		    
			saveData()
		    return 'Laser Beam'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['MindBlast'] = true
		    
			saveData()
		    return 'Mind Blast'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['GrenadeLauncher'] = true
		    
			saveData()
		    return 'Grenade Launcher'
		end

		if com >= 71 and com <= 80 then
		    data.weapons['Protected'] = true
		    
			saveData()
		    return 'Protected'
		end

		if com >= 81 and com <= 90 then
		    data.weapons['Hypnosis'] = true
		    
			saveData()
		    return 'Hypnosis'
		end

		if com >= 91 and com <= 100 then
		    data.gems = data.gems + 5
		    
			saveData()
		    return '5 Gems'
		end
	end

	if typeSpin == 'God' then
		if com >= 1 and com <= 10 then
		    data.weapons['GalacticBeam'] = true
		    
			saveData()
		    return 'Galactic Beam'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['SolarFlare'] = true
		    
			saveData()
		    return 'Solar Flare'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['CometStrike'] = true
		    
			saveData()
		    return 'Comet Strike'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['DeathVirus'] = true
		    
			saveData()
		    return 'Death Virus'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['VoidBurst'] = true
		    
			saveData()
		    return 'Void Burst'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['CelestialDisruption'] = true
		    
			saveData()
		    return 'Celestial Disruption'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['QuantumFlux'] = true
		    
			saveData()
		    return 'Quantum Flux'
		end

		if com >= 71 and com <= 80 then
		        data.gold = data.gold + 100
		        
				saveData()
		        return '100 Gold'
		end

		if com >= 81 and com <= 100 then
		        data.gems = data.gems + 20
		        
				saveData()
		        return '20 Gems'
		end
	end

	if typeSpin == 'Item' then
		if com >= 1 and com <= 20 then
		    data.items['Retreat'] = true
		    
		    data.retreat = data.retreat + 1
			saveData()
		    return 'Retreat'
		end

		if com >= 21 and com <= 50 then
		    data.items['Wall'] = true
		    
		    data.walls = data.walls + 1
			saveData()
		    return 'Wall'
		end

		if com >= 51 and com <= 60 then
		    data.items['Zap'] = true
		    
		    data.zap= data.zap + 1
			saveData()
		    return 'zap'
		end

		if com >= 61 and com <= 65 then
		    data.items['Bomb'] = true
		    
		    data.bomb = data.bomb + 1
			saveData()
		    return 'Bomb'
		end

		if com >= 66 and com <= 75 then
		    data.items['DoubleGold'] = true
		    
		    data.doubleGold = data.doubleGold + 1
			saveData()
		    return 'DoubleGold'
		end

		if com >= 76 and com <= 80 then
		    data.items['Teleporter'] = true
		    
		    data.teleporter = data.teleporter + 1
			saveData()
		    return 'Teleporter'
		end

		if com >= 81 and com <= 90 then
		    data.items['Electricity'] = true
		    
		    data.electricity= data.electricity + 1
			saveData()
		    return 'Electricity'
		end

		if com >= 91 and com <= 100 then
		    data.items['Protection'] = true
		    
		    data.protection = data.protection + 1
			saveData()
		    return 'Protection'
		end
	end
end