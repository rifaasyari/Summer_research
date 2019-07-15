--------------------------------- Functions ------------------------------------
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

function filter_duplicate(origin, gen)
    local result = {}
    local offset = 2
    if gen == 0 then
        offset = 0
    end
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

local file = 'data/DATA57_#35_gen.txt'
local data = lines_from(file)

base = {unpack(data, 1, 8}
for i = LINE, 1, -1 do
    table.insert(base, {base[i][2], base[i][1]})
end
-- propagate through four quarters
shape = {}
gen_full_shape(base, SYMMETRY, shape)
--for qq = 1, #shape, 2 do
--   print(shape[qq], shape[qq + 1])
--end


base = {unpack(data, 1, 8}
print(#base)
for i = #base, 1, -1 do
    table.insert(base, {base[i][2], base[i][1]})
end
-- propagate through four quarters
shape = {}
gen_full_shape(base, SYMMETRY, shape)
shape2 = filter_duplicate(shape, activate[1])
-- test shape
--for qq = 1, #shape2, 2 do
--    print(shape2[qq], shape2[qq + 1])
--end
--print(activate[1])
--print(#shape2)
for qq = 1, #shape2, 1 do
   print(shape2[qq])
end
