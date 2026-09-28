-- ============================================================
-- main.lua — entry point + state routing + high score entry
-- ------------------------------------------------------------
-- WORLD 3000x2000, camera follow, score, 4-letter arcade initials
-- States: menu / playing / paused / gameover / enter_name / highscores
-- ============================================================

local State, Camera, Player, Bullet, Enemy, Highscore

-- world
local WORLD_W, WORLD_H   = 3000, 2000
local SCREEN_W, SCREEN_H = 1600, 900

-- game objects
local player, camera
local bullets, enemies
local score, spawnTimer, spawnInterval

-- name entry (4 letters arcade style)
local ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "
local nameCharsIdx
local nameCursor
local nameBlink

local fontSmall, fontMedium, fontBig

-- ------------------------------------------------------------
local function getCurrentName()
    local s = ""
    for i = 1, 4 do
        local idx = nameCharsIdx[i] or 1
        s = s .. ALPHABET:sub(idx, idx)
    end
    return s
end

local function initNameEntry()
    nameCharsIdx = {1, 1, 1, 1} -- AAAA
    nameCursor = 1
    nameBlink = 0
end

local function startNewGame()
    player = Player.new(WORLD_W / 2, WORLD_H / 2)
    camera = Camera.new(WORLD_W, WORLD_H, SCREEN_W, SCREEN_H)
    bullets = {}
    enemies = {}
    score = 0
    spawnTimer = 0
    spawnInterval = 1.8
end

local function spawnEnemy()
    local side = love.math.random(4)
    local x, y
    if side == 1 then
        x = 0
        y = love.math.random(0, WORLD_H)
    elseif side == 2 then
        x = WORLD_W
        y = love.math.random(0, WORLD_H)
    elseif side == 3 then
        x = love.math.random(0, WORLD_W)
        y = 0
    else
        x = love.math.random(0, WORLD_W)
        y = WORLD_H
    end
    table.insert(enemies, Enemy.new(x, y))
    spawnInterval = math.max(0.5, spawnInterval - 0.02)
end

-- ------------------------------------------------------------
function love.load()
    State     = require("state")
    Camera    = require("camera")
    Player    = require("player")
    Bullet    = require("bullet")
    Enemy     = require("enemy")
    Highscore = require("highscore")

    love.graphics.setDefaultFilter("nearest", "nearest")
    fontSmall  = love.graphics.newFont(18)
    fontMedium = love.graphics.newFont(28)
    fontBig    = love.graphics.newFont(48)

    Highscore:load()
    startNewGame()
    State.set("menu")
    initNameEntry()
end

-- ------------------------------------------------------------
function love.update(dt)
    if State.is("enter_name") then
        nameBlink = nameBlink + dt
        return
    end
    if State.is("menu") or State.is("paused")
       or State.is("gameover") or State.is("highscores") then
        return
    end

    -- playing
    local mx, my = love.mouse.getPosition()
    local wx, wy = camera:screenToWorld(mx, my)

    player:update(dt, wx, wy, WORLD_W, WORLD_H)
    camera:update(dt, player.x, player.y)

    -- shooting
    if love.mouse.isDown(1) and player:canShoot() then
        local ang = player.angle
        local bx = player.x + math.cos(ang) * 30
        local by = player.y + math.sin(ang) * 30
        table.insert(bullets, Bullet.new(bx, by, ang, 700))
        player:resetCooldown()
    end

    for i = #bullets, 1, -1 do
        bullets[i]:update(dt)
        if bullets[i].dead then table.remove(bullets, i) end
    end

    -- spawning
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnEnemy()
    end

    for i = #enemies, 1, -1 do
        enemies[i]:update(dt, player.x, player.y)
    end

    -- bullet vs enemy
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        for j = #enemies, 1, -1 do
            local e = enemies[j]
            local dx, dy = b.x - e.x, b.y - e.y
            if dx * dx + dy * dy < (12 + 18) * (12 + 18) then
                e:takeDamage(1)
                table.remove(bullets, i)
                if e.dead then
                    table.remove(enemies, j)
                    score = score + 100
                end
                break
            end
        end
    end

    -- enemy vs player
    for j = #enemies, 1, -1 do
        local e = enemies[j]
        local dx, dy = player.x - e.x, player.y - e.y
        if dx * dx + dy * dy < (22 + 18) * (22 + 18) then
            if player:takeDamage(e.damage or 20) then
                local len = math.sqrt(dx * dx + dy * dy) + 0.01
                e.x = e.x - (dx / len) * 40
                e.y = e.y - (dy / len) * 40
                if not player:isAlive() then
                    if Highscore:isHighScore(score) then
                        initNameEntry()
                        State.set("enter_name")
                    else
                        State.set("gameover")
                    end
                    break
                end
            end
        end
    end
