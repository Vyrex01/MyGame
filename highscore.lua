-- ============================================================
-- highscore.lua — persistent top 10 with 4-letter initials
-- ------------------------------------------------------------
-- Saves to LÖVE save dir:
-- Linux: ~/.local/share/love/My 2D Game/highscores.dat
-- Format: one per line: NAME SCORE
-- ============================================================

local Highscore = {}
Highscore.max = 10
Highscore.scores = {}
Highscore.file = "highscores.dat"
Highscore.ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 "

function Highscore:load()
    self.scores = {}
    if love.filesystem.getInfo(self.file) then
        local data = love.filesystem.read(self.file)
        for line in data:gmatch("[^\r\n]+") do
            local name, score = line:match("^(%S+)%s+(%d+)$")
            if name and score then
                table.insert(self.scores, {name = name, score = tonumber(score)})
            end
        end
        table.sort(self.scores, function(a, b) return a.score > b.score end)
    end
    if #self.scores == 0 then
        self.scores = {
            {name = "VYRX", score = 5000},
            {name = "AAA",  score = 2500},
            {name = "BLA",  score = 1800},
            {name = "ZAP",  score = 1200},
            {name = "KID",  score = 900},
        }
        self:save()
    end
end

function Highscore:save()
    local lines = {}
    for _, e in ipairs(self.scores) do
        table.insert(lines, e.name .. " " .. e.score)
    end
    love.filesystem.write(self.file, table.concat(lines, "\n"))
end

function Highscore:isHighScore(score)
    if #self.scores < self.max then return true end
    return score > self.scores[#self.scores].score
end

function Highscore:add(name, score)
    name = name:upper():gsub("%s+", ""):sub(1, 4)
    if name == "" then name = "AAAA" end
    table.insert(self.scores, {name = name, score = score})
    table.sort(self.scores, function(a, b) return a.score > b.score end)
    while #self.scores > self.max do table.remove(self.scores) end
    self:save()
end

function Highscore:getAll()
    return self.scores
end

return Highscore
