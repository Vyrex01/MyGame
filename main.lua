local Player = require("player")
local Bullet = require("bullet")
local Enemy  = require("enemy")
local Camera = require("camera")

local WORLD_W, WORLD_H   = 3000, 2000
local SCREEN_W, SCREEN_H = 1600, 900

local player, camera
local bullets, enemies
local spawnTimer, spawnInterval, score, gameOver

local function dist(ax, ay, bx, by)
    return math.sqrt((ax - bx) ^ 2 + (ay - by) ^ 2)
end

local function spawnEnemy()
    local side = math.random(1, 4)
    local x, y
    if side == 1 then x = math.random(0, WORLD_W) y = -30
    elseif side == 2 then x = WORLD_W + 30 y = math.random(0, WORLD_H)
    elseif side == 3 then x = math.random(0, WORLD_W) y = WORLD_H + 30
    else x = -30 y = math.random(0, WORLD_H) end
    table.insert(enemies, Enemy.new(x, y))
end

local function drawWorldBackground()
    love.graphics.setColor(0.25, 0.25, 0.35)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 0, 0, WORLD_W, WORLD_H)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.15, 0.15, 0.22)
    for x = 0, WORLD_W, 200 do love.graphics.line(x, 0, x, WORLD_H) end
    for y = 0, WORLD_H, 200 do love.graphics.line(0, y, WORLD_W, y) end
    love.graphics.setColor(1, 1, 1)
end

function love.load()
    love.graphics.setBackgroundColor(0.08, 0.08, 0.12)
    math.randomseed(os.time())
    player  = Player.new(WORLD_W / 2, WORLD_H / 2)
    camera  = Camera.new(WORLD_W, WORLD_H, SCREEN_W, SCREEN_H)
    bullets = {}
    enemies = {}
    score = 0
    spawnTimer = 0
    spawnInterval = 1.8
    gameOver = false
end

function love.update(dt)
    if gameOver then return end

    local mx, my = love.mouse.getPosition()
    local wx, wy = camera:screenToWorld(mx, my)

    player:update(dt, wx, wy, WORLD_W, WORLD_H)
    camera:update(dt, player.x, player.y)

    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnEnemy()
        if spawnInterval > 0.5 then spawnInterval = spawnInterval - 0.02 end
    end

    for i = #bullets, 1, -1 do
        local b = bullets[i]
        b:update(dt)
        if b.dead then table.remove(bullets, i) end
    end

    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player.x, player.y)
        if e.dead then table.remove(enemies, i) end
    end

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

    for _, e in ipairs(enemies) do
        if dist(e.x, e.y, player.x, player.y) < e.radius + player.radius then
            if player:takeDamage(e.damage) then
                local dx = e.x - player.x
                local dy = e.y - player.y
                local len = math.sqrt(dx * dx + dy * dy) + 0.001
                e.x = e.x + dx / len * 40
                e.y = e.y + dy / len * 40
            end
            if player.dead then gameOver = true end
        end
    end

    if love.mouse.isDown(1) and player:canShoot() then
        local bx = player.x + math.cos(player.angle) * (player.radius + 12)
        local by = player.y + math.sin(player.angle) * (player.radius + 12)
        table.insert(bullets, Bullet.new(bx, by, player.angle, 650))
        player:resetCooldown()
    end
end

function love.draw()
    camera:apply()
    drawWorldBackground()
    for _, b in ipairs(bullets) do b:draw() end
    for _, e in ipairs(enemies) do e:draw() end
    player:draw()
    camera:reset()

    player:drawHealthBar(15, 70, 250, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("WASD Move | Mouse Aim | Hold Click Shoot | ESC Quit | F11 Fullscreen | R Restart", 15, 15)
    love.graphics.print(
        string.format("FPS:%d Score:%d Enemies:%d Cam:(%d,%d)",
            love.timer.getFPS(), score, #enemies,
            math.floor(camera.x), math.floor(camera.y)),
        15, 35
    )

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
        love.graphics.setColor(1, 0.2, 0.25)
        love.graphics.printf("GAME OVER", 0, 400, SCREEN_W, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            string.format("Final Score: %d — Press R to Restart", score),
            0, 440, SCREEN_W, "center"
        )
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit()
    elseif key == "f11" then love.window.setFullscreen(not love.window.getFullscreen())
    elseif key == "r" and gameOver then love.load() end
end
