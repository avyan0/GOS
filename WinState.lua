WinState = Class{__includes = BaseState}

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
    local planet = tonumber(string.match(data.currentLevel,'%d+'))
    local gold = 0
    if planet == 1 then
        gold = 10 * data.goldBuff
    elseif planet == 2 then
        gold = 15* data.goldBuff
    elseif planet == 3 then
        gold = 22* data.goldBuff
    elseif planet == 4 then
        gold = 30* data.goldBuff
    elseif planet ==5 then
        gold = 38* data.goldBuff
    elseif planet == 6 then
        gold = 48* data.goldBuff
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


    love.graphics.printf('Gold Won: '..tostring(gold),0,330,1280,'center')
    setColor(1,240/255,33/255)
    love.graphics.rectangle('fill',60,430,350,225)
    love.graphics.rectangle('fill',870,430,350,225)

    setColor(33/255,156/255,186/255)

    love.graphics.setFont(gFonts['game'])
    love.graphics.printf('Play again',60,527,350,'center')
    love.graphics.printf('Go To Home',870,527,350,'center')
    love.setBright()

    push:apply('end')
end

function WinState:mousePressed(x,y)

    if love.clicked(x,y,870,870+350,430,430+225) then
        gStateMachine:change('home')
    end

    if love.clicked(x,y,60,60+350,430,430+225) then
        gStateMachine:change('weaponSelect')
    end

end
