ProfileScreenState = Class{__includes = BaseState}


-- ADD PROFILE PIC
function ProfileScreenState:render()
	push:apply('start')
	love.graphics.setColor(100/255,79/255,255/255,1)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	love.drawBack(100,151,255)

	love.graphics.setColor(100/255, 170/255, 255/255)
	love.graphics.setFont(gFonts['game'])
	love.graphics.printf('Wins: '..tostring(data.wins),0,150,600,'center')
	love.graphics.printf('Time Played: '..tostring(data.time),670,150,600,'center')
	love.graphics.printf('Gold: '..tostring(data.gold),0,290,600,'center')
	love.graphics.printf('Gems: '..tostring(data.gems),670,290,600,'center')
	love.graphics.printf('Planet Unlocked: '..tostring(data.planet),0,430,600,'center')
	love.graphics.printf('Aliens Killed: '..tostring(data.aliensKilled),670,430,600,'center')
	love.graphics.printf('Matches Played: '..tostring(data.matchesPlayed),0,570,600,'center')
	love.graphics.printf('Save Number: '..tostring(data.saveNumber),670,570,600,'center')

	love.setBright()
	push:apply('end')
end

function ProfileScreenState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('home')
	end
end