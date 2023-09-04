WeaponSelect = Class{__includes = BaseState}

local weaponnum = 0
local buttons = {
    {name = 'Astroi dRain', x = 0, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Poison Arrow', x = 188, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Triple Threat', x = 376, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Cosmic Fire', x = 564, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Astrobolt', x = 752, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Star Blast', x = 940, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Laser Kill', x = 1124, y = 158, width = 156, height = 38, highlighted = false},
    {name = 'Stellar Boost', x = 0, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Thunder Strike', x = 188, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Battle Ram', x = 376, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Electro Jolt', x = 564, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Dagger Throw', x = 752, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Hevalstruck', x = 940, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Recursive Explosion', x = 1124, y = 255, width = 156, height = 38, highlighted = false},
    {name = 'Dueltroid', x = 0, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Fresh Start', x = 188, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Santa Axe', x = 376, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Respawn', x = 564, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Offguard', x = 752, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Laser Beam', x = 940, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Mind Blast', x = 1124, y = 353, width = 156, height = 38, highlighted = false},
    {name = 'Grenade Launcher', x = 0, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Protected', x = 188, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Hypnosis', x = 376, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Galactic Beam', x = 564, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Solar Flare', x = 752, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Comet Strike', x = 940, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Death Virus', x = 1124, y = 451, width = 156, height = 38, highlighted = false},
    {name = 'Void Burst', x = 0, y = 548, width = 156, height = 38, highlighted = false},
    {name = 'Celestial Disruption', x = 188, y = 548, width = 156, height = 38, highlighted = false},
    {name = 'Quantum Flux', x = 376, y = 548, width = 156, height = 38, highlighted = false}
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
            if button.name == 'Recursive Explosion' or button.name == 'Grenade Launcher' or button.name == 'Celestial Disruption' then
                love.graphics.setFont(gFonts['game15'])
            else
                love.graphics.setFont(gFonts['game18'])
            end
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
        data.weaponChoose1 = string.gsub(weaponName, " ", "")
    end
    if weaponnum == 2 then
        data.weaponChoose2 = string.gsub(weaponName, " ", "")
    end
    if weaponnum == 3 then
        data.weaponChoose3 = string.gsub(weaponName, " ", "")
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
