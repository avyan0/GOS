WeaponsScreenState = Class{__includes = BaseState}

function WeaponsScreenState:render()

	push:apply('start')
	
		love.drawBottom(3)

		love.graphics.setFont(gFonts['weapons1'])
		love.graphics.setColor(40/255,200/255,245/255)
		love.graphics.rectangle('fill', 0,0,640,285)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf("Common",0,90,640,'center')

		love.graphics.setColor(200/255,100/255,50/255)
		love.graphics.rectangle('fill', 640,0,640,285)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf("Rare",640,90,640,'center')

		love.graphics.setColor(170/255,0/255,170/255)
		love.graphics.rectangle('fill', 0,285,640,285)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf("Scarce",0,390,640,'center')

		love.graphics.setColor(215/255,190/255,10/255)
		love.graphics.rectangle('fill', 640,285,640,285)
		love.graphics.setColor(0,0,0,1)
		love.graphics.printf("God",640,390,640,'center')
		love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

   	push:apply('end')

end

function WeaponsScreenState:mousePressed(x,y)
	love.bottomClicked(x,y)

	if love.clicked(x,y,0,640,0,285) then
		gStateMachine:change('commonWeapons')
	end

	if love.clicked(x,y,640,1280,0,285) then
		gStateMachine:change('rareWeapons')
	end

	if love.clicked(x,y,0,640,285,570) then
		gStateMachine:change('scarceWeapons')
	end
	
	if love.clicked(x,y,640,1280,285,570) then
		gStateMachine:change('godWeapons')
	end

end

function WeaponsScreenState:exit() end
function WeaponsScreenState:enter() end