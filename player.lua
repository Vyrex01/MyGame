local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.radius = 20
    self.speed = 300
    self.angle = 0
    return self
end

function Player:update(dt)
    -- WASD movement
    local dx, dy = 0, 0
    if love.keyboard.isDown("w") then dy = dy - 1 end
    if love.keyboard.isDown("s") then dy = dy + 1 end
    if love.keyboard.isDown("a") then dx = dx - 1 end
    if love.keyboard.isDown("d") then dx = dx + 1 end

    -- Normalize diagonal movement
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- Mouse aiming
    local mx, my = love.mouse.getPosition()
    self.angle = math.atan2(my - self.y, mx - self.x)
end

function Player:draw()
    -- Body
    love.graphics.setColor(0.2, 0.8, 0.3)
    love.graphics.circle("fill", self.x, self.y, self.radius)

    -- Gun barrel
    local bx = self.x + math.cos(self.angle) * self.radius
    local by = self.y + math.sin(self.angle) * self.radius
    local ex = self.x + math.cos(self.angle) * (self.radius + 25)
    local ey = self.y + math.sin(self.angle) * (self.radius + 25)

    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setLineWidth(6)
    love.graphics.line(bx, by, ex, ey)

    love.graphics.setColor(1, 1, 1)
end

return Player
