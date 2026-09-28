local Bullet = {}
Bullet.__index = Bullet

function Bullet.new(x, y, angle, speed)
    return setmetatable({
        x = x, y = y,
        angle = angle or 0,
        speed = speed or 600,
        radius = 5,
        life = 2.5,
        dead = false
    }, Bullet)
end

function Bullet:update(dt)
    self.x = self.x + math.cos(self.angle) * self.speed * dt
    self.y = self.y + math.sin(self.angle) * self.speed * dt
    self.life = self.life - dt
    if self.life <= 0 then self.dead = true end
end

function Bullet:draw()
    love.graphics.setColor(1, 0.9, 0.2)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1)
end

return Bullet
