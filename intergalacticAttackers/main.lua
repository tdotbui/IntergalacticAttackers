push = require 'push'
Class = require 'class'

require 'Player'
require 'Enemy'
require 'Laser'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PLAYER_SPEED = 200
ENEMY_SPEED = 75
LASER_SPEED = 500

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Intergalactic Attackers')
    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)

    sounds = {
        ['kill'] = love.audio.newSource('sounds/kill.wav', 'static'),
        ['shoot'] = love.audio.newSource('sounds/shoot.wav', 'static')
    }

    background = love.graphics.newImage('graphics/spaceBackground.jpg')
    spaceship = love.graphics.newImage('graphics/spaceship.png')
    alien = love.graphics.newImage('graphics/alien.png')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })
    
    player = Player(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT - 20, 10, 10)

    enemies = {}
    enemy = Enemy(10, 10)

    lasers = {}
    laser = Laser(2, 10)

    enemy:insert(1, 9)

    highScore = 0
    enemy:default()
    
    gameState = 'menu'
end

function love.resize(w, h)
    push:resize(w, h)
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

    enemy:update(dt)
    -- laser projection
    laser:update(dt)
    player:update(dt)

    collisionDetect(enemies, lasers)

    if gameState == 'play' then
        if enemy:lvlPassed() == true then
            gameState = 'victory'
        elseif enemy:gameOver() == true then
            gameState = 'defeat'
        end
    end

    highScore = math.max(highScore, lvlCounter)
end

function collisionDetect(enemies, lasers)
    for a, e in ipairs(enemies) do
	    for b, l in ipairs(lasers) do
            if l.y <= e.y + e.height and l.x > e.x and l.x < e.x + e.width then
                table.remove(enemies, a)
                table.remove(lasers, b)
                sounds['kill']:play()
		    end
	    end
	end
end

function love.keypressed(key)
    -- menu navigation, pausing, resuming, etc.
    if gameState == 'menu' then
        if key == 'escape' then
            love.event.quit()
        elseif key == 'return' then
            gameState = 'play'
        end
        enemy:default()
    end

    if gameState == 'paused' then
        if key == 'return' then
            enemy:resume()
            gameState = 'play'
        elseif key == 'escape' then
            gameState = 'menu'
            enemy:reset()
            enemy:default()
            enemy:insert(enemyAmountX, enemyAmountY)
        end
    end

    if gameState == 'play' then
        if key == 'escape' then
            enemy:paused()
            gameState = 'paused'
        elseif key == 'space' then
            laser:insert()
            sounds['shoot']:play()
        end
    end

    if gameState == 'victory' then
        if key == 'return' then
            gameState = 'play'
            enemy:reset()
            enemy:increment()
            enemy:insert(enemyAmountX, enemyAmountY)
        elseif key == 'escape' then
            gameState = 'menu'
            enemy:reset()
            enemy:default()
            enemy:insert(enemyAmountX, enemyAmountY)
        end
    end

    if gameState == 'defeat' then
        if key == 'return' or key == 'escape' then
            gameState = 'menu'
            enemy:reset()
            enemy:insert(enemyAmountX, enemyAmountY)
        end
        lvlCounter = 1
        ENEMY_SPEED = 75
        enemyAmountY = 9
        enemyAmountX = 1
    end
end

function love.draw()
    push:apply('start')
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background)
    love.graphics.setFont(smallFont)
    if gameState == 'menu' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf('Intergalatic Attackers', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Please read the README file for controls', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ENTER to start', 0, 40, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(largeFont)
        love.graphics.printf('HIGHEST LVL: ' .. tostring(highScore), 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'paused' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf('GAME PAUSED', 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press ENTER to resume', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ESC to return to menu', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'victory' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf('LEVEL PASSED', 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press ENTER to continue', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press ESC to return to menu', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'defeat' then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 2 - 30, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press ENTER or ESC to return to menu', 0, VIRTUAL_HEIGHT / 2 - 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'play' then
        love.graphics.setColor(1, 1, 1)
        displayHighScore()
        displayLVL()
        love.graphics.rectangle('fill', 0, VIRTUAL_HEIGHT - 5, VIRTUAL_WIDTH, 5)
        player:render()
        enemy:render()

        love.graphics.setColor(1, 0, 0)
        laser:render()
    end

    displayFPS()
    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIRTUAL_WIDTH - 40, 5)
end

function displayLVL()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('LVL: ' .. tostring(lvlCounter), 5, 5)
end

function displayHighScore()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(largeFont)
    love.graphics.printf('HIGHEST LVL: ' .. tostring(highScore), 0, 5, VIRTUAL_WIDTH, 'center')
end