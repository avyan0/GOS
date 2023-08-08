AlienScreenState = Class{__includes = BaseState}

local slide = 0

function AlienScreenState:render()
	setColor(85/255,0,0)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)	
	love.drawBottom(1)

	setColor(222/255,184/255,135/255)
	love.graphics.rectangle('fill',106-5,115,200,120)
	love.graphics.rectangle('fill',397-5,115,200,120)
	love.graphics.rectangle('fill',688-5,115,200,120)
	if slide ~= 3 then
		love.graphics.rectangle('fill',979-5,115,200,120)
		love.graphics.rectangle('fill',106-5,350,200,120)
		love.graphics.rectangle('fill',397-5,350,200,120)
		love.graphics.rectangle('fill',688-5,350,200,120)
		love.graphics.rectangle('fill',979-5,350,200,120)
	end

	setColor(1,.1,.1)
	if slide < 3 then 
		love.graphics.polygon('fill',1200,480,1200,540,1260,510)
	end
	if slide > 0 then 
		love.graphics.polygon('fill',80,480,80,540,20,510)
	end

	love.graphics.setFont(gFonts['game25'])
	setColor(84/255,195/255,51/255)
	if slide == 0 then
		love.graphics.printf('Joe',101,200,200,'center')
		love.graphics.printf('Monster',392,200,200,'center')
		love.graphics.printf('President',683,200,200,'center')
		love.graphics.printf('King',974,200,200,'center')
		love.graphics.printf('Bob',101,435,200,'center')
		love.graphics.printf('Shielder',392,435,200,'center')
		love.graphics.printf('Spacecraft',683,435,200,'center')
		love.graphics.printf('Speed',974,435,200,'center')
	end
	if slide == 1 then
		love.graphics.printf('Grandpa',101,200,200,'center')
		love.graphics.printf('Spawner',392,200,200,'center')
		love.graphics.printf('Wall Hopper',683,200,200,'center')
		love.graphics.printf('Giant',974,200,200,'center')
		love.graphics.printf('Weed Wacker',101,435,200,'center')
		love.graphics.printf('Revalutionist',392,435,200,'center')
		love.graphics.printf('Transmuter',683,435,200,'center')
		love.graphics.printf('Fusion Master',974,435,200,'center')
	end
	if slide == 2 then
		love.graphics.printf('Common Crippler',101,200,200,'center')
		love.graphics.printf('Splashscreen',392,200,200,'center')
		love.graphics.printf('Saboteur',683,200,200,'center')
		love.graphics.printf('Guardian',974,200,200,'center')
		love.graphics.printf('Evolutionist',101,435,200,'center')
		love.graphics.printf('Blocked',392,435,200,'center')
		love.graphics.printf('Suppressionist',683,435,200,'center')
		love.graphics.printf('dimentional',974,435,200,'center')
	end
	if slide == 3 then
		love.graphics.printf('Faminize',101,200,200,'center')
		love.graphics.printf('The Hevalgod',392,200,200,'center')
		love.graphics.printf('God of Space',683,200,200,'center')
	end
	



	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
end

function AlienScreenState:mousePressed(x,y)
	if love.clicked(x,y,0,290,570,720) then
        gStateMachine:change('aliens')
    end

    if love.clicked(x,y,330,620,570,720) then
        gStateMachine:change('home')
    end

    if love.clicked(x,y,660,950,570,720) then 
        gStateMachine:change('weapons')
    end
    if love.clicked(x,y,990,1280,570,720) then
        gStateMachine:change('shop')
    end
	if slide ~= 3 then
		if love.clicked(x,y,1200,1260,480,540) then
			slide = slide + 1
		end
	end
	if slide ~= 0 then
		if love.clicked(x,y,20,80,480,540) then
			slide = slide -1
		end
	end
end