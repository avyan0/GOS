WinState = Class{__includes = BaseState}
local planet = nil
local gold = 0
local spin = nil

function WinState:init()
    data.matchesPlayed = data.matchesPlayed + 1
    saveData()
    local planet = tonumber(string.match(data.currentLevel,'%d+'))
    --local levelNumber = tonumber(string.match(currentLevel, '-(%d+)'))
    --if levelNumber-1 == data.level then
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
    --[[else
        if planet == 1 then
            gold = math.random(1,3) * data.goldBuff
        elseif planet == 2 then
            gold = math.random(1,5)* data.goldBuff
        elseif planet == 3 then
            gold = math.random(1,8)* data.goldBuff
        elseif planet == 4 then
            gold = math.random(1,11)* data.goldBuff
        elseif planet ==5 then
            gold = math.random(2,13)* data.goldBuff
        elseif planet == 6 then
            gold = math.random(3,16)* data.goldBuff
        end--]]
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
    if(l==7 and p==1) then
        setAlienUnlock(3)
    elseif(l==14 and p==1) then
        setAlienUnlock(4)
    elseif(l==21 and p==1) then
        setAlienUnlock(5)
    elseif(l==28 and p==1) then
        setAlienUnlock(6)
    elseif(l==5 and p==2) then
        setAlienUnlock(7)
    elseif(l==12 and p==2) then
        setAlienUnlock(8)
    elseif(l==19 and p==2) then
        setAlienUnlock(9)
    elseif(l==26 and p==2) then
        setAlienUnlock(10)
    elseif(l==3 and p==3) then
        setAlienUnlock(11)
    elseif(l==10 and p==3) then
        setAlienUnlock(12)
    elseif(l==17 and p==3) then
        setAlienUnlock(13)
    elseif(l==24 and p==3) then
        setAlienUnlock(14)
    elseif(l==1 and p==4) then
        setAlienUnlock(15)
    elseif(l==8 and p==4) then
        setAlienUnlock(16)
    elseif(l==14 and p==4) then
        setAlienUnlock(17)
    elseif(l==20 and p==4) then
        setAlienUnlock(18)
    elseif(l==26 and p==4) then
        setAlienUnlock(19)
    elseif(l==2 and p==5) then
        setAlienUnlock(20)
    elseif(l==8 and p==5) then
        setAlienUnlock(21)
    elseif(l==14 and p==5) then
        setAlienUnlock(22)
    elseif(l==20 and p==5) then
        setAlienUnlock(23)
    elseif(l==26 and p==5) then
        setAlienUnlock(24)
    elseif(l==2 and p==6) then
        setAlienUnlock(25)
    elseif(l==8 and p==6) then
        setAlienUnlock(26)
    elseif(l==14 and p==6) then
        setAlienUnlock(27)
    end
    saveData()
end

function setAlienUnlock(x)
    if (data.aliensUnlocked<=x) then
        data.aliensUnlocked = x
        saveData();
    end
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
