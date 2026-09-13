WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 1280, 720

push = require 'src/lib/push'
Class = require 'src/lib/Class'
ui = require 'src/ui'
icons = require 'src/icons'
require 'src/StateMachine'
require 'src/content'

require 'src/states/Loading'
require 'src/states/Home'
require 'src/states/Aliens'
require 'src/states/Weapons'
require 'src/states/Shop'
require 'src/states/Items'
require 'src/states/Settings'
require 'src/states/Profile'
require 'src/states/HowToPlay'
require 'src/states/PlanetMap'
require 'src/states/Loadout'
require 'src/states/StageSelect'
require 'src/states/Battle'
require 'src/states/Pause'
require 'src/states/Result'
require 'src/states/Reward'

local sessionStart = 0
local saveTimer = 0

function love.load()
    love.window.setTitle('Gods Of Space')
    love.graphics.setDefaultFilter('linear', 'linear')
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {vsync = true, fullscreen = false, resizable = true})

    loadData()
    weaponDictionary()
    alienDictionary()
    makeLevel()
    saveData()
    ui.initBackground()
    sessionStart = {hours = data.hours, mins = data.mins}

    gStateMachine = StateMachine {
        loading     = function() return Loading() end,
        home        = function() return Home() end,
        aliens      = function() return AliensScreen() end,
        weapons     = function() return WeaponsScreen() end,
        shop        = function() return Shop() end,
        items       = function() return Items() end,
        settings    = function() return Settings() end,
        profile     = function() return Profile() end,
        howToPlay   = function() return HowToPlay() end,
        planetMap   = function() return PlanetMap() end,
        loadout     = function() return Loadout() end,
        stageSelect = function() return StageSelect() end,
        battle      = function() return GameState() end,
        pause       = function() return Pause() end,
        result      = function() return Result() end,
        reward      = function() return Reward() end,
    }
    gStateMachine:change('loading')
    love.keyboard.keysPressed = {}
end

function love.resize(w, h) push:resize(w, h) end

function love.update(dt)
    dt = math.min(dt, 1 / 30)
    local totalMins = sessionStart.hours * 60 + sessionStart.mins + math.floor(love.timer.getTime() / 60)
    data.hours, data.mins = math.floor(totalMins / 60), totalMins % 60
    data.time = string.format('%02d:%02d', data.hours, data.mins)

    saveTimer = saveTimer + dt
    if saveTimer >= 60 then saveData(); saveTimer = 0 end

    ui.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')
    gStateMachine:render()
    ui.drawToasts()
    ui.brightness()
    ui.drawFade()
    push:apply('end')
    ui.endFrame()
end

function love.mousepressed(x, y, button)
    x, y = push:toGame(x, y)
    if x and y and button == 1 then
        ui.click(x, y)
        gStateMachine:mousePressed(x, y, button)
    end
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    gStateMachine:keyPressed(key)
end

function love.keyboard.wasPressed(key) return love.keyboard.keysPressed[key] == true end

function love.quit() saveData() end

function math.round(n) return math.floor(n + 0.5) end
function setColor(r, g, b, a) love.graphics.setColor(r, g, b, a) end
