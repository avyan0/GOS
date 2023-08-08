LoadingScreenState = Class{__includes = BaseState}

local countdownTime = .55

function LoadingScreenState:init()
	self.count = 3
	self.timer = 0
    self.a = 0
end

function LoadingScreenState:update(dt)
	self.timer = self.timer + dt

    if self.timer > countdownTime then
        self.timer = self.timer % countdownTime
        self.count = self.count - 1

        if self.count == 0 then
            Timer.tween(2, {
                [self] = {a = 1}
            }):finish(function()
                gStateMachine:change('home')end)
        end
    end
    Timer.update(dt)
end

function LoadingScreenState:render() 

    love.graphics.printf('Gods Of Space', 0, VIRTUAL_HEIGHT/3, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(0,0,0,1-(data.brightness/100))
    love.graphics.rectangle('fill', 0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT)

    love.graphics.setColor(0,0,0, self.a)
    love.graphics.rectangle('fill',0,0,VIRTUAL_WIDTH,VIRTUAL_HEIGHT
)

end

function LoadingScreenState:mousePressed(x,y) end

function LoadingScreenState:exit() end
function LoadingScreenState:enter() end