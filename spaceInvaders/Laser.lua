Laser = Class{}

function Laser:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    self.dy = 0
end

function Laser:update(dt)
    self.y = self.y - self.dy * dt
end

function Laser:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end