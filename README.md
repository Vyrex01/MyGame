# MyGame — LÖVE2D Top-Down Shooter

A 2D top-down game built with **LÖVE2D** and **Lua** on Linux Mint.
Player moves with **WASD** and aims with the **mouse**.

**Repository:** https://github.com/Vyrex01/MyGame
**Owner:** Vyrex01
**Platform:** LÖVE2D 11.x (Linux Mint)
**Workflow:** Built collaboratively with AI assistants (Claude / Meta AI / DeepSeek)

---

## Table of Contents

1. Project Overview
2. System Requirements
3. Project Structure
4. File-by-File Breakdown
5. How to Run
6. Controls
7. Git & GitHub Setup
8. Common Errors & Fixes
9. AI Collaboration Rules
10. Roadmap

---

## 1. Project Overview

This is a **2D top-down game** built from scratch with LÖVE2D.

- Player is drawn as a green circle with a white "gun barrel"
- Movement: **WASD**
- Aiming: **mouse position** — the barrel always faces the cursor
- Diagonal movement is normalized so it isn't faster than straight

Code is heavily commented so multiple AI assistants (and the human)
can work on it without confusion.


---

## 2. System Requirements

- OS: Linux Mint (tested on Yoga 6-13ALC7)
- LÖVE2D: 11.x  (install: sudo apt install love)
- Lua: bundled with LÖVE2D
- Git: installed by default on Mint

---

## 3. Project Structure

    ~/Downloads/mygame/
    ├── conf.lua      # Window + engine configuration
    ├── main.lua      # Entry point — game loop, HUD, key handlers
    ├── player.lua    # Player entity (movement + mouse aiming)
    └── README.md     # This file

---

## 4. File-by-File Breakdown

### conf.lua
Runs BEFORE main.lua. Sets window title, size (1600x900), resizable, vsync, highdpi.

### player.lua
Metatable-based OOP.

- Player.new(x, y)  -> constructor
- Player:update(dt) -> WASD input, normalize diagonal, move, aim at mouse
- Player:draw()     -> green circle + white gun barrel

Key concepts:
- Delta time (dt): movement = speed * dt, frame-rate independent
- Normalization: prevents diagonal being 1.41x faster
- math.atan2(dy, dx): converts vector to angle

### main.lua
LÖVE2D calls these automatically:

- love.load()       -> one-time setup
- love.update(dt)   -> per-frame logic
- love.draw()       -> per-frame rendering
- love.keypressed() -> ESC quits, F11 toggles fullscreen

---

## 5. How to Run

    cd ~/Downloads/mygame
    love .

A 1600x900 window opens.

---

## 6. Controls

| Key         | Action            |
|-------------|-------------------|
| W           | Move up           |
| A           | Move left         |
| S           | Move down         |
| D           | Move right        |
| Mouse move  | Aim gun           |
| F11         | Toggle fullscreen |
| ESC         | Quit              |

---

## 7. Git & GitHub Setup

Repo: https://github.com/Vyrex01/MyGame

### Init

    cd ~/Downloads/mygame
    git init
    git branch -M main
    git add .
    git commit -m "Initial commit: LOVE2D WASD movement + mouse aim"
    git remote add origin https://github.com/Vyrex01/MyGame.git

### Auth — Personal Access Token

GitHub no longer accepts account passwords over HTTPS.
Use a Personal Access Token (classic) with 'repo' scope.

- Generate: https://github.com/settings/tokens
- Use as PASSWORD when Git prompts
- Username = GitHub username (Vyrex01), NOT email, NOT Google

### Push

    git push -u origin main

### Remember credentials

    git config --global credential.helper store

---

## 8. Common Errors & Fixes

| Error                                 | Fix                                      |
|---------------------------------------|------------------------------------------|
| fatal: not a git repository           | Run git init in project folder           |
| remote origin already exists          | Skip git remote add, or use set-url      |
| Invalid username or token             | Username = Vyrex01, not email            |
| Password authentication not supported | Use the token, not account password      |
| Updates were rejected                 | git pull origin main --rebase, then push |
| src refspec main does not match any   | git branch -M main, then push            |
| Logged in via Google                  | Irrelevant for git — use username + token|

---

## 9. AI Collaboration Rules

### File format

Every .lua file must:
- Start with a header block
- Use section separators like:
      -- ============================================================
      -- filename.lua  —  purpose
      -- ------------------------------------------------------------
      -- Description
      -- ============================================================
- Have inline comments on non-trivial lines

### Deliverable format

AI outputs FULL files as:

    cat > filename.lua << 'EOF'
    ...file contents...
    EOF

Never "just replace lines X-Y". Always the full file.

### Change flow

1. User describes feature
2. AI outputs full files via cat << 'EOF'
3. User pastes into terminal
4. User commits and pushes:
       git add .
       git commit -m "short description"
       git push

### Secrets

- Never paste Personal Access Tokens, passwords, or SSH keys in chat
- If leaked: revoke immediately at https://github.com/settings/tokens

### New-chat handoff

Start a new chat with:

    "My project is at https://github.com/Vyrex01/MyGame.
     Current files: [paste main.lua, player.lua, conf.lua].
     Please help with XXX."

---

## 10. Roadmap

Done:
- [x] LÖVE2D window configuration
- [x] Player entity with OOP structure
- [x] WASD movement with diagonal normalization
- [x] Mouse aiming
- [x] HUD (FPS, controls hint)
- [x] F11 fullscreen toggle
- [x] Full code comments
- [x] GitHub repo + first push

Upcoming:
- [ ] Shooting with left-click (next)
- [ ] Camera / world scrolling
- [ ] Enemies with simple chase AI
- [ ] Collision (circle-circle, then bump.lua)
- [ ] Sprites instead of circles
- [ ] Game states (menu, playing, paused, game-over)
- [ ] Sound effects
- [ ] Score / health system
- [ ] Levels / wave spawning
