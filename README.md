# Gods of Space

A turn-based lane defence game: aliens march down five lanes toward your base, you hold them off with
three weapons a turn. Six worlds, 180 levels, 43 weapons, 36 aliens. Built with [LÖVE](https://love2d.org) 11.5.

## Play

Install LÖVE 11.5, then from this folder:

```bash
"C:\Program Files\LOVE\love.exe" .
```

or drag the folder onto `love.exe`. Saves live in `%APPDATA%\LOVE\GodsOfSpace\`.

**Controls:** click a weapon or press `A` `S` `D` · click a lane/tile to aim (`1`-`5` picks a lane) ·
`Enter` ends the turn · hold `Space` to fast-forward · `P` pauses · `F11` fullscreen · `Esc` goes back.

## Build a release

```bash
powershell -ExecutionPolicy Bypass -File build.ps1
```

Produces `dist/GodsOfSpace.love` (cross-platform, needs LÖVE installed) and `dist/GodsOfSpace-win64/`
(self-contained Windows folder - zip it and ship it).

## Develop

```bash
"C:\Program Files\LOVE\lovec.exe" . --test              # headless rules tests
"C:\Program Files\LOVE\lovec.exe" . --sim "" auto 0 20  # balance probe: greedy bot plays every planet
"C:\Program Files\LOVE\lovec.exe" . --profile dev       # play with a separate save
```

Layout: `main.lua` boots everything · `src/content.lua` weapons, aliens, levels, save system ·
`src/battle.lua` pure battle rules (tested) · `src/fx.lua` battle animation · `src/ui.lua` design system ·
`src/icons.lua` code-drawn art · `src/sfx.lua` synthesised sound · `src/states/` one file per screen.
`unused/` holds the old art and save backups and is not shipped.
