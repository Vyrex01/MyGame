local Camera = {}
Camera.__index = Camera

function Camera.new(worldW, worldH, screenW, screenH)
    return setmetatable({
        worldW = worldW, worldH = worldH,
        screenW = screenW, screenH = screenH,
        x = 0, y = 0,
        smooth = 5.0
    }, Camera)
end

function Camera:update(dt, targetX, targetY)
    local desiredX = targetX - self.screenW / 2
    local desiredY = targetY - self.screenH / 2
    self.x = self.x + (desiredX - self.x) * self.smooth * dt
    self.y = self.y + (desiredY - self.y) * self.smooth * dt
    self.x = math.max(0, math.min(self.worldW - self.screenW, self.x))
    self.y = math.max(0, math.min(self.worldH - self.screenH, self.y))
end

function Camera:apply()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function Camera:reset()
    love.graphics.pop()
end

function Camera:screenToWorld(sx, sy)
    return sx + self.x, sy + self.y
end

return Camera
