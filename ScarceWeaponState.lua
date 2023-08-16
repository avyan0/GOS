ScarceWeaponState = Class{__includes = BaseState}

function ScarceWeaponState.render()
	-- FIX LAYOUT

	push:apply('start')

	love.graphics.setColor(170/255,0,170/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.drawBack(44,218,218)

	if data.weapons['SantaAxe'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',20,120,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Santa Axe',20,285,280,'center')
	end
	if data.weapons['Respawn'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',340,120,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Respawn',340,285,280,'center')
	end
	if data.weapons['Offguard'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',660,120,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Offguard',660,285,280,'center')
	end
	if data.weapons['LaserBeam'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',980,120,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Laser Beam',980,285,280,'center')
	end
	if data.weapons['MindBlast'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',20,330,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Mind Blast',20,495,280,'center')
	end
	if data.weapons['GrenadeLauncher'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',340,330,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Grenade Launcher',340,495,280,'center')
	end
	if data.weapons['Protected'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',660,330,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Protected',660,495,280,'center')
	end
	if data.weapons['Hypnosis'] then
	love.graphics.setColor(44/255,218/255,218/255)
	love.graphics.rectangle('fill',980,330,280,180)
	love.graphics.setColor(230/255,0,0)
	love.graphics.printf('Hypnosis',980,495,280,'center')
	end

	love.graphics.setColor(1,1,1)

	if data.weapons['SantaAxe'] then
	local w1 = gWeapons['SantaAxe']:getWidth()
	local h1 = gWeapons['SantaAxe']:getHeight()
	love.graphics.draw(gWeapons['SantaAxe'],40,150,0,240 / (w1 - 1), 90 / (h1 - 1))
else
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,120,0,280 / (w1 - 1), 180 / (h1 - 1))
	end
	if data.weapons['Respawn'] then
	local w2 = gWeapons['Respawn']:getWidth()
	local h2 = gWeapons['Respawn']:getHeight()
	love.graphics.draw(gWeapons['Respawn'],360,150,0,240 / (w2 - 1), 90 / (h2 - 1))
else
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,120,0,280 / (w2 - 1), 180 / (h2 - 1))
	end
	if data.weapons['Offguard'] then
	local w3 = gWeapons['Offguard']:getWidth()
	local h3 = gWeapons['Offguard']:getHeight()
	love.graphics.draw(gWeapons['Offguard'],680,150,0,240 / (w3 - 1), 90 / (h3 - 1))
else
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,120,0,280 / (w3 - 1), 180 / (h3 - 1))
	end
	if data.weapons['LaserBeam'] then
	local w4 = gWeapons['LaserDeath']:getWidth()
	local h4 = gWeapons['LaserDeath']:getHeight()
	love.graphics.draw(gWeapons['LaserDeath'],1000,150,0,240 / (w4 - 1), 90 / (h4 - 1))
else
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,120,0,280 / (w4 - 1), 180 / (h4 - 1))
	end
	if data.weapons['MindBlast'] then
	local w5 = gWeapons['MagicGun']:getWidth()
	local h5 = gWeapons['MagicGun']:getHeight()
	love.graphics.draw(gWeapons['MagicGun'],40,360,0,240 / (w5 - 1), 90 / (h5 - 1))
else
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,330,0,280 / (w5 - 1), 180 / (h5 - 1))
	end
	if data.weapons['GrenadeLauncher'] then
	local w6 = gWeapons['Grenade']:getWidth()
	local h6 = gWeapons['Grenade']:getHeight()
	love.graphics.draw(gWeapons['Grenade'],360,360,0,240 / (w6 - 1), 90 / (h6 - 1))
else
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,330,0,280 / (w6 - 1), 180 / (h6 - 1))
	end
	if data.weapons['Protected'] then
	local w7 = gWeapons['Walls']:getWidth()
	local h7 = gWeapons['Walls']:getHeight()
	love.graphics.draw(gWeapons['Walls'],680,360,0,240 / (w7 - 1), 90 / (h7 - 1))
else
	local w7 = gTextures['lockWeapons']:getWidth()
	local h7 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,330,0,280 / (w7 - 1), 180 / (h7 - 1))
	end
	if data.weapons['Hypnosis'] then
	local w8 = gWeapons['MindControl']:getWidth()
	local h8 = gWeapons['MindControl']:getHeight()
	love.graphics.draw(gWeapons['MindControl'],1000,360,0,240 / (w8 - 1), 90 / (h8 - 1))
else
	local w8 = gTextures['lockWeapons']:getWidth()
	local h8 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,330,0,280 / (w8 - 1), 180 / (h8 - 1))
	end
love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end');

end

function ScarceWeaponState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('weapons')
	end
	if data.weapons['SantaAxe'] then
	if love.clicked(x,y,20,300,120,300) then
		gStateMachine:change('weaponInfo',Weapons['SantaAxe'])
	end end
	if data.weapons['Respawn'] then
	if love.clicked(x,y,340,620,120,300) then
		gStateMachine:change('weaponInfo',Weapons['Respawn'])
	end end
	if data.weapons['Offguard'] then
	if love.clicked(x,y,640,920,120,300) then
		gStateMachine:change('weaponInfo',Weapons['Offguard'])
	end end
	if data.weapons['LaserBeam'] then
	if love.clicked(x,y,980,980 + 280,120,300) then
		gStateMachine:change('weaponInfo',Weapons['LaserBeam'])
	end end
	if data.weapons['MindBlast'] then
	if love.clicked(x,y,20,300,330,510) then
		gStateMachine:change('weaponInfo',Weapons['MindBlast'])
	end end
	if data.weapons['GrenadeLauncher'] then
	if love.clicked(x,y,340,340 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['GrenadeLauncher'])
	end end
	if data.weapons['Protected'] then
	if love.clicked(x,y,660,660 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['Protected'])
	end end
	if data.weapons['Hypnosis'] then
	if love.clicked(x,y,980,980 + 280,330,510) then
		gStateMachine:change('weaponInfo',Weapons['Hypnosis'])
	end end
end
