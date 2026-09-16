StateMachine = Class{}

local NOOP = function() end
local EMPTY = {render = NOOP, update = NOOP, enter = NOOP, exit = NOOP, mousePressed = NOOP, keyPressed = NOOP, textInput = NOOP}

function StateMachine:init(states)
    self.states = states or {}
    self.current = EMPTY
    self.currentName = nil
    self.pending = nil
end

-- Changes are applied at the start of the next update, so a state can safely
-- request a change from inside render() (immediate-mode buttons do this).
function StateMachine:change(name, params)
    assert(self.states[name], 'unknown state ' .. tostring(name))
    self.pending = {name = name, params = params}
end

function StateMachine:apply()
    if not self.pending then return end
    local p = self.pending
    self.pending = nil
    self.current:exit()
    self.current = self.states[p.name]()
    self.currentName = p.name
    for k, v in pairs(EMPTY) do if not self.current[k] then self.current[k] = v end end
    if p.name ~= 'battle' then ui.fadeIn() end
    self.current:enter(p.params)
end

function StateMachine:update(dt)
    self:apply()
    self.current:update(dt)
end

function StateMachine:render() self.current:render() end
function StateMachine:mousePressed(x, y, b) self.current:mousePressed(x, y, b) end
function StateMachine:keyPressed(k) self.current:keyPressed(k) end
function StateMachine:textInput(t) self.current:textInput(t) end
