GameState = Class{__includes = BaseState}

local spotTaken = {}
local weapon1Clicked = false
local weapon2Clicked = false
local weapon3Clicked = false
local mousePressed = true
local weapon1Cooldown = 0
local weapon2Cooldown = 0
local weapon3Cooldown = 0
local chooseTile = false
local selectedLane = 0
local selectedRow = 0
local chooseLane = false
local fieldCleared = false
local alienCounter = 0
local respawnLane = 0
local attackCounter = 0
local attacker = {aoe = ''}
local stage = 'first'
local aliensNeeded = 0
local lastTileLane = 0
local lastTileRow = 0
local damageBuff = 1
local stellar = 0
local commonBuff = 1
local rareBuff = 1
local scarceBuff = 1
local targetBuff = 1
local allGood = false

for i = 1, 13 do
    spotTaken[i] = {}
 for j = 1, 5 do
    spotTaken[i][j] = false
    end
end


alienAlive= {}
for i = 1, 13 do
    alienAlive[i] = {}
    for j = 1, 5 do
        alienAlive[i][j] = false
    end
end

alienStats = {}
for i = 1, 13 do
    alienStats[i] = {}
    for j = 1, 5 do
        alienStats[i][j] = {speed = 1, health = 0, hevalten = false, poisoned = false,poisonDamage = 0, stunned = false, stunDuration = 0, hypno = false,immmunity = false,fly = false,flyCounter = -1,name = '',giant = 0,morph = false}
    end
end
walls = {}
for i = 1,12 do
    walls[i]= {}
    for j = 1,5 do
        walls[i][j] = false
    end
end
  
function GameState:render()
    love.graphics.clear()
    local alienW = gTextures['alien']:getWidth()
    local alienH = gTextures['alien']:getHeight()
    local wallW = gTextures['walls']:getWidth()
    local wallH = gTextures['walls']:getHeight()
    local alienW1 = gTextures['flyingAlien']:getWidth()
    local alienH1 = gTextures['flyingAlien']:getHeight()
    push:apply('start')

    setColor(41/255,189/255,193/255)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

    setColor(179/255, 25/255, 21/255)

    love.graphics.setLineWidth(2)
    love.graphics.line(0,0,1280,0)
    love.graphics.line(0,65,1280,65)
    love.graphics.line(0,130,1280,130)
    love.graphics.line(0,195,1280,195)
    love.graphics.line(0,260,1280,260)
    love.graphics.line(0,325,1280,325)
    love.graphics.line(0,390,1280,390)
    love.graphics.line(0,455,1280,455)
    love.graphics.line(0,520,1280,520)
    love.graphics.line(0,585,1280,585)
    love.graphics.line(0,650,1280,650)
    love.graphics.line(0,0,0,650)
    love.graphics.line(256,0,256,650)
    love.graphics.line(512,0,512,650)
    love.graphics.line(768,0,768,650)
    love.graphics.line(1024,0,1024,650)
    setColor(54/255,54/255,54/255,.8)
    if weapon1Clicked then
        love.graphics.rectangle('fill',0,650,350,130)
    end
    if weapon2Clicked then
        love.graphics.rectangle('fill',350,650,350,130)
    end
    if weapon3Clicked then
        love.graphics.rectangle('fill',700,650,350,130)
    end
    setColor(179/255, 25/255, 21/255)


    love.graphics.setLineWidth(5)
    love.graphics.rectangle('line',0,650,1050,130)
    setColor(0,172/255,102/255)
    love.graphics.rectangle('line',1055,650,150,130)
    setColor(102/255,51/255,153/255)
    love.graphics.rectangle('line',1210,650,70,130)
    setColor(179/255, 25/255, 21/255)



    love.graphics.line(350,650,350,780)
    love.graphics.line(700,650,700,780)
    
    love.graphics.setFont(gFonts['game25'])
    love.graphics.printf(data.weaponChoose1,0,680,350,'center')
    love.graphics.printf(data.weaponChoose2,350,680,350,'center')
    love.graphics.printf(data.weaponChoose3,700,680,350,'center')
    love.graphics.setFont(gFonts['game70'])
    setColor(79/255, 125/255, 221/255)
    if chooseLane then
        love.graphics.printf('Choose Lane Number',0,650,1280,'center')
    end

    if chooseTile then
        love.graphics.printf('Choose Tile Number',0,650,1280,'center')
    end
    setColor(0,172/255,102/255)
    love.graphics.setFont(gFonts['game25'])
    love.graphics.printf('End Turn',1055,680,150,'center')

    
    setColor(1,1,1)
    for i = 1, 10 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] then
                if not alienStats[i][j].fly then
                    love.graphics.draw(gTextures['alien'],j*256 - 150,(i-1)*65 + 16,0,34 / (alienW - 1), 50 / (alienH - 1))
                else
                    love.graphics.draw(gTextures['flyingAlien'],j*256 - 150,(i-1)*65 + 16,0,34 / (alienW1 - 1), 50 / (alienH1 - 1))
                end
                love.graphics.setFont(gFonts['game10'])
                love.graphics.print(math.round(alienStats[i][j].health),(j*256 - 143),((i-1)*65 + 6))
                love.graphics.print(alienStats[i][j].name,j*256-112,(i-1)*65 + 33)
                if alienStats[i][j].poisoned then
                    setColor(0,1,0)
                    love.graphics.print('p',(j*256 - 123),((i-1)*65 + 6))
                    setColor(1,1,1)
                end
                if alienStats[i][j].stunned then
                    setColor(.7,.1,.2)
                    love.graphics.print('s',(j*256 - 114),((i-1)*65 + 6))
                    setColor(1,1,1)
                end
                if alienStats[i][j].hypno then
                    setColor(102/255,51/255,153/255)
                    love.graphics.print('h',(j*256 - 105),((i-1)*65 + 6))
                    setColor(1,1,1)
                end
                if alienStats[i][j].immmunity then
                    setColor(212/255,175/255,55/255)
                    love.graphics.print('i',(j*256 - 123),((i-1)*65 + 6))
                    setColor(1,1,1)
                end
            end
            if walls[i][j] then
                love.graphics.draw(gTextures['walls'],j*256 - 130,(i-1)*65 + 16,0,30 / (wallW - 1), 45 / (wallH - 1))
            end
        end
    end
    setColor(102/255,51/255,153/255)
    love.graphics.setFont(gFonts['game18'])
    love.graphics.printf('Pause',1210,680,70,'center')

    love.setBright()
    push:apply('end')
end

