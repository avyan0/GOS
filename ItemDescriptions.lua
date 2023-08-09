ItemDescriptions = Class{__includes = BaseState}

function ItemDescriptions:render()
	if hi == 'The item places a wall on any tile of your choosing. This wall blocks the movement of almost all aliens for a single turn, which means that if an alien is on the tile before the wall, it will be prevented from moving on that space for one turn.' then
		var = data.walls
	end
	if hi == 'Kills one random alien on screen' then
		var = data.teleporter
	end
	if hi == 'This item allows the user to skip a stage in a level. When activated, the user is instantly transported to the next stage, or if activated at the third stage, then finishes the level.' then
		var = data.retreat
	end
	if hi == 'All damage is boosted by 50% for the rest of the stage' then
		var = data.protection
	end
	if hi == 'This item stuns every alien in the entire battlefield for 1 turn. Other aliens could spawn and move. When an alien is stunned, it cannot move for a specific amount of turns, for this item,it is 1.' then
		var = data.electricity
	end
	if hi == 'This item doubles the gold gained for the level it is activated on. This item has to be used during the level.' then
		var = data.doubleGold
	end
	if hi == 'This item stuns every alien in a random lane for 3 turns. Other aliens could spawn in that lane and move. When an alien is stunned, it cannot move for a specific amount of time, in this case 3 turns.' then
		var = data.zap
	end
	if hi == '“This item allows the user to skip 2 stages in a level. When activated, the user is instantly transported to the 3rd stage, or if activated at 2cd or 3rd then finishes the level.' then
		var = data.bomb
	end
	love.graphics.setColor(144/255,238/255,144/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.graphics.setColor(1,1,1)
	love.graphics.circle('fill',333,315,44)
	love.graphics.circle('fill',373,367,19)
	love.graphics.rectangle('fill',607,207,519,219)

	love.graphics.setColor(0,0,0)
	love.graphics.setFont(gFonts['itemsNumbers'])
	love.graphics.printf(var,364,360,38)
	love.graphics.setColor(0,0,0)
	love.graphics.setFont(gFonts['items'])
	love.graphics.printf(hi,607,207,519)
	love.drawBack(0,0,0)

	love.graphics.setColor(1,1,1)
	local w = gTextures['lockWeapons']:getWidth()
	local h = gTextures['lockWeapons']:getHeight()
	love.graphics.draw(gTextures['lockWeapons'],305,265,78/(w-1),78/(h-1))
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
end

function ItemDescriptions:enter(txt)
	hi = txt
end

function ItemDescriptions:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
		gStateMachine:change('items')
	end
end
