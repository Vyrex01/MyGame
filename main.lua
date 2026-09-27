-- ============================================================
-- main.lua — entry point, game loop, HUD, input
-- ------------------------------------------------------------
-- LÖVE2D calls love.load, love.update(dt), love.draw automatically.
-- Manages player + bullets table. Left click = shoot.
-- ============================================================

local Player = require("player")
local Bullet = require("bullet")

local player
local bullets = {}

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)
    player = Player.new(800, 450) -- center of 1600x900
    bullets = {}
end

function love.update(dt)
    player:update(dt)

    -- Update all bullets backwards for safe removal
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)
        if b.dead then
            table.remove(bullets, i)
        end
    end

    -- Hold left mouse to auto-shoot
    if love.mouse.isDown(1) and player:canShoot() then
        local bx = player.x + math.cos(player.angle) * (player.radius + 12)
        local by = player.y + math.sin(player.angle) * (player.radius + 12)
        table.insert(bullets, Bullet.new(bx, by, player.angle, 650))
        player:resetCooldown()
    end
end

function love.draw()
    -- Draw bullets
    for _, b in ipairs(bullets) do
        b:draw()
    end

    -- Draw player on top
    player:draw()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD = Move | Mouse = Aim | Hold Left Click = Shoot | ESC = Quit | F11 = Fullscreen", 15, 15)
    love.graphics.print("FPS: " .. love.timer.getFPS() .. " | Bullets: " .. #bullets, 15, 35)
    love.graphics.print(string.format("Angle: %.2f | Pos: %.0f, %.0f", player.angle, player.x, player.y), 15, 55)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        local fs = love.window.getFullscreen()
        love.window.setFullscreen(not fs)
    end
end