function GameState:update(dt)
    local god = false
    for i = 10,2,-1 do
        for j = 1,5 do
            if alienStats[i][j].immmunity then
                alienStats[i][j].immmunity = false
            end
            if alienStats[i][j].name == 'GodOfSpace' then
                god = true
            end
        end
    end
    if god then 
        allGood = true
    end
    god = false

    if chooseTile and attacker.aoe == 'tile' then
        if love.keyboard.wasPressed('q') then
            selectedLane = 1
        elseif love.keyboard.wasPressed('w') then
            selectedLane = 2
        elseif love.keyboard.wasPressed('e') then
            selectedLane = 3
        elseif love.keyboard.wasPressed('r') then
            selectedLane = 4
        elseif love.keyboard.wasPressed('t') then
            selectedLane = 5
        end

        if love.keyboard.wasPressed('0') then
            selectedRow = 10
        elseif love.keyboard.wasPressed('1') then
            selectedRow = 1
        elseif love.keyboard.wasPressed('2') then
            selectedRow = 2
        elseif love.keyboard.wasPressed('3') then
            selectedRow = 3
        elseif love.keyboard.wasPressed('4') then
            selectedRow = 4
        elseif love.keyboard.wasPressed('5') then
            selectedRow = 5
        elseif love.keyboard.wasPressed('6') then
            selectedRow = 6
        elseif love.keyboard.wasPressed('7') then
            selectedRow = 7
        elseif love.keyboard.wasPressed('8') then
            selectedRow = 8
        elseif love.keyboard.wasPressed('9') then
            selectedRow = 9
        end

        if (lastTileLane ~= selectedLane or lastTileRow ~= selectedRow) then
        if not (attackCounter >= attacker.attack) then
        if (0 ~= selectedLane and 0 ~= selectedRow) then
            if attackCounter >= attacker.attack then
                chooseTile = false
                selectedLane = 0
                selectedRow = 0
                attackCounter = 0
                lastTileLane = 0
                lastTileRow = 0
            else
                attackCounter = attackCounter + 1
                GameState:attackTile(attacker, selectedRow, selectedLane)
                lastTileLane = selectedLane
                lastTileRow = selectedRow
                selectedLane = 0
                selectedRow = 0
            end
        end
        else
            chooseTile = false
                selectedLane = 0
                selectedRow = 0
                attackCounter = 0
                lastTileLane = 0
                lastTileRow = 0
        end
    end
    end

    if not chooseLane and not chooseTile then
        if love.keyboard.wasPressed('a') then
            if not weapon1Clicked then
                GameState:attack(data.weaponChoose1)
                weapon1Clicked = true
            end
        elseif love.keyboard.wasPressed('s') then
            if not weapon2Clicked then
                GameState:attack(data.weaponChoose2)
                weapon2Clicked = true
            end
        elseif love.keyboard.wasPressed('d') then
            if not weapon3Clicked then
                GameState:attack(data.weaponChoose3)
                weapon3Clicked = true
            end
        elseif love.keyboard.wasPressed('p') then
            gStateMachine:change('pause')
        elseif love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            mousePressed = true  
                if weapon1Cooldown >= Weapons[data.weaponChoose1].cooldown then
                    weapon1Clicked = false
                    weapon1Cooldown = 0
                end
                if weapon2Cooldown >= Weapons[data.weaponChoose2].cooldown then
                    weapon2Clicked = false
                    weapon2Cooldown = 0
                end
                if weapon3Cooldown >= Weapons[data.weaponChoose3].cooldown then
                    weapon3Clicked = false
                    weapon3Cooldown = 0
                end
                if weapon1Clicked then
                    weapon1Cooldown = weapon1Cooldown + 1 end
                if weapon2Clicked then
                    weapon2Cooldown = weapon2Cooldown + 1 end
                if weapon3Clicked then
                    weapon3Cooldown = weapon3Cooldown + 1 
                end
            end
    end

    if stage == 'first' then
        aliensNeeded =  Levels[data.currentLevel].first
    elseif stage == 'second' then
        aliensNeeded =  Levels[data.currentLevel].second
    elseif stage == 'third' then
        aliensNeeded =  Levels[data.currentLevel].third
    end
    
    if stage == 'first' then-- check stages
        if alienCounter >= Levels[data.currentLevel].first and GameState:checkDead() then
            alienCounter = 0
            stage = 'second'
            weapon1Clicked = false
            weapon2Clicked = false
            weapon3Clicked = false
            mousePressed = true
            weapon1Cooldown = 0
            damageBuff = 1
            commonBuff = 1
            targetBuff = 1
            rareBuff = 1
            scarceBuff = 1
            weapon2Cooldown = 0
            weapon3Cooldown = 0
            chooseTile = false
            chooseLane = false
            GameState:killAllAliens()
            gStateMachine:change('stageSelect')
        end
    elseif stage == 'second' then
        if alienCounter >= Levels[data.currentLevel].second and GameState:checkDead() then
            alienCounter = 0
            stage = 'third'
            weapon1Clicked = false
            weapon2Clicked = false
            weapon3Clicked = false
            mousePressed = true
            weapon1Cooldown = 0
            damageBuff = 1
            commonBuff = 1
            rareBuff = 1
            targetBuff = 1
            weapon2Cooldown = 0
            scarceBuff = 1
            weapon3Cooldown = 0
            chooseLane = false
            chooseTile = false
            GameState:killAllAliens()
            gStateMachine:change('stageSelect')        
        end
    elseif stage == 'third' then
        if alienCounter >= Levels[data.currentLevel].third and GameState:checkDead() then
            alienCounter = 0
            stage = 'first'
            weapon1Clicked = false
            weapon2Clicked = false
            weapon3Clicked = false
            mousePressed = true
            weapon1Cooldown = 0
            weapon2Cooldown = 0
            weapon3Cooldown = 0
            chooseLane = false
            damageBuff = 1
            scarceBuff = 1
            rareBuff = 1
            commonBuff = 1
            targetBuff = 1
            chooseTile = false
            GameState:killAllAliens()
            gStateMachine:change('win')
        end
    end

    if mousePressed and not love.mouse.isDown(1) then -- checks if end turn
        mousePressed = false
        GameState:applyPoison()
        GameState:spawnAliens()
        for i = 2, 10 do
            for j = 1, 5 do
                if alienStats[i][j].morph then
                    alienStats[i][j] = GameState:morph(i, j)
                end
            end
        end
        data.turn = true
        saveData()
    end

    if attacker.aoe == 'lane' and chooseLane then -- does lane damage
        if love.keyboard.wasPressed('1') then
            GameState:attackLane(attacker,1)
            chooseLane = false
        elseif love.keyboard.wasPressed('2') then
             GameState:attackLane(attacker,2)
            chooseLane = false
        elseif love.keyboard.wasPressed('3') then
             GameState:attackLane(attacker,3)
            chooseLane = false
        elseif love.keyboard.wasPressed('4') then
             GameState:attackLane(attacker,4)
            chooseLane = false
        elseif love.keyboard.wasPressed('5') then
             GameState:attackLane(attacker,5)
            chooseLane = false
        end
    end

    for i =1,5 do -- check if lose
        if spotTaken[11][i] then
            data.turn = false
            alienCounter = 0
            stage = 'first'
            weapon1Clicked = false
            weapon2Clicked = false
            weapon3Clicked = false
            mousePressed = true
            weapon1Cooldown = 0
            weapon2Cooldown = 0
            weapon3Cooldown = 0
            chooseLane = false
            damageBuff = 1
            scarceBuff = 1
            rareBuff = 1
            commonBuff = 1
            targetBuff = 1
            chooseTile = false
            GameState:killAllAliens()
            saveData()
            gStateMachine:change('lose')
        end
    end
end

function GameState:spawnAliens()
    if alienCounter < aliensNeeded  then
        respawnLane = 0
            local alien = math.random(1,100)
             alien1 = nil
             for _, alienName in ipairs(alienNames) do
                if alien <= Levels[data.currentLevel][alienName] then
                    alien1 = Aliens[alienName]
                    break
                end
            end

            local lane = 1
        if respawnLane ~= 0 then
            for i = 1, 5 do
                if respawnLane == i then
                    if respawnLane == 1 then
                        lane = math.random(2,5)
                    elseif respawnLane == 5 then
                        lane = math.random(1,4)
                    else
                        lane = math.random(1,5)
                        while lane == i do
                            lane = math.random(1,5)
                        end
                    end
                end
            end
        else
            lane = math.random(1,5)
        end
        if alien1.hevalten then
            lane = math.random(1,5)
        end
        if lane == 1 then
            GameState:moveLane(1,alien1)
        elseif lane == 2 then
            GameState:moveLane(2,alien1)
        elseif lane == 3 then
            GameState:moveLane(3,alien1)
        elseif lane == 4 then
            GameState:moveLane(4,alien1)
        elseif lane == 5 then
            GameState:moveLane(5,alien1)
        end
    else
        GameState:moveLane()
    end
end

