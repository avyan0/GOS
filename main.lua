WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 1280, 720

push = require 'src/lib/push'
Class = require 'src/lib/Class'
ui = require 'src/ui'
sfx = require 'src/sfx'
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

function love.load(args)
    if args and args[1] == '--test' then TESTING = true; require 'src/tests'; love.event.quit(); return end
    if args and args[1] == '--sim' then TESTING = true; SIM_ARGS = {args[2], args[3], args[4], args[5], args[6], args[7], args[8]}; require 'src/sim'; love.event.quit(); return end
    -- `lovec . --profile name` plays with a separate save (dev/testing)
    if args and args[1] == '--profile' and args[2] then love.filesystem.setIdentity('GodsOfSpace-' .. args[2]) end
    -- `lovec . --smoke` drives every screen with random input and exits non-zero on any error
    if args and args[1] == '--smoke' then TESTING = true; SMOKE = require 'src/smoke'; love.filesystem.setIdentity('GodsOfSpace-smoke') end
    DEBUG = os.getenv('GOS_DEBUG') ~= nil or SMOKE ~= nil -- F9 in battle fires a random event
    love.window.setTitle('Gods Of Space')
    love.graphics.setDefaultFilter('linear', 'linear')
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {vsync = true, fullscreen = false, resizable = true})

    loadData()
    if data.fullscreen then love.window.setFullscreen(true); push:resize(love.graphics.getDimensions()) end
    pcall(sfx.init) -- no audio device is not fatal
    -- window icon: a Hevalten-red planet drawn with our own icon code
    pcall(function() -- not every platform (web) can set an icon
        local c = love.graphics.newCanvas(64, 64)
        love.graphics.setCanvas(c); love.graphics.clear(0, 0, 0, 0)
        if not icons.planetArt(6, 32, 32, 24) then icons.planet(32, 32, 24, PLANETS[6].hue, false) end
        love.graphics.setCanvas()
        love.window.setIcon(c:newImageData())
    end)
    weaponDictionary()
    alienDictionary()
    makeLevel(); applyNewSpawns()
    sanitizeData()
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
    if SMOKE then SMOKE.begin() end
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
    if SMOKE then
        SMOKE.guarded(gStateMachine.update, gStateMachine, 1 / 12) -- fast clock so turns actually pass
        if SMOKE.step(dt) then love.event.quit(SMOKE.errors() > 0 and 1 or 0) end
    else
        gStateMachine:update(dt)
    end
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:apply('start')
    if SMOKE then SMOKE.guarded(gStateMachine.render, gStateMachine) else gStateMachine:render() end
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

function toggleFullscreen()
    data.fullscreen = not love.window.getFullscreen()
    love.window.setFullscreen(data.fullscreen)
    push:resize(love.graphics.getDimensions())
end

function love.keypressed(key)
    if key == 'f11' then toggleFullscreen(); return end
    love.keyboard.keysPressed[key] = true
    gStateMachine:keyPressed(key)
end

function love.textinput(t) gStateMachine:textInput(t) end

function love.keyboard.wasPressed(key) return love.keyboard.keysPressed[key] == true end

function love.quit() if not TESTING then saveData() end end

function math.round(n) return math.floor(n + 0.5) end
function setColor(r, g, b, a) love.graphics.setColor(r, g, b, a) end
