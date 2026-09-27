local Player = require("player")

local player
local font

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

    -- Bigger font for HUD
    font = love.graphics.newFont(24)
    love.graphics.setFont(font)

    local w, h = love.graphics.getDimensions()
    player = Player.new(w / 2, h / 2)
end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    player:draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD to move, mouse to aim", 20, 20)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 20, 55)
    love.graphics.print("F11 = fullscreen | ESC = quit", 20, 90)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        love.window.setFullscreen(
            not love.window.getFullscreen(),
            "desktop"
        )
    end
end
