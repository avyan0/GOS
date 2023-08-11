P1Level = Class{__includes = BaseState}

function P1Level:render()
    push:apply('start')
    local wb = gTextures['p1Background']:getWidth()
    local hb = gTextures['p1Background']:getHeight()
    love.graphics.draw(gTextures['p1Background'],0,0,0,VIRTUAL_WIDTH / (wb - 1), VIRTUAL_HEIGHT / (hb - 1))


    love.drawBack()
    love.graphics.setBackgroundColor(.7,.7,.7)
    love.graphics.setLineWidth(8)
    setColor(89/255,89/255,89/255)
    love.graphics.line(158,594,1121,594)
    love.graphics.line(1121,594,1121,472)
    love.graphics.line(121,472,121,350)
    love.graphics.line(121,228,121,106)
    love.graphics.line(1121,350,1121,228)
    love.graphics.line(158,472,1121,472)
    love.graphics.line(158,228,1121,228)
    love.graphics.line(158,106,1121,106)

    love.graphics.line(158,350,1121,350)

    
    setColor(20/255,93/255,40/255)

   
    if data.planet == 1 then
        if data.level >= 1 then
            love.graphics.line(121,594,321,594)
            if data.level >= 2 then
                love.graphics.line(321,594,521,594)
                if data.level >= 3 then
                    love.graphics.line(521,594,721,594)
                    if data.level >= 4 then
                        love.graphics.line(721,594,921,594)
                        if data.level >= 5 then
                            love.graphics.line(921,594,1121,594)
                            if data.level >= 6 then
                                love.graphics.line(1121,594,1121,472)
                                if data.level >= 7 then
                                    love.graphics.line(1121,472,921,472)
                                    if data.level >= 8 then
                                        love.graphics.line(921,472,721,472)
                                        if data.level >= 9 then
                                            love.graphics.line(721,472,521,472)
                                            if data.level >= 10 then
                                                love.graphics.line(521,472,321,472)
                                                if data.level >= 11 then
                                                    love.graphics.line(321,472,121,472)
                                                    if data.level >= 12 then
                                                        love.graphics.line(121,472,121,350)
                                                        if data.level >= 13 then
                                                            love.graphics.line(121,350,321,350)
                                                            if data.level >= 14 then
                                                                love.graphics.line(321,350,521,350)
                                                                if data.level >= 15 then
                                                                    love.graphics.line(521,350,721,350)
                                                                    if data.level >= 16 then
                                                                        love.graphics.line(721,350,921,350)
                                                                        if data.level >= 17 then
                                                                            love.graphics.line(921,350,1121,350)
                                                                            if data.level >= 18 then
                                                                                love.graphics.line(1121,350,1121,228)
                                                                                if data.level >= 19 then
                                                                                    love.graphics.line(1121,228,921,228)
                                                                                    if data.level >= 20 then
                                                                                        love.graphics.line(921,228,721,228)
                                                                                        if data.level >= 21 then
                                                                                            love.graphics.line(721,228,521,228)
                                                                                            if data.level >= 22 then
                                                                                                love.graphics.line(521,228,321,228)
                                                                                                if data.level >= 23 then
                                                                                                    love.graphics.line(321,228,121,228)
                                                                                                    if data.level >= 24 then
                                                                                                        love.graphics.line(121,228,121,106)
                                                                                                        if data.level >= 25 then
                                                                                                            love.graphics.line(121,106,321,106)
                                                                                                            if data.level >= 26 then
                                                                                                                love.graphics.line(321,106,521,106)
                                                                                                                if data.level >= 27 then
                                                                                                                    love.graphics.line(521,106,721,106)
                                                                                                                    if data.level >= 28 then
                                                                                                                        love.graphics.line(721,106,921,106)
                                                                                                                        if data.level >= 29 then
                                                                                                                            love.graphics.line(921,106,1121,106)
                                                                                                                        end
                                                                                                                    end
                                                                                                                end
                                                                                                            end
                                                                                                        end
                                                                                                    end
                                                                                                end
                                                                                            end
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        love.graphics.line(158,594,1121,594)
        love.graphics.line(1121,594,1121,472)
        love.graphics.line(121,472,121,350)
        love.graphics.line(121,228,121,106)
        love.graphics.line(1121,350,1121,228)
        love.graphics.line(158,472,1121,472)
        love.graphics.line(158,228,1121,228)
        love.graphics.line(158,106,1121,106)
        love.graphics.line(158,350,1121,350)
    end

    

    
    setColor(238/255,238/255,238/255)
    love.graphics.circle('fill',121,594,36) -- if clicked go to that level
    love.graphics.circle('fill',321,594,36)
    love.graphics.circle('fill',521,594,36)
    love.graphics.circle('fill',721,594,36)
    love.graphics.circle('fill',921,594,36)
    love.graphics.circle('fill',1121,594,36)

    setColor(89/255,89/255,89/255)
   

    setColor(238/255,238/255,238/255)
    love.graphics.circle('fill',121,472,36)
    love.graphics.circle('fill',321,472,36)
    love.graphics.circle('fill',521,472,36)
    love.graphics.circle('fill',721,472,36)
    love.graphics.circle('fill',921,472,36)
    love.graphics.circle('fill',1121,472,36)

    setColor(89/255,89/255,89/255)

    setColor(238/255,238/255,238/255)
    love.graphics.circle('fill',121,350,36)
    love.graphics.circle('fill',321,350,36)
    love.graphics.circle('fill',521,350,36)
    love.graphics.circle('fill',721,350,36)
    love.graphics.circle('fill',921,350,36)
    love.graphics.circle('fill',1121,350,36)

    setColor(89/255,89/255,89/255)

    setColor(238/255,238/255,238/255)
    love.graphics.circle('fill',121,228,36)
    love.graphics.circle('fill',321,228,36)
    love.graphics.circle('fill',521,228,36)
    love.graphics.circle('fill',721,228,36)
    love.graphics.circle('fill',921,228,36)
    love.graphics.circle('fill',1121,228,36)

    setColor(89/255,89/255,89/255)

    setColor(238/255,238/255,238/255)
    love.graphics.circle('fill',121,106,36)
    love.graphics.circle('fill',321,106,36)
    love.graphics.circle('fill',521,106,36)
    love.graphics.circle('fill',721,106,36)
    love.graphics.circle('fill',921,106,36)
    love.graphics.circle('fill',1121,106,36)

    setColor(0,0,0)
    love.graphics.setFont(gFonts['game'])
    love.graphics.printf('1',85,578,72,'center')
    love.graphics.printf('2',285,578,72,'center')
    love.graphics.printf('3',485,578,72,'center')
    love.graphics.printf('4',685,578,72,'center')
    love.graphics.printf('5',885,578,72,'center')
    love.graphics.printf('6',1085,578,72,'center')
    love.graphics.printf('12',85,456,72,'center')
    love.graphics.printf('11',285,456,72,'center')
    love.graphics.printf('10',485,456,72,'center')
    love.graphics.printf('9',685,456,72,'center')
    love.graphics.printf('8',885,456,72,'center')
    love.graphics.printf('7',1085,456,72,'center')
    love.graphics.printf('13',85,334,72,'center')
    love.graphics.printf('14',285,334,72,'center')
    love.graphics.printf('15',485,334,72,'center')
    love.graphics.printf('16',685,334,72,'center')
    love.graphics.printf('17',885,334,72,'center')
    love.graphics.printf('18',1085,334,72,'center')
    love.graphics.printf('24',85,212,72,'center')
    love.graphics.printf('23',285,212,72,'center')
    love.graphics.printf('22',485,212,72,'center')
    love.graphics.printf('21',685,212,72,'center')
    love.graphics.printf('20',885,212,72,'center')
    love.graphics.printf('19',1085,212,72,'center')
    love.graphics.printf('25',85,90,72,'center')
    love.graphics.printf('26',285,90,72,'center')
    love.graphics.printf('27',485,90,72,'center')
    love.graphics.printf('28',685,90,72,'center')
    love.graphics.printf('29',885,90,72,'center')
    love.graphics.printf('30',1085,90,72,'center')

    setColor(1,1,1)
    local w = gTextures['wheel']:getWidth()
    local h = gTextures['wheel']:getHeight()
    love.graphics.draw(gTextures['wheel'],1000,579,30/(w-1),30/(h-1))
    love.graphics.draw(gTextures['wheel'],200,457,30/(w-1),30/(h-1))
    love.graphics.draw(gTextures['wheel'],1000,335,30/(w-1),30/(h-1))
    love.graphics.draw(gTextures['wheel'],200,213,30/(w-1),30/(h-1))
    love.graphics.draw(gTextures['wheel'],1000,91,30/(w-1),30/(h-1))

    love.setBright()
    

    push:apply('end')
