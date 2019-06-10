pi = math.pi
deg = pi / 180
math.randomseed(os.time())

points = {{{0, 0}, {0.1, 0}, {0.2, 0}, {0.3, 0}, {0.4, 0}, {0.5, 0}},
          {{0, 9}, {0.1, 9}, {0.2, 9}, {0.3, 9}, {0.4, 9}, {0.5, 9}},
          {{0, 18}, {0.1, 18}, {0.2, 18}, {0.3, 18}, {0.4, 18}, {0.5, 18}},
          {{0, 27}, {0.1, 27}, {0.2, 27}, {0.3, 27}, {0.4, 27}, {0.5, 27}},
          {{0, 36}, {0.1, 36}, {0.2, 36}, {0.3, 36}, {0.4, 36}, {0.5, 36}, {0.6, 36}},
          {{0, 45}, {0.1 ,45}, {0.2, 45}, {0.3, 45}, {0.4, 45}, {0.5, 45}, {0.6, 45}, {0.7, 45}}}

function get_k_b(x1, y1, x2, y2)
    k = (y1 - y2) / (x1 - x2)
    b = y1 - k * x1
    return k, b
end

function table.clone(org)
    return {table.unpack(org)}
end

function insert_skipped1(skip, k, b, base)
    for j = 1, #skip, 1 do
        local angle = points[skip[j]][1][2]
        x = b / (math.tan(angle * deg) - k)
        y = math.tan(angle * deg) * x
        table.insert(base, {x, y})
    end
end

function insert_skipped2(skip, base, x)
    for j = 1, #skip, 1 do
        local angle = points[skip[j]][1][2]
        y = math.tan(angle * deg) * x
        table.insert(base, {x, y})
    end
end

-- pass in cur points, points
-- return one_8th of the shape
function one_8th(cur_points, points)
    local base = {}
    local skip = {}
    local x1, y1 = -1, -1
    local cur_points = sample

    for i = 1, 6, 1 do
        if sample[i] == 0 then
            table.insert(skip, i)
        else
            cur_point = points[i][cur_points[i]]
            x2 = cur_point[1] * math.cos(cur_point[2] * deg)
            y2 = cur_point[1] * math.sin(cur_point[2] * deg)
            if x1 == -1 and i > 1 then
                x1, y1 = x2, 0
                table.insert(base, {x1, y1})
                table.remove(skip, 1)
            end
            if #skip ~= 0 then
                local k, b = get_k_b(x1, y1, x2, y2)
                if k == -math.huge then
                    insert_skipped2(skip, base, x1)
                else
                    insert_skipped1(skip, k, b, base)
                end
            end
            skip = {}
            table.insert(base, {x2, y2})
            x1, y1 = x2, y2
        end
    end

    if #skip ~= 0 then
        local k, b = -1, x1 + y1
        insert_skipped1(skip, k, b, base)
    end
    return table.clone(base)
end


sample = {0, 0, 0, 0, 0, 4}
quarter = {}
base = one_8th(sample, points)


for i = 1, #base, 1 do
    print(base[i][1], base[i][2])
end
