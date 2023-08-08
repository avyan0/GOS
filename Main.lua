-- main.lua

-- Constants
local TILE_SIZE = 50
local ALIEN_SPEED = TILE_SIZE
local NUM_LANES = 5
local NUM_ROWS = 10
local NUM_ALIENS = 3

-- Game variables
local aliens = {}
local currentPlayerTurn = "player" -- Set initial turn to player

-- Player variables
local selectedWeapon = nil -- Selected weapon index
local weaponCooldown = 0.5 -- Cooldown between weapon uses (in seconds)

function love.load()
  -- Create aliens
  for i = 1, NUM_LANES do
    aliens[i] = {}
  end

  -- Randomly spawn aliens
  for i = 1, NUM_ALIENS do
    local lane = love.math.random(1, NUM_LANES)
    local row = NUM_ROWS
    local alien = {
      x = (lane - 1) * TILE_SIZE,
      y = (row - 1) * TILE_SIZE,
      speed = ALIEN_SPEED,
      lane = lane,
      row = row,
      health = 100
    }
    table.insert(aliens[lane], alien)
  end

  -- Set background color
  love.graphics.setBackgroundColor(255, 192, 203) -- Light Pink
end

function love.update(dt)
  -- Check if it's the player's turn
  if currentPlayerTurn == "player" then
    -- Update weapon cooldown
    weaponCooldown = weaponCooldown - dt

    -- Switch turn to aliens if weapon cooldown is complete
    if weaponCooldown <= 0 then
      currentPlayerTurn = "aliens"
    end
  else
    -- Move aliens
    for i = 1, NUM_LANES do
      for j = #aliens[i], 1, -1 do
        local alien = aliens[i][j]
        alien.y = alien.y - alien.speed * dt -- Move the alien up
        alien.row = alien.row - 1 -- Update the alien's row

        -- Remove alien if its health reaches 0 or it reaches the top row
        if alien.row <= 0 or alien.health <= 0 then
          table.remove(aliens[i], j)
        end
      end
    end

    -- Switch turn to player
    currentPlayerTurn = "player"
  end
end

function love.draw()
  -- Draw aliens
  for i = 1, NUM_LANES do
    for j = 1, #aliens[i] do
      local alien = aliens[i][j]
      love.graphics.rectangle("fill", alien.x, alien.y, TILE_SIZE, TILE_SIZE) -- Draw a rectangle for each alien
      love.graphics.print("HP: " .. alien.health, alien.x, alien.y + TILE_SIZE + 5) -- Display alien health
    end
  end

  -- Draw lanes
  for i = 1, NUM_LANES do
    love.graphics.rectangle("line", (i - 1) * TILE_SIZE, 0, TILE_SIZE, love.graphics.getHeight())
  end

  -- Draw weapon info
  love.graphics.print("Selected Weapon: " .. (selectedWeapon or "-"), 10, 10)
  love.graphics.print("Weapon Cooldown: " .. weaponCooldown, 10, 30)
end

function love.mousepressed(x, y, button)
  -- Check if it's the player's turn and a weapon is selected
  if currentPlayerTurn == "player" and selectedWeapon ~= nil and button == 1 and weaponCooldown <= 0 then
    -- Find the alien at the clicked position
    local lane = math.ceil(x / TILE_SIZE)
    local row = math.ceil(y / TILE_SIZE)
    local alien = aliens[lane][row]

    -- Deal damage to the alien
    if alien then
      alien.health = alien.health - 50
      if alien.health <= 0 then
        table.remove(aliens[lane], row)
      end
    end

    -- Reset weapon cooldown
    weaponCooldown = 0.5

    -- Switch turn to aliens
    currentPlayerTurn = "aliens"
  end
end

function love.keypressed(key)
  -- Change selected weapon based on number key input (1, 2, 3)
  local num = tonumber(key)
  if num and num >= 1 and num <= 3 then
    selectedWeapon = num
  end
end