function GameState:moveLane(n, thingy)
    local sameSpot = false
    local hypnoDone = true
    local moveThenKill = false
    local allAliensDone = false
    stellar = stellar -1
    local counter = 0
    if stellar == 2 then        
        damageBuff = damageBuff /(1.2 * ((data.upgrades[attacker.name] * 0.1) + 1))
        damageBuff = damageBuff*1.1 * ((data.upgrades[attacker.name] * 0.1) + 1)
    elseif stellar == 0 then
        damageBuff = damageBuff/(1.1 *((data.upgrades[attacker.name] * 0.1) + 1))
    end
    
    for a = 10,1,-1 do
        for b = 1,5 do
            if alienStats[a][b].name == 'Albot' then
                if not alienAlive[a][1] or not alienAlive[a][2] or not alienAlive[a][3] or not alienAlive[a][4] or not alienAlive[a][5] then
                    local temp1 = math.random(1,5)
                    while alienAlive[a][temp1] do
                        temp1 = math.random(1,5)
                    end
                    local randAlien = math.random(1,9)
                    if randAlien == 1 then
                        alienStats[a][temp1].health = Aliens['Joe'].health
                        alienStats[a][temp1].hevalten = Aliens['Joe'].hevalten
                        alienStats[a][temp1].speed = Aliens['Joe'].speed
                        alienStats[a][temp1].name = Aliens['Joe'].name
                    elseif randAlien == 2 then
                        alienStats[a][temp1].health = Aliens['Gen57'].health
                        alienStats[a][temp1].hevalten = Aliens['Gen57'].hevalten
                        alienStats[a][temp1].speed = Aliens['Gen57'].speed
                        alienStats[a][temp1].name = Aliens['Gen57'].name
                    elseif randAlien == 3 then
                        alienStats[a][temp1].health = Aliens['President'].health
                        alienStats[a][temp1].hevalten = Aliens['President'].hevalten
                        alienStats[a][temp1].speed = Aliens['President'].speed
                        alienStats[a][temp1].name = Aliens['President'].name
                        GameState:setMost(a,temp1)
                    elseif randAlien == 4 then
                        alienStats[a][temp1].health = Aliens['King'].health
                        alienStats[a][temp1].hevalten = Aliens['King'].hevalten
                        alienStats[a][temp1].speed = Aliens['King'].speed
                        alienStats[a][temp1].name = Aliens['King'].name
                        GameState:setMost(a,temp1)
                    elseif randAlien == 5 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['DJ'].health
                        alienStats[a][temp1].hevalten = Aliens['DJ'].hevalten
                        alienStats[a][temp1].speed = Aliens['DJ'].speed
                        alienStats[a][temp1].name = Aliens['DJ'].name
                    elseif randAlien == 6 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['SpaceFence'].health
                        alienStats[a][temp1].hevalten = Aliens['SpaceFence'].hevalten
                        alienStats[a][temp1].speed = Aliens['SpaceFence'].speed
                        alienStats[a][temp1].name = Aliens['SpaceFence'].name
                    elseif randAlien == 7 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['Spaceship'].health
                        alienStats[a][temp1].hevalten = Aliens['Spaceship'].hevalten
                        alienStats[a][temp1].speed = Aliens['Spaceship'].speed
                        alienStats[a][temp1].name = Aliens['Spaceship'].name
                    elseif randAlien == 8 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['VRWorkout'].health
                        alienStats[a][temp1].hevalten = Aliens['VRWorkout'].hevalten
                        alienStats[a][temp1].speed = Aliens['VRWorkout'].speed
                        alienStats[a][temp1].name = Aliens['VRWorkout'].name
                    elseif randAlien == 9 then
                        GameState:setMost(a,temp1)
                        alienStats[a][temp1].health = Aliens['OldGranny'].health
                        alienStats[a][temp1].hevalten = Aliens['OldGranny'].hevalten
                        alienStats[a][temp1].speed = Aliens['OldGranny'].speed
                        alienStats[a][temp1].name = Aliens['OldGranny'].name
                    end
                end
            end
        end
    end

    for j = 1, 5 do--hypno shit
        hypnoDone = true
        for i = 10, 1,-1 do
        if i > 1 then
            if alienStats[i][j].hypno and not alienAlive[i-1][j]  and hypnoDone then
                hypnoDone = false
                moveThenKill = true
                GameState:changeStats(i-1,j,i,j)

                GameState:reset(i,j)
            elseif alienStats[i][j].hypno and alienAlive[i-1][j] then
                local temp = alienStats[i-1][j].health
                local win = false

                alienStats[i-1][j].health =  alienStats[i-1][j].health - alienStats[i][j].health
                alienStats[i][j].health =  alienStats[i][j].health - temp
                if alienStats[i][j].health >= 0 and alienStats[i-1][j].health <= 0 then
                    win = true
                end

                if alienStats[i][j].health >= 0 and alienStats[i-1][j].health <= 0 and not moveThenKill then
                    hypnoDone = false
                    GameState:changeStats(i-1,j,i,j)
                    GameState:resetStats(i,j)
                elseif alienStats[i-1][j].health >= 0 and alienStats[i][j].health <= 0  then
                    hypnoDone = false
                    spotTaken[i][j] = false
                    moveThenKill = false
                    GameState:reset(i,j)
                end
                if moveThenKill and win then
                    GameState:resetStats(i-1,j)
                end
                moveThenKill = false

            end
        elseif i == 1 and alienStats[i][j].hypno and hypnoDone then
            GameState:reset(i,j)
        end
        if alienStats[i][j].fly then
            alienStats[i][j].fly = false
        end
        if alienStats[i][j].flyCounter >= 0 and  not alienStats[i][j].fly then
            alienStats[i][j].flyCounter = alienStats[i][j].flyCounter + 1
        end
        if  alienStats[i][j].flyCounter > 2 and not alienStats[i][j].fly then
            alienStats[i][j].fly = true
            alienStats[i][j].flyCounter = 0
        end
        if alienStats[i][j].health <= 0 then
            GameState:reset(i,j)
        end
    end
    end

    for i = 10, 1, -1 do
        for j = 1, 5 do
            if alienAlive[i][j] then
                counter = counter +1
            end
            if alienStats[i][j].name ~= 'Giant' or  alienStats[i][j].giant == 1 then
                alienStats[i][j].giant = 0
                if alienStats[i][j].name == 'Army' then
                    damageBuff = damageBuff - 0.02
                end
                if alienStats[i][j].name == 'Interdimentional' then
                    damageBuff = damageBuff * .75
                end
                if alienAlive[i][j] then
                    local alien = alienStats[i][j]
                    local speed = 1
                    if alienStats[i][j].stunned then
                        speed = 0 -- Stunned aliens cannot move
                    end


                    local destRow = i
                    local canMove = false

                    for k = 1, speed do
                        destRow = destRow + 1
                        if alienAlive[destRow] and not alienStats[destRow][j].stunned then
                            canMove = true
                        else
                            canMove = false
                        break
                        end
                    end

                    if canMove and not alienStats[i][j].hypno and not alienAlive[destRow][j] then
                        if not walls[destRow][j] then
                                GameState:changeStats(destRow,j,i,j)
                                GameState:reset(i,j)
                        else
                            if alienStats[i][j].name == 'Jumper' then
                                local temp = 1
                                while walls[destRow + temp][j] do
                                    temp = temp +1
                                end
                                GameState:changeStats(destRow + temp,j,i,j)
                                GameState:reset(i,j)
                            else
                                walls[destRow][j] = false
                            end
                        end
                    end
                end
            else
                alienStats[i][j].giant = 1
            end
        end
    end

    if n ~= nil then
        while alienAlive[1][n] do
            n = math.random(1, 5)
        end
        if thingy.name == 'DarkArts' then
            GameState:upgrade()
        end
        if thingy.name == 'Virus' then
            weapon1Cooldown = weapon1Cooldown - 1
            weapon2Cooldown = weapon2Cooldown -1
            weapon3Cooldown = weapon3Cooldown -1
        end
        if thingy.name == 'GodOfSpace' then
            GameState:godRand(thingy)
            GameState:godRand(thingy)
            GameState:godRand(thingy)
        end
            
        GameState:makeAlien(1,n,thingy.health,thingy.hevalten,thingy.name)
    end

    for x = 1,10 do
        for y = 1,5 do
            if alienStats[x][y].name == 'Fusion' then
                local tempRow = math.random(1,10)
                local tempLane = math.random(1,5)
                local tempRow1 = math.random(1,10)
                local tempLane1 = math.random(1,5)
                if counter >= 2 then
                    while (not alienAlive[tempRow][tempLane] or not alienAlive[tempRow1][tempLane1]) or (tempRow == tempRow1 or tempLane == tempLane1) do
                        tempRow = math.random(1,10)
                        tempLane = math.random(1,5)
                        tempRow1 = math.random(1,10)
                        tempLane1 = math.random(1,5)
                    end
                    local tempHold = (alienStats[tempRow][tempLane].health + alienStats[tempRow1][tempLane1].health)*1.5
                    local tempAlien = nil
                    GameState:reset(tempRow,tempLane)
                    GameState:reset(tempRow1,tempLane1)
                    for l = 1,27 do
                        if Aliensrand[l].health >= tempHold then
                            tempAlien = Aliensrand[l]
                            break
                        end
                        if l == 27 then
                            tempAlien = Aliensrand[27]
                        end
                    end
                    GameState:makeAlien(tempRow,tempLane,tempAlien.health,tempAlien.hevalten,tempAlien.name)
                end
            end
        end
    end
    for i = 1,10 do
        for j = 1,5 do
            if alienAlive[i][j] then
                if alienStats[i][j].stunned then
                    alienStats[i][j].stunDuration = alienStats[i][j].stunDuration -1
                end
                if alienStats[i][j].stunDuration <= 0 then
                    alienStats[i][j].stunned = false
                end
            end
        end
    end
