------------------------------- Global Variables -------------------------------
SYMMETRYDEG = math.pi / 180
math.randomseed(os.time())
SYMMETRY = {{1, 1}, {-1, 1}, {-1, -1}, {1, -1}}
ANGLE = {0,9,18,27,36,45}
LINE = 6
--------------------------------- Functions ------------------------------------
-- return a copy
function table.clone(org)
    return {table.unpack(org)}
end
function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function lines_from(file)
    if not file_exists(file) then return {} end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = tonumber(line)
    end
    return lines
end
-- generate the full shape
function gen_full_shape(base, SYMMETRY, shape)
    for i = 1, #SYMMETRY, 1 do
        if i % 2 == 1 then
            for j = 1, #base, 1 do
                for k = 1, 2, 1 do
                    table.insert(shape, base[j][k] * SYMMETRY[i][k])
                end
            end
        else
            for j = #base, 1 , -1 do
                for k = 1, 2, 1 do
                    table.insert(shape, base[j][k] * SYMMETRY[i][k])
                end
            end
        end
    end
end
-- return one_8th of the shape
function one_8th(length, ANGLE)
    local base = {}
    for i = 1, LINE, 1 do
        x = length[i] * math.cos(ANGLE[i] * SYMMETRYDEG)
        y = length[i] * math.sin(ANGLE[i] * SYMMETRYDEG)
        table.insert(base, {x, y})
    end
    return table.clone(base)
end

function filter_duplicate(origin)
    local result = {}
    local offset = 2
    for i = 1, #origin - offset, 2 do
        if i > 2 and math.abs(origin[i - 2] - origin[i]) <= 0.00001 and
                     math.abs(origin[i + 1] - origin[i - 1]) <= 0.00001 then
            --print(origin[i], origin[i + 1], i, i + 1)
        else
            --print(origin[i], origin[i + 1], i, i + 1)
            table.insert(result, origin[i])
            table.insert(result, origin[i + 1])
        end
    end
    return table.clone(result)
end

------------------------------- Main starts here -------------------------------

local file = '../Prediction/2019_7_15_1_p.txt'
local data = lines_from(file)
--print(#data)

base = one_8th(data, ANGLE)

--for i = 1, #base, 1 do
--    print(base[i][1], base[i][2])
--end

for i = 6, 1, -1 do
    table.insert(base, {base[i][2], base[i][1]})
end
-- propagate through four quarters
shape = {}
gen_full_shape(base, SYMMETRY, shape)
--for qq = 1, #shape, 2 do
--   print(shape[qq], shape[qq + 1])
--end


for i = LINE, 1, -1 do
    table.insert(base, {base[i][2], base[i][1]})
end
-- propagate through four quarters
shape = {}
gen_full_shape(base, SYMMETRY, shape)
shape2 = filter_duplicate(shape)
-- test shape
--for qq = 1, #shape2, 2 do
--    print(shape2[qq], shape2[qq + 1])
--end
--print(activate[1])
--print(#shape2)
for qq = 1, #shape2, 1 do
  print(shape2[qq])
end
