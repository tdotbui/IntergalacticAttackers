push = require 'push'
Class = require 'class'

require 'Player'
require 'Laser'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PLAYER_SPEED = 200
LASER_SPEED = 500

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true,
        canvas = false
    })

    lasers = {}
    player = Player(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - 20, 10, 10)
end

function love.update(dt)
    -- player movement
    if love.keyboard.isDown('a') then
        player.dx = -PLAYER_SPEED
    elseif love.keyboard.isDown('d') then
        player.dx = PLAYER_SPEED
    else
        player.dx = 0
    end

    -- laser projection
    for i,v in ipairs(lasers) do 
        v.y = v.y + (v.dy * dt)
    end

    player:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'space' then
        table.insert(lasers, {x = player.x + 4, y = player.y - 10, dy = -LASER_SPEED})
    end
end

function love.draw()
    push:start()
    love.graphics.setColor(1, 1, 1)
    player:render()

    love.graphics.setColor(1, 0, 0)
    for i,v in ipairs(lasers) do 
        love.graphics.rectangle('fill', v.x, v.y, 2, 10)
    end
    push:finish()
end