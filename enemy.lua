-- ============================================================
-- enemy.lua — simple chase AI enemy
-- ------------------------------------------------------------
-- Red circle that walks straight toward player.
-- Uses normalized vector + speed * dt.
-- One hit from bullet kills it.
-- ============================================================

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    return setmetatable({
        x = x or 0,
        y = y or 0,
        radius = 18,
        speed = 90 + math.random() * 80, -- 90-170 px/sec, varied
        health = 1,
        dead = false,
        wobble = math.random() * math.pi * 2 -- visual pulse
    }, Enemy)
end

function Enemy:update(dt, px, py)
    -- Vector to player
    local dx = px - self.x
    local dy = py - self.y
    local dist = math.sqrt(dx * dx + dy * dy)

    -- Only move if not already on top of player
    if dist > 1 then
        dx, dy = dx / dist, dy / dist
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end

    self.wobble = self.wobble + dt * 3
end

function Enemy:takeDamage(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then
        self.dead = true
    end
end

function Enemy:draw()
    -- Body - red with slight wobble
    local r = self.radius + math.sin(self.wobble) * 1.5
    love.graphics.setColor(0.95, 0.2, 0.25)
    love.graphics.circle("fill", self.x, self.y, r)

    -- Eyes
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x - 5, self.y - 4, 3)
    love.graphics.circle("fill", self.x + 5, self.y - 4, 3)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", self.x - 5, self.y - 3, 1.2)
    love.graphics.circle("fill", self.x + 5, self.y - 3, 1.2)

    love.graphics.setColor(1, 1, 1)
end

return Enemy
