-- ============================================================
-- player.lua — player entity (WASD + aim + health + world)
-- ------------------------------------------------------------
-- Movement clamped to WORLD_W/H, not screen.
-- Aim uses world mouse coords passed from main.lua/camera.
-- Health + invuln + flicker + shoot cooldown.
-- ============================================================

local Player = {}
Player.__index = Player

function Player.new(x, y)
    return setmetatable({
        x = x or 1500,
        y = y or 1000,
        speed = 300,
        radius = 22,
        angle = 0,
        shootCooldown = 0,
        shootRate = 0.15,
        maxHealth = 100,
        health = 100,
        invuln = 0,
        invulnDuration = 1.0,
        dead = false
    }, Player)
end

function Player:update(dt, worldMouseX, worldMouseY, worldW, worldH)
    if worldMouseX and worldMouseY then
        self.angle = math.atan2(worldMouseY - self.y, worldMouseX - self.x)
    end

    local dx, dy = 0, 0
    if love.keyboard.isDown("w", "up")    then dy = dy - 1 end
    if love.keyboard.isDown("s", "down")  then dy = dy + 1 end
    if love.keyboard.isDown("a", "left")  then dx = dx - 1 end
    if love.keyboard.isDown("d", "right") then dx = dx + 1 end

    if dx ~= 0 or dy ~= 0 then
        local len = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / len, dy / len
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    if self.shootCooldown > 0 then self.shootCooldown = self.shootCooldown - dt end
    if self.invuln > 0 then self.invuln = self.invuln - dt end

    worldW = worldW or 3000
    worldH = worldH or 2000
    self.x = math.max(self.radius, math.min(worldW - self.radius, self.x))
    self.y = math.max(self.radius, math.min(worldH - self.radius, self.y))

    if self.health <= 0 then self.dead = true end
end

function Player:canShoot()
    return self.shootCooldown <= 0 and not self.dead
end

function Player:resetCooldown()
    self.shootCooldown = self.shootRate
end

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
    if self.invuln > 0 and math.floor(self.invuln * 10) % 2 == 0 then
        return
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)

    love.graphics.setColor(0.2, 0.9, 0.4)
    love.graphics.circle("fill", 0, 0, self.radius)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 8, -4, self.radius + 12, 8)

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1)
end

function Player:drawHealthBar(x, y, w, h)
    local pct = self.health / self.maxHealth

    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, w, h)

    if pct > 0.5 then
        love.graphics.setColor(0.2, 0.9, 0.4)
    elseif pct > 0.25 then
        love.graphics.setColor(1, 0.8, 0.2)
    else
        love.graphics.setColor(1, 0.2, 0.25)
    end
    love.graphics.rectangle("fill", x, y, w * pct, h)

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.print(string.format("HP: %d/%d", self.health, self.maxHealth), x, y - 18)
end

return Player
