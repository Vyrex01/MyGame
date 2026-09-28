-- ============================================================
-- state.lua — game state machine
-- ------------------------------------------------------------
-- Valid: menu / playing / paused / gameover / enter_name / highscores
-- ============================================================

local State = {
    current = "menu",
    valid = {
        menu       = true,
        playing    = true,
        paused     = true,
        gameover   = true,
        enter_name = true,
        highscores = true
    }
}

function State.set(name)
    if State.valid[name] then
        State.current = name
    else
        error("Invalid state: " .. tostring(name))
    end
end

function State.is(name)
    return State.current == name
end

return State