end

function P1Level:mousePressed(x,y)
    if love.clicked(x,y,0,320,0,90) then
    	gStateMachine:change('home')
    end
    if data.planet > 1 then
        if love.clicked(x,y,121-36,121+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
            data.currentLevel = '1-1'
        elseif love.clicked(x,y,321-36,321+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-2'
        elseif love.clicked(x,y,521-36,521+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-3'
        elseif love.clicked(x,y,721-36,721+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-4'
        elseif love.clicked(x,y,921-36,921+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-5'
        elseif love.clicked(x,y,1121-36,1121+36,594-36,594+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-6'
        elseif love.clicked(x,y,121-36,121+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-12'
        elseif love.clicked(x,y,321-36,321+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-11'
        elseif love.clicked(x,y,521-36,521+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-10'
        elseif love.clicked(x,y,721-36,721+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-9'
        elseif love.clicked(x,y,921-36,921+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-8'
        elseif love.clicked(x,y,1121-36,1121+36,472-36,472+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-7'
        elseif love.clicked(x,y,121-36,121+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-13'
        elseif love.clicked(x,y,321-36,321+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-14'
        elseif love.clicked(x,y,521-36,521+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-15'
        elseif love.clicked(x,y,721-36,721+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-16'
        elseif love.clicked(x,y,921-36,921+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-17'
        elseif love.clicked(x,y,1121-36,1121+36,350-36,350+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-18'
        elseif love.clicked(x,y,121-36,121+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-24'
        elseif love.clicked(x,y,321-36,321+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-23'
        elseif love.clicked(x,y,521-36,521+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-22'
        elseif love.clicked(x,y,721-36,721+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-21'
        elseif love.clicked(x,y,921-36,921+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-20'
        elseif love.clicked(x,y,1121-36,1121+36,228-36,228+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-19'
            elseif love.clicked(x,y,121-36,121+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-25'
        elseif love.clicked(x,y,321-36,321+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-26'
        elseif love.clicked(x,y,521-36,521+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-27'
        elseif love.clicked(x,y,721-36,721+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-28'
        elseif love.clicked(x,y,921-36,921+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-29'
        elseif love.clicked(x,y,1121-36,1121+36,106-36,106+36) then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-30'
        end
    elseif data.planet == 1 then
        if love.clicked(x,y,121-36,121+36,594-36,594+36) and data.level >=0 then
            gStateMachine:change('weaponSelect')
            data.currentLevel = '1-1'
        elseif love.clicked(x,y,321-36,321+36,594-36,594+36) and data.level >=1 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-2'
        elseif love.clicked(x,y,521-36,521+36,594-36,594+36) and data.level >=2 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-3'
        elseif love.clicked(x,y,721-36,721+36,594-36,594+36) and data.level >=3 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-4'
        elseif love.clicked(x,y,921-36,921+36,594-36,594+36) and data.level >=4 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-5'
        elseif love.clicked(x,y,1121-36,1121+36,594-36,594+36) and data.level >=5 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-6'
        elseif love.clicked(x,y,121-36,121+36,472-36,472+36) and data.level >=6 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-12'
        elseif love.clicked(x,y,321-36,321+36,472-36,472+36) and data.level >=7 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-11'
        elseif love.clicked(x,y,521-36,521+36,472-36,472+36) and data.level >=8 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-10'
        elseif love.clicked(x,y,721-36,721+36,472-36,472+36) and data.level >=9 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-9'
        elseif love.clicked(x,y,921-36,921+36,472-36,472+36) and data.level >=10 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-8'
        elseif love.clicked(x,y,1121-36,1121+36,472-36,472+36) and data.level >=11 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-7'
        elseif love.clicked(x,y,121-36,121+36,350-36,350+36) and data.level >=12 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-13'
        elseif love.clicked(x,y,321-36,321+36,350-36,350+36) and data.level >=13 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-14'
        elseif love.clicked(x,y,521-36,521+36,350-36,350+36) and data.level >=14 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-15'
        elseif love.clicked(x,y,721-36,721+36,350-36,350+36) and data.level >=15 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-16'
        elseif love.clicked(x,y,921-36,921+36,350-36,350+36) and data.level >=16 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-17'
        elseif love.clicked(x,y,1121-36,1121+36,350-36,350+36) and data.level >=17 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-18'
        elseif love.clicked(x,y,121-36,121+36,228-36,228+36) and data.level >=18 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-24'
        elseif love.clicked(x,y,321-36,321+36,228-36,228+36) and data.level >=19 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-23'
        elseif love.clicked(x,y,521-36,521+36,228-36,228+36) and data.level >=20 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-22'
        elseif love.clicked(x,y,721-36,721+36,228-36,228+36) and data.level >=21 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-21'
        elseif love.clicked(x,y,921-36,921+36,228-36,228+36) and data.level >=22 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-20'
        elseif love.clicked(x,y,1121-36,1121+36,228-36,228+36) and data.level >=23 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-19'
            elseif love.clicked(x,y,121-36,121+36,106-36,106+36) and data.level >=24 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-25'
        elseif love.clicked(x,y,321-36,321+36,106-36,106+36) and data.level >=25 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-26'
        elseif love.clicked(x,y,521-36,521+36,106-36,106+36) and data.level >=26 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-27'
        elseif love.clicked(x,y,721-36,721+36,106-36,106+36) and data.level >=27 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-28'
        elseif love.clicked(x,y,921-36,921+36,106-36,106+36) and data.level >=28 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-29'
        elseif love.clicked(x,y,1121-36,1121+36,106-36,106+36) and data.level >=29 then
            gStateMachine:change('weaponSelect')
data.currentLevel = '1-30'
        end
    end
end
