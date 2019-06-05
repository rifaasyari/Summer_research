function TableConcat(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

d = {0, math.random()}
c = {math.random(), math.random()}
b = {math.random(), math.random()}
a = {math.random(), 0}

quarter = {a, b, c, d}
shape = {}
for i = 1, 2, 1 do
    for j = 1, 4, 1 do
        for k = 1, 2, 1 do
            table.insert(shape, quarter[j][k])
        end
        quarter[j][1], quarter[j][2] = quarter[j][2], quarter[j][1]
        quarter[j][1] = -1 * quarter[j][1]
    end
end
--print(#shape)
for i = 1, #shape, 1 do
    print(shape[i])
end
--for i = 1, 4, 1 do
--    shape = TableConcat(shape, )
