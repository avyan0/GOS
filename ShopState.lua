ShopState = Class{__includes = BaseState}

function ShopState:render()
	push:apply('start')
	love.graphics.setColor(1,230/255,230/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.drawBottom(4)

	love.graphics.setFont(gFonts['shop'])
	love.graphics.setColor(0,0,0)
	love.graphics.printf('Spin',15, 140, 250, 'center')
	love.graphics.printf('Spin',265, 140, 250, 'center')
	love.graphics.printf('Spin',515, 140, 250, 'center')
	love.graphics.printf('Spin',765, 140, 250, 'center')
	love.graphics.printf('Spin',1015, 140, 250, 'center')

	love.graphics.printf('Common',15, 80, 250, 'center')
	love.graphics.printf('Rare',265, 80, 250, 'center')
	love.graphics.printf('Scarce',515, 80, 250, 'center')
	love.graphics.printf('God',765, 80, 250, 'center')
	love.graphics.printf('Item',1015, 80, 250, 'center')

	love.graphics.printf('25 Gold',15, 470, 250, 'center')
	love.graphics.printf('45 Gold',265, 470, 250, 'center')
	love.graphics.printf('100 Gold',515, 470, 250, 'center')
	love.graphics.printf('270 Gold',765, 470, 250, 'center')
	love.graphics.printf('25 Gold',1015, 470, 250, 'center')

	love.graphics.setFont(gFonts['shop'])
	love.graphics.printf(tostring(data.gold)..' Gold',0, 30, VIRTUAL_WIDTH, 'center')

	local w = gTextures['wheel']:getWidth()
	local h = gTextures['wheel']:getHeight()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(gTextures['wheel'],20,180,100/(w-1),200/(h-1))
	love.graphics.draw(gTextures['wheel'],270,180,100/(w-1),200/(h-1))
	love.graphics.draw(gTextures['wheel'],520,180,100/(w-1),200/(h-1))
	love.graphics.draw(gTextures['wheel'],770,180,100/(w-1),200/(h-1))
	love.graphics.draw(gTextures['wheel'],1020,180,100/(w-1),200/(h-1))


	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	push:apply('end')
end

function ShopState:mousePressed(x,y)
	if love.clicked(x,y,40,225,200,400) then
		gStateMachine:change('spin','Common')
	end
	love.bottomClicked(x,y)
	if love.clicked(x,y,290,475,200,400) then
		gStateMachine:change('spin','Rare')
	end
	if love.clicked(x,y,540,725,200,400) then
		gStateMachine:change('spin','Scarce')
	end
	if love.clicked(x,y,790,985,200,400) then
		gStateMachine:change('spin','God')
	end
	if love.clicked(x,y,1040,1225,200,400) then
		gStateMachine:change('spin','Item')
	end
end