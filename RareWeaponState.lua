RareWeaponState = Class{__includes = BaseState}

function RareWeaponState:render()


	push:apply("start");


	love.graphics.setColor(1,115/255,20/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	love.drawBack(20,80,90)

	love.graphics.setFont(gFonts['commonWeapons'])

	if data.weapons['ThunderStrike'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',20,120,280,180)
	love.graphics.setColor(0,1,0)	
	love.graphics.printf('Thunder Strike',20,285,280,'center')
	end
	if data.weapons['BattleRam'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',340,120,280,180)
	love.graphics.setColor(0,1,0)	
	love.graphics.printf('Battle Ram',340,285,280,'center')
	end
	if data.weapons['ElectroJolt'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',660,120,280,180)
	love.graphics.setColor(0,1,0)	
	love.graphics.printf('Electro Jolt',660,285,280,'center')
	end
	if data.weapons['DaggerThrow'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',980,120,280,180)
	love.graphics.setColor(0,1,0)	
	love.graphics.printf('Dagger Throw',980,285,280,'center')
	end
	if data.weapons['Hevalstruck'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',20,330,280,180)
	love.graphics.setColor(0,1,0)
	love.graphics.printf('Hevalstruck',20,495,280,'center')
	end
	if data.weapons['RecursiveExplosion'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',340,330,280,180)
	love.graphics.setColor(0,1,0)
	love.graphics.printf('Recursive Explosion',340,495,280,'center')
	end
	if data.weapons['Dueltroid'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',660,330,280,180)
	love.graphics.setColor(0,1,0)
	love.graphics.printf('Dueltroid',660,495,280,'center')
	end
	if data.weapons['FreshStart'] then
	love.graphics.setColor(20/255,80/255,90/255)
	love.graphics.rectangle('fill',980,330,280,180)
	love.graphics.setColor(0,1,0)
	love.graphics.printf('Fresh Start',980,495,280,'center')
	end

	love.graphics.setColor(1,1,1)

	if data.weapons['ThunderStrike'] then
	local w1 = gWeapons['ElectricBall']:getWidth()
	local h1 = gWeapons['ElectricBall']:getHeight()
	love.graphics.draw(gWeapons['ElectricBall'],40,150,0,240 / (w1 - 1), 90 / (h1 - 1))
	else
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,120,0,280 / (w1 - 1), 180 / (h1 - 1))
	end

	if data.weapons['BattleRam'] then
	local w2 = gWeapons['SwordShield']:getWidth()
	local h2 = gWeapons['SwordShield']:getHeight()
	love.graphics.draw(gWeapons['SwordShield'],360,150,0,240 / (w2 - 1), 90 / (h2 - 1))
else
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,120,0,280 / (w2 - 1), 180 / (h2 - 1))
	end

	if data.weapons['ElectroJolt'] then
	local w3 = gWeapons['ElectroShock']:getWidth()
	local h3 = gWeapons['ElectroShock']:getHeight()
	love.graphics.draw(gWeapons['ElectroShock'],680,150,0,240 / (w3 - 1), 90 / (h3 - 1))
else
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,120,0,280 / (w3 - 1), 180 / (h3 - 1))
	end
	if data.weapons['DaggerThrow'] then
	local w4 = gWeapons['PiercingSword']:getWidth()
	local h4 = gWeapons['PiercingSword']:getHeight()
	love.graphics.draw(gWeapons['PiercingSword'],1000,150,0,240 / (w4 - 1), 90 / (h4 - 1))
else
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,120,0,280 / (w4 - 1), 180 / (h4 - 1))
	end

	if data.weapons['Hevalstruck'] then
	local w5 = gWeapons['Hevalstruck']:getWidth()
	local h5 = gWeapons['Hevalstruck']:getHeight()
	love.graphics.draw(gWeapons['Hevalstruck'],40,360,0,240 / (w5 - 1), 90 / (h5 - 1))
else
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],20,330,0,280 / (w5 - 1), 180 / (h5 - 1))
	end
	if data.weapons['RecursiveExplosion'] then
	local w6 = gWeapons['RecursiveExplosion']:getWidth()
	local h6 = gWeapons['RecursiveExplosion']:getHeight()
	love.graphics.draw(gWeapons['RecursiveExplosion'],360,360,0,240 / (w6 - 1), 90 / (h6 - 1))
else
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],340,330,0,280 / (w6 - 1), 180 / (h6 - 1))
	end
	if data.weapons['Dueltroid'] then
	local w7 = gWeapons['Dueltroid']:getWidth()
	local h7 = gWeapons['Dueltroid']:getHeight()
	love.graphics.draw(gWeapons['Dueltroid'],680,360,0,240 / (w7 - 1), 90 / (h7 - 1))
else
	local w7 = gTextures['lockWeapons']:getWidth()
	local h7 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],660,330,0,280 / (w7 - 1), 180 / (h7 - 1))
	end
	if data.weapons['FreshStart'] then
	local w8 = gWeapons['FreshStart']:getWidth()
	local h8 = gWeapons['FreshStart']:getHeight()
	love.graphics.draw(gWeapons['FreshStart'],1000,360,0,240 / (w8 - 1), 90 / (h8 - 1))
else
	local w8 = gTextures['lockWeapons']:getWidth()
	local h8 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],980,330,0,280 / (w8 - 1), 180 / (h8 - 1))
	end
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	push:apply('end');

end

function RareWeaponState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('weapons')
	end
end