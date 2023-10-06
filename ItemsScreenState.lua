ItemsScreenState = Class{__includes = BaseState}

function ItemsScreenState:render()
	push:apply('start')

	love.graphics.setColor(144/255,238/255,144/255)
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	love.drawBack()

love.graphics.setColor(1,1,1)
	love.graphics.circle('fill',37,212,31)
	love.graphics.circle('fill',37,492,31)
	love.graphics.circle('fill',341,212,31)
	love.graphics.circle('fill',341,492,31)
	love.graphics.circle('fill',645,212,31)
	love.graphics.circle('fill',645,492,31)
	love.graphics.circle('fill',949,212,31)
	love.graphics.circle('fill',949,492,31)
if data.items['Wall'] then
	love.graphics.circle('fill',66,237,14)
end
if data.items['Retreat'] then
	love.graphics.circle('fill',66,517,14)
end
if data.items['Zap'] then
	love.graphics.circle('fill',370,237,14)
end
if data.items['Bomb'] then
	love.graphics.circle('fill',370,517,14)
end
if data.items['DoubleGold'] then
	love.graphics.circle('fill',674,237,14)
end
if data.items['Teleporter'] then
	love.graphics.circle('fill',674,517,14)
end
if data.items['Electricity'] then
	love.graphics.circle('fill',978,237,14)
end
if data.items['Protection'] then
	love.graphics.circle('fill',978,517,14)
end

love.graphics.setColor(0,0,0)
love.graphics.setFont(gFonts['items'])
	love.graphics.print('Walls',78,204)
	love.graphics.print('Retreat',78,481)
	love.graphics.print('Zap',385,204)
	love.graphics.print('Bomb',385,481)
	love.graphics.print('Double Gold',692,204)
	love.graphics.print('Teleporter', 692,481)
	love.graphics.print('Electricity',999,204)
	love.graphics.print('Protection',999,481)
	love.graphics.setFont(gFonts['itemsNumbers'])
		if data.items['Wall'] then
	love.graphics.printf(tostring(data.walls),62,229,28)
end
if data.items['Retreat'] then
	love.graphics.printf(tostring(data.retreat),62,510,28)
end
if data.items['Zap'] then
	love.graphics.printf(tostring(data.zap),366,229,28)
end
if data.items['Bomb'] then
	love.graphics.printf(tostring(data.bomb),366,510,28)
end
if data.items['DoubleGold'] then
	love.graphics.printf(tostring(data.doubleGold),670,229,28)
end
if data.items['Teleporter'] then
	love.graphics.printf(tostring(data.teleporter),670,510,28)
end
if data.items['Electricity'] then
	love.graphics.printf(tostring(data.electricity),974,229,28)
end
if data.items['Protection'] then
	love.graphics.printf(tostring(data.protection),974,510,28)
end

	love.graphics.setColor(1,1,1)
	if data.items['Wall'] then
	local w = gTextures['lockWeapons']:getWidth()
	local h = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],16,182,55/(w-1),55/(h-1))
else
	local w = gTextures['lockWeapons']:getWidth()
	local h = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],16,182,55/(w-1),55/(h-1))
end

	if data.items['Retreat'] then
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],16,462,55/(w1-1),55/(h1-1))
else 
	local w1 = gTextures['lockWeapons']:getWidth()
	local h1 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],16,462,55/(w1-1),55/(h1-1))
end

	if data.items['Zap'] then
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],320,182,55/(w2-1),55/(h2-1))
else
	local w2 = gTextures['lockWeapons']:getWidth()
	local h2 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],320,182,55/(w2-1),55/(h2-1))
end

	if data.items['Bomb'] then
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],320,462,55/(w3-1),55/(h3-1))
else
	local w3 = gTextures['lockWeapons']:getWidth()
	local h3 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],320,462,55/(w3-1),55/(h3-1))
end

	if data.items['DoubleGold'] then
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],624,182,55/(w4-1),55/(h4-1))
else
	local w4 = gTextures['lockWeapons']:getWidth()
	local h4 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],624,182,55/(w4-1),55/(h4-1))
end
	
	if data.items['Teleporter'] then
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],624,462,55/(w5-1),55/(h5-1))
else
	local w5 = gTextures['lockWeapons']:getWidth()
	local h5 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],624,462,55/(w5-1),55/(h5-1))
end

	if data.items['Electricity'] then
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],925,182,55/(w6-1),55/(h6-1))
else
	local w6 = gTextures['lockWeapons']:getWidth()
	local h6 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],925,182,55/(w6-1),55/(h6-1))
end

	if data.items['Protection'] then
	local w8 = gTextures['lockWeapons']:getWidth()
	local h8 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],925,462,55/(w8-1),55/(h8-1))
else 
	local w8 = gTextures['lockWeapons']:getWidth()
	local h8 = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],925,462,55/(w8-1),55/(h8-1))
end
	
	
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')
end

function ItemsScreenState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
		gStateMachine:change('home')
	end
	if  data.items['Wall'] then
		if love.clicked(x,y,0,266,170,260) then
			gStateMachine:change('itemDescriptions','The item places a wall on any tile of your choosing. This wall blocks the movement of almost all aliens for a single turn, which means that if an alien is on the tile before the wall, it will be prevented from moving on that space for one turn.')
		end
	end
	if data.items['Teleporter'] then
		if love.clicked(x,y,608,874,451,541) then
			gStateMachine:change('itemDescriptions','When used, you place down 1 teleporter, this teleporter will send aliens back 3 spaces, the alien will no longer be affected by the teleporter. 10 turns after placing the 1st teleporter, you will get a second teleporter to place. Now, when an alien steps on either teleporter, they will be teleported to the other')
		end
	end
	if data.items['Retreat'] then
		if love.clicked(x,y,0,266,451,541) then
			gStateMachine:change('itemDescriptions', 'This item allows the user to skip a stage in a level. When activated, the user is instantly transported to the next stage, or if activated at the third stage, then finishes the level.')
		end
	end
	if data.items['Protection'] then
		if love.clicked(x,y,912,1178,451,541) then
			gStateMachine:change('itemDescriptions', 'This item helps walls on the field by making them impossible to avoid. This makes some aliens unable to fly or jump over it. This item also prevents alien abilities from destroying walls. In addition, when aliens try to break walls that are on the field right now, they take 2 extra turns.')
		end
	end
	if data.items['Zap'] then
		if love.clicked(x,y,304,570,170,260) then
			gStateMachine:change('itemDescriptions',  'This item stuns every alien in a random lane for 3 turns. Other aliens could spawn in that lane and move. When an alien is stunned, it cannot move for a specific amount of time, in this case 3 turns.')
		end
	end
	
	if data.items['DoubleGold'] then
		if love.clicked(x,y,608,874,170,260) then
			gStateMachine:change('itemDescriptions', 'This item doubles the gold gained for the level it is activated on. This item has to be used during the level.')
		end
	end
	if data.items['Electricity'] then
		if love.clicked(x,y,912,1178,170,260) then
			gStateMachine:change('itemDescriptions', 'This item stuns every alien in the entire battlefield for 1 turn. Other aliens could spawn and move. When an alien is stunned, it cannot move for a specific amount of turns, for this item,it is 1.')
		end
	end
	if data.items['Bomb'] then
		if love.clicked(x,y,304,570,451, 541) then
			gStateMachine:change('itemDescriptions', '“This item allows the user to skip 2 stages in a level. When activated, the user is instantly transported to the 3rd stage, or if activated at 2cd or 3rd then finishes the level.')
		end
	end

end
