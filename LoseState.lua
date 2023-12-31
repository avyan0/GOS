LoseState = Class{__includes = BaseState}
function LoseState:init()
    data.matchesPlayed = data.matchesPlayed + 1
    saveData()
end

function LoseState:render()
    push:apply('start')

    setColor(245/255,111/255,77/255)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

    setColor(33/255,156/255,186/255)
    love.graphics.setFont(gFonts['game80'])
    love.graphics.printf('You Lost!',0,100,1280,'center')
    love.graphics.setFont(gFonts['game70'])
    love.graphics.printf('Choose An Option',0,230,1280,'center')
    love.graphics.setFont(gFonts['game'])
    love.graphics.printf('Play again',60,597,350,'center')

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

function LoseState:mousePressed(x,y)

    if love.clicked(x,y,870,870+350,430,430+225) then
        gStateMachine:change('home')
    end

    if love.clicked(x,y,60,60+350,430,430+225) then
        gStateMachine:change('weaponSelect')
    end

end
