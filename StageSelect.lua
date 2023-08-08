StageSelect = Class{__includes = BaseState}

local weaponnum = 0
local weaponToReplace = nil
local replaceNum = 0
local weaponToAdd = nil
local buttons = {
    {name = 'AstroidRain', x = 0, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'PoisonArrow', x = 188, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'TripleThreat', x = 376, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'CosmicFire', x = 564, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Astrobolt', x = 752, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'StarBlast', x = 940, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'LaserKill', x = 1124, y = 158, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'StellarBoost', x = 0, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'ThunderStrike', x = 188, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'BattleRam', x = 376, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'ElectroJolt', x = 564, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'DaggerThrow', x = 752, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Hevalstruck', x = 940, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'RecursiveExplosion', x = 1124, y = 255, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Dueltroid', x = 0, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'FreshStart', x = 188, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'SantaAxe', x = 376, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Respawn', x = 564, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Offguard', x = 752, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'LaserBeam', x = 940, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'MindBlast', x = 1124, y = 353, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'GrenadeLauncher', x = 0, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Protected', x = 188, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'Hypnosis', x = 376, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'GalacticBeam', x = 564, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'SolarFlare', x = 752, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'CometStrike', x = 940, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'DeathVirus', x = 1124, y = 451, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'VoidBurst', x = 0, y = 548, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'CelestialDisruption', x = 188, y = 548, width = 156, height = 38, highlighted = false, highlightedRed= false},
    {name = 'QuantumFlux', x = 376, y = 548, width = 156, height = 38, highlighted = false, highlightedRed= false}
}

function StageSelect:render()
    push:apply('start')
    love.graphics.setFont(gFonts['game30'])
    setColor(192/255, 192/255, 192/255)
    love.graphics.printf("Choose 1 Weapon",0,10,1280,'center')
    setColor(136/255,136/255,255/255)
    love.graphics.rectangle('fill',990,608,200,90)
    setColor(192/255, 192/255, 192/255)
    love.graphics.printf("Next",990,638,200,'center')

    setColor(192/255, 192/255, 192/255)
    love.graphics.printf("Weapon 1: " .. data.weaponChoose1, 0, 70, 427, 'center')
    love.graphics.printf("Weapon 2: " .. data.weaponChoose2,427, 70, 427, 'center')
    love.graphics.printf("Weapon 3: " .. data.weaponChoose3, 854, 70, 426, 'center')

    
    love.graphics.setFont(gFonts['game18'])
    for i, button in ipairs(buttons) do
        if (data.weapons[button.name] ~= false) then
            
            if button.highlightedRed then
                setColor(1,0,0)
            else
                setColor(192/255, 192/255, 192/255)
            end
        
            if button.highlighted then
                setColor(0, 1, 0)
            end
            love.graphics.rectangle('fill', button.x, button.y, button.width, button.height)
            setColor(1,1,1)
            love.graphics.printf(button.name, button.x, button.y + button.height / 2, button.width, 'center')
        end
    end
    push:apply('end')
end

function StageSelect:mousePressed(x, y)
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
                gStateMachine:change('game')
                if weaponToAdd ~= nil and weaponToRemove ~= nil then
                    if replaceNum == 1 then
                        data.weaponChoose1 = weaponToAdd
                    elseif replaceNum == 2 then
                        data.weaponChoose2 = weaponToAdd
                    elseif replaceNum == 3 then
                        data.weaponChoose3 = weaponToAdd
                    end
                end 
        end
    end
end

function StageSelect:handleWeaponButtonClick(weaponName)
    if data.weaponChoose1 == weaponName or data.weaponChoose2 == weaponName or data.weaponChoose3 == weaponName then
        for _, button in ipairs(buttons) do
            if button.name == weaponName then
                if button.highlightedRed then
                    button.highlightedRed = false
                    weaponToRemove = nil
                    replaceNum = 0
                else
                    button.highlightedRed = true
                    weaponToRemove = button.name
                    if data.weaponChoose1 == weaponName then
                        replaceNum = 1
                    elseif data.weaponChoose2 == weaponName then
                        replaceNum = 2
                    elseif data.weaponChoose3 == weaponName then
                        replaceNum = 3
                    end
                end
            else
                button.highlightedRed = false
            end
        end
    else
        for _, button in ipairs(buttons) do
            if button.name == weaponName then
                if button.highlighted then
                    button.highlighted = false
                    weaponToAdd = nil
                else
                    button.highlighted = true
                    weaponToAdd = button.name
                end
            else
                button.highlighted = false
            end
        end
    end
end
