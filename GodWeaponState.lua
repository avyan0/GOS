GodWeaponState = Class{__includes = BaseState}

function GodWeaponState.render()

	push:apply('start')
	love.graphics.setColor(215/255,190/255,10/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.drawBack(235,73,152)

	if data.weapons['GalacticBeam'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',20,120,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Galactic Beam',20,285,280,'center')
	end
	if data.weapons['SolarFlare'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',340,120,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Solar Flare',340,285,280,'center')
	end
	if data.weapons['CometStrike'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',660,120,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Comet Strike',660,285,280,'center')
	end
	if data.weapons['DeathVirus'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',980,120,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Death virus',980,285,280,'center')
	end
	if data.weapons['VoidBurst'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',20,330,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Void Burst',20,495,280,'center')
	end
	if data.weapons['CelestialDisruption'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',340,330,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Celestial Disruption',340,495,280,'center')
	end
	if data.weapons['QuantumFlux'] then
	love.graphics.setColor(235/255,73/255,152/255)
	love.graphics.rectangle('fill',660,330,280,180)
	love.graphics.setColor(1,222/255,222/255)
	love.graphics.printf('Quantum Flux',660,495,280,'center')
	end


	love.graphics.setColor(1,1,1)
	if data.weapons['GalacticBeam'] then
	local w1 = gWeapons['RazorBlade']:getWidth()
	local h1 = gWeapons['RazorBlade']:getHeight()
	love.graphics.draw(gWeapons['RazorBlade'],40,150,0,240 / (w1 - 1), 90 / (h1 - 1))
else
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,120,0,280 / (w1 - 1), 180 / (h1 - 1))
	end

	if data.weapons['SolarFlare'] then
	local w2 = gWeapons['Fireball']:getWidth()
	local h2 = gWeapons['Fireball']:getHeight()
	love.graphics.draw(gWeapons['Fireball'],360,150,0,240 / (w2 - 1), 90 / (h2 - 1))
else
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,120,0,280 / (w2 - 1), 180 / (h2 - 1))
	end

	if data.weapons['CometStrike'] then
	local w3 = gWeapons['Meteor']:getWidth()
	local h3 = gWeapons['Meteor']:getHeight()
	love.graphics.draw(gWeapons['Meteor'],680,150,0,240 / (w3 - 1), 90 / (h3 - 1))
else
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,120,0,280 / (w3 - 1), 180 / (h3 - 1))
	end

	if data.weapons['DeathVirus'] then
	local w4 = gWeapons['DeathVirus']:getWidth()
	local h4 = gWeapons['DeathVirus']:getHeight()
	love.graphics.draw(gWeapons['DeathVirus'],1000,150,0,240 / (w4 - 1), 90 / (h4 - 1))
else
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,120,0,280 / (w4 - 1), 180 / (h4 - 1))
	end

	if data.weapons['VoidBurst'] then
	local w5 = gWeapons['Cannon']:getWidth()
	local h5 = gWeapons['Cannon']:getHeight()
	love.graphics.draw(gWeapons['Cannon'],40,360,0,240 / (w5 - 1), 90 / (h5 - 1))
else
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,330,0,280 / (w5 - 1), 180 / (h5 - 1))
	end

	if data.weapons['CelestialDisruption'] then
	local w6 = gWeapons['Wipeout']:getWidth()
	local h6 = gWeapons['Wipeout']:getHeight()
	love.graphics.draw(gWeapons['Wipeout'],360,360,0,240 / (w6 - 1), 90 / (h6 - 1))
else
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,330,0,280 / (w6 - 1), 180 / (h6 - 1))
	end

	if data.weapons['QuantumFlux'] then
	local w7 = gWeapons['Transformer']:getWidth()
	local h7 = gWeapons['Transformer']:getHeight()
	love.graphics.draw(gWeapons['Transformer'],680,360,0,240 / (w7 - 1), 90 / (h7 - 1))
else
	local w7 = gTextures['lockWeapons']:getWidth()
	local h7 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,330,0,280 / (w7 - 1), 180 / (h7 - 1))
	end
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	push:apply('end');

end

function GodWeaponState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('weapons')
	end
end
