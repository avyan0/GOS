HomeScreenState = Class{__includes = BaseState}

function HomeScreenState:render()

	push:apply('start')

	love.drawBottom(2)

	love.graphics.setColor(52/255,52/255,52/255,1)
	love.graphics.rectangle('fill', 0, 00, 400,150)
	love.graphics.setColor(200/255,120/255,150/255,1)
	love.graphics.setFont(gFonts['bottomHome'])
	love.graphics.printf('Settings', 0, 30, 400,'center')
	love.graphics.rectangle('line', 0, 0, 400,150)
	

	love.graphics.setColor(52/255,52/255,52/255,1)
	love.graphics.rectangle('fill', 440, 00, 400,150)
	love.graphics.setColor(0/255,255/255,0/255,1)
	love.graphics.setFont(gFonts['bottomHome'])
	love.graphics.printf('Items', 440, 30, 400,'center')
	love.graphics.rectangle('line', 440, 0, 400,150)




	local backgroundWidth = data.profile:getWidth()
    local backgroundHeight = data.profile:getHeight()
	

	love.graphics.setColor(52/255,52/255,52/255,1)
	love.graphics.rectangle('fill', 880, 00, 400,150)
	love.graphics.setColor(100/255,79/255,255/255,1)
	love.graphics.setFont(gFonts['bottomHome'])
	love.graphics.printf(data.name, 880, 30, 400,'center')
	love.graphics.rectangle('line', 880, 0, 400,150)
	love.graphics.setColor(52/255,52/255,52/255,1)
	love.graphics.draw(data.profile,1160,30,0,80 / (backgroundWidth - 1), 60 / (backgroundHeight - 1))

	love.graphics.setColor(1,1,1,1)

	local backgroundWidth1 = gTextures['planet1']:getWidth()
    local backgroundHeight1 = gTextures['planet1']:getHeight()
    love.graphics.draw(gTextures['planet1'],0,270,0,180 / (backgroundWidth1 - 1), 130 / (backgroundHeight1 - 1))

	if data.planet >= 2 then
    local backgroundWidth2 = gTextures['planet2']:getWidth()
    local backgroundHeight2 = gTextures['planet2']:getHeight()
    love.graphics.draw(gTextures['planet2'],220,270,0,180 / (backgroundWidth2 - 1), 130 / (backgroundHeight2 - 1))
	end
	if data.planet >=3 then
    local backgroundWidth3 = gTextures['planet3']:getWidth()
    local backgroundHeight3 = gTextures['planet3']:getHeight()
    love.graphics.draw(gTextures['planet3'],440,270,0,180 / (backgroundWidth3 - 1), 130 / (backgroundHeight3 - 1))
	end
	if data.planet >= 4 then
    local backgroundWidth4 = gTextures['planet4']:getWidth()
    local backgroundHeight4 = gTextures['planet4']:getHeight()
    love.graphics.draw(gTextures['planet4'],660,270,0,180 / (backgroundWidth4 - 1), 130 / (backgroundHeight4 - 1))
	end
	if data.planet >=5 then
    local backgroundWidth5 = gTextures['planet5']:getWidth()
    local backgroundHeight5 = gTextures['planet5']:getHeight()
    love.graphics.draw(gTextures['planet5'],880,270,0,180 / (backgroundWidth5 - 1), 130 / (backgroundHeight5 - 1))
	end
	if data.planet >=6 then
    local backgroundWidth6 = gTextures['planet6']:getWidth()
    local backgroundHeight6 = gTextures['planet6']:getHeight()
    love.graphics.draw(gTextures['planet6'],1100,270,0,180 / (backgroundWidth6 - 1), 130 / (backgroundHeight6 - 1))
	end
    love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')

end

function HomeScreenState:mousePressed(x,y)
	x = love.mouse.getX()
	y = love.mouse.getY()

	love.bottomClicked(x,y)

	if love.clicked(x,y,0,400,0,150) then
		gStateMachine:change('settings')
	end

	if love.clicked(x,y,440,840,0,150) then
		gStateMachine:change('items')
	end

	if love.clicked(x,y,1160,1240,30,90) then
		gStateMachine:change('profileChoose')
	elseif love.clicked(x,y,880,1280,0,150) then
		gStateMachine:change('profile')
	end
	
	

	if love.clicked(x,y,0,180,270,400) then
		gStateMachine:change('p1Level')
	end

	if data.planet >= 2 then
	if love.clicked(x,y,220,400,270,400) then
		gStateMachine:change('p2Level')
	end end

	if data.planet >= 3 then
	if love.clicked(x,y,440,620,270,400) then
		gStateMachine:change('p3Level')
	end end

	if data.planet >= 4 then
	if love.clicked(x,y,660,840,270,400) then
		gStateMachine:change('p4Level')
	end end

	if data.planet >= 5 then
	if love.clicked(x,y,880,1060,270,400) then
		gStateMachine:change('p5Level')
	end end

	if data.planet >= 6 then
	if love.clicked(x,y,1100,1280,270,400) then
		gStateMachine:change('p6Level')
	end end
end



function HomeScreenState:exit() end
function HomeScreenState:enter() end
