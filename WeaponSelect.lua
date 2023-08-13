WeaponSelect = Class{__includes = BaseState}

local weaponnum = 0
local buttons = {
    {name = 'AstroidRain', x = 0, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'PoisonArrow', x = 188, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'TripleThreat', x = 376, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'CosmicFire', x = 564, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Astrobolt', x = 752, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'StarBlast', x = 940, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'LaserKill', x = 1124, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'StellarBoost', x = 0, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'ThunderStrike', x = 188, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'BattleRam', x = 376, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'ElectroJolt', x = 564, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'DaggerThrow', x = 752, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Hevalstruck', x = 940, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'RecursiveExplosion', x = 1124, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Dueltroid', x = 0, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'FreshStart', x = 188, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'SantaAxe', x = 376, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Respawn', x = 564, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Offguard', x = 752, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'LaserBeam', x = 940, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'MindBlast', x = 1124, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'GrenadeLauncher', x = 0, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Protected', x = 188, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Hypnosis', x = 376, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'GalacticBeam', x = 564, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'SolarFlare', x = 752, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'CometStrike', x = 940, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'DeathVirus', x = 1124, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'VoidBurst', x = 0, y = 548, width = 156, height = 38, highlighted = false},
    {name = 'CelestialDisruption', x = 188, y = 548, width = 156, height = 38, highlighted = false},
    {name = 'QuantumFlux', x = 376, y = 548, width = 156, height = 38, highlighted = false}
}

function WeaponSelect:render()
    love.graphics.setFont(gFonts['game30'])
    setColor(192/255, 192/255, 192/255)
    love.graphics.printf("Choose 3 Weapons",0,10,1280,'center')
    setColor(136/255,136/255,255/255)
    love.graphics.rectangle('fill',990,608,200,90)
    setColor(192/255, 192/255, 192/255)
    love.graphics.printf("Next",990,638,200,'center')

    love.graphics.setFont(gFonts['game18'])
    for i, button in ipairs(buttons) do
        if (data.weapons[button.name] ~= false) then
            if button.highlighted then
                setColor(1, 1, 0)
            else
                setColor(192/255, 192/255, 192/255)
            end
        
            love.graphics.rectangle('fill', button.x, button.y, button.width, button.height)
            setColor(1,1,1)
            love.graphics.printf(button.name, button.x, button.y + button.height / 2, button.width, 'center')
        end
    end

    setColor(192/255,192/255,192/255)
    love.drawBack()

end

function WeaponSelect:mousePressed(x, y)
    if love.clicked(x, y, 0, 320, 0, 90) then
        gStateMachine:change('home')
    end

    for i, button in ipairs(buttons) do
        if love.clicked(x, y, button.x, button.width + button.x, button.y, button.height + button.y) then
            if button.name == 'Done' then
                self:handleDoneButtonClick()
            else
                self:handleWeaponButtonClick(button.name)
            end
            break
        end
    end

    if love.clicked(x,y,990,1190,608,698) then
        if not(data.weaponChoose1 == data.weaponChoose2 or data.weaponChoose1 == data.weaponChoose3 or data.weaponChoose2 == data.weaponChoose3) then
            if data.weaponChoose1 ~= "" and data.weaponChoose2~="" and data.weaponChoose3~="" then
                gStateMachine:change('game')
            end
        end
    end
end

function WeaponSelect:handleWeaponButtonClick(weaponName)
    local clickedButton = nil
    local highlightedCount = 0
    weaponnum = weaponnum%3 +1
    if weaponnum == 1 then
        data.weaponChoose1 = weaponName
    end
    if weaponnum == 2 then
        data.weaponChoose2 = weaponName
    end
    if weaponnum == 3 then
        data.weaponChoose3 = weaponName
    end
    saveData()
    for _, button in ipairs(buttons) do
        if button.name == weaponName then
            clickedButton = button
        elseif button.highlighted then
            highlightedCount = highlightedCount + 1
        end
    end
    if clickedButton then
        if clickedButton.highlighted then
            clickedButton.highlighted = false
        elseif highlightedCount < 3 then
            clickedButton.highlighted = true
        end
    end
    if highlightedCount >= 3 then
        for _, button in ipairs(buttons) do
            if button.highlighted and button ~= clickedButton then
                button.highlighted = false
                break
            end
        end
    end
end

function WeaponSelect:mouseMoved(x, y)
    for i, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            button.highlighted = true
        else
            button.highlighted = false
        end
    end
end
