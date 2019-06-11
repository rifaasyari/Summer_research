------------------------------- Global Variables -------------------------------

LINE = 6
SYMMETRYDEG = math.pi / 180
math.randomseed(os.time())
SYMMETRY = {{1, 1}, {-1, 1}, {-1, -1}, {1, -1}}
-- all pixel POINTS
POINTS = {{{0, 0}, {0.1, 0}, {0.2, 0}, {0.3, 0}, {0.4, 0}, {0.5, 0}},
          {{0, 9}, {0.1, 9}, {0.2, 9}, {0.3, 9}, {0.4, 9}, {0.5, 9}},
          {{0, 18}, {0.1, 18}, {0.2, 18}, {0.3, 18}, {0.4, 18}, {0.5, 18}},
          {{0, 27}, {0.1, 27}, {0.2, 27}, {0.3, 27}, {0.4, 27}, {0.5, 27}},
          {{0, 36}, {0.1, 36}, {0.2, 36}, {0.3, 36}, {0.4, 36}, {0.5, 36}, {0.6, 36}},
          {{0, 45}, {0.1 ,45}, {0.2, 45}, {0.3, 45}, {0.4, 45}, {0.5, 45}, {0.6, 45}, {0.7, 45}}}

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
        next = pre + i
        if next > 0 and next <= #POINTS[cur_line] then
            table.insert(sub, next)
            dfs(POINTS, cur_line + 1, next, end_line, sub, res, activate)
            table.remove(sub)
        end
    end
end

-- you's function used in printing spectrum
function str_from_complex(a)
    return string.format('%.4f %.4f', a[1], a[2])
end

-- you's function
function polar_str_from_complex(a)
    local phase = math.atan2(a[1], a[2])
    if phase < 0 then
        phase = phase + 2*pi
    end
end

-- get k and b value of the line function containing (x1, y1) and (x2, y2)
function get_k_b(x1, y1, x2, y2)
    k = (y1 - y2) / (x1 - x2)
    b = y1 - k * x1
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
        y = math.tan(angle * SYMMETRYDEG) * x
        table.insert(base, {x, y})
    end
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

-- generate the spectrum
function generate_spectrum()
    for freq = 1/lamda3*period, 1/lamda1*period, 0.003 do
        S:SetFrequency(freq)
        S:SetLayerPatternPolygon('slab', 'Silicon', {0, 0}, 0, shape)
        S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})

        forw, back = S:GetAmplitudes('top', 0)
        forw, h = S:GetAmplitudes('bottom', 0)

        print(freq, str_from_complex(forw[1]))
    end
end

-- check if the shape is able to generate spectrum
function check_shape(p)
    num_zero = 0
    for i = 1, #p, 1 do
        if p[i] == 1 then
            num_zero = num_zero + 1
        end
        if LINE - num_zero < 2 then
            return false
        end
    end
    return true
end

------------------------------- Main starts here -------------------------------

S = S4.NewSimulation()
ux = 1
uy = 0
vx = 0
vy = 1

S:SetLattice({ux,uy}, {vx,vy})
S:SetNumG(100)

lamda1=1;
lamda2=1.42;
lamda3=1.7;

n_PDMS=1.4^2;
n_si=3.54^2;

S:AddMaterial('Vacuum', {1,0})
S:AddMaterial('Silicon', {n_si,0})
S:AddMaterial('PDMS', {n_PDMS,0})

period=600*10^-3;
h=750*10^-3;
h_relative=h/period;

S:AddLayer('top', 0, 'PDMS')
S:AddLayer('slab',h_relative , 'PDMS')
S:AddLayerCopy('bottom', 0, 'top')


count = 0
sub_p, permutations = {}, {}
permutation(1, sub_p, permutations)
for k = 2, #permutations, 1 do
    -- test code: choose the activation sequence
    --k = 2
    activate = permutations[k]

    -- test code: see the activated line
    -- print('Activated lines')
    -- print(activate[1], activate[2], activate[3], activate[4], activate[5], activate[6])

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
    -- print('# of shapes: ' .. #res)

    count = count + #res
    for i = 1, #res, 1 do
        -- test code: choose the number of shape
        -- i = 2

        -- test the dfs result, ex {1, 0, 2, 3, 1, 5}
        -- for b = 1, #res, 1 do
        --    print(res[b][1], res[b][2], res[b][3], res[b][4], res[b][5], res[b][6])
        -- end
        base = one_8th(res[i], POINTS)
        for i = LINE, 1, -1 do
            table.insert(base, {base[i][2], base[i][1]})
        end
        shape = {}
        -- propagate through four quarters
        gen_full_shape(base, SYMMETRY, shape)

        -- test shape
        -- for q = 1, #shape, 2 do
        --    print(shape[q], shape[q + 1])
        -- end

        generate_spectrum()
    end
end

print('Total # of shpae: ' .. count)
