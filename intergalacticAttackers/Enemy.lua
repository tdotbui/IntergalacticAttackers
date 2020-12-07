Enemy = Class{}

WALL_COUNT = 0

function Enemy:init(width, height)
    self.width = width
    self.height = height

    self.dx = ENEMY_SPEED
end

function Enemy:update(dt)
    for i,v in ipairs(enemies) do
        v.x = v.x + (v.dx * dt)
    end

    for i,v in ipairs(enemies) do
        if v.x > VIRTUAL_WIDTH - self.width - 5 then
            for i,v in ipairs(enemies) do
                v.dx = -self.dx
                WALL_COUNT = WALL_COUNT + 1
            end
        elseif v.x < 5 then
            for i,v in ipairs(enemies) do
                v.dx = self.dx
                WALL_COUNT = WALL_COUNT + 1
            end
        end
    end

    for i,v in ipairs(enemies) do
        if WALL_COUNT > 0 then
            for i,v in ipairs(enemies) do
                v.y = v.y + 15
                WALL_COUNT = 0
            end
        end
    end
end

function Enemy:insert(enemyAmountY, enemyAmountX)
    for a = 0, enemyAmountY do
        for b = 0, enemyAmountX do 
            table.insert(enemies, {x = (b * 20) + 5, y = (a * 20) + 25, width = self.width, height = self.height, dx = self.dx})
        end
    end
end

function Enemy:paused()
    for i,v in ipairs(enemies) do
        if v.dx > 0 then
            currentDX = self.dx
            v.dx = 0
        elseif v.dx < 0 then
            currentDX = -self.dx
            v.dx = 0
        end
    end
end

function Enemy:resume()
    for i,v in ipairs(enemies) do
        v.dx = currentDX
    end
end

function Enemy:reset()
    for i,v in ipairs(enemies) do
        enemies[i] = nil
    end
end

function Enemy:default()
    lvlCounter = 1
    ENEMY_SPEED = 75
    enemyAmountY = 9
    enemyAmountX = 1
end

function Enemy:increment()
    lvlCounter = lvlCounter + 1
    ENEMY_SPEED = ENEMY_SPEED * 1.1
    enemyAmountY = enemyAmountY + 1
    enemyAmountX = enemyAmountX + 1
end

function Enemy:gameOver()
    for i,v in ipairs(enemies) do
        if v.y + v.height > VIRTUAL_HEIGHT - 5 then
            return true
        end
    end
end

function Enemy:lvlPassed()
    local count = 0
    for _ in ipairs(enemies) do
        count = count + 1
    end
    if count == 0 then
        return true
    end
end

function Enemy:render()
    for i,v in ipairs(enemies) do
        love.graphics.draw(alien, v.x, v.y)
    end
end