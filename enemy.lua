local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    return setmetatable({
        x = x or 0, y = y or 0,
        radius = 18,
        speed = 90 + math.random() * 80,
        health = 1,
        damage = 20,
        dead = false,
        wobble = math.random() * math.pi * 2
    }, Enemy)
end

function Enemy:update(dt, px, py)
    local dx, dy = px - self.x, py - self.y
    local d = math.sqrt(dx * dx + dy * dy)
    if d > 1 then
        dx, dy = dx / d, dy / d
        self.x = self.x + dx * self.speed * dt
        self.y = self.y + dy * self.speed * dt
    end
    self.wobble = self.wobble + dt * 3
end

function Enemy:takeDamage(dmg)
    self.health = self.health - dmg
    if self.health <= 0 then self.dead = true end
end

function Enemy:draw()
    local r = self.radius + math.sin(self.wobble) * 1.5
    love.graphics.setColor(0.95, 0.2, 0.25)
    love.graphics.circle("fill", self.x, self.y, r)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", self.x - 5, self.y - 4, 3)
    love.graphics.circle("fill", self.x + 5, self.y - 4, 3)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", self.x - 5, self.y - 3, 1.2)
    love.graphics.circle("fill", self.x + 5, self.y - 3, 1.2)
    love.graphics.setColor(1, 1, 1)
end

return Enemy
