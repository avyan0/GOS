ProfileChoose = Class{__includes = BaseState}

function ProfileChoose:init()
     profileIcons ={
        gTextures['playerIcon1'],
        gTextures['playerIcon'],
    }
end

function ProfileChoose:render()
    push:apply('start')
    setColor(100/255, 170/255, 255/255)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)
    love.drawBack()

    love.graphics.setFont(gFonts['game80'])
    love.graphics.printf('Choose an icon',0,60,VIRTUAL_WIDTH,'center')
    local counter = 0
    setColor(1,1,1,1)
    for _, icons in ipairs(profileIcons) do
        counter = counter + 1
        local w = icons:getWidth()
        local h = icons:getHeight()
        love.graphics.draw(icons,100*counter,300,0,80/(w-1),80/(h-1))
    end
    love.setBright()
    push:apply('end')
end


function ProfileChoose:mousePressed(x,y)
    if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('home')
	end
    for i = 1, 2 do
        if love.clicked(x,y,100*i,100*i +80,300,380) then
            data.profile = profileIcons[i]
            gStateMachine:change('home')
        end
    end
end