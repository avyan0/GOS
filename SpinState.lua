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
			data.gold = data.gold + 10
			data.gold = data.gold - priceForSpin
			return '10 Gold'
			
		end
		if com >= 21 and com <= 30 then
			data.weapons['AstroidRain'] = true
			data.gold = data.gold - priceForSpin
			return 'Astroid Rain'
		end
		if com >=31 and com <= 40 then
			data.weapons['TripleThreat'] = true
			data.gold = data.gold - priceForSpin
			return 'Triple Threat'
		end 
		if com >=41 and com <= 50 then
			data.weapons['PoisonArrow'] = true
			data.gold = data.gold - priceForSpin
			return 'Poison Arrow'
		end 
		if com >=51 and com <= 60 then
			data.weapons['CosmicFire'] = true
			data.gold = data.gold - priceForSpin
			return 'Cosmic Fire'
		end 
		if com >=61 and com <= 70 then
			data.weapons['Astrobolt'] = true
			data.gold = data.gold - priceForSpin
			return 'Astrobolt'
		end 
		if com >=71 and com <= 80 then
			data.weapons['StarBlast'] = true
			data.gold = data.gold - priceForSpin
			return 'Star Blast'
		end
		if com >=81 and com <= 90 then
			data.weapons['LaserKill'] = true
			data.gold = data.gold - priceForSpin
			return 'Laser Kill'
		end
		if com >=91 and com <= 100 then
			data.weapons['StellarBoost'] = true
			data.gold = data.gold - priceForSpin
			return 'Stellar Boost'
		end 
	end

	if typeSpin == 'Rare' then
		if com >= 1 and com <= 10 then
		    data.gold = data.gold + 50
		    data.gold = data.gold - priceForSpin
		    return '50 Gold'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['ThunderStrike'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Thunder Strike'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['Battle am'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Battle Ram'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['ElectroJolt'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Electro Jolt'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['DaggerThrow'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Dagger Throw'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['Hevalstruck'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Hevalstruck'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['RecursiveExplosion'] = true
		    data.gold = data.gold - priceForSpin
		    return 'RecursiveExplosion'
		end

		if com >= 71 and com <= 80 then
		    data.weapons['Dueltroid'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Dueltroid'
		end

		if com >= 81 and com <= 90 then
		    data.weapons['FreshStart'] = true
		    data.gold = data.gold - priceForSpin
		    return 'FreshStart'
		end

		if com >= 91 and com <= 100 then
			data.gold = data.gold + 50
			data.gold = data.gold - priceForSpin
			return '50 Gold'
		end
	end

	if typeSpin == 'Scarce' then
		if com >= 1 and com <= 10 then
		    data.gold = data.gold + 75
		    data.gold = data.gold - priceForSpin
		    return '75 Gold'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['SantaAxe'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Santa Axe'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['Respawn'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Respawn'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['Offguard'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Offguard'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['LaserBeam'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Laser Beam'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['MindBlast'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Mind Blast'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['GrenadeLauncher'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Grenade Launcher'
		end

		if com >= 71 and com <= 80 then
		    data.weapons['Protected'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Protected'
		end

		if com >= 81 and com <= 90 then
		    data.weapons['Hypnosis'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Hypnosis'
		end

		if com >= 91 and com <= 100 then
		    data.gems = data.gems + 5
		    data.gold = data.gold - priceForSpin
		    return '5 Gems'
		end
	end

	if typeSpin == 'God' then
		if com >= 1 and com <= 10 then
		    data.weapons['GalacticBeam'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Galactic Beam'
		end

		if com >= 11 and com <= 20 then
		    data.weapons['SolarFlare'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Solar Flare'
		end

		if com >= 21 and com <= 30 then
		    data.weapons['CometStrike'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Comet Strike'
		end

		if com >= 31 and com <= 40 then
		    data.weapons['DeathVirus'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Death Virus'
		end

		if com >= 41 and com <= 50 then
		    data.weapons['VoidBurst'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Void Burst'
		end

		if com >= 51 and com <= 60 then
		    data.weapons['CelestialDisruption'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Celestial Disruption'
		end

		if com >= 61 and com <= 70 then
		    data.weapons['QuantumFlux'] = true
		    data.gold = data.gold - priceForSpin
		    return 'Quantum Flux'
		end

		if com >= 71 and com <= 80 then
		        data.gold = data.gold + 100
		        data.gold = data.gold - priceForSpin
		        return '100 Gold'
		end

		if com >= 81 and com <= 100 then
		        data.gems = data.gems + 20
		        data.gold = data.gold - priceForSpin
		        return '20 Gems'
		end
	end

	if typeSpin == 'Item' then
		if com >= 1 and com <= 20 then
		    data.items['Retreat'] = true
		    data.gold = data.gold - priceForSpin
		    data.retreat = data.retreat + 1
		    return 'Retreat'
		end

		if com >= 21 and com <= 50 then
		    data.items['Wall'] = true
		    data.gold = data.gold - priceForSpin
		    data.walls = data.walls + 1
		    return 'Wall'
		end

		if com >= 51 and com <= 60 then
		    data.items['Zap'] = true
		    data.gold = data.gold - priceForSpin
		    data.zap= data.zap + 1
		    return 'zap'
		end

		if com >= 61 and com <= 65 then
		    data.items['Bomb'] = true
		    data.gold = data.gold - priceForSpin
		    data.bomb = data.bomb + 1
		    return 'Bomb'
		end

		if com >= 66 and com <= 75 then
		    data.items['DoubleGold'] = true
		    data.gold = data.gold - priceForSpin
		    data.doubleGold = data.doubleGold + 1
		    return 'DoubleGold'
		end

		if com >= 76 and com <= 80 then
		    data.items['Teleporter'] = true
		    data.gold = data.gold - priceForSpin
		    data.teleporter = data.teleporter + 1
		    return 'Teleporter'
		end

		if com >= 81 and com <= 90 then
		    data.items['Electricity'] = true
		    data.gold = data.gold - priceForSpin
		    data.electricity= data.electricity + 1
		    return 'Electricity'
		end

		if com >= 91 and com <= 100 then
		    data.items['Protection'] = true
		    data.gold = data.gold - priceForSpin
		    data.protection = data.protection + 1
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