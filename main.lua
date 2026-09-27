-- ============================================================
-- main.lua — game loop, spawning, bullets, enemies, HUD
-- ------------------------------------------------------------
-- love.load = setup, love.update(dt) = logic, love.draw = render
-- Handles: player, bullets table, enemies table, score, spawning
-- ============================================================

local Player = require("player")
local Bullet = require("bullet")
local Enemy  = require("enemy")

local player
local bullets = {}
local enemies = {}
local spawnTimer = 0
local spawnInterval = 1.8 -- seconds between spawns
local score = 0

-- Helper: distance between two points
local function dist(ax, ay, bx, by)
    return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end

-- Helper: spawn enemy at random screen edge
local function spawnEnemy()
    local side = math.random(1, 4)
    local x, y
    if side == 1 then          -- top
        x = math.random(0, 1600); y = -30
    elseif side == 2 then      -- right
        x = 1630; y = math.random(0, 900)
    elseif side == 3 then      -- bottom
        x = math.random(0, 1600); y = 930
    else                       -- left
        x = -30; y = math.random(0, 900)
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
end

function love.update(dt)
    player:update(dt)

    -- Spawning + difficulty ramp
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnEnemy()
        if spawnInterval > 0.5 then
            spawnInterval = spawnInterval - 0.02
        end
    end

    -- Update bullets
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)
        if b.dead then
            table.remove(bullets, i)
        end
    end

    -- Update enemies (chase player)
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player.x, player.y)
        if e.dead then
            table.remove(enemies, i)
        end
    end

    -- Collision: bullet vs enemy
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
                break -- bullet consumed
            end
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
    -- Bullets
    for _, b in ipairs(bullets) do b:draw() end
    -- Enemies
    for _, e in ipairs(enemies) do e:draw() end
    -- Player
    player:draw()

    -- HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD Move | Mouse Aim | Hold Click Shoot | ESC Quit | F11 Fullscreen", 15, 15)
    love.graphics.print(
        string.format("FPS: %d | Score: %d | Enemies: %d | Bullets: %d | Next spawn: %.1fs",
            love.timer.getFPS(), score, #enemies, #bullets, spawnInterval),
        15, 35
    )
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end
