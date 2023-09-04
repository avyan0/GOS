SpinState = Class{__includes = BaseState}

function SpinState:render()
	push:apply('start')

	love.graphics.setColor(70/255,20/255,200/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
	love.drawBack()
	if typeSpin == 'Common' then
		priceForSpin = 25
	end
	if typeSpin == 'Rare' then
		priceForSpin = 45
	end
	if typeSpin == 'Scarce' then
		priceForSpin = 100
	end
	if typeSpin == 'God' then
		priceForSpin = 270
	end
	if typeSpin == 'Item' then
		priceForSpin = 25
	end
	love.graphics.getFont(gFonts['game'])
	love.graphics.setColor(192/255,192/255,192/255)
	love.graphics.printf(typeSpin..' Spin',400,50,400,'center')
	love.graphics.printf('Gold: '..tostring(data.gold),400,125,400,'center')

	local backgroundWidth1 = gTextures['wheel']:getWidth()
    local backgroundHeight1 = gTextures['wheel']:getHeight()
    love.graphics.draw(gTextures['wheel'],400,500,0,400 / (backgroundWidth1 - 1), 200 / (backgroundHeight1 - 1))
	love.graphics.setColor(192/255,192/255,192/255)
	if draw19 then
		love.graphics.printf('You won '.. weapon198 ..'!',400,300,400,'center')
	end

	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')
end

function SpinState:enter(spin)
	typeSpin = spin
	draw19 = false
end

function SpinState:getChance()
	com = math.random(1,100)
	if typeSpin == 'Common' then
		if com >= 1 and com<=20 then
			local rand = math.random(15,35)
			data.gold = data.gold + rand
			data.gold = data.gold - priceForSpin
			saveData()
			return (rand..' Gold')
			
		end
		if com >= 21 and com <= 30 then
			if data.weapons['AstroidRain'] == true then
				data.upgrades['Astroid Rain'] = data.upgrades['Astroid Rain'] + 1
			else
				data.weapons['AstroidRain'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Astroid Rain'
		end
		if com >=31 and com <= 40 then
			if data.weapons['TripleThreat'] == true then
				data.upgrades['Triple Threat'] = data.upgrades['Triple Threat'] + 1
			else
				data.weapons['TripleThreat'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Triple Threat'
		end 
		if com >=41 and com <= 50 then
			if data.weapons['PoisonArrow'] == true then
				data.upgrades['Poison Arrow'] = data.upgrades['Poison Arrow'] + 1
			else
				data.weapons['PoisonArrow'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Poison Arrow'
		end 
		if com >=51 and com <= 60 then
			if data.weapons['CosmicFire'] == true then
				data.upgrades['Cosmic Fire'] = data.upgrades['Cosmic Fire'] + 1
			else
				data.weapons['CosmicFire'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Cosmic Fire'
		end 
		if com >=61 and com <= 70 then
			if data.weapons['Astrobolt'] == true then
				data.upgrades['Astrobolt'] = data.upgrades['Astrobolt'] + 1
			else
				data.weapons['Astrobolt'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Astrobolt'
		end 
		if com >=71 and com <= 80 then
			if data.weapons['StarBlast'] == true then
				data.upgrades['Star Blast'] = data.upgrades['Star Blast'] + 1
			else
				data.weapons['StarBlast'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Star Blast'
		end
		if com >=81 and com <= 90 then
			if data.weapons['LaserKill'] == true then
				data.upgrades['Laser Kill'] = data.upgrades['Laser Kill'] + 1
			else
				data.weapons['LaserKill'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Laser Kill'
		end
		if com >=91 and com <= 100 then
			if data.weapons['StellarBoost'] == true then
				data.upgrades['Stellar Boost'] = data.upgrades['Stellar Boost'] + 1
			else
				data.weapons['StellarBoost'] = true
			end
			data.gold = data.gold - priceForSpin
			saveData()
			return 'Stellar Boost'
		end 
	end

	if typeSpin == 'Rare' then
		if com >= 1 and com <= 10 then
			local rand = math.random(27,63)
		    data.gold = data.gold + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gold')
		end

		if com >= 11 and com <= 20 then
			if data.weapons['ThunderStrike'] == true then
				data.upgrades['Thunder Strike'] = data.upgrades['Thunder Strike'] + 1
			else
				data.weapons['ThunderStrike'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Thunder Strike'
		end

		if com >= 21 and com <= 30 then
			if data.weapons['BattleRam'] == true then
				data.upgrades['Battle Ram'] = data.upgrades['Battle Ram'] + 1
			else
				data.weapons['BattleRam'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Battle Ram'
		end

		if com >= 31 and com <= 40 then
			if data.weapons['ElectroJolt'] == true then
				data.upgrades['Electro Jolt'] = data.upgrades['Electro Jolt'] + 1
			else
				data.weapons['ElectroJolt'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Electro Jolt'
		end

		if com >= 41 and com <= 50 then
			if data.weapons['DaggerThrow'] == true then
				data.upgrades['Dagger Throw'] = data.upgrades['Dagger Throw'] + 1
			else
				data.weapons['DaggerThrow'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Dagger Throw'
		end

		if com >= 51 and com <= 60 then
			if data.weapons['Hevalstruck'] == true then
				data.upgrades['Hevalstruck'] = data.upgrades['Hevalstruck'] + 1
			else
				data.weapons['Hevalstruck'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Hevalstruck'
		end

		if com >= 61 and com <= 70 then
			if data.weapons['RecursiveExplosion'] == true then
				data.upgrades['Recursive Explosion'] = data.upgrades['Recursive Explosion'] + 1
			else
				data.weapons['RecursiveExplosion'] = true
			end
		    data.weapons['RecursiveExplosion'] = true
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Recursive Explosion'
		end

		if com >= 71 and com <= 80 then
			if data.weapons['Dueltroid'] == true then
				data.upgrades['Dueltroid'] = data.upgrades['Dueltroid'] + 1
			else
				data.weapons['Dueltroid'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Dueltroid'
		end

		if com >= 81 and com <= 90 then
			if data.weapons['FreshStart'] == true then
				data.upgrades['Fresh Start'] = data.upgrades['Fresh Start'] + 1
			else
				data.weapons['FreshStart'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Fresh Start'
		end

		if com >= 91 and com <= 100 then
			local rand = math.random(27,63)
		    data.gold = data.gold + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gold')
		end
	end

	if typeSpin == 'Scarce' then
		if com >= 1 and com <= 10 then
			local rand = math.random(60,140)
		    data.gold = data.gold + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gold')
		end

		if com >= 11 and com <= 20 then
			if data.weapons['SantaAxe'] == true then
				data.upgrades['Santa Axe'] = data.upgrades['Santa Axe'] + 1
			else
				data.weapons['SantaAxe'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Santa Axe'
		end

		if com >= 21 and com <= 30 then
			if data.weapons['Respawn'] == true then
				data.upgrades['Respawn'] = data.upgrades['Respawn'] + 1
			else
				data.weapons['Respawn'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Respawn'
		end

		if com >= 31 and com <= 40 then
			if data.weapons['Offguard'] == true then
				data.upgrades['Offguard'] = data.upgrades['Offguard'] + 1
			else
				data.weapons['Offguard'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Offguard'
		end

		if com >= 41 and com <= 50 then
			if data.weapons['LaserBeam'] == true then
				data.upgrades['Laser Beam'] = data.upgrades['Laser Beam'] + 1
			else
				data.weapons['LaserBeam'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Laser Beam'
		end

		if com >= 51 and com <= 60 then
			if data.weapons['MindBlast'] == true then
				data.upgrades['Mind Blast'] = data.upgrades['Mind Blast'] + 1
			else
				data.weapons['MindBlast'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Mind Blast'
		end

		if com >= 61 and com <= 70 then
			if data.weapons['GrenadeLauncher'] == true then
				data.upgrades['Grenade Launcher'] = data.upgrades['Grenade Launcher'] + 1
			else
				data.weapons['GrenadeLauncher'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Grenade Launcher'
		end

		if com >= 71 and com <= 80 then
			if data.weapons['Protected'] == true then
				data.upgrades['Protected'] = data.upgrades['Protected'] + 1
			else
				data.weapons['Protected'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Protected'
		end

		if com >= 81 and com <= 90 then
			if data.weapons['Hypnosis'] == true then
				data.upgrades['Hypnosis'] = data.upgrades['Hypnosis'] + 1
			else
				data.weapons['Hypnosis'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Hypnosis'
		end

		if com >= 91 and com <= 100 then
			local rand = math.random(3,7)
		    data.gems = data.gems + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gems')
		end
	end

	if typeSpin == 'God' then
		if com >= 1 and com <= 10 then
			if data.weapons['GalacticBeam'] == true then
				data.upgrades['Galactic Beam'] = data.upgrades['Galactic Beam'] + 1
			else
				data.weapons['GalacticBeam'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Galactic Beam'
		end

		if com >= 11 and com <= 20 then
			if data.weapons['SolarFlare'] == true then
				data.upgrades['Solar Flare'] = data.upgrades['Solar Flare'] + 1
			else
				data.weapons['SolarFlare'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Solar Flare'
		end

		if com >= 21 and com <= 30 then
			if data.weapons['CometStrike'] == true then
				data.upgrades['Comet Strike'] = data.upgrades['Comet Strike'] + 1
			else
				data.weapons['CometStrike'] = true
			end
		    data.weapons['CometStrike'] = true
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Comet Strike'
		end

		if com >= 31 and com <= 40 then
			if data.weapons['DeathVirus'] == true then
				data.upgrades['Death Virus'] = data.upgrades['Death Virus'] + 1
			else
				data.weapons['DeathVirus'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Death Virus'
		end

		if com >= 41 and com <= 50 then
			if data.weapons['VoidBurst'] == true then
				data.upgrades['Void Burst'] = data.upgrades['Void Burst'] + 1
			else
				data.weapons['VoidBurst'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Void Burst'
		end

		if com >= 51 and com <= 60 then
			if data.weapons['CelestialDisruption'] == true then
				data.upgrades['Celestial Disruption'] = data.upgrades['Celestial Disruption'] + 1
			else
				data.weapons['CelestialDisruption'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Celestial Disruption'
		end

		if com >= 61 and com <= 70 then
			if data.weapons['QuantumFlux'] == true then
				data.upgrades['Quantum Flux'] = data.upgrades['Quantum Flux'] + 1
			else
				data.weapons['QuantumFlux'] = true
			end
		    data.gold = data.gold - priceForSpin
			saveData()
		    return 'Quantum Flux'
		end

		if com >= 71 and com <= 80 then
			local rand = math.random(162,378)
		    data.gold = data.gold + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gold')
		end

		if com >= 81 and com <= 100 then
			local rand = math.random(12,28)
		    data.gems = data.gems + rand
		    data.gold = data.gold - priceForSpin
			saveData()
		    return (rand..' Gems')
		end
	end

	if typeSpin == 'Item' then
		if com >= 1 and com <= 20 then
		    data.items['Retreat'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,3)
		    data.retreat = data.retreat + temp
			temp = math.random(1,3)
			saveData()
		    return 'Retreat'
		end

		if com >= 21 and com <= 50 then
		    data.items['Wall'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,6)
		    data.walls = data.walls + temp
			temp = math.random(1,6)
			saveData()
		    return 'Wall'
		end

		if com >= 51 and com <= 60 then
		    data.items['Zap'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,3)
		    data.zap= data.zap + temp
			temp = math.random(1,3)
			saveData()
		    return 'zap'
		end

		if com >= 61 and com <= 65 then
		    data.items['Bomb'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,2)
		    data.bomb = data.bomb + temp
			temp = math.random(1,2)
			saveData()
		    return 'Bomb'
		end

		if com >= 66 and com <= 75 then
		    data.items['DoubleGold'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,3)
		    data.doubleGold = data.doubleGold + temp
			temp = math.random(1,3)
			saveData()
		    return 'DoubleGold'
		end

		if com >= 76 and com <= 80 then
		    data.items['Teleporter'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,5)
		    data.teleporter = data.teleporter + temp
			temp= math.random(1,5)
			saveData()
		    return 'Teleporter'
		end

		if com >= 81 and com <= 90 then
		    data.items['Electricity'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,3)
		    data.electricity= data.electricity + temp
			temp = math.random(1,3)
			saveData()
		    return 'Electricity'
		end

		if com >= 91 and com <= 100 then
		    data.items['Protection'] = true
		    data.gold = data.gold - priceForSpin
			local temp = math.random(1,2)
		    data.protection = data.protection + temp
			temp = math.random(1,2)
			saveData()
		    return 'Protection'
		end
	end
end

function SpinState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
		gStateMachine:change('shop')
	end
	if love.clicked(x,y,400,800,500,700) and data.gold>=priceForSpin then
		weapon198 =SpinState:getChance()
		draw19 = true
		SpinState:render()

	end
end


function SpinState:win()

	push:apply('end')
end
