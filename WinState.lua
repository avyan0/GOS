WinState = Class{__includes = BaseState}
local planet = nil
local gold = 0
local spin = nil

function WinState:init()
    data.matchesPlayed = data.matchesPlayed + 1
    saveData()
    local planet = tonumber(string.match(data.currentLevel,'%d+'))
    if planet == 1 then
        gold = math.random(7,13) * data.goldBuff
    elseif planet == 2 then
        gold = math.random(10,20)* data.goldBuff
    elseif planet == 3 then
        gold = math.random(15,29)* data.goldBuff
    elseif planet == 4 then
        gold = math.random(21,39)* data.goldBuff
    elseif planet ==5 then
        gold = math.random(27,49)* data.goldBuff
    elseif planet == 6 then
        gold = math.random(34,62)* data.goldBuff
    end
    if data.goldBuff ~= 1 then
        data.goldBuff = 1
    end
    data.gold = data.gold + gold

    if tonumber(string.match(data.currentLevel, '%-(%d+)')) == data.level + 1 and planet == data.planet then
        data.level = data.level + 1
    end

    if data.level >= 30 then
        data.level = 0
        if data.planet < 6 then
            data.planet = data.planet + 1
        end
    end
    data.wins = data.wins + 1
    local p = data.planet
    local l = data.level
    
    if p == 1 then
        if (l == 5 or l == 11 or l == 17 or l == 23 or l == 29) then
            spin = 'Common'
        end
    elseif p ==2 then
        if (l == 11 or l == 23) then
            spin = 'Common'
        end
        if (l == 5 or l == 17  or l == 29) then
            spin = 'Rare'
        end
    elseif p==3 then
        if (l == 5) then
            spin = 'Common'
        end
        if (l == 17  or l == 11 or l ==23) then
            spin = 'Rare'
        end
        if  l == 29 then
            spin = 'Scarce'
        end
    elseif p==4 then
        if (l == 5) then
            spin = 'Common'
        end
        if (l == 11  or l == 23) then
            spin = 'Rare'
        end
        if  (l == 17 or l==29)then
            spin = 'Scarce'
        end
    elseif p==5 then
        if (l == 5) then
            spin = 'Rare'
        end
        if(l == 17  or l == 11 or l == 23) then
            spin = 'Scarce'
        end
        if  l == 29 then
            spin = 'God'
        end
    elseif p==6 then
        if(l == 5 or l == 11 or l == 23) then
            spin = 'Scarce'
        end
        if(l==17 or l==29)then
            spin = 'God'
        end
    end
    saveData()
end

function WinState:render()
    push:apply('start')

    setColor(245/255,111/255,77/255)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

    setColor(33/255,156/255,186/255)
    love.graphics.setFont(gFonts['game80'])
    love.graphics.printf('You Win!',0,100,1280,'center')
    love.graphics.setFont(gFonts['game70'])
    love.graphics.printf('Your Rewards:',0,230,1280,'center')
    love.graphics.setFont(gFonts['game'])

    love.graphics.printf('Gold Won: '..tostring(gold),0,330,1280,'center')
    setColor(1,240/255,33/255)
    love.graphics.rectangle('fill',60,430,350,225)
    love.graphics.rectangle('fill',870,430,350,225)

    setColor(33/255,156/255,186/255)

    love.graphics.setFont(gFonts['game'])
    love.graphics.printf('Play again',60,527,350,'center')
    love.graphics.printf('Go To Home',870,527,350,'center')
    love.setBright()
    saveData()

    push:apply('end')
end

function WinState:mousePressed(x,y)
    if love.clicked(x,y,870,870+350,430,430+225) then
        if data.planet == tonumber(data.currentLevel:match("(%d+)")) and (data.level == 5 or data.level == 11 or data.level == 17 or data.level == 23 or data.level == 29) then
            gStateMachine:change('levelSpin',{spin = spin, go = 'home'})
        else
            gStateMachine:change('home')
        end
    end

    if love.clicked(x,y,60,60+350,430,430+225) then
        if data.planet == tonumber(data.currentLevel:match("(%d+)")) and (data.level == 5 or data.level == 11 or data.level == 17 or data.level == 23 or data.level == 29) then
            gStateMachine:change('levelSpin',{spin = spin, go = 'redo'})
        else
            gStateMachine:change('weaponSelect')
        end
    end

end