end

function GameState:mousePressed(x, y)
    if not chooseLane and not chooseTile then
        if love.clicked(x,y,0,350,630,780) then
            if not weapon1Clicked then
                GameState:attack(data.weaponChoose1)
                weapon1Clicked = true
            end
        elseif love.clicked(x,y,350,700,630,780) then
            if not weapon2Clicked then
                GameState:attack(data.weaponChoose2)
                weapon2Clicked = true
            end
        elseif love.clicked(x,y,700,1050,630,780) then
            if not weapon3Clicked then
                GameState:attack(data.weaponChoose3)
                weapon3Clicked = true
            end
        elseif love.clicked(x,y,1050,1210,630,780) then
            mousePressed = true  
            if weapon1Cooldown >= Weapons[data.weaponChoose1].cooldown then
                weapon1Clicked = false
                weapon1Cooldown = 0
            end
            if weapon2Cooldown >= Weapons[data.weaponChoose2].cooldown then
                weapon2Clicked = false
                weapon2Cooldown = 0
            end
            if weapon3Cooldown >= Weapons[data.weaponChoose3].cooldown then
                weapon3Clicked = false
                weapon3Cooldown = 0
            end
            if weapon1Clicked then
                weapon1Cooldown = weapon1Cooldown + 1 end
            if weapon2Clicked then
                weapon2Cooldown = weapon2Cooldown + 1 end
            if weapon3Clicked then
                weapon3Cooldown = weapon3Cooldown + 1 end
        elseif love.clicked(x,y,1010,1280,630,780) then
            gStateMachine:change('pause')
        end

    end
end

function GameState:attack(weapon)
    attacker = Weapons[weapon]
    attacker.damageAll = attacker.damageAll * ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageLane = attacker.damageLane * ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageTile = attacker.damageTile * ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.poison = attacker.poison * ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageRandLane = attacker.damageRandLane * ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damage = attacker.damage * ((data.upgrades[attacker.name] * 0.1) + 1)

    if attacker.name == 'Death Virus' then
        GameState:DeathVirus()
    end
    if attacker.aoe == 'buff' then
        GameState:StellarBoost()
        stellar = 3
    end
    if attacker.name == 'Protected' then
        GameState:protected()
    end
    if attacker.name == 'Grenade Launcher' then
        GameState:GrenadeLancher()
    end
    if attacker.name == 'Offguard' then
        GameState:Offguard()
    end
    if attacker.name == 'Hypnosis' then
        GameState:Hynosis()
    end
   
    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] and not alienStats[i][j].immmunity then
                local alien = alienStats[i][j]
                local preHealth = alien.health
                if not (alien.name == 'Splashfest') then
                    if GameState:checkGuardian(j) then
                        if attacker.rarity == 'common' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * commonBuff)
                        elseif attacker.rarity == 'rare' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * rareBuff)
                        elseif attacker.rarity == 'scarce' then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff * scarceBuff)
                        else
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageAll * damageBuff)
                        end
                    elseif attacker.rarity == 'common' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * commonBuff)
                    elseif attacker.rarity == 'rare' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * rareBuff)
                    elseif attacker.rarity == 'scarce' then
                        alien.health = alien.health - (attacker.damageAll * damageBuff * scarceBuff)
                    else
                        alien.health = alien.health - (attacker.damageAll * damageBuff)
                    end
                end

                if attacker.aoe == 'lane' then
                    chooseLane = true
                end

                if attacker.aoe == 'tile'then
                    chooseTile = true
                end

                if alien.health <= 0 then -- check if killed
                    GameState:resetStats(i,j)
                end
                if alien.name == 'OldGranny' and alien.health ~= preHealth and not alienAlive[i+1][j] and not GameState:checkGuardian(j) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alien,preHealth)
            end
        end
    end
    attacker.damageAll = attacker.damageAll / ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageLane = attacker.damageLane / ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageTile = attacker.damageTile / ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.poison = attacker.poison / ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damageRandLane = attacker.damageRandLane / ((data.upgrades[attacker.name] * 0.1) + 1)
    attacker.damage = attacker.damage / ((data.upgrades[attacker.name] * 0.1) + 1)
end

function GameState:attackLane(weapon, lane)
    local weaponTemp = weapon
    if attacker.name == 'Laser Kill' then
        GameState:LaserKill(lane)
    end
    if attacker.name == 'Celestial Disruption' then
        GameState:CelestialDisruption(lane)
    end
    if attacker.name == 'Laser Beam' then
        GameState:LaserBeam(lane)
    end
    if attacker.name == 'Thunder Strike' then
        GameState:ThunderStrike(lane)
    end
    if attacker.name == 'Battle Ram' or attacker.name == 'Hevalstruck' then
        GameState:attackFirst(lane)
    end
    if attacker.name ==  'Dueltroid' then
        GameState:Dueltroid(lane)
    end
    if attacker.name == 'Respawn' then
        GameState:respawn(lane)
    end
    if attacker.name == 'Mind Blast' then
        GameState:MindBlast(lane)
    end
    for i = 10,1,-1 do
        if spotTaken[i][lane] and alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            local alien = alienStats[i][lane]
            local preHealth = alien.health
            if not (alien.name == 'Splashfest') then
                if GameState:checkGuardian(lane) then
                    if attacker.rarity == 'common' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
                    elseif attacker.rarity == 'rare' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * rareBuff)
                    elseif attacker.rarity == 'scarce' then
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * scarceBuff)
                    else
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff)
                    end
                elseif weaponTemp.rarity == 'common' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff * commonBuff)
                elseif  weaponTemp.rarity == 'rare' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff* rareBuff)
                elseif weaponTemp.rarity == 'scarce' then
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff*scarceBuff)
                else
                    alien.health = alien.health - (weaponTemp.damageLane * damageBuff)
                end
            end
            if weaponTemp.poison > 0 and not GameState:checkGuardian(lane) and not(allGood) then
                GameState:checkPoison(weaponTemp.poison,lane)
            end
            if alien.health <= 0 then
                GameState:resetStats(i,lane)
            end
            if alien.name == 'OldGranny' and alien.health ~= preHealth and not alienAlive[i+1][lane] and not GameState:checkGuardian(lane)then
                GameState:changeStats(i+1,lane,i,lane)
                GameState:reset(i,lane)
            end
            GameState:spawnRand(alien,preHealth)
        end
    end
    if attacker.knockback > 0 then
        GameState:knockback(attacker,lane)
    end
    if attacker.stunDuration > 0 then
        GameState:stun(attacker,lane)
    end
