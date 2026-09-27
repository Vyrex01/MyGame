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
7. Gameplay Loop
8. Git & GitHub Setup
9. Common Errors & Fixes
10. AI Collaboration Rules
11. Roadmap
12. Changelog

---

## 1. Project Overview

This is a **2D top-down game** built from scratch with LÖVE2D.

- Player is drawn as a green circle with a white gun barrel
- Movement: **WASD** (arrow keys also work)
- Aiming: **mouse position** — the barrel always faces the cursor
- Shooting: **hold left mouse button** (auto-fire with cooldown)
- Enemies: **red circles** spawn from screen edges and chase the player
- Killing enemies with bullets awards **+100 score**
- Player has **100 HP**, loses 20 HP per enemy contact, 1s invulnerability after each hit
- Health bar turns green → yellow → red as HP drops
- **Game Over** overlay when HP reaches 0, press **R** to restart
- Spawn rate ramps up over time (difficulty scaling)
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
    ├── main.lua      # Entry point — game loop, HUD, input, spawns, collisions
    ├── player.lua    # Player entity (WASD, mouse aim, shoot cooldown, health)
    ├── bullet.lua    # Bullet entity (position, velocity, lifetime)
    ├── enemy.lua     # Enemy entity (chase AI, contact damage)
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
- Player:update(dt) — aim at mouse, WASD movement, cooldown + invuln tick, clamp to screen
- Player:canShoot() — returns true if cooldown elapsed and alive
- Player:resetCooldown() — restarts shoot cooldown
- Player:takeDamage(amount) — applies damage only if not invulnerable; returns true if it landed
- Player:isAlive() — returns not dead
- Player:draw() — green circle + white barrel; flickers while invuln
- Player:drawHealthBar(x, y, w, h) — HUD helper, color-coded fill

Key concepts:

- Delta time (dt): movement = speed * dt, frame-rate independent
- Normalization: prevents diagonal being 1.41x faster
- math.atan2(dy, dx): converts vector to angle
- love.graphics.push()/pop(): isolated transform stack for rotated drawing
- Invulnerability frames: prevents damage every frame while touching an enemy
- Flicker: skip drawing every other 0.1s while invuln > 0

### bullet.lua

Simple projectile entity.

- Bullet.new(x, y, angle, speed) — constructor
- Bullet:update(dt) — moves along angle, ticks lifetime
- Bullet:draw() — yellow filled circle

Key concepts:

- Position update: x += cos(angle) * speed * dt
- Lifetime: bullet.dead = true after ~2.5 seconds
- Dead bullets are removed from main.lua's bullets table

### enemy.lua

Simple chase-AI enemy with contact damage.

- Enemy.new(x, y) — constructor
- Enemy:update(dt, px, py) — moves toward player (px, py)
- Enemy:takeDamage(dmg) — reduces health, sets dead = true at 0
- Enemy:draw() — red circle with white eyes

Key concepts:

- Vector normalization: prevents speed changes at different distances
- Random speed (90-170 px/s) so enemies don't move in lockstep
- 1 HP: one bullet kill
- damage = 20: how much HP the player loses on contact

### main.lua

LÖVE2D calls these automatically:

- love.load() — one-time setup (background, player spawn, empty tables, random seed)
- love.update(dt) — per-frame logic (player, spawning, bullets, enemies, collisions, shooting)
- love.draw() — per-frame rendering (bullets, enemies, player, HUD, Game Over overlay)
- love.keypressed(key) — ESC quits, F11 toggles fullscreen, R restarts when dead

Handles:

- Spawn timer + difficulty ramp (spawnInterval decreases 0.02s per spawn, floor 0.5s)
- Bullet-vs-enemy circle collision (+100 score per kill)
- Enemy-vs-player circle collision (20 damage + 40px knockback to enemy)
- Game Over state when player dies
- HUD: FPS, score, enemy count, bullet count, health bar

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
| R               | Restart (when dead) |
| ESC             | Quit              |

---

## 7. Gameplay Loop

1. Player spawns at screen center (800, 450) with 100 HP
2. Enemies spawn from random screen edges every ~1.8s
3. Enemies walk straight toward the player at random speeds (90-170 px/s)
4. Player holds left-click to fire bullets toward the cursor
5. Bullet hits enemy → enemy dies → +100 score
6. Enemy touches player → player loses 20 HP, 1s invulnerability + flicker, enemy knocked back 40px
7. Health bar turns yellow at 50%, red at 25%
8. Spawn interval shrinks by 0.02s per spawn (floor 0.5s)
9. At 0 HP: Game Over overlay; press R to restart

---

## 8. Git & GitHub Setup

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

### Standard Workflow (avoids push rejections)

    git add .
    git commit -m "short description"
    git pull origin main --no-rebase
    git push

The pull-before-push pattern prevents "Updates were rejected"
errors when the remote has new commits.

### Remember credentials

    git config --global credential.helper store

---

## 9. Common Errors & Fixes

| Error                                 | Fix                                        |
|---------------------------------------|--------------------------------------------|
| fatal: not a git repository           | Run git init in project folder             |
| remote origin already exists          | Skip git remote add, or use set-url        |
| Invalid username or token             | Username = Vyrex01, not email              |
| Password authentication not supported | Use the token, not account password        |
| Updates were rejected                 | git pull origin main --no-rebase, then push|
| src refspec main does not match any   | git branch -M main, then push              |
| Logged in via Google                  | Irrelevant for git — use username + token  |
| Lua syntax error on two assigns       | One statement per line (use ; or newline)  |

---

## 10. AI Collaboration Rules

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
    git pull origin main --no-rebase
    git push

5. AI also updates README.md — roadmap, changelog, file list

### Secrets

- Never paste Personal Access Tokens, passwords, or SSH keys in chat
- If leaked: revoke immediately at https://github.com/settings/tokens

### New-chat handoff

Start a new chat with:

    "My project is at https://github.com/Vyrex01/MyGame.
     Current files: [paste main.lua, player.lua, bullet.lua, enemy.lua, conf.lua].
     Please help with XXX."

---

## 11. Roadmap

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
- [x] Enemies with simple chase AI (chase, spawn, kill, score)
- [x] Collision: bullet-vs-enemy (circle-circle)
- [x] Collision + health (100 HP, 20 dmg, i-frames, health bar, game over)

Upcoming:

- [ ] Camera / world scrolling                <-- NEXT
- [ ] Sprites instead of circles
- [ ] Game states (menu, playing, paused, game-over)
- [ ] Sound effects
- [ ] Score display improvements
- [ ] Levels / wave spawning

---

## 12. Changelog

### v0.5 — Health & Damage

- player.lua: added health, maxHealth, invuln, invulnDuration, dead
- player.lua: takeDamage() with i-frames, isAlive(), drawHealthBar()
- player.lua: flicker draw while invulnerable
- enemy.lua: added damage = 20 field (contact damage)
- main.lua: enemy-vs-player circle collision with knockback
- main.lua: Game Over overlay, R to restart
- main.lua: HUD shows health bar

### v0.4 — Enemies

- Added enemy.lua (chase AI, takeDamage, dead flag)
- main.lua: enemies table, spawnEnemy() on edges, difficulty ramp
- main.lua: bullet-vs-enemy circle collision, +100 score per kill
- main.lua: HUD shows score, enemy count, next spawn timer

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

Personal project — no license yet.
