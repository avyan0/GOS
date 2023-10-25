WeaponInfo = Class{__includes = BaseState}
function WeaponInfo:render()
	push:apply('start')
	love.graphics.setColor(40/255,200/255,245/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	love.drawBack(0,0,0)

	love.graphics.setColor(0,0,0)
	love.graphics.setFont(gFonts['game45'])
	love.graphics.printf('Damage: '..tostring(self.weapon1.damage * ((data.upgrades[self.weapon1.name] * 0.1) + 1) ),0,380,VIRTUAL_WIDTH-30,'center')
	love.graphics.printf('Special Effect:'..tostring(self.weapon1.specialEffect),0,470,VIRTUAL_WIDTH-30,'center')
	love.graphics.printf('Cooldown:'..tostring(self.weapon1.cooldown) .. ' turns',0,585,VIRTUAL_WIDTH-30,'center')
	love.graphics.printf('Upgrades:'..tostring(data.upgrades[self.weapon1.name]),0,650,VIRTUAL_WIDTH-30,'center')

	love.graphics.setFont(gFonts['game45'])
	love.graphics.printf(tostring(self.weapon1.name),0,75,VIRTUAL_WIDTH,'center')

	love.graphics.setColor(1,1,1)
	local w = self.weapon1.image:getWidth()
	local h = self.weapon1.image:getWidth()
	love.graphics.draw(self.weapon1.image,VIRTUAL_WIDTH/2 - 135,150,0,180/(w-1),150/(h-1))
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

	push:apply('end')
end

function WeaponInfo:enter(weapon)
	self.weapon1 = {}
	self.weapon1.damage = weapon.damage
	self.weapon1.specialEffect = weapon.specialEffect
	self.weapon1.cooldown = weapon.cooldown
	self.weapon1.name = weapon.name
	self.weapon1.image = weapon.image
	self.weapon1.rarity = weapon.rarity
end

function WeaponInfo:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change(self.weapon1.rarity..'Weapons')
	end
end
