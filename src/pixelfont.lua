-- Hand-drawn 5x7 pixel font used for titles, buttons and HUD numbers.
-- Built at runtime into LÖVE ImageFonts, one per integer scale, so it stays
-- crisp and ships with no font file (and no licence to worry about).
local pixelfont = {}

local G = {
    A = {'.###.', '#...#', '#...#', '#####', '#...#', '#...#', '#...#'},
    B = {'####.', '#...#', '#...#', '####.', '#...#', '#...#', '####.'},
    C = {'.###.', '#...#', '#....', '#....', '#....', '#...#', '.###.'},
    D = {'####.', '#...#', '#...#', '#...#', '#...#', '#...#', '####.'},
    E = {'#####', '#....', '#....', '####.', '#....', '#....', '#####'},
    F = {'#####', '#....', '#....', '####.', '#....', '#....', '#....'},
    G = {'.###.', '#...#', '#....', '#.###', '#...#', '#...#', '.####'},
    H = {'#...#', '#...#', '#...#', '#####', '#...#', '#...#', '#...#'},
    I = {'###', '.#.', '.#.', '.#.', '.#.', '.#.', '###'},
    J = {'..###', '....#', '....#', '....#', '#...#', '#...#', '.###.'},
    K = {'#...#', '#..#.', '#.#..', '##...', '#.#..', '#..#.', '#...#'},
    L = {'#....', '#....', '#....', '#....', '#....', '#....', '#####'},
    M = {'#...#', '##.##', '#.#.#', '#.#.#', '#...#', '#...#', '#...#'},
    N = {'#...#', '#...#', '##..#', '#.#.#', '#..##', '#...#', '#...#'},
    O = {'.###.', '#...#', '#...#', '#...#', '#...#', '#...#', '.###.'},
    P = {'####.', '#...#', '#...#', '####.', '#....', '#....', '#....'},
    Q = {'.###.', '#...#', '#...#', '#...#', '#.#.#', '#..#.', '.##.#'},
    R = {'####.', '#...#', '#...#', '####.', '#.#..', '#..#.', '#...#'},
    S = {'.####', '#....', '#....', '.###.', '....#', '....#', '####.'},
    T = {'#####', '..#..', '..#..', '..#..', '..#..', '..#..', '..#..'},
    U = {'#...#', '#...#', '#...#', '#...#', '#...#', '#...#', '.###.'},
    V = {'#...#', '#...#', '#...#', '#...#', '#...#', '.#.#.', '..#..'},
    W = {'#...#', '#...#', '#...#', '#.#.#', '#.#.#', '#.#.#', '.#.#.'},
    X = {'#...#', '#...#', '.#.#.', '..#..', '.#.#.', '#...#', '#...#'},
    Y = {'#...#', '#...#', '.#.#.', '..#..', '..#..', '..#..', '..#..'},
    Z = {'#####', '....#', '...#.', '..#..', '.#...', '#....', '#####'},
    ['0'] = {'.###.', '#...#', '#..##', '#.#.#', '##..#', '#...#', '.###.'},
    ['1'] = {'.#.', '##.', '.#.', '.#.', '.#.', '.#.', '###'},
    ['2'] = {'.###.', '#...#', '....#', '...#.', '..#..', '.#...', '#####'},
    ['3'] = {'####.', '....#', '....#', '.###.', '....#', '....#', '####.'},
    ['4'] = {'...#.', '..##.', '.#.#.', '#..#.', '#####', '...#.', '...#.'},
    ['5'] = {'#####', '#....', '####.', '....#', '....#', '#...#', '.###.'},
    ['6'] = {'..##.', '.#...', '#....', '####.', '#...#', '#...#', '.###.'},
    ['7'] = {'#####', '....#', '...#.', '..#..', '.#...', '.#...', '.#...'},
    ['8'] = {'.###.', '#...#', '#...#', '.###.', '#...#', '#...#', '.###.'},
    ['9'] = {'.###.', '#...#', '#...#', '.####', '....#', '...#.', '.##..'},
    [' '] = {'...', '...', '...', '...', '...', '...', '...'},
    ['.'] = {'.', '.', '.', '.', '.', '.', '#'},
    [','] = {'..', '..', '..', '..', '..', '.#', '#.'},
    [':'] = {'.', '#', '.', '.', '.', '#', '.'},
    [';'] = {'..', '.#', '..', '..', '..', '.#', '#.'},
    ['!'] = {'#', '#', '#', '#', '#', '.', '#'},
    ['?'] = {'.###.', '#...#', '....#', '...#.', '..#..', '.....', '..#..'},
    ["'"] = {'#', '#', '.', '.', '.', '.', '.'},
    ['"'] = {'#.#', '#.#', '...', '...', '...', '...', '...'},
    ['-'] = {'...', '...', '...', '###', '...', '...', '...'},
    ['+'] = {'.....', '..#..', '..#..', '#####', '..#..', '..#..', '.....'},
    ['='] = {'...', '...', '###', '...', '###', '...', '...'},
    ['/'] = {'....#', '....#', '...#.', '..#..', '.#...', '#....', '#....'},
    ['%'] = {'##..#', '##..#', '...#.', '..#..', '.#...', '#..##', '#..##'},
    ['('] = {'.#', '#.', '#.', '#.', '#.', '#.', '.#'},
    [')'] = {'#.', '.#', '.#', '.#', '.#', '.#', '#.'},
    ['['] = {'##', '#.', '#.', '#.', '#.', '#.', '##'},
    [']'] = {'##', '.#', '.#', '.#', '.#', '.#', '##'},
    ['<'] = {'...#', '..#.', '.#..', '#...', '.#..', '..#.', '...#'},
    ['>'] = {'#...', '.#..', '..#.', '...#', '..#.', '.#..', '#...'},
    ['&'] = {'.##..', '#..#.', '#.#..', '.#...', '#.#.#', '#..#.', '.##.#'},
    ['#'] = {'.#.#.', '#####', '.#.#.', '.#.#.', '#####', '.#.#.', '.....'},
    ['*'] = {'.....', '#.#.#', '.###.', '#####', '.###.', '#.#.#', '.....'},
    ['_'] = {'.....', '.....', '.....', '.....', '.....', '.....', '#####'},
    ['|'] = {'#', '#', '#', '#', '#', '#', '#'},
}

