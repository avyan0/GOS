SettingsScreenState = Class{__includes = BaseState}
function SettingsScreenState:init()
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
function SettingsScreenState:render()
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
	love.graphics.rectangle('line',0,570,300,150)
	love.graphics.rectangle('line',980,570,300,150)
	love.graphics.rectangle('line',470,240,300,180)
	love.graphics.setColor(238/255,238/255,238/255)
	love.graphics.rectangle('fill',480,345,120,30) -- change language to english, highlight current language in use
	love.graphics.rectangle('fill',480,285,120,30) -- same thing but spanish
	love.graphics.rectangle('fill',640,285,120,30) -- same thing but chinese
	love.graphics.rectangle('fill',640,345,120,30) -- same thing but hindi
	love.graphics.rectangle('fill', 1000,300,220,90) -- takes to tutorial
	love.graphics.rectangle('fill',40,600,220,90) -- takes to credit page
	love.graphics.rectangle('fill',1020,600,220,90) -- takes to switch account page

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
	love.graphics.printf('How To Play',990,255,290,'center')
	love.graphics.printf('Click Here To Go To The Tutorial',1000,315,220,'center')
	love.graphics.printf('Credits',0,570,300,'center')
	love.graphics.printf('Click here to go to credits',40,630,220,'center')
	love.graphics.printf('Account',980,570,300,'center')
	love.graphics.printf('Click here to create/switch accounts',1020,615,220,'center')

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

	SettingsScreenState:draw()
	love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
	push:apply('end')
end

function SettingsScreenState:mousePressed(x,y)
	if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('home')
	end
end

function SettingsScreenState:update(dt)
	brightSlider:update()
	volumeSlider:update()
	sfxSlider:update()
end

function SettingsScreenState:draw()
	love.graphics.setColor(0,0,0)
	brightSlider:draw()
	volumeSlider:draw()
	sfxSlider:draw()
end