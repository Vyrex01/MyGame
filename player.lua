-- ============================================================
-- player.lua — player entity (WASD + mouse aim + shoot)
-- ------------------------------------------------------------
-- Handles movement, mouse aiming, drawing.
-- Movement uses WASD with normalization for diagonal.
-- Aiming uses math.atan2(mouse - player)
-- ============================================================

local Player = {}
Player.__index = Player

function Player.new(x, y)
    return setmetatable({
        x = x or 800,          -- center for 1600x900
        y = y or 450,
        speed = 300,           -- pixels per second
        radius = 22,
        angle = 0,             -- facing angle in radians
        shootCooldown = 0,     -- time until next shot allowed
        shootRate = 0.15       -- seconds between shots
    }, Player)
end

function Player:update(dt)
    -- 1. AIM — always face mouse cursor
    local mx, my = love.mouse.getPosition()
    self.angle = math.atan2(my - self.y, mx - self.x)

    -- 2. MOVE — WASD input
    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up") then dy = dy - 1 end
    if love.keyboard.isDown("s", "down") then dy = dy + 1 end
    if love.keyboard.isDown("a", "left") then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end

    -- Normalize diagonal so sqrt(1+1) != 1.41x speed
    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
        -- dt = frame-rate independence
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    -- Cooldown tick
    if self.shootCooldown > 0 then
        self.shootCooldown = self.shootCooldown - dt
    end

    -- Keep inside screen (for now, before camera)
    self.x = math.max(self.radius, math.min(1600 - self.radius, self.x))
    self.y = math.max(self.radius, math.min(900 - self.radius, self.y))
end

function Player:canShoot()
    return self.shootCooldown <= 0
end

function Player:resetCooldown()
    self.shootCooldown = self.shootRate
end

function Player:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- Body - green circle
    love.graphics.setColor(0.2, 0.9, 0.4)
    love.graphics.circle("fill", 0, 0, self.radius)

    -- Gun barrel - white, points to mouse
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 8, -4, self.radius + 12, 8)

    love.graphics.pop()

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Player
