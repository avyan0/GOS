require 'calls'


function love.load()
    loadData()

	math.randomseed(os.time())

	love.window.setTitle('Gods Of Space')

	gFonts = {
		['loadingScreen'] = love.graphics.newFont('loadingScreen/backgroundFont.otf',100),
        ['bottomHome'] = love.graphics.newFont('states/homeState/things/bottomHome.otf', 60),
        ['weapons1'] = love.graphics.newFont('states/homeState/weapons/things/weapons.ttf',85),
        ['commonWeapons'] = love.graphics.newFont('states/homeState/weapons/things/commonWeaponFont.otf',45),
        ['back'] = love.graphics.newFont('states/homeState/weapons/things/backSign.ttf',35),
        ['shop'] = love.graphics.newFont('states/homeState/things/shop.otf',30),
        ['shop2'] = love.graphics.newFont('states/homeState/things/shop.otf',20),
        ['profile'] = love.graphics.newFont('states/homeState/things/profile.ttf',60),
        ['settingsBig'] = love.graphics.newFont('states/homeState/things/settings.ttf',19),
        ['settingsSmall'] = love.graphics.newFont('states/homeState/things/settings.ttf',15),
        ['items'] = love.graphics.newFont('states/homeState/things/Items.otf',25),
        ['itemsNumbers'] = love.graphics.newFont('states/homeState/things/Items.otf',19),
        ['game'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',40),
        ['game25'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',25),
        ['game18'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',18),
        ['game30'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',30),
        ['game10'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',10),
        ['game80'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',80),
        ['game70'] = love.graphics.newFont('states/homeState/game/things/WeaponSelect.otf',70)


	}
	love.graphics.setFont(gFonts['loadingScreen'])

	gTextures = {
		['loadingScreen'] = love.graphics.newImage('loadingScreen/loadBackground.png'),
        ['playerIcon'] = love.graphics.newImage('states/homeState/things/profileIcon.png'),
        ['planet1'] = love.graphics.newImage('states/homeState/things/Planet1.png'),
        ['planet2'] = love.graphics.newImage('states/homeState/things/Planet2.png'),
        ['planet3'] = love.graphics.newImage('states/homeState/things/Planet3.png'),
        ['planet4'] = love.graphics.newImage('states/homeState/things/Planet4.png'),
        ['planet5'] = love.graphics.newImage('states/homeState/things/Planet5.png'),
        ['planet6'] = love.graphics.newImage('states/homeState/things/Planet6.png'),
        ['back'] = love.graphics.newImage('states/homeState/weapons/things/BackArrow.png'),
        ['lockWeapons'] = love.graphics.newImage('states/homeState/weapons/things/LockWeapons.png'),
        ['mouse'] = love.graphics.newImage('states/homeState/things/Mouse.png'),
        ['keyboard'] = love.graphics.newImage('states/homeState/things/Keyboard.png'),
        ['wheel'] = love.graphics.newImage('states/homeState/things/Wheel.png'),
        ['p1Background'] = love.graphics.newImage('Pictures/Level Select Screen/P1Background.png'),
        ['p2Background'] = love.graphics.newImage('Pictures/Level Select Screen/P2Background.png'),
        ['p3Background'] = love.graphics.newImage('Pictures/Level Select Screen/P3Background.png'),
        ['p4Background'] = love.graphics.newImage('Pictures/Level Select Screen/P4Background.png'),
        ['p5Background'] = love.graphics.newImage('Pictures/Level Select Screen/P5Background.png'),
        ['p6Background'] = love.graphics.newImage('Pictures/Level Select Screen/P6Background.png'),
        ['gameBackground1'] = love.graphics.newImage('states/homeState/game/things/gameBackground1.png'),
        ['alien'] = love.graphics.newImage('states/homeState/game/things/alien.jpg'),
        ['flyingAlien'] = love.graphics.newImage('states/homeState/game/things/flyingAlien.jpg')
	}

    gWeapons = {
        ['AsteroidRain'] = love.graphics.newImage('states/homeState/weapons/things/pics/AsteroidRain.png'),
        ['PoisonDart'] = love.graphics.newImage('states/homeState/weapons/things/pics/PoisonDart.png'),
        ['Targeted'] = love.graphics.newImage('states/homeState/weapons/things/pics/Targeted.png'),
        ['RazorThrower'] = love.graphics.newImage('states/homeState/weapons/things/pics/RazorThrower.png'),
        ['Lightning'] = love.graphics.newImage('states/homeState/weapons/things/pics/Lightning.png'),
        ['StarBlast'] = love.graphics.newImage('states/homeState/weapons/things/pics/StarBlast.png'),
        ['LaserKill'] = love.graphics.newImage('states/homeState/weapons/things/pics/LaserKill.png'),
        ['Buffer'] = love.graphics.newImage('states/homeState/weapons/things/pics/Buffer.png'),
        ['ElectricBall'] = love.graphics.newImage('states/homeState/weapons/things/pics/ElectricBall.png'),
        ['SwordShield'] = love.graphics.newImage('states/homeState/weapons/things/pics/SwordShield.png'),
        ['ElectroShock'] = love.graphics.newImage('states/homeState/weapons/things/pics/ElectroShock.jpg'),
        ['PiercingSword'] = love.graphics.newImage('states/homeState/weapons/things/pics/PiercingSword.png'),
        ['Hevalstruck'] = love.graphics.newImage('states/homeState/weapons/things/pics/Hevelstruck.png'),
        ['RecursiveExplosion'] = love.graphics.newImage('states/homeState/weapons/things/pics/RecursiveExplosion.jpeg'),
        ['Dueltroid'] = love.graphics.newImage('states/homeState/weapons/things/pics/Dueltriod.png'),
        ['FreshStart'] = love.graphics.newImage('states/homeState/weapons/things/pics/FreshStart.png'),
        ['SantaAxe'] = love.graphics.newImage('states/homeState/weapons/things/pics/SantaAxe.png'),
        ['Respawn'] = love.graphics.newImage('states/homeState/weapons/things/pics/Respawn.png'),
        ['Offguard'] = love.graphics.newImage('states/homeState/weapons/things/pics/Offgaurd.png'),
        ['LaserDeath'] = love.graphics.newImage('states/homeState/weapons/things/pics/LaserDeath.png'),
        ['MagicGun'] = love.graphics.newImage('states/homeState/weapons/things/pics/MagicGun.png'),
        ['Grenade'] = love.graphics.newImage('states/homeState/weapons/things/pics/Grenade.png'),
        ['Walls'] = love.graphics.newImage('states/homeState/weapons/things/pics/Walls.png'),
        ['MindControl'] = love.graphics.newImage('states/homeState/weapons/things/pics/MindControl.png'),
        ['ShrinkRay'] = love.graphics.newImage('states/homeState/weapons/things/pics/ShrinkRay.png'),
        ['RazorBlade'] = love.graphics.newImage('states/homeState/weapons/things/pics/RazorBlade.png'),
        ['Fireball'] = love.graphics.newImage('states/homeState/weapons/things/pics/Fireball.png'),
        ['Meteor'] = love.graphics.newImage('states/homeState/weapons/things/pics/Meteor.png'),
        ['DeathVirus'] = love.graphics.newImage('states/homeState/weapons/things/pics/DeathVirus.png'),
        ['Cannon'] = love.graphics.newImage('states/homeState/weapons/things/pics/Cannon.png'),
        ['Wipeout'] = love.graphics.newImage('states/homeState/weapons/things/pics/Wipeout.png'),
        ['Transformer'] = love.graphics.newImage('states/homeState/weapons/things/pics/Transformer.png')

    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

     gStateMachine = StateMachine {
        ['loading'] = function() return LoadingScreenState() end,
        ['home'] = function() return HomeScreenState() end,
        ['aliens'] = function() return AlienScreenState() end,
        ['weapons'] = function() return WeaponsScreenState() end,
        ['settings'] = function() return SettingsScreenState() end,
        ['items'] = function() return ItemsScreenState() end,
        ['profile'] = function() return ProfileScreenState() end,
        ['commonWeapons'] = function() return CommonWeaponState() end,
        ['rareWeapons'] = function() return RareWeaponState() end,
        ['scarceWeapons'] = function() return ScarceWeaponState() end,
        ['godWeapons'] = function() return GodWeaponState() end,
        ['shop'] = function() return ShopState() end,
        ['weaponInfo'] = function() return WeaponInfo() end,
        ['itemDescriptions'] = function() return ItemDescriptions() end,
        ['spin'] = function() return SpinState() end,
        ['p1Level'] = function() return P1Level() end,
        ['p2Level'] = function() return P2Level() end,
        ['p3Level'] = function() return P3Level() end,
        ['p4Level'] = function() return P4Level() end,
        ['p5Level'] = function() return P5Level() end,
        ['p6Level'] = function() return P6Level() end,
        ['weaponSelect'] = function() return WeaponSelect() end,
        ['game'] = function() return GameState() end,
        ['lose'] = function() return LoseState() end,
        ['stageSelect'] = function() return StageSelect() end,
        ['win'] = function() return WinState() end,
        ['pause'] = function() return PauseState() end
        
    }
    makeLevel()
    gStateMachine:change('pause')


    love.keyboard.keysPressed = {}
	weaponDictionary()
    alienDictionary()
    makeLevel()


end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    saveData()
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    if key == 'escape' then
    	love.event.quit()
    end
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
	push:apply('start')
    
	local backgroundWidth = gTextures['loadingScreen']:getWidth()
    local backgroundHeight = gTextures['loadingScreen']:getHeight()
    love.graphics.draw(gTextures['loadingScreen'],0,0,0,VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

	gStateMachine:render()

    push:apply('end')
end

function love.mousepressed(x, y)
    x1 = love.mouse.getX()
    y1 = love.mouse.getY()
    gStateMachine:mousePressed(x1,y1)
end

function love.mouseMoved(x,y)
    x1 = love.mouse.getX()
    y1 = love.mouse.getY()
    gStateMachine:mouseMoved(x1,y1)
end


function love.clicked(x,y,x1,x2,y1,y2)
        if(x>x1 and x<x2 and y>y1 and y<y2) then
            return true
        end
end

function love.bottomClicked(x,y)

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

end

function love.drawBottom(x)
    push:apply('start')
    love.graphics.setLineWidth(3)

    love.graphics.setColor(52/255,52/255,52/255,1)
    love.graphics.rectangle('fill', 0, 570, 290,150)
    love.graphics.setColor(255/255,28/255,28/255)
    love.graphics.setFont(gFonts['bottomHome'])
    love.graphics.printf('Aliens', 0, 630, 290,'center')
    if x~=1 then
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle('line', 0, 570, 290,150)

    

    love.graphics.setColor(52/255,52/255,52/255,1)
    love.graphics.rectangle('fill', 330, 570, 290,150)
    love.graphics.setColor(238/255,243/255,11/255)
    love.graphics.setFont(gFonts['bottomHome'])
    love.graphics.printf('Home', 330, 630, 290,'center')
    if(x ~= 2) then
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle('line', 330, 570, 290,150)


    love.graphics.setColor(52/255,52/255,52/255,1)
    love.graphics.rectangle('fill', 660, 570, 290,150)
    love.graphics.setColor(120/255,255/255,240/255)
    love.graphics.setFont(gFonts['bottomHome'])
    love.graphics.printf('Weapons', 660, 630, 290,'center')
    if x ~= 3 then
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle('line', 660, 570, 290,150)

    love.graphics.setColor(52/255,52/255,52/255,1)
    love.graphics.rectangle('fill', 990, 570, 290,150)
    love.graphics.setColor(17/255,249/255,171/255)
    love.graphics.setFont(gFonts['bottomHome'])
    love.graphics.printf('Shop', 990, 630, 290,'center')
    if x ~= 4 then
        love.graphics.setColor(1,1,1,1)
    end
    love.graphics.rectangle('line', 990, 570, 290,150)

    
    push:apply('end')
end

function love.drawBack()
    love.graphics.setFont(gFonts['back'])
    love.graphics.setColor(0,0,0)
    love.graphics.printf('Back',0,27,150,'center')
    local w = gTextures['back']:getWidth()
    local h = gTextures['back']:getHeight()
    love.graphics.draw(gTextures['back'],160,30,0,72 / (w - 1), 54 / (h - 1))
end

function love.setBright()
    love.graphics.setColor(0,0,0,1-(data.brightness/100))
	love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
end

function setColor(r,g,b)
    love.graphics.setColor(r,g,b)
end

function math.round(num) 
    return math.floor(num+0.5)
end
