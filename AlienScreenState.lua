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
		if( data.aliensUnlocked >= 8) and slide == 0 then
		love.graphics.polygon('fill',1200,480,1200,540,1260,510)
		end
		if( data.aliensUnlocked >= 16) and slide == 1 then
			love.graphics.polygon('fill',1200,480,1200,540,1260,510)
			end
	end
	if slide > 0 then 
		love.graphics.polygon('fill',80,480,80,540,20,510)
	end

	love.graphics.setFont(gFonts['game30'])
	setColor(84/255,195/255,51/255)
	if slide == 0 then
		love.graphics.printf('Joe',101,200,200,'center')
		love.graphics.printf('Gen57',392,200,200,'center')
		if data.aliensUnlocked >=3 then
		love.graphics.printf('President',683,200,200,'center')
		end
		if data.aliensUnlocked >=4 then
		love.graphics.printf('King',974,200,200,'center')
		end
		if data.aliensUnlocked >=5 then
		love.graphics.printf('DJ',101,435,200,'center')
		end
		if data.aliensUnlocked >=6 then
		love.graphics.printf('Space Fence',392,435,200,'center')
		end
		if data.aliensUnlocked >=7 then
		love.graphics.printf('Spaceship',683,435,200,'center')
		end
		if data.aliensUnlocked >=8 then
		love.graphics.printf('VR Workout',974,435,200,'center')
		end
	end
	if slide == 1 then
		if data.aliensUnlocked >=9 then
		love.graphics.printf('Old Granny',101,200,200,'center')
		end
		if data.aliensUnlocked >=10 then
		love.graphics.printf('Albot',392,200,200,'center')
		end
		if data.aliensUnlocked >=11 then
		love.graphics.printf('Jumper',683,200,200,'center')
		end
		if data.aliensUnlocked >=12 then
		love.graphics.printf('Giant',974,200,200,'center')
		end
		if data.aliensUnlocked >=13 then
		love.graphics.printf('Gardener',101,435,200,'center')
		end
		if data.aliensUnlocked >=14 then
		love.graphics.printf('Army',392,435,200,'center')
		end
		if data.aliensUnlocked >=15 then
		love.graphics.printf('Morpher',683,435,200,'center')
		end
		if data.aliensUnlocked >=16 then
		love.graphics.printf('Fusion',974,435,200,'center')
		end
	end
	if slide == 2 then
		love.graphics.setFont(gFonts['game25'])
		if data.aliensUnlocked >=17 then
		love.graphics.printf('Common Crippler',101,200,200,'center')
		end
		if data.aliensUnlocked >=18 then
		love.graphics.printf('Interdimentional',974,435,200,'center')
		end
		love.graphics.setFont(gFonts['game30'])
		if data.aliensUnlocked >=19 then
		love.graphics.printf('Splashfest',392,200,200,'center')
		end
		if data.aliensUnlocked >=20 then
		love.graphics.printf('Virus',683,200,200,'center')
		end
		if data.aliensUnlocked >=21 then
		love.graphics.printf('Guardian',974,200,200,'center')
		end
		if data.aliensUnlocked >=22 then
		love.graphics.printf('Dark Arts',101,435,200,'center')
		end
		if data.aliensUnlocked >=23 then
		love.graphics.printf('Rare',392,435,200,'center')
		end
		if data.aliensUnlocked >=24 then
		love.graphics.printf('Protected',683,435,200,'center')
		end
	end
	if slide == 3 then
		if data.aliensUnlocked >=25 then
		love.graphics.printf('Scarce',101,200,200,'center')
		end
		if data.aliensUnlocked >=26 then
		love.graphics.printf('The Heval God',392,200,200,'center')
		end
		if data.aliensUnlocked >=27 then
		love.graphics.printf('God of Space',683,200,200,'center')
		end
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
	if slide == 0 then
		if love.clicked(x,y,1200,1260,480,540) and data.aliensUnlocked>=9 then
			slide = slide + 1
		end
	elseif slide == 1 then
		if love.clicked(x,y,1200,1260,480,540) and data.aliensUnlocked>=17 then
			slide = slide + 1
		end
	elseif slide == 2 then
		if love.clicked(x,y,1200,1260,480,540) and data.aliensUnlocked>=25 then
			slide = slide + 1
		end
	end
	if slide ~= 0 then
		if love.clicked(x,y,20,80,480,540) then
			slide = slide -1
		end
	end
	if slide == 0 then
		if love.clicked(x,y,101,301,115,235) then
			gStateMachine:change('alienInfo',Aliens['Joe'])
		elseif love.clicked(x,y,392,592,115,235) then
			gStateMachine:change('alienInfo',Aliens['Gen57'])
		elseif love.clicked(x,y,683,883,115,235) and data.aliensUnlocked >= 3 then
			gStateMachine:change('alienInfo',Aliens['President'])
		elseif love.clicked(x,y,974,1174,115,235) and data.aliensUnlocked >= 4 then
			gStateMachine:change('alienInfo',Aliens['King'])
		elseif love.clicked(x,y,101,301,350,470)and data.aliensUnlocked >= 5 then
			gStateMachine:change('alienInfo',Aliens['DJ'])
		elseif love.clicked(x,y,392,592,350,470)and data.aliensUnlocked >= 6 then
			gStateMachine:change('alienInfo',Aliens['SpaceFence'])
		elseif love.clicked(x,y,683,883,350,470)and data.aliensUnlocked >= 7 then
			gStateMachine:change('alienInfo',Aliens['Spaceship'])
		elseif love.clicked(x,y,974,1174,350,470)and data.aliensUnlocked >= 8 then
			gStateMachine:change('alienInfo',Aliens['VRWorkout'])
		end
	elseif slide == 1 then
		if love.clicked(x,y,101,301,115,235)and data.aliensUnlocked >= 9 then
			gStateMachine:change('alienInfo',Aliens['OldGranny'])
		elseif love.clicked(x,y,392,592,115,235)and data.aliensUnlocked >= 10 then
			gStateMachine:change('alienInfo',Aliens['Albot'])
		elseif love.clicked(x,y,683,883,115,235)and data.aliensUnlocked >= 11 then
			gStateMachine:change('alienInfo',Aliens['Jumper'])
		elseif love.clicked(x,y,974,1174,115,235)and data.aliensUnlocked >= 12 then
			gStateMachine:change('alienInfo',Aliens['Giant'])
		elseif love.clicked(x,y,101,301,350,470)and data.aliensUnlocked >= 13 then
			gStateMachine:change('alienInfo',Aliens['Gardener'])
		elseif love.clicked(x,y,392,592,350,470)and data.aliensUnlocked >= 14 then
			gStateMachine:change('alienInfo',Aliens['Army'])
		elseif love.clicked(x,y,683,883,350,470)and data.aliensUnlocked >= 15 then
			gStateMachine:change('alienInfo',Aliens['Morpher'])
		elseif love.clicked(x,y,974,1174,350,470)and data.aliensUnlocked >= 16 then
			gStateMachine:change('alienInfo',Aliens['Fusion'])
		end
	elseif slide == 2 then
		if love.clicked(x,y,101,301,115,235)and data.aliensUnlocked >= 17 then
			gStateMachine:change('alienInfo',Aliens['CommonCrippler'])
		elseif love.clicked(x,y,392,592,115,235)and data.aliensUnlocked >= 18 then
			gStateMachine:change('alienInfo',Aliens['Splashfest'])
		elseif love.clicked(x,y,683,883,115,235)and data.aliensUnlocked >= 19 then
			gStateMachine:change('alienInfo',Aliens['Virus'])
		elseif love.clicked(x,y,974,1174,115,235)and data.aliensUnlocked >= 20 then
			gStateMachine:change('alienInfo',Aliens['Guardian'])
		elseif love.clicked(x,y,101,301,350,470)and data.aliensUnlocked >= 21 then
			gStateMachine:change('alienInfo',Aliens['DarkArts'])
		elseif love.clicked(x,y,392,592,350,470)and data.aliensUnlocked >= 22 then
			gStateMachine:change('alienInfo',Aliens['Rare'])
		elseif love.clicked(x,y,683,883,350,470)and data.aliensUnlocked >= 23 then
			gStateMachine:change('alienInfo',Aliens['Protected'])
		elseif love.clicked(x,y,974,1174,350,470)and data.aliensUnlocked >= 24 then
			gStateMachine:change('alienInfo',Aliens['Interdimentional'])
		end
	elseif slide == 3 then
		if love.clicked(x,y,101,301,115,235)and data.aliensUnlocked >= 25 then
			gStateMachine:change('alienInfo',Aliens['Scarce'])
		elseif love.clicked(x,y,392,592,115,235)and data.aliensUnlocked >= 26 then
			gStateMachine:change('alienInfo',Aliens['TheHevalGod'])
		elseif love.clicked(x,y,683,883,115,235)and data.aliensUnlocked >= 27 then
			gStateMachine:change('alienInfo',Aliens['GodOfSpace'])
		end
	end
end
