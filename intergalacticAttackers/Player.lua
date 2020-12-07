Player = Class{}

function Player:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.dx = 0
end

function Player:update(dt)
    -- prevents player from moving off screen
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    elseif self.dx > 0 then
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

function Player:render()
    love.graphics.draw(spaceship, self.x, self.y)
end

function Player:paused()
    player.dx = 0
end