end

function GameState:killAllAliens() -- kills all aliens

    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] and alienAlive[i][j] then
                GameState:reset(i,j)
            end
            walls[i][j] = false
        end
    end
end

function GameState:checkDead() -- checks if any alien is left
    for i = 1, 11 do
        for j = 1, 5 do
            if spotTaken[i][j] or alienAlive[i][j] then
                    return false
            end
        end
    end
    return true
    
end

function GameState:checkPoison(damage, lane)
    for i = 1, 11 do
        if spotTaken[i][lane] and alienAlive[i][lane] and not(allGood) then
            alienStats[i][lane].poisonDamage = damage
            alienStats[i][lane].poisoned = true
        end
    end
end

function GameState:resetStats(i,j)

    alienAlive[i][j] = false
    spotTaken[i][j] = false
    alienCounter = alienCounter + 1
    data.aliensKilled = data.aliensKilled + 1
    saveData()
    alienStats[i][j].health = 0 
    alienStats[i][j].hevalten = false 
    alienStats[i][j].immmunity = false 
    alienStats[i][j].speed = 1
    alienStats[i][j].poisoned = false
    alienStats[i][j].giant = 0 
    alienStats[i][j].morph = false
    if alienStats[i][j].name == 'Army' then
        damageBuff = damageBuff +.02
    end
    if alienStats[i][j].name == 'CommonCrippler' then
        commonBuff = commonBuff / 0.75
    end
    if alienStats[i][j].name == 'Protected' then
        targetBuff = targetBuff /.5
    end
    if alienStats[i][j].name == 'Rare' then
        rareBuff = rareBuff / 0.8
    end
    if alienStats[i][j].name == 'Scarce' then
        scarceBuff = scarceBuff / 0.85
    end         
    alienStats[i][j].name = ''
    alienStats[i][j].fly = false
    alienStats[i][j].flyCounter = -1
    alienStats[i][j].poisonDamage = 0 
    alienStats[i][j].stunned = false 
    alienStats[i][j].stunDuration = 0
    alienStats[i][j].hypno = false
end

function GameState:applyPoison()
    for i = 1, 10 do
        for j = 1, 5 do
            if alienAlive[i][j] and alienStats[i][j].poisoned and not alienStats[i][j].immmunity and not(GameState:checkGuardian(j))  and not(allGood) then
                alienStats[i][j].health = alienStats[i][j].health - alienStats[i][j].poisonDamage * damageBuff
                if alienStats[i][j].health <= 0 then
                    GameState:resetStats(i, j)
                end
                if alienStats[i][j].name == 'OldGranny' and not alienAlive[i+1][j] and not GameState:checkGuardian(j) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alienStats[i][j])
            end
        end
    end
end

function GameState:attackTile(weapon, row,lane)
    local weaponTemp = weapon
    if attacker.name == 'Star Blast' then
        GameState:starBlast(row,lane)
    end
    if attacker.name == 'Fresh Start' then
        GameState:FreshStart(row,lane)
    end
    if attacker.name == 'Comet Strike' then
        GameState:CometStrike(row,lane)
    end
    GameState:makeDead()
        if alienAlive[row][lane] and not alienStats[row][lane].immmunity  then
            local alien = alienStats[row][lane]
            local preHealth = alien.health
            if GameState:checkGuardian(lane) then
                if attacker.rarity == 'common' then
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageTile * damageBuff * commonBuff*targetBuff)
                elseif attacker.rarity == 'rare' then
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageTile * damageBuff * rareBuff*targetBuff)
                elseif attacker.rarity == 'scarce' then
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageTile * damageBuff * scarceBuff*targetBuff)
                else
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damageTile * damageBuff*targetBuff)
                end
            elseif weaponTemp.rarity == 'common' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff * commonBuff * targetBuff)
            elseif weaponTemp.rarity == 'rare' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*rareBuff*targetBuff)
            elseif weaponTemp.rarity == 'scarce' then
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*scarceBuff*targetBuff)
            else
                alien.health = alien.health - (weaponTemp.damageTile * damageBuff*targetBuff)
            end
            if weaponTemp.poison > 0 and not GameState:checkGuardian(lane) then
                GameState:checkPoison(weaponTemp.poison,lane)
            end
            if alien.health <= 0 then
                GameState:resetStats(row,lane)
            end
            if alienStats[row][lane].name == 'OldGranny' and preHealth ~= alien.health and not alienAlive[row+1][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+1,lane,row,lane)
            end
            GameState:spawnRand(alienStats[row][lane],preHealth)
        end
end

function checkStunned(row, lane)
    if alienAlive[row][lane] and alienStats[row][lane].stunned then
        if alienStats[row][lane].stunDuration <= 0 then
            alienStats[row][lane].stunned = false
            alienStats[row][lane].stunDuration = 0
        else
            alienStats[row][lane].stunDuration = alienStats[row][lane].stunDuration - 1
        end
    end
    return alienStats[row][lane].stunned
end

function GameState:stun(weapon, lane)
   local stunCounter = 0
    for i = 10, 1, -1 do
        if stunCounter < attacker.stun and not(allGood) then
            if alienAlive[i][lane] and not alienStats[i][lane].stunned and not alienStats[i][lane].immmunity  then
                stunCounter = stunCounter + 1
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = weapon.stunDuration
            end
        end
    end
end