-- order of glyphs in the image; lowercase letters reuse the capitals (the font is caps-only)
local ORDER = {}
for c in ('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:;!?\'"-+=/%()[]<>&#*_|'):gmatch('.') do ORDER[#ORDER + 1] = c end
for c in ('abcdefghijklmnopqrstuvwxyz'):gmatch('.') do ORDER[#ORDER + 1] = c end

local ROWS, PAD_TOP, PAD_BOTTOM = 7, 1, 2 -- glyph rows plus breathing room so line height reads well

-- bold face for large sizes: every stroke is doubled to the right (a glyph gets one column wider).
-- Small sizes keep the regular face so long names still fit.
local REGULAR, BOLD = G, {}
for c, rows in pairs(REGULAR) do
    local bold = {}
    for r, row in ipairs(rows) do
        local out = {}
        local w = #row
        for col = 1, w + 1 do
            local here = col <= w and row:sub(col, col) == '#'
            local left = col > 1 and row:sub(col - 1, col - 1) == '#'
            out[col] = (here or left) and '#' or '.'
        end
        bold[r] = table.concat(out)
    end
    if c == ' ' then bold = rows end
    BOLD[c] = bold
end

local function build(scale)
    local G = scale >= 3 and BOLD or REGULAR
    local height = (ROWS + PAD_TOP + PAD_BOTTOM) * scale
    local width = 1
    for _, c in ipairs(ORDER) do width = width + #G[c:upper()][1] * scale + 1 end
    local img = love.image.newImageData(width, height)
    -- separator column colour (magenta), then each glyph followed by a separator
    local function sep(x) for y = 0, height - 1 do img:setPixel(x, y, 1, 0, 1, 1) end end
    local x = 0
    sep(x); x = x + 1
    for _, c in ipairs(ORDER) do
        local rows = G[c:upper()]
        local w = #rows[1]
        for r = 1, ROWS do
            for col = 1, w do
                if rows[r]:sub(col, col) == '#' then
                    for dy = 0, scale - 1 do for dx = 0, scale - 1 do
                        img:setPixel(x + (col - 1) * scale + dx, (PAD_TOP + r - 1) * scale + dy, 1, 1, 1, 1)
                    end end
                end
            end
        end
        x = x + w * scale
        sep(x); x = x + 1
    end
    local font = love.graphics.newImageFont(img, table.concat(ORDER), scale) -- `scale` px between letters
    font:setFilter('nearest', 'nearest')
    return font
end

local cache = {}
-- `size` is the nominal point size callers ask for; map it to a whole-number pixel scale
function pixelfont.get(size, fallback)
    local scale = math.max(1, math.floor(size * 0.8 / ROWS + 0.65))
    if not cache[scale] then
        cache[scale] = build(scale)
        if fallback then cache[scale]:setFallbacks(fallback) end -- anything we have no glyph for
    end
    return cache[scale]
end

return pixelfont