end

-- ------------------------------------------------------------
local function drawGrid()
    love.graphics.setColor(0.15, 0.18, 0.22)
    for x = 0, WORLD_W, 200 do
        love.graphics.line(x, 0, x, WORLD_H)
    end
    for y = 0, WORLD_H, 200 do
        love.graphics.line(0, y, WORLD_W, y)
    end
    love.graphics.setColor(0.25, 0.3, 0.4)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 0, 0, WORLD_W, WORLD_H)
    love.graphics.setLineWidth(1)
end

local function drawPlayingWorld()
    camera:apply()
    drawGrid()
    for _, e in ipairs(enemies) do e:draw() end
    for _, b in ipairs(bullets) do b:draw() end
    player:draw()
    camera:reset()
end

local function drawHUD()
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        "FPS:" .. love.timer.getFPS() ..
        "  Score:" .. score ..
        "  Enemies:" .. #enemies ..
        "  Cam:(" .. math.floor(camera.x) .. "," .. math.floor(camera.y) .. ")",
        10, 10
    )
    player:drawHealthBar(10, 35, 250, 20)
end

local function drawMenu()
    love.graphics.clear(0.06, 0.07, 0.09)
    love.graphics.setFont(fontBig)
    love.graphics.setColor(0.2, 1, 0.4)
    love.graphics.printf("MYGAME", 0, 260, SCREEN_W, "center")
    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("LÖVE2D Top-Down Shooter", 0, 340, SCREEN_W, "center")
    love.graphics.setFont(fontSmall)
    love.graphics.printf("Press ENTER to Start  |  H for High Scores  |  ESC to Quit", 0, 420, SCREEN_W, "center")
    love.graphics.printf("WASD Move   Mouse Aim   Hold Click Shoot   P Pause", 0, 470, SCREEN_W, "center")
end

local function drawPaused()
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 1, 0.2)
    love.graphics.printf("PAUSED", 0, SCREEN_H / 2 - 40, SCREEN_W, "center")
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("P Resume   M Menu", 0, SCREEN_H / 2 + 30, SCREEN_W, "center")
end

local function drawGameOver()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("GAME OVER", 0, SCREEN_H / 2 - 80, SCREEN_W, "center")
    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Score: " .. score, 0, SCREEN_H / 2 - 10, SCREEN_W, "center")
    love.graphics.setFont(fontSmall)
    love.graphics.printf("R Restart   M Menu   H High Scores", 0, SCREEN_H / 2 + 40, SCREEN_W, "center")
end

local function drawEnterName()
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.9, 0.2)
    love.graphics.printf("NEW HIGH SCORE!", 0, 180, SCREEN_W, "center")
    love.graphics.setFont(fontMedium)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("SCORE " .. score, 0, 250, SCREEN_W, "center")
    love.graphics.printf("ENTER YOUR INITIALS", 0, 300, SCREEN_W, "center")

    local boxW, boxH, gap = 90, 90, 18
    local totalW = 4 * boxW + 3 * gap
    local startX = (SCREEN_W - totalW) / 2
    local y = 360
    for i = 1, 4 do
        local x = startX + (i - 1) * (boxW + gap)
        local isCur = (i == nameCursor)
        if isCur and math.floor(nameBlink * 2) % 2 == 0 then
            love.graphics.setColor(1, 1, 0.2)
        else
            love.graphics.setColor(0.2, 0.3, 0.6)
        end
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x, y, boxW, boxH, 10)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fontBig)
        local ch = ALPHABET:sub(nameCharsIdx[i], nameCharsIdx[i])
        love.graphics.printf(ch, x, y + 12, boxW, "center")
        if isCur then
            love.graphics.setColor(1, 1, 0.2, 0.6)
            love.graphics.rectangle("fill", x, y + boxH + 8, boxW, 6)
        end
    end
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("ARROWS: Change Letter / Move   ENTER: Submit", 0, 490, SCREEN_W, "center")
    love.graphics.printf("Name: " .. getCurrentName(), 0, 520, SCREEN_W, "center")