function GameState:starBlast(row,lane)
    if alienAlive[row][lane] and not alienStats[row][lane].immmunity and not(alienStats[row][lane].name == 'Splashfest') then
        if GameState:checkGuardian(lane) then
            alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
        else
            alienStats[row][lane].health = alienStats[row][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
        end
        if alienStats[row][lane].name == 'OldGranny' and not alienAlive[row+1][lane] and not GameState:checkGuardian(lane) then
            GameState:changeStats(row+1,lane,row,lane)
        end
        GameState:spawnRand(alienStats[row][lane])
    end
    if lane -1 > 0 and not alienStats[row][lane-1].immmunity and not(alienStats[row][lane-1].name == 'Splashfest') and alienAlive[row][lane-1] then
        if alienAlive[row][lane-1] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane-1)][lane-1].health = alienStats[GameState:findGuardian(lane-1)][lane-1].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row][lane-1].health = alienStats[row][lane-1].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row][lane-1].name == 'OldGranny' and not alienAlive[row+1][lane-1] and not GameState:checkGuardian(lane-1) then
                GameState:changeStats(row+1,lane-1,row,lane-1)
            end
            GameState:spawnRand(alienStats[row][lane-1])
        end
    end
    if lane +1 < 6 and not alienStats[row][lane+1].immmunity and not(alienStats[row][lane+1].name == 'Splashfest') and alienAlive[row][lane+1] then
        if alienAlive[row][lane+1] then
            if GameState:checkGuardian(lane+1) then
                alienStats[GameState:findGuardian(lane+1)][lane+1].health = alienStats[GameState:findGuardian(lane+1)][lane+1].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row][lane+1].health = alienStats[row][lane+1].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row][lane+1].name == 'OldGranny' and not alienAlive[row+1][lane+1] and not GameState:checkGuardian(lane+1) then
                GameState:changeStats(row+1,lane+1,row,lane+1)
            end
            GameState:spawnRand(alienStats[row][lane+1])
        end
    end
    if row +1 < 11 and not alienStats[row+1][lane].immmunity and not(alienStats[row+1][lane].name == 'Splashfest') and alienAlive[row+1][lane] then
        if alienAlive[row+1][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row+1][lane].health = alienStats[row+1][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row+1][lane].name == 'OldGranny' and not alienAlive[row+2][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+2,lane,row+1,lane)
            end
            GameState:spawnRand(alienStats[row+1][lane])
        end
    end
    if row +2 < 11 and not alienStats[row+2][lane].immmunity and not(alienStats[row+2][lane].name == 'Splashfest') and alienAlive[row+2][lane] then
        if alienAlive[row+2][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row+2][lane].health = alienStats[row+2][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row+2][lane].name == 'OldGranny' and not alienAlive[row+3][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row+3,lane,row+2,lane)
            end
            GameState:spawnRand(alienStats[row+2][lane])
        end
    end
    if row -1 > 0 and not alienStats[row-1][lane].immmunity and not(alienStats[row-1][lane].name == 'Splashfest') and alienAlive[row-1][lane] then
        if alienAlive[row-1][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row-1][lane].health = alienStats[row-1][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row-1][lane].name == 'OldGranny' and not alienAlive[row][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row,lane,row-1,lane)
            end
            GameState:spawnRand(alienStats[row-1][lane])
        end
    end
    if row -2 > 0 and not alienStats[row-2][lane].immmunity and not(alienStats[row-2][lane].name == 'Splashfest') and alienAlive[row-2][lane] then
        if alienAlive[row-2][lane] then
            if GameState:checkGuardian(lane) then
                alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damageLane * damageBuff * commonBuff)
            else
                alienStats[row-2][lane].health = alienStats[row-2][lane].health - (attacker.damage * damageBuff * commonBuff * targetBuff)
            end
            if alienStats[row-2][lane].name == 'OldGranny' and not alienAlive[row-1][lane] and not GameState:checkGuardian(lane) then
                GameState:changeStats(row-1,lane,row-2,lane)
            end
            GameState:spawnRand(alienStats[row-2][lane])
        end
    end
end

function GameState:LaserKill(lane)

    for i = 10, 1, -1 do
        if alienAlive[i][lane] and alienStats[i][lane].health <= (attacker.damage * ((data.upgrades[attacker.name] * 0.1) + 1)) and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 0
        end
    end
end

function GameState:StellarBoost()
    damageBuff = damageBuff * 1.2 * ((data.upgrades[attacker.name] * 0.1) + 1)
end

function GameState:ThunderStrike(lane)
    local odds = true
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            while odds do
                local value = math.random(1,3)
                if value == 1 then
                    alienStats[i][lane].stunned = true
                    alienStats[i][lane].stunDuration = math.round(2 * ((data.upgrades[attacker.name] * 0.1) + 1))
                    break
                else
                    odds = false
                end
            end
        end
    end
end

function GameState:knockback(weapon, lane)
    local done = true
    local first = true
    local fixed = false
    for i = 10, 2, -1 do
        if alienAlive[i][lane] and done and not alienStats[i][lane].immmunity and not GameState:checkGuardian(lane) and not(allGood) then
                done = false

            if not(alienAlive[i-1]) then
                GameState:changeStats(i-1,lane,i,lane)

                GameState:reset(i,lane)

            else
                local temp = i
                local counter = 1
                while temp > 1 and alienAlive[temp-1][lane] do
                    counter = counter + 1
                    temp = temp-1
                end
                while counter > 0 and temp > 1 do
                    GameState:changeStats(i-counter,lane,i-counter + 1,lane)
                    GameState:reset(i-counter +1,lane)
                    counter = counter -1
                end
            end


        end
    end
end

function GameState:attackFirst(lane)
    local done = true
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and done and not alienStats[i][lane].immmunity then
            done = false
            local preHealth = alienStats[i][lane].health
            if attacker.name == 'Hevalstruck' and alienStats[1][lane].hevalten then
                if GameState:checkGuardian(lane) then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * rareBuff * 2)
                else
                    alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff *rareBuff* 2)
                end
            elseif attacker.name == 'Mind Blast' then
                if GameState:checkGuardian(lane) then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * scarceBuff)
                else
                    alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*scarceBuff)
                end
                if not(allGood) then
                    if not GameState:checkGuardian(lane) then
                        if alienStats[i][lane].health > 0 then
                            alienStats[i][lane].hypno = true
                        end
                    end
                end
            elseif attacker.name == 'Hypnosis' then
                if not(allGood) then
                    if not GameState:checkGuardian(lane) then
                        alienStats[i][lane].hypno = true
                        alienStats[i][lane].health = alienStats[i][lane].health + 1
                    else
                        alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health +1
                    end
                end
            elseif GameState:checkGuardian(lane) then
                if attacker.rarity == 'common' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * commonBuff)
                elseif attacker.rarity == 'rare' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * rareBuff)
                elseif attacker.rarity == 'scarce' then
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff * scarceBuff)
                else
                    alienStats[GameState:findGuardian(lane)][lane].health = alienStats[GameState:findGuardian(lane)][lane].health - (attacker.damage * damageBuff)
                end
            elseif attacker.rarity == 'common' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff * commonBuff)
            elseif attacker.rarity == 'rare' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*rareBuff)
            elseif attacker.rarity == 'scarce' then
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff*scarceBuff)
            else
                alienStats[i][lane].health = alienStats[i][lane].health - attacker.damage*(damageBuff)
            end
            if alienStats[i][lane].name == 'OldGranny' and not alienAlive[i][lane] and preHealth ~= alienStats[i][lane].health and not GameState:checkGuardian(lane) then
                GameState:changeStats(i+1,lane,i,lane)
            end
            GameState:spawnRand(alienStats[i][lane],preHealth)
        end
    end
end
function GameState:Dueltroid(lane)
    local which = math.random(1,2)
    local first = true
    local second = true
    local secondCount = 0
    if which == 1 then
        for i = 10, 1, -1 do
            if alienAlive[i][lane] and first and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly and not(allGood) then
                first = false
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = math.round(5 * ((data.upgrades[attacker.name] * 0.1) + 1))
            end
        end
    else
        for i = 10, 1, -1 do
            if alienAlive[i][lane] and second and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly and not(allGood) then
                secondCount = secondCount +1
                if secondCount >= 2 then second = false end
                alienStats[i][lane].stunned = true
                alienStats[i][lane].stunDuration = math.round(3*((data.upgrades[attacker.name] * 0.1) + 1))
            end
        end
    end
end
function GameState:FreshStart(row,lane)
    if lane == 1 then
        if row == 10 then
            for i = 10, 9,-1 do
                for j = 1, 2 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                       GameState:changeStats(i-8,j,i,j)
                        GameState:reset(i,j)
                    end
                end
            end
        else
            for i = row-1, row+1 do
                for j = 1, 2 do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                            GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    elseif lane == 5 then
        if row == 10 then
            for i = 10, 9,-1 do
                for j = 4, 5 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                        GameState:changeStats(i-8,j,i,j)
                       GameState:reset(i,j)
                    end
                end
            end
        else
            for i = row-1, row+1 do
                for j = 4, 5 do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                            GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                            GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    else
        if row == 10 then
            for i = 10, 9,-1 do
                for j = lane-1, lane+1 do
                    if alienAlive[i][j] and not alienAlive[i-8][j] then
                        GameState:changeStats(i-8,j,i,j)
                        GameState:reset(i,j)
                     end
                end
            end
        else
            for i =row-1,row+1 do
                for j = lane-1, lane+1  do
                    if alienAlive[i][j] then
                        if i == row-1 and not alienAlive[1][j] then
                            GameState:changeStats(1,j,i,j)
                                GameState:reset(i,j)
                        elseif i == row and not alienAlive[2][j] then
                            GameState:changeStats(2,j,i,j)
                                GameState:reset(i,j)
                        elseif i == row + 1 and not alienAlive[3][j] then
                            GameState:changeStats(3,j,i,j)
                                GameState:reset(i,j)
                        end
                    end
                end
            end
        end
    end
