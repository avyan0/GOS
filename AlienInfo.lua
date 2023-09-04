AlienInfo = Class{__includes = BaseState}
function AlienInfo:render()
	push:apply('start')
	setColor(85/255,0,0)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.drawBack(0,0,0)

	love.graphics.setColor(0,0,0)
	love.graphics.setFont( love.graphics.newFont('states/homeState/things/shop.otf',40))
	love.graphics.printf('Health: '..tostring(self.weapon1.health),0,380,VIRTUAL_WIDTH-30,'center')
	love.graphics.printf('Ability:'..tostring(self.weapon1.desc),0,470,VIRTUAL_WIDTH-30,'center')
	love.graphics.printf('Hevalten:'..tostring(self.weapon1.hevalten),0,560,VIRTUAL_WIDTH-30,'center')

	love.graphics.setFont( love.graphics.newFont('states/homeState/things/shop.otf',50))
	love.graphics.printf(tostring(self.weapon1.name),0,75,VIRTUAL_WIDTH,'center')

	love.graphics.setColor(1,1,1)
	--[[local w = self.weapon1.image:getWidth()
	local h = self.weapon1.image:getWidth()
	love.graphics.draw(self.weapon1.image,VIRTUAL_WIDTH/2 - 135,150,0,180/(w-1),150/(h-1))--]]
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	push:apply('end')
end

function AlienInfo:enter(weapon)
	self.weapon1 = {}
	self.weapon1.health = weapon.health
    if weapon.hevalten then
        self.weapon1.hevalten = 'Yes'
    else
        self.weapon1.hevalten = 'No'
    end
	self.weapon1.name = weapon.name
	self.weapon1.desc = weapon.desc
end

function AlienInfo:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('aliens')
	end
end