Laser = Class{}

function Laser:init(width, height)
    self.width = width
    self.height = height

    self.dy = -LASER_SPEED
end

function Laser:update(dt)
    for i,v in ipairs(lasers) do 
        v.y = v.y + (v.dy * dt)
    end

    -- deletes lasers that exit screen
    for i,v in ipairs(lasers) do 
        if v.y < 0 then
            table.remove(lasers, i)
        end
    end
end

function Laser:insert()
    table.insert(lasers, {x = player.x + 4, y = player.y - 10, width = self.width, height = self.height, dy = self.dy})
end

function Laser:render()
    for i,v in ipairs(lasers) do 
        love.graphics.rectangle('fill', v.x, v.y, self.width, self.height)
    end
end