end
function GameState:respawn(lane)
    respawnLane = lane
end
function GameState:LaserBeam(lane)

    for i = 10, 1, -1 do
        if alienAlive[i][lane] and alienStats[i][lane].health <= (attacker.damage* ((data.upgrades[attacker.name] * 0.1) + 1)) and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 0
        end
    end
end
function GameState:GrenadeLancher()
    for i = 10, 1, -9 do
        for j = 1, 5 do
            if alienAlive[i][j] and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest')  then
                local preHealth = alienStats[i][j].health
                if GameState:checkGuardian(j) then
                    alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (-attacker.damage * damageBuff*scarceBuff)
                else
                    alienStats[i][j].health = alienStats[i][j].health - attacker.damage*scarceBuff*damageBuff
                end
                if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                    GameState:changeStats(i+1,j,i,j)
                end
                GameState:spawnRand(alienStats[i][j],preHealth)
            end
        end
    end
end
function GameState:DeathVirus()
    local lane = math.random(1,5)
    for i = 10,1,-1 do
        if alienAlive[i][lane] and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly  then
            alienAlive[i][lane] = false
            GameState:resetStats(i,lane)

        end
    end

end
function GameState:CelestialDisruption(lane)
    local counter = 0
    for i = 10, 1,-1 do
        if alienAlive[i][lane] and (not alienStats[i][lane].hevalten) and counter < 4 and not alienStats[i][lane].immmunity and not alienStats[i][lane].fly then
            alienStats[i][lane].health = 1
            counter = counter + 1
        end
    end
end
function GameState:Offguard()
     for i = 10, 1,-1 do
        for j = 1,5 do
            if alienAlive[i][j] and not alienStats[i][j].stunned and not alienStats[i][j].immmunity and not(allGood) then
                alienStats[i][j].stunned = true
                alienStats[i][j].stunDuration = math.round(2*((data.upgrades[attacker.name] * 0.1) + 1))
            end
        end
    end
end
function GameState:CometStrike(row,lane)
    if lane == 1 then
        if row == 1 then
            for i = 1, 2 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j] and not alienStats[i][j].immmunity  and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i = row-1, row+1 do
                for j = 1, 2 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j] and not alienStats[i][j].immmunity  and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    elseif lane == 5 then
        if row == 1 then
            for i = 1, 2 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]   and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i = row-1, row+1 do
                for j = 4, 5 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    else
        if row == 1 then
            for i = 1, 2 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        elseif row == 10 then
            for i = 10, 9,-1 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        else
            for i =row-1,row+1 do
                for j = lane-1, lane+1 do
                    local preHealth = alienStats[i][j].health
                    if alienAlive[i][j]  and not alienStats[i][j].immmunity and not(alienStats[i][j].name == 'Splashfest') then
                        if GameState:checkGuardian(j) then
                            alienStats[GameState:findGuardian(j)][j].health = alienStats[GameState:findGuardian(j)][j].health - (attacker.damage * damageBuff*targetBuff)
                        else
                            alienStats[i][j].health = alienStats[i][j].health - (attacker.damage * damageBuff * targetBuff)
                        end
                    end
                    if alienStats[i][j].name == 'OldGranny' and not alienAlive[i][j] and preHealth ~= alienStats[i][j].health and not GameState:checkGuardian(lane) then
                        GameState:changeStats(i+1,j,i,j)
                    end
                    GameState:spawnRand(alienStats[i][j],preHealth)
                end
            end
        end
    end
end
function GameState:MindBlast(lane)
    GameState:attackFirst(lane)
end
function GameState:Hynosis()
    GameState:attackFirst(1)
    GameState:attackFirst(2)
    GameState:attackFirst(3)
    GameState:attackFirst(5)
    GameState:attackFirst(4)
end
function GameState:makeDead()
    for i = 10,1,-1 do
        for j = 1,5 do
            if alienStats[i][j].health <= 0 and alienAlive[i][j] then
                GameState:resetStats(i,j)

            end
        end
    end
end
function GameState:changeStats(desI,desJ,norI,norJ)
    alienAlive[desI][desJ] = alienAlive[norI][norJ]
    spotTaken[desI][desJ] = spotTaken[norI][norJ]
    alienStats[desI][desJ].health = alienStats[norI][norJ].health
    alienStats[desI][desJ].speed = alienStats[norI][norJ].speed
    alienStats[desI][desJ].stunned = alienStats[norI][norJ].stunned
    alienStats[desI][desJ].hevalten = alienStats[norI][norJ].hevalten
    alienStats[desI][desJ].immmunity = alienStats[norI][norJ].immmunity
    alienStats[desI][desJ].poisoned = alienStats[norI][norJ].poisoned
    alienStats[desI][desJ].giant = alienStats[norI][norJ].giant
    alienStats[desI][desJ].morph = alienStats[norI][norJ].morph
    alienStats[desI][desJ].name = alienStats[norI][norJ].name
    alienStats[desI][desJ].fly = alienStats[norI][norJ].fly
    alienStats[desI][desJ].flyCounter = alienStats[norI][norJ].flyCounter
    alienStats[desI][desJ].poisonDamage = alienStats[norI][norJ].poisonDamage
    alienStats[desI][desJ].stunDuration = alienStats[norI][norJ].stunDuration
    alienStats[desI][desJ].hypno = alienStats[norI][norJ].hypno
end
function GameState:reset(i,j)
    alienAlive[i][j] = false
    spotTaken[i][j] = false
    alienStats[i][j].health = 0 
    alienStats[i][j].giant = 0 
    alienStats[i][j].morph = false
    alienStats[i][j].hevalten = false 
    alienStats[i][j].immmunity = false 
    alienStats[i][j].speed = 1
    alienStats[i][j].poisoned = false
    alienStats[i][j].name = ''
    alienStats[i][j].fly = false
    alienStats[i][j].flyCounter = -1
    alienStats[i][j].poisonDamage = 0 
    alienStats[i][j].stunned = false 
    alienStats[i][j].stunDuration = 0
    alienStats[i][j].hypno = false
end
function GameState:setMost(a,temp1)
    spotTaken[a][temp1] = true
    alienAlive[a][temp1] = true
    alienStats[a][temp1].morph = false
    alienStats[a][temp1].poisoned = false
    alienStats[a][temp1].giant = 0
    alienStats[a][temp1].fly = false
    alienStats[a][temp1].poisonDamage = 0
    alienStats[a][temp1].stunned = false
    alienStats[a][temp1].morph = false
    alienStats[a][temp1].stunDuration = 0
    alienStats[a][temp1].hypno = false
end
function GameState:morph(i,j)
    local temp = math.random(1,data.aliensUnlocked)
    
    local stats = {}
    stats.giant = 0
    stats.morph = true
    stats.poisoned = alienStats[i][j].poisoned
    stats.speed = 1
    stats.poisonDamage = alienStats[i][j].poisonDamage
    stats.stunned = alienStats[i][j].stunned
    stats.stunDuration = alienStats[i][j].stunDuration
    stats.stunned = alienStats[i][j].stunned
    stats.hypno = alienStats[i][j].hypno
    stats.fly = false

    stats.flyCounter = -1
    stats.immmunity = false
    for k = 1,data.aliensUnlocked do
        if temp == k then
            stats.health= (alienStats[i][j].health/Aliens[alienStats[i][j].name].health)*Aliensrand[k].health
            stats.hevalten = Aliensrand[k].hevalten
            stats.name = Aliensrand[k].name
            if stats.name == 'SpaceFence' then stats.immmunity = true end
            if stats.name == 'Spaceship' then stats.flyCounter = 0 end
        end
    end
    return stats
