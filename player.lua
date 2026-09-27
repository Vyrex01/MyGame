-- ============================================================
-- player.lua — player entity (WASD + aim + health)
-- ------------------------------------------------------------
-- Handles: normalized WASD movement, mouse aim via atan2,
-- shoot cooldown, health with invulnerability frames,
-- screen clamp, and flicker draw while invuln.
-- ============================================================

local Player = {}
Player.__index = Player

function Player.new(x, y)
    return setmetatable({
        x = x or 800,
        y = y or 450,
        speed = 300,
        radius = 22,
        angle = 0,

        -- shooting
        shootCooldown = 0,
        shootRate = 0.15,

        -- health system
        maxHealth = 100,
        health = 100,
        invuln = 0,
        invulnDuration = 1.0,
        dead = false
    }, Player)
end

function Player:update(dt)
    -- AIM: face mouse cursor
    local mx, my = love.mouse.getPosition()
    self.angle = math.atan2(my - self.y, mx - self.x)

    -- MOVE: WASD + arrow keys
    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up")    then dy = dy - 1 end
    if love.keyboard.isDown("s", "down")  then dy = dy + 1 end
    if love.keyboard.isDown("a", "left")  then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end

    -- normalize diagonal so it isn't 1.41x faster
    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    -- tick down cooldowns
    if self.shootCooldown > 0 then self.shootCooldown = self.shootCooldown - dt end
    if self.invuln > 0 then self.invuln = self.invuln - dt end

    -- clamp to 1600x900 window
    self.x = math.max(self.radius, math.min(1600 - self.radius, self.x))
    self.y = math.max(self.radius, math.min(900 - self.radius, self.y))

    if self.health <= 0 then self.dead = true end
end

function Player:canShoot()
    return self.shootCooldown <= 0 and not self.dead
end

function Player:resetCooldown()
    self.shootCooldown = self.shootRate
end

-- Returns true if damage was actually applied (not invulnerable)
function Player:takeDamage(amount)
    if self.invuln > 0 or self.dead then
        return false
    end
    self.health = self.health - amount
    self.invuln = self.invulnDuration
    if self.health <= 0 then
        self.health = 0
        self.dead = true
    end
    return true
end

function Player:isAlive()
    return not self.dead
end

function Player:draw()
    -- flicker while invulnerable (skip every other frame)
    if self.invuln > 0 and math.floor(self.invuln * 10) % 2 == 0 then
        return
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    -- body
    love.graphics.setColor(0.2, 0.9, 0.4)
    love.graphics.circle("fill", 0, 0, self.radius)

    -- gun barrel
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 8, -4, self.radius + 12, 8)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

-- Called from main.lua HUD
function Player:drawHealthBar(x, y, w, h)
    local pct = self.health / self.maxHealth

    -- background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, w, h)

    -- color-coded fill
    if pct > 0.5 then
        love.graphics.setColor(0.2, 0.9, 0.4)
    elseif pct > 0.25 then
        love.graphics.setColor(1, 0.8, 0.2)
    else
        love.graphics.setColor(1, 0.2, 0.25)
    end
    love.graphics.rectangle("fill", x, y, w * pct, h)

    -- border + text
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.print(string.format("HP: %d/%d", self.health, self.maxHealth), x, y - 18)
end

return Player
