-- Procedural sound effects: every sound is synthesised at load, so the game
-- ships with no audio files. Volume follows the Settings sliders.
local sfx = {}

local RATE = 22050
local bank = {}      -- name -> Source
local lastPlay = {}  -- name -> time, to stop identical sounds stacking in one frame
local enabled = false

local function clamp(v) return math.max(-1, math.min(1, v)) end

-- build a Source from fn(t, dur) -> sample in [-1, 1]
local function gen(dur, fn)
    local n = math.floor(RATE * dur)
    local sd = love.sound.newSoundData(n, RATE, 16, 1)
    for i = 0, n - 1 do
        local t = i / RATE
        sd:setSample(i, clamp(fn(t, dur)))
    end
    return love.audio.newSource(sd, 'static')
end

local function env(t, dur, attack, curve) -- quick attack, exponential-ish decay
    local a = attack or 0.005
    if t < a then return t / a end
    local p = (t - a) / (dur - a)
    return (1 - p) ^ (curve or 2)
end

local function noise() return math.random() * 2 - 1 end
local function sine(f, t) return math.sin(2 * math.pi * f * t) end
local function square(f, t) return sine(f, t) > 0 and 1 or -1 end
local function tri(f, t) return 2 * math.abs(2 * ((f * t) % 1) - 1) - 1 end

-- a few notes played in sequence (arpeggio), each `step` seconds long
local function arp(freqs, step, wave)
    return gen(step * #freqs + 0.25, function(t, dur)
        local k = math.min(#freqs, math.floor(t / step) + 1)
        local lt = t - (k - 1) * step
        local e = lt < step and env(lt, step, 0.005, 1.5) or 0
        local tail = env(t, dur, 0.001, 3)
        local w = wave or sine
        return (w(freqs[k], t) * 0.5 + sine(freqs[k] * 2, t) * 0.15) * e * 0.5 + w(freqs[#freqs], t) * tail * 0.1 * (k == #freqs and 1 or 0)
    end)
end

function sfx.init()
    if not love.audio or not love.sound then return end
    math.randomseed(1234) -- deterministic noise textures
    bank.click  = gen(0.06, function(t, d) return sine(1400, t) * env(t, d, 0.002, 3) * 0.35 end)
    bank.hover  = gen(0.03, function(t, d) return sine(2200, t) * env(t, d, 0.002, 3) * 0.08 end)
    bank.hit    = gen(0.16, function(t, d) return (noise() * 0.6 + sine(180 - t * 400, t) * 0.5) * env(t, d, 0.002, 2.5) * 0.6 end)
    bank.kill   = gen(0.45, function(t, d) return (noise() * 0.7 + sine(120 - t * 150, t) * 0.6) * env(t, d, 0.003, 2) * 0.7 end)
    bank.boom   = gen(0.5,  function(t, d) return (noise() * 0.5 + sine(70 - t * 60, t) * 0.8) * env(t, d, 0.004, 1.8) * 0.8 end)
    bank.whoosh = gen(0.35, function(t, d) local p = t / d; return noise() * math.sin(p * math.pi) * (0.25 + 0.5 * p) * 0.6 end)
    bank.zap    = gen(0.28, function(t, d) return (square(900 + math.sin(t * 90) * 500, t) * 0.35 + noise() * 0.35) * env(t, d, 0.002, 2) * 0.55 end)
    bank.beam   = gen(0.5,  function(t, d) return (sine(320 + t * 900, t) * 0.4 + sine(640 + t * 1800, t) * 0.2 + noise() * 0.1) * env(t, d, 0.03, 1.5) * 0.6 end)
    bank.spawn  = gen(0.22, function(t, d) return tri(300 + t * 1400, t) * env(t, d, 0.01, 2) * 0.3 end)
    bank.status = gen(0.3,  function(t, d) return (sine(880, t) * 0.4 + sine(1320, t) * 0.3 + sine(1760, t) * 0.2) * env(t, d, 0.005, 2.5) * 0.45 end)
    bank.step   = gen(0.09, function(t, d) return (sine(90, t) * 0.7 + noise() * 0.15) * env(t, d, 0.003, 2) * 0.5 end)
    bank.wall   = gen(0.2,  function(t, d) return (sine(140, t) * 0.5 + noise() * 0.3) * env(t, d, 0.003, 2) * 0.6 end)
    bank.crack  = gen(0.3,  function(t, d) return noise() * env(t, d, 0.001, 3) * 0.7 end)
    bank.clash  = gen(0.3,  function(t, d) return (square(220, t) * 0.3 + noise() * 0.6) * env(t, d, 0.002, 2.5) * 0.6 end)
    bank.ability = gen(0.35, function(t, d) return (sine(520, t) * 0.5 + sine(780, t) * 0.25) * env(t, d, 0.02, 1.6) * 0.4 end)
    bank.turn   = gen(0.25, function(t, d) return (sine(196, t) * 0.6 + sine(392, t) * 0.2) * env(t, d, 0.01, 2) * 0.45 end)
    bank.tick   = gen(0.03, function(t, d) return noise() * env(t, d, 0.001, 3) * 0.3 end)
    bank.coin   = gen(0.3,  function(t, d) return (sine(1568, t) * 0.5 + sine(2093, t) * 0.4) * env(t, d, 0.003, 2.5) * 0.45 end)
    bank.notify = arp({659, 988}, 0.09)
    bank.chime  = arp({523, 659, 784, 1047}, 0.09)
    bank.win    = arp({392, 494, 587, 784, 988}, 0.14, tri)
    bank.lose   = arp({392, 349, 311, 262}, 0.22, tri)
    bank.freeze = gen(0.6,  function(t, d) return (sine(1200 - t * 900, t) * 0.4 + sine(2400 - t * 1800, t) * 0.15) * env(t, d, 0.05, 1.5) * 0.4 end)
    math.randomseed(os.time())
    enabled = true
end

function sfx.volume()
    return ((data and data.volume) or 100) / 100
end

-- play a named sound; opts: vol (0..1), pitch, gap (min seconds between repeats, default 0.04)
function sfx.play(name, opts)
    if not enabled then return end
    local src = bank[name]
    if not src then return end
    opts = opts or {}
    local now = love.timer.getTime()
    if lastPlay[name] and now - lastPlay[name] < (opts.gap or 0.04) then return end
    lastPlay[name] = now
    local v = sfx.volume() * (opts.vol or 1)
    if v <= 0.001 then return end
    local s = src:clone()
    s:setVolume(v)
    s:setPitch(opts.pitch or 1)
    s:play()
end

return sfx
