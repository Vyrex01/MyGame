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
11. Changelog

---

## 1. Project Overview

This is a **2D top-down game** built from scratch with LÖVE2D.

- Player is drawn as a green circle with a white gun barrel
- Movement: **WASD** (arrow keys also work)
- Aiming: **mouse position** — the barrel always faces the cursor
- Shooting: **hold left mouse button** (auto-fire with cooldown)
- Diagonal movement is normalized so it isn't faster than straight

Code is heavily commented so multiple AI assistants (and the human)
can work on it without confusion.

---

## 2. System Requirements

- OS: Linux Mint (tested on Yoga 6-13ALC7)
- LÖVE2D: 11.x (install: sudo apt install love)
- Lua: bundled with LÖVE2D
- Git: installed by default on Mint

---

## 3. Project Structure

    ~/Downloads/mygame/
    ├── conf.lua      # Window + engine configuration
    ├── main.lua      # Entry point — game loop, HUD, input, bullet manager
    ├── player.lua    # Player entity (WASD, mouse aim, shoot cooldown)
    ├── bullet.lua    # Bullet entity (position, velocity, lifetime)
    └── README.md     # This file

---

## 4. File-by-File Breakdown

### conf.lua

Runs BEFORE main.lua. Sets:

- Window title: "My 2D Game"
- Size: 1600x900
- Resizable: yes
- vsync: on
- highdpi: on

### player.lua

Metatable-based OOP.

- Player.new(x, y) — constructor
- Player:update(dt) — aim at mouse, WASD movement, cooldown tick, clamp to screen
- Player:canShoot() — returns true if cooldown has elapsed
- Player:resetCooldown() — restarts cooldown after firing
- Player:draw() — green circle + white rectangular barrel (rotated via translate + rotate)

Key concepts:

- Delta time (dt): movement = speed * dt, frame-rate independent
- Normalization: prevents diagonal being 1.41x faster
- math.atan2(dy, dx): converts vector to angle
- love.graphics.push()/pop(): isolated transform stack for rotated drawing

### bullet.lua

Simple projectile entity.

- Bullet.new(x, y, angle, speed) — constructor
- Bullet:update(dt) — moves along angle, ticks lifetime
- Bullet:draw() — yellow filled circle

Key concepts:

- Position update: x += cos(angle) * speed * dt
- Lifetime: bullet.dead = true after ~2.5 seconds
- Dead bullets are removed from main.lua's bullets table

### main.lua

LÖVE2D calls these automatically:

- love.load() — one-time setup (background color, player spawn, bullets table)
- love.update(dt) — per-frame logic (player update, bullets update, hold-to-fire)
- love.draw() — per-frame rendering (bullets, player, HUD text)
- love.keypressed(key) — ESC quits, F11 toggles fullscreen

HUD displays:

- Controls hint line
- FPS + live bullet count
- Player angle + X/Y position (debug)

---

## 5. How to Run

    cd ~/Downloads/mygame
    love .

A 1600x900 window opens.

---

## 6. Controls

| Key             | Action            |
|-----------------|-------------------|
| W               | Move up           |
| A               | Move left         |
| S               | Move down         |
| D               | Move right        |
| Arrow keys      | Also move (bonus) |
| Mouse move      | Aim gun           |
| Hold Left Click | Shoot (auto-fire) |
| F11             | Toggle fullscreen |
| ESC             | Quit              |

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
Use a Personal Access Token (classic) with repo scope.

- Generate: https://github.com/settings/tokens
- Use as PASSWORD when Git prompts
- Username = GitHub username (Vyrex01), NOT email, NOT Google

### Push

    git push -u origin main

### Remember credentials

    git config --global credential.helper store

---

## 8. Common Errors & Fixes

| Error                                 | Fix                                        |
|---------------------------------------|--------------------------------------------|
| fatal: not a git repository           | Run git init in project folder             |
| remote origin already exists          | Skip git remote add, or use set-url        |
| Invalid username or token             | Username = Vyrex01, not email              |
| Password authentication not supported | Use the token, not account password        |
| Updates were rejected                 | git pull origin main --rebase, then push   |
| src refspec main does not match any   | git branch -M main, then push              |
| Logged in via Google                  | Irrelevant for git — use username + token  |

---

## 9. AI Collaboration Rules

### File format

Every .lua file must:

- Start with a header block
- Use section separators like:

    -- ============================================================
    -- filename.lua — purpose
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

5. AI also updates README.md — roadmap, changelog, file list

### Secrets

- Never paste Personal Access Tokens, passwords, or SSH keys in chat
- If leaked: revoke immediately at https://github.com/settings/tokens

### New-chat handoff

Start a new chat with:

    "My project is at https://github.com/Vyrex01/MyGame.
     Current files: [paste main.lua, player.lua, bullet.lua, conf.lua].
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
- [x] Shooting with left-click (bullet entity, cooldown, hold-to-fire)
- [x] Player clamped to screen bounds

Upcoming:

- [ ] Enemies with simple chase AI           <-- NEXT
- [ ] Collision (circle-circle, then bump.lua)
- [ ] Camera / world scrolling
- [ ] Sprites instead of circles
- [ ] Game states (menu, playing, paused, game-over)
- [ ] Sound effects
- [ ] Score / health system
- [ ] Levels / wave spawning

---

## 11. Changelog

### v0.3 — Shooting

- Added bullet.lua (projectile entity with lifetime)
- player.lua: added shootCooldown, canShoot(), resetCooldown()
- player.lua: clamped x/y to window bounds
- player.lua: barrel drawn via translate + rotate
- player.lua: arrow keys now also move the player
- main.lua: bullets table, hold-to-fire with cooldown
- main.lua: HUD shows bullet count, angle, and position

### v0.2 — README + Comments

- Full section-comment style across all .lua files
- README documenting workflow and AI collaboration rules
- GitHub repo set up and pushed

### v0.1 — Base

- conf.lua: 1600x900 window, vsync, highdpi
- player.lua: WASD movement + mouse aim
- main.lua: game loop, HUD, F11/ESC

---

## License

Personal project — no license yet