end

local function drawHighScores()
    love.graphics.clear(0.06, 0.07, 0.09)
    love.graphics.setFont(fontBig)
    love.graphics.setColor(1, 0.4, 0.8)
    love.graphics.printf("HIGH SCORES", 0, 100, SCREEN_W, "center")
    love.graphics.setFont(fontMedium)
    local scores = Highscore:getAll()
    for i, e in ipairs(scores) do
        local y = 180 + (i - 1) * 38
        if i == 1 then
            love.graphics.setColor(1, 1, 0.2)
        else
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(string.format("%2d.  %4s   %5d", i, e.name, e.score), 0, y, SCREEN_W, "center")
    end
    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("M / ENTER = Menu    R = Play Again", 0, SCREEN_H - 60, SCREEN_W, "center")
end

-- ------------------------------------------------------------
function love.draw()
    if State.is("menu") then drawMenu(); return end
    if State.is("highscores") then drawHighScores(); return end

    drawPlayingWorld()
    drawHUD()

    if State.is("paused") then
        drawPaused()
    elseif State.is("gameover") then
        drawGameOver()
    elseif State.is("enter_name") then
        drawEnterName()
    end
end

-- ------------------------------------------------------------
function love.keypressed(key)
    if key == "escape" then love.event.quit(); return end
    if key == "f11" then
        local fs = love.window.getFullscreen()
        love.window.setFullscreen(not fs)
        return
    end

    if State.is("menu") then
        if key == "return" or key == "kpenter" then
            startNewGame()
            State.set("playing")
        elseif key == "h" then
            State.set("highscores")
        end

    elseif State.is("playing") then
        if key == "p" then State.set("paused") end

    elseif State.is("paused") then
        if key == "p" then State.set("playing")
        elseif key == "m" then State.set("menu") end

    elseif State.is("gameover") then
        if key == "r" then
            startNewGame()
            State.set("playing")
        elseif key == "m" then
            State.set("menu")
        elseif key == "h" then
            State.set("highscores")
        end

    elseif State.is("enter_name") then
        if key == "left" then
            nameCursor = math.max(1, nameCursor - 1)
        elseif key == "right" then
            nameCursor = math.min(4, nameCursor + 1)
        elseif key == "up" then
            nameCharsIdx[nameCursor] = nameCharsIdx[nameCursor] % #ALPHABET + 1
        elseif key == "down" then
            nameCharsIdx[nameCursor] = (nameCharsIdx[nameCursor] - 2) % #ALPHABET + 1
        elseif key == "return" or key == "kpenter" then
            local finalName = getCurrentName():gsub("%s+", "")
            if finalName == "" then finalName = "AAAA" end
            Highscore:add(finalName, score)
            State.set("highscores")
        elseif key == "backspace" then
            nameCharsIdx[nameCursor] = 27 -- space
        end

    elseif State.is("highscores") then
        if key == "m" or key == "return" or key == "kpenter" or key == "r" then
            if key == "r" then
                startNewGame()
                State.set("playing")
            else
                State.set("menu")
            end
        end
    end
end

function love.textinput(t)
    if State.is("enter_name") then
        local up = t:upper()
        local pos = ALPHABET:find(up, 1, true)
        if pos then
            nameCharsIdx[nameCursor] = pos
            if nameCursor < 4 then nameCursor = nameCursor + 1 end
        end
    end
end
