------------------------------- Global Variables -------------------------------

LINE = 6
SYMMETRYDEG = math.pi / 180
math.randomseed(os.time())
SYMMETRY = {{1, 1}, {-1, 1}, {-1, -1}, {1, -1}}
-- all pixel POINTS
POINTS = {{{0.1, 0}, {0.2, 0}, {0.3, 0}, {0.4, 0}, {0.5, 0}},
          {{0.1, 9}, {0.2, 9}, {0.3, 9}, {0.4, 9}, {0.5, 9}},
          {{0.1, 18}, {0.2, 18}, {0.3, 18}, {0.4, 18}, {0.5, 18}},
          {{0.1, 27}, {0.2, 27}, {0.3, 27}, {0.4, 27}, {0.5, 27}},
          {{0.1, 36}, {0.2, 36}, {0.3, 36}, {0.4, 36}, {0.5, 36}, {0.6, 36}},
          {{0.1 ,45}, {0.2, 45}, {0.3, 45}, {0.4, 45}, {0.5, 45}, {0.6, 45}, {0.7, 45}}}

---------------------------------- Functions -----------------------------------

-- return a copy
function table.clone(org)
    return {table.unpack(org)}
end

-- dfs function search through the matrix
function dfs(POINTS, cur_line, pre, end_line, sub, res, activate)
    -- exit dfs, when cur_line is more than 45 degree line
    if cur_line > end_line then
        table.insert(res, table.clone(sub))
        return
    end

    -- if current line is deactivated, jump this line
    if activate[cur_line] == 0 then
        table.insert(sub, 0)
        dfs(POINTS, cur_line + 1, pre, end_line, sub, res, activate)
        table.remove(sub)
        return
    end

    -- current line is activate, we do dfs search
    for i = -1, 1, 1 do
        local next = pre + i
        if next > 0 and next <= #POINTS[cur_line] then
            table.insert(sub, next)
            dfs(POINTS, cur_line + 1, next, end_line, sub, res, activate)
            table.remove(sub)
        end
    end
end

-- get k and b value of the line function containing (x1, y1) and (x2, y2)
function get_k_b(x1, y1, x2, y2)
    local k = (y1 - y2) / (x1 - x2)
    local b = y1 - k * x1
    return k, b
end

-- insert the skipped line coordinate information
function insert_skipped1(skip, k, b, base)
    for j = 1, #skip, 1 do
        local angle = POINTS[skip[j]][1][2]
        x = b / (math.tan(angle * SYMMETRYDEG) - k)
        y = math.tan(angle * SYMMETRYDEG) * x
        table.insert(base, {x, y})
    end
end

-- insert the skipped line coordinate information
-- when the 0 angle line is missing
function insert_skipped2(skip, base, x)
    for j = 1, #skip, 1 do
        local angle = POINTS[skip[j]][1][2]
        local y = math.tan(angle * SYMMETRYDEG) * x
        table.insert(base, {x, y})
    end
end

function one_8th_gen(cur_points, POINTS)
    local base = {}
    for i = 1, LINE, 1 do
        if cur_points[i] ~= 0 then
            cur_point = POINTS[i][cur_points[i]]
            x = cur_point[1] * math.cos(cur_point[2] * SYMMETRYDEG)
            y = cur_point[1] * math.sin(cur_point[2] * SYMMETRYDEG)
            table.insert(base, {x, y})
            --print(x, y)
        end
    end
    return table.clone(base)
end


-- pass in cur POINTS, POINTS
-- return one_8th of the shape
function one_8th(cur_points, POINTS)
    local base = {}
    local skip = {}
    local x1, y1 = -1, -1

    for i = 1, LINE, 1 do
        if cur_points[i] == 0 then
            table.insert(skip, i)
        else
            cur_point = POINTS[i][cur_points[i]]
            x2 = cur_point[1] * math.cos(cur_point[2] * SYMMETRYDEG)
            y2 = cur_point[1] * math.sin(cur_point[2] * SYMMETRYDEG)
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

function permutation(cur, sub, res)
    if cur > LINE then
        table.insert(res, table.clone(sub))
        return
    end

    table.insert(sub, 0)
    permutation(cur + 1, sub, res)
    table.remove(sub)
    table.insert(sub, 1)
    permutation(cur + 1, sub, res)
    table.remove(sub)
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

function round(num, x)
    return tonumber(string.format("%" .. (x or 0) .. "f", num))
end
------------------------------- Main starts here -------------------------------

count = 0
sub_p, permutations = {}, {}
permutation(1, sub_p, permutations)

--for k = 2, 3, 1 do
    -- test code: choose the activation sequence
    k = 16

    activate = permutations[k]

    -- test code: see the activated line
    --print('Activated lines')
    --print(activate[1], activate[2], activate[3], activate[4], activate[5], activate[6])

    sub, res = {}, {}
    dfs_start = -1

    -- corner case if the permutation starts with 0s {0, 0, 1, 0, 1, 1}
    for i = 1, LINE, 1 do
        if dfs_start == -1 and activate[i] == 1 then
            dfs_start = i
        end
        if dfs_start == -1 and activate[i] == 0 then
            table.insert(sub, 0)
        end
    end

    -- do the dfs based on current activated lines
    for i = 1, #POINTS[dfs_start], 1 do
        table.insert(sub, i)
        dfs(POINTS, dfs_start + 1, i, 6, sub, res, activate)
        table.remove(sub)
    end

    -- test code: the number of current shape
    --print('# of shapes: ' .. #res)

    -- count = count + #res
    --activate = {1,0,0,0,0,0}
    --res = {0,0,0,0,0,3}
    for i = 1, #res, 1 do
        -- test code: choose the number of shape
        --i = 1

        count = count + 1

        -- test the dfs result, ex {1, 0, 2, 3, 1, 5}
        --print('Shape: ' .. count)
        --print(res[i][1], res[i][2], res[i][3], res[i][4], res[i][5], res[i][6])

        base = one_8th(res[i], POINTS)
        for i = LINE, 1, -1 do
            table.insert(base, {base[i][2], base[i][1]})
        end

        -- propagate through four quarters
        shape = {}
        gen_full_shape(base, SYMMETRY, shape)
        for qq = 1, #shape, 2 do
           print(shape[qq], shape[qq + 1])
        end

        base = one_8th_gen(res[i], POINTS)
        --print(#base)
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
        --for qq = 1, #shape2, 1 do
        --   print(shape2[qq])
        --end

    end

--end
--print(#shape2)
--print('Total # of shape: ' .. count)
