PauseState = Class{__includes = BaseState}

function PauseState:init()
	local p = {}
	p.width = 15
	p.orientation = 'horizontal'
	p.track = 'line'
	p.knob = 'rectangle'
	brightSlider = newSlider(500, 160, 260, data.brightness, 5, 100, function (v) data.brightness = (v-(v%1)) end,p) -- set brightness
	local q = {}
	q.width = 15
	q.orientation = 'horizontal'
	q.track = 'rectangle'
	q.knob = 'rectangle'
	volumeSlider = newSlider(930,60,400,data.volume,0,100,function (v) love.audio.setVolume(v/100) data.volume = v - (v%1) end,q)
	sfxSlider = newSlider(930,105,400,data.sfx,0,100,function(v) data.sfx = v - v%1 end, q) -- sfx volume
end

function PauseState:render()
	push:apply('start')
	love.graphics.setColor(153/255,153/255,153/255)
	love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	love.drawBack(1,1,1)
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('line',360,0,300,180)
	love.graphics.rectangle('line',680,0,520,180)
	love.graphics.rectangle('line',0,240,300,180)
	love.graphics.setColor(238/255,238/255,238/255)
	love.graphics.rectangle('fill',75,270,30,30)
	love.graphics.rectangle('fill',105,270,30,30)
	love.graphics.rectangle('fill',135,270,30,30)
	love.graphics.rectangle('fill',165,270,30,30)
	love.graphics.rectangle('fill',195,270,30,30)
	love.graphics.rectangle('fill',75,300,30,30)
	love.graphics.rectangle('fill',105,300,30,30) -- switch weapon control to mouse
	love.graphics.rectangle('fill',135,300,30,30) -- same thing
	love.graphics.rectangle('fill',165,300,30,30) -- same thing
	love.graphics.rectangle('fill',195,300,30,30) -- same thing
	love.graphics.rectangle('fill',75,330,30,30)  -- switch weapon control to keyboard
	love.graphics.rectangle('fill',105,330,30,30) -- same thing
	love.graphics.rectangle('fill',135,330,30,30) -- same thing
	love.graphics.rectangle('fill',165,330,30,30) -- same thing
	love.graphics.rectangle('fill',195,330,30,30) -- same thing
	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('line', 960,240,300,180)
	love.graphics.rectangle('line',470,240,300,180)
	love.graphics.setColor(238/255,238/255,238/255)
	love.graphics.rectangle('fill',480,345,120,30) -- change language to english, highlight current language in use
	love.graphics.rectangle('fill',480,285,120,30) -- same thing but spanish
	love.graphics.rectangle('fill',640,285,120,30) -- same thing but chinese
	love.graphics.rectangle('fill',640,345,120,30) -- same thing but hindi
	love.graphics.rectangle('fill', 1000,300,220,90) -- takes to tutorial

	love.graphics.setFont(gFonts['settingsBig'])
	love.graphics.setColor(0,0,0)
	love.graphics.printf('Brightness',360,10,300,'center')
	love.graphics.printf('Brightness (' ..tostring(data.brightness) .. '%)',360,130,300,'center')
	love.graphics.setFont(gFonts['settingsSmall'])
	love.graphics.printf('0%',380,1140,640,'left')
	love.graphics.setFont(gFonts['settingsBig'])
	love.graphics.print('Audio',680,0)
	love.graphics.printf('Master Volume('..tostring(data.volume)..'%)',730,25,400,'center')
	love.graphics.printf('SFX Volume('..tostring(data.sfx)..'%)',730,70,400,'center')
	love.graphics.printf('Weapon Controls',0,240,300,'center')
	love.graphics.setFont(gFonts['settingsSmall'])
	love.graphics.printf('1',75,280,30,'center')
	love.graphics.printf('2',105,280,30,'center')
	love.graphics.printf('3',135,280,30,'center')
	love.graphics.printf('4',165,280,30,'center')
	love.graphics.printf('5',195,280,30,'center')
	love.graphics.setFont(gFonts['settingsBig'])
	love.graphics.printf('Language',470,255,300,'center')
	love.graphics.printf('English',480,345,120,'center')
	love.graphics.printf('Spanish',480,285,120,'center')
	love.graphics.printf('Hindi',640,345,120,'center')
	love.graphics.printf('Chinese',640,285,120,'center')
	love.graphics.printf('QUIT',960,255,300,'center')
	love.graphics.printf('Click Here To Exit Game',1000,315,220,'center')

	local w1 = gTextures['mouse']:getWidth()
	local h1 = gTextures['mouse']:getWidth()
	love.graphics.draw(gTextures['mouse'],85,300,20/w1,30/h1)
	love.graphics.draw(gTextures['mouse'],105,300,20/w1,30/h1)
	love.graphics.draw(gTextures['mouse'],135,300,20/w1,30/h1)
	love.graphics.draw(gTextures['mouse'],165,300,20/w1,30/h1)
	love.graphics.draw(gTextures['mouse'],195,300,20/w1,30/h1)
	local w2 = gTextures['keyboard']:getWidth()
	local h2 = gTextures['keyboard']:getWidth()
	love.graphics.draw(gTextures['keyboard'],75,330,20/w2,30/h2)
	love.graphics.draw(gTextures['keyboard'],105,330,20/w2,30/h2)
	love.graphics.draw(gTextures['keyboard'],135,330,20/w2,30/h2)
	love.graphics.draw(gTextures['keyboard'],165,330,20/w2,30/h2)
	love.graphics.draw(gTextures['keyboard'],195,330,20/w2,30/h2)

    love.graphics.setFont(gFonts['game18'])
    if data.walls > 0 then
        love.graphics.printf('Walls',170,500,60,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',200,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.walls,170,542,60,'center')
    end
    if data.teleporter > 0 then
        love.graphics.print('Teleporter',285,500)
        setColor(1,1,1)
        love.graphics.circle('fill',330,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.teleporter,300,542,60,'center')
    end
    if data.retreat > 0 then
        love.graphics.printf('Retreat',420,500,80,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',460,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.retreat,430,542,60,'center')
    end
    if data.protection > 0 then
        love.graphics.printf('Protection',535,500,110,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',590,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.protection,560,542,60,'center')
    end
    if data.electricity > 0 then
        love.graphics.printf('Electricity',665,500,110,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',720,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.electricity,690,542,60,'center')
    end
    if data.doubleGold > 0 then
        love.graphics.printf('Double Gold',795,500,110,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',850,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.doubleGold,820,542,60,'center')
    end
    if data.zap > 0 then
        love.graphics.printf('Zap',925,500,110,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',980,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.zap,950,542,60,'center')
    end
    if data.bomb > 0 then
        love.graphics.printf('Bomb',1055,500,110,'center')
        setColor(1,1,1)
        love.graphics.circle('fill',1110,550,30)
        setColor(0,0,0)
        love.graphics.printf(data.bomb,1080,542,60,'center')
    end
    

	PauseState:draw()
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')
end

function PauseState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('game')
	end
    if love.clicked(x,y,1000,1220,300,390) then
        gStateMachine:change('game','quit')
    end
    if data.walls > 0 then
        if love.clicked(x,y,170,230,520,580) then
            data.walls = data.walls - 1
        end
    end
    if data.teleporter > 0 then
        if love.clicked(x,y,300,360,520,580) then
            data.teleporter = data.teleporter - 1
            gStateMachine:change('game','teleporter')
        end
    end
    if data.retreat > 0 then
        if love.clicked(x,y,430,490,520,580) then
            data.retreat = data.retreat - 1
            gStateMachine:change('game','retreat')
        end
    end
    if data.protection > 0 then
        if love.clicked(x,y,560,620,520,580) then
            data.protection = data.protection - 1
        end
    end
    if data.electricity > 0 then
        if love.clicked(x,y,690,750,520,580) then
            data.electricity = data.electricity - 1
            gStateMachine:change('game','electricity')
        end
    end
    if data.doubleGold > 0 then
        if love.clicked(x,y,820,880,520,580) then
            data.doubleGold = data.doubleGold - 1
            gStateMachine:change('game','gold')
        end
    end
    if data.zap > 0 then
        if love.clicked(x,y,950,1010,520,580) then
            data.zap = data.zap - 1
            gStateMachine:change('game','zap')
        end
    end
    if data.bomb > 0 then
        if love.clicked(x,y,1080,1140,520,580) then
            data.bomb = data.bomb - 1
            gStateMachine:change('game','bomb')
        end
    end
end

function PauseState:update(dt)
	brightSlider:update()
	volumeSlider:update()
	sfxSlider:update()
end

function PauseState:draw()
	love.graphics.setColor(0,0,0)
	brightSlider:draw()
	volumeSlider:draw()
	sfxSlider:draw()
end
