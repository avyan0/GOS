CommonWeaponState = Class{__includes = BaseState}

function CommonWeaponState:render()
	-- make it so that when a weapon is unlocked, it is added to the players list and it looks like it was the first one unlocked
	push:apply('start')

	love.graphics.setColor(40/255,200/255,245/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	love.drawBack(170,255,103)
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(gFonts['commonWeapons'])

	if data.weapons['AstroidRain'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',20,120,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Asteroid Rain',20,245,280,'center')
	end
	if data.weapons['PoisonArrow'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',340,120,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Poison Arrow',340,245,280,'center')
	end
	if data.weapons['TripleThreat'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',660,120,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Triple Threat',660,245,280,'center')
	end
	if data.weapons['CosmicFire'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',980,120,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Cosmic Fire',980,245,280,'center')
	end
	if data.weapons['Astrobolt'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',20,330,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Astrobolt',20,455,280,'center')
	end
	if data.weapons['StarBlast'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',340,330,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Star Blast',340,455,280,'center')
	end
	if data.weapons['LaserKill'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',660,330,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('Laser Kill',660,455,280,'center')
	end
	if data.weapons['StellarBoost'] then
	love.graphics.setColor(170/255,1,103/255)
	love.graphics.rectangle('fill',980,330,280,180)
	love.graphics.setColor(230/255,0,115/255)
	love.graphics.printf('StellarBoost',980,455,280,'center')
	end

	love.graphics.setColor(1,1,1)

	if data.weapons['AstroidRain'] then
	local w1 = gWeapons['AsteroidRain']:getWidth()
	local h1 = gWeapons['AsteroidRain']:getHeight()
	love.graphics.draw(gWeapons['AsteroidRain'],40,150,0,240 / (w1 - 1), 90 / (h1 - 1))
else
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,120,0,280 / (w1 - 1), 180 / (h1 - 1))
	end

	if data.weapons['PoisonArrow'] then
	local w2 = gWeapons['PoisonDart']:getWidth()
	local h2 = gWeapons['PoisonDart']:getHeight()
	love.graphics.draw(gWeapons['PoisonDart'],360,150,0,240 / (w2 - 1), 90 / (h2 - 1))
else
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,120,0,280 / (w2 - 1), 180 / (h2 - 1))
	end

	if data.weapons['TripleThreat'] then
	local w3 = gWeapons['Targeted']:getWidth()
	local h3 = gWeapons['Targeted']:getHeight()
	love.graphics.draw(gWeapons['Targeted'],680,150,0,240 / (w3 - 1), 90 / (h3 - 1))
else
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,120,0,280 / (w3 - 1), 180 / (h3 - 1))
	end
	if data.weapons['CosmicFire'] then

	local w4 = gWeapons['RazorThrower']:getWidth()
	local h4 = gWeapons['RazorThrower']:getHeight()
	love.graphics.draw(gWeapons['RazorThrower'],1000,150,0,240 / (w4 - 1), 90 / (h4 - 1))
else
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,120,0,280 / (w4 - 1), 180 / (h4 - 1))
	end
	if data.weapons['Astrobolt'] then

	local w5 = gWeapons['Lightning']:getWidth()
	local h5 = gWeapons['Lightning']:getHeight()
	love.graphics.draw(gWeapons['Lightning'],40,360,0,240 / (w5 - 1), 90 / (h5 - 1))
else
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,330,0,280 / (w5 - 1), 180 / (h5 - 1))
	end
	if data.weapons['StarBlast'] then

	local w6 = gWeapons['StarBlast']:getWidth()
	local h6 = gWeapons['StarBlast']:getHeight()
	love.graphics.draw(gWeapons['StarBlast'],360,360,0,240 / (w6 - 1), 90 / (h6 - 1))
else
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,330,0,280 / (w6 - 1), 180 / (h6 - 1))
	end
	if data.weapons['LaserKill'] then
	local w7 = gWeapons['LaserKill']:getWidth()
	local h7 = gWeapons['LaserKill']:getHeight()
	love.graphics.draw(gWeapons['LaserKill'],680,360,0,240 / (w7 - 1), 90 / (h7 - 1))
else
	local w7 = gTextures['lockWeapons']:getWidth()
	local h7 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,330,0,280 / (w7 - 1), 180 / (h7 - 1))
	end
	if data.weapons['StellarBoost'] then
	local w8 = gWeapons['Buffer']:getWidth()
	local h8 = gWeapons['Buffer']:getHeight()
	love.graphics.draw(gWeapons['Buffer'],1000,360,0,240 / (w8 - 1), 90 / (h8 - 1))
else
	local w8 = gTextures['lockWeapons']:getWidth()
	local h8 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,330,0,280 / (w8 - 1), 180 / (h8 - 1))
	end
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')

end

function CommonWeaponState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('weapons')
	end
	if data.weapons['AstroidRain'] then
	if love.clicked(x,y,20,300,120,300) then
		gStateMachine:change('weaponInfo',Weapons['AstroidRain'])
	end end
	if data.weapons['PoisonArrow'] then
	if love.clicked(x,y,340,620,120,300) then
		gStateMachine:change('weaponInfo',Weapons['PoisonArrow'])
	end end
	if data.weapons['TripleThreat'] then
	if love.clicked(x,y,640,920,120,300) then
		gStateMachine:change('weaponInfo',Weapons['TripleThreat'])
	end end
	if data.weapons['CosmicFire'] then
	if love.clicked(x,y,980,980 + 280,120,300) then
		gStateMachine:change('weaponInfo',Weapons['CosmicFire'])
	end end
	if data.weapons['Astrobolt'] then
	if love.clicked(x,y,20,300,330,510) then
		gStateMachine:change('weaponInfo',Weapons['Astrobolt'])
	end end
	if data.weapons['StarBlast'] then
	if love.clicked(x,y,340,340 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['StarBlast'])
	end end
	if data.weapons['LaserKill'] then
	if love.clicked(x,y,660,660 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['LaserKill'])
	end end
	if data.weapons['StellarBoost'] then
	if love.clicked(x,y,980,980 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['StellarBoost'])
	end end
end