end
function GameState:makeAlien(row,n,health,hevalten,name)
    if name == 'SpaceFence' then
        alienStats[row][n].immmunity = true
    else
        alienStats[row][n].immmunity = false
    end
    if name == 'Spaceship' then
        alienStats[row][n].flyCounter = 0
    else
        alienStats[row][n].flyCounter = -1
    end
    if name == 'Morpher' then
        alienStats[row][n].morph = true
    else
        alienStats[row][n].morph = false
    end
    spotTaken[row][n] = true
    alienAlive[row][n] = true
    alienStats[row][n].health = health
    alienStats[row][n].hevalten = hevalten
    alienStats[row][n].speed = 1
    alienStats[row][n].poisoned = false
    alienStats[row][n].giant = 0
    alienStats[row][n].name = name
    alienStats[row][n].fly = false
    alienStats[row][n].poisonDamage = 0
    alienStats[row][n].stunned = false
    alienStats[row][n].stunDuration = 0
    alienStats[row][n].hypno = false
    if alienStats[row][n].name == 'Army' then
        damageBuff = damageBuff - 0.02
    end
    if alienStats[row][n].name == 'CommonCrippler' then
        commonBuff = commonBuff * 0.75
    end
    if alienStats[row][n].name == 'Protected' then
        targetBuff = targetBuff * .5
    end
    if alienStats[row][n].name == 'Rare' then
        rareBuff = rareBuff * 0.8
    end
    if alienStats[row][n].name == 'Scarce' then
        scarceBuff = scarceBuff * 0.85
    end
    if alienStats[row][n].name == 'GodOfSpace' then
        allGood = true
    end
end
function GameState:spawnRand(alien,preHealth)
    local temp = math.random(1,data.aliensUnlocked)
    local alive3 = false
    for i = 1,3 do
        for j = 1,5 do
            if not alienAlive[i][j] then 
                alive3 = true 
            end
        end
    end
    if preHealth == nil then preHealth = -293939238 end
    if alien.name == 'TheHevalGod' and alien.health ~= preHealth and alive3 then
        for k = 1,data.aliensUnlocked do
            if temp == k then
                local randRow = math.random(1,3)
                local randLane = math.random(1,5)
                while alienAlive[randRow][randLane] do
                    randRow = math.random(1,3)
                    randLane = math.random(1,5)
                end
                GameState:makeAlien(randRow,randLane,Aliensrand[k].health,Aliensrand[k].hevalten,Aliensrand[k].name)
            end
        end
    end
end
function GameState:upgrade()
    for num = 26,1,-1 do
        for i = 1, 10 do
            for j = 1, 5 do

                if alienAlive[i][j] and alienStats[i][j].name == Aliensrand[num].name then
                    local health = alienStats[i][j].health
                    local name = alienStats[i][j].name
                    GameState:reset(i,j)
                    GameState:makeAlien(i,j,(health/(Aliens[name].health))*Aliensrand[num+1].health,Aliensrand[num+1].hevalten,Aliensrand[num+1].name)
                end
            end
        end
    end
end
function GameState:checkGuardian(j)
    for i = 10,1,-1 do
        if alienStats[i][j].name == 'Guardian' then
            return true
        end
    end
    return false
end
function GameState:findGuardian(j)
    for i = 10,1,-1 do
        if alienStats[i][j].name == 'Guardian' then
            return i
        end
    end
end
function GameState:godRand(thingy)
    local alive3 = false
    for i = 1,3 do
        for j = 1,5 do
            if not alienAlive[i][j] then 
                alive3 = true 
            end
        end
    end
    local temp2 = math.random(1,data.aliensUnlocked)
    if thingy.name == 'GodOfSpace' and alive3 then
        for k = 1,data.aliensUnlocked do
            if temp2 == k then
                local randRow = math.random(1,3)
                local randLane = math.random(1,5)
                while alienAlive[randRow][randLane] do
                    randRow = math.random(1,3)
                    randLane = math.random(1,5)
                end
                GameState:makeAlien(randRow,randLane,Aliensrand[k].health,Aliensrand[k].hevalten,Aliensrand[k].name)
            end
        end
    end
end
function GameState:enter(item)
    if item == 'quit' then
        stage = 'first'
        GameState:switchStage()
        gStateMachine:change('home')
    end
    if item == 'bomb' then
        if stage == 'second' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('win')
        elseif stage == 'third' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('win')
        elseif stage == 'first' then
            stage = 'third'
            GameState:switchStage()
        end
    elseif item == 'zap' then
        local rand = math.random(1,5)
        for i = 10, 1, -1 do
            if not(allGood) then
                if alienAlive[i][rand] and not alienStats[i][rand].stunned and not alienStats[i][rand].immmunity  then
                    alienStats[i][rand].stunned = true
                    alienStats[i][rand].stunDuration = 3
                end
            end
        end
    elseif item == 'electricity' then
        for i = 10, 1, -1 do
            for j = 1,5 do
                if not(allGood) then
                    if alienAlive[i][j] and not alienStats[i][j].stunned and not alienStats[i][j].immmunity  then
                        alienStats[i][j].stunned = true
                        alienStats[i][j].stunDuration = 2
                    end
                end
            end
        end
    elseif item == 'retreat' then
        if stage == 'second' then
            stage = 'third'
            GameState:switchStage()
        elseif stage == 'third' then
            stage = 'first'
            GameState:switchStage()
            gStateMachine:change('win')
        elseif stage == 'first' then
            stage = 'second'
            GameState:switchStage()
        end
    elseif item == 'teleporter' then
        local done = false
        local i = math.random(1,10)
        local j = math.random(1,5)
        local alive = false
        for a = 1,10 do
            for b =1,5 do
                if alienAlive[a][b] then
                    alive = true
                end
            end
        end
        while not alienAlive[i][j] and alive do
            i = math.random(1,10)
            j = math.random(1,5)
        end
        GameState:resetStats(i,j)
    elseif item == 'gold' then
        data.goldBuff = 2
        saveData()
    elseif item == 'protection' then
        damageBuff = damageBuff * 1.5
    elseif item == 'walls' then
        local allLanesFull = checkAllLanesFull()

        if not allLanesFull then
            data.walls = data.walls + 1
            saveData()
        else
            local lane = math.random(1, 5)
            while not goodLane(lane) do
                lane = math.random(1, 5)
            end
            local row = math.random(2,10)
            while walls[row][lane] do
                row = math.random(2,10)
            end
            walls[row][lane] = true
        end
    end
end
function checkAllLanesFull()
    for j = 1, 5 do
        if goodLane(j) then
            return true
        end
    end
    return false
end
function goodLane(j)
    return checkLane(j) and checkWall(j)
end
function GameState:switchStage()
    weapon1Clicked = false
    weapon2Clicked = false
    weapon3Clicked = false
    alienCounter = 0
    mousePressed = true
    weapon1Cooldown = 0
    weapon2Cooldown = 0
    weapon3Cooldown = 0
    chooseLane = false
    damageBuff = 1
    scarceBuff = 1
    rareBuff = 1
    commonBuff = 1
    targetBuff = 1
    chooseTile = false
    GameState:killAllAliens()
end
function checkLane(j)
    for i = 1,10 do
        if alienStats[i][j].name == 'Gardener' then
            return false
        end
    end
    return true
end
function checkWall(j)
    for i = 2,10 do
        if not walls[i][j] then
            return true
        end
    end
    return false
end
function GameState:protected()
    damageBuff = damageBuff * 1.0125
end
