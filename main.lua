-- ============================================================
-- main.lua — game loop, spawns, health collision, game over
-- ------------------------------------------------------------
-- Handles: player, bullets, enemies, score, spawn ramp,
-- bullet-vs-enemy kills, enemy-vs-player damage,
-- health bar HUD, Game Over overlay, R to restart.
-- ============================================================

local Player = require("player")
local Bullet = require("bullet")
local Enemy  = require("enemy")

local player
local bullets, enemies
local spawnTimer, spawnInterval, score, gameOver

-- Helper: distance between two points
local function dist(ax, ay, bx, by)
    return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end

-- Helper: spawn enemy at a random screen edge
local function spawnEnemy()
    local side = math.random(1, 4)
    local x, y
    if side == 1 then          -- top
        x = math.random(0, 1600)
        y = -30
    elseif side == 2 then      -- right
        x = 1630
        y = math.random(0, 900)
    elseif side == 3 then      -- bottom
        x = math.random(0, 1600)
        y = 930
    else                       -- left
        x = -30
        y = math.random(0, 900)
    end
    table.insert(enemies, Enemy.new(x, y))
end

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)
    math.randomseed(os.time())
    player = Player.new(800, 450)
    bullets = {}
    enemies = {}
    score = 0
    spawnTimer = 0
    spawnInterval = 1.8
    gameOver = false
end

function love.update(dt)
    if gameOver then return end

    player:update(dt)

    -- spawn timer + difficulty ramp
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnEnemy()
        if spawnInterval > 0.5 then
            spawnInterval = spawnInterval - 0.02
        end
    end

    -- update bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)
        if b.dead then table.remove(bullets, i) end
    end

    -- update enemies (chase player)
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player.x, player.y)
        if e.dead then table.remove(enemies, i) end
    end

    -- bullet vs enemy collision
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        for j = #enemies, 1, -1 do
            local e = enemies[j]
            if dist(b.x, b.y, e.x, e.y) < b.radius + e.radius then
                e:takeDamage(1)
                b.dead = true
                if e.dead then
                    score = score + 100
                    table.remove(enemies, j)
                end
                break
            end
        end
    end

    -- enemy vs player collision (contact damage)
    for _, e in ipairs(enemies) do
        if dist(e.x, e.y, player.x, player.y) < e.radius + player.radius then
            if player:takeDamage(e.damage) then
                -- knockback enemy so it doesn't sit on top of player
                local dx = e.x - player.x
                local dy = e.y - player.y
                local len = math.sqrt(dx * dx + dy * dy) + 0.001
                e.x = e.x + dx / len * 40
                e.y = e.y + dy / len * 40
            end
            if player.dead then
                gameOver = true
            end
        end
    end

    -- hold left mouse to auto-shoot
    if love.mouse.isDown(1) and player:canShoot() then
        local bx = player.x + math.cos(player.angle) * (player.radius + 12)
        local by = player.y + math.sin(player.angle) * (player.radius + 12)
        table.insert(bullets, Bullet.new(bx, by, player.angle, 650))
        player:resetCooldown()
    end
end

function love.draw()
    for _, b in ipairs(bullets) do b:draw() end
    for _, e in ipairs(enemies) do e:draw() end
    player:draw()

    -- HUD
    player:drawHealthBar(15, 70, 250, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD Move | Mouse Aim | Hold Click Shoot | ESC Quit | F11 Fullscreen | R Restart", 15, 15)
    love.graphics.print(
        string.format("FPS: %d | Score: %d | Enemies: %d | Bullets: %d",
            love.timer.getFPS(), score, #enemies, #bullets),
        15, 35
    )

    -- Game over overlay
    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, 1600, 900)
        love.graphics.setColor(1, 0.2, 0.25)
        love.graphics.printf("GAME OVER", 0, 400, 1600, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            string.format("Final Score: %d — Press R to Restart", score),
            0, 440, 1600, "center"
        )
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "r" and gameOver then
        love.load()   -- full restart
    end
end
