pi = math.pi
deg = pi / 180
math.randomseed(os.time())

symmetry = {{1, 1}, {-1, 1}, {-1, -1}, {1, -1}}
points = {{{0, 0}, {0.1, 0}, {0.2, 0}, {0.3, 0}, {0.4, 0}, {0.5, 0}},
          {{0, 0}, {0.1, 9}, {0.2, 9}, {0.3, 9}, {0.4, 9}, {0.5, 9}},
          {{0, 0}, {0.1, 18}, {0.2, 18}, {0.3, 18}, {0.4, 18}, {0.5, 18}},
          {{0, 0}, {0.1, 27}, {0.2, 27}, {0.3, 27}, {0.4, 27}, {0.5, 27}},
          {{0, 0}, {0.1, 36}, {0.2, 36}, {0.3, 36}, {0.4, 36}, {0.5, 36}, {0.6, 36}},
          {{0, 0}, {0.1 ,45}, {0.2, 45}, {0.3, 45}, {0.4, 45}, {0.5, 45}, {0.6, 45}, {0.7, 45}}}

function table.clone(org)
    return {table.unpack(org)}
end

function dfs(points, cur_line, pre, end_line, sub, res)
    if cur_line > end_line then
      --count = count + 1
                  --print("combination")
        table.insert(res, table.clone(sub))
                  --for i = 1, #sub, 1 do
                  --    print(sub[i])
                  --end
        return
    end

    for i = -1, 1, 1 do
        next = pre + i
        if next > 0 and next <= #points[cur_line] then
            table.insert(sub, next)
            dfs(points, cur_line + 1, next, end_line, sub, res)
            table.remove(sub)
        end
    end
end

function str_from_complex(a)
    return string.format('%.4f %.4f', a[1], a[2])
end

function polar_str_from_complex(a)
    local phase = math.atan2(a[1], a[2])
    if phase < 0 then
        phase = phase + 2*pi
    end
end

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



shape, quarter = {}, {}
sub, res = {}, {}
for i = 1, 6, 1 do
    table.insert(sub, i)
    dfs(points, 2, i, 6, sub, res)
    table.remove(sub)
end

test_shape = 700
--[[
for i = 1, #res[100], 1 do
    print(res[test_shape][i])
end
--]]
--for i = 1, #res, 1 do
    local cur_points = res[test_shape]
    -- apply the first 45 degree points distribution
    for j = 1, 6, 1 do
        cur_point = points[j][cur_points[j]]
        x = cur_point[1] * math.cos(cur_point[2] * deg)
        y = cur_point[1] * math.sin(cur_point[2] * deg)
        table.insert(quarter, {x, y})
        --table.insert(quarter, y)
    end

    -- fill the other 45 degree points
    for j = 6, 1, -1 do
        cur_point = points[j][cur_points[j]]
        y = cur_point[1] * math.cos(cur_point[2] * deg)
        x = cur_point[1] * math.sin(cur_point[2] * deg)
        table.insert(quarter, {x, y})
        --table.insert(quarter, y)
    end

    -- propagate through four quarters
    for i = 1, #symmetry, 1 do
        if i % 2 == 1 then
            for j = 1, #quarter, 1 do
                for k = 1, 2, 1 do
                    table.insert(shape, quarter[j][k] * symmetry[i][k])
                end
            end
        else
            for j = #quarter, 1 , -1 do
                for k = 1, 2, 1 do
                    table.insert(shape, quarter[j][k] * symmetry[i][k])
                end
            end
        end
    end

    for i = 1, #shape, 2 do
        print(shape[i], shape[i + 1])
    end

    --[[
        for freq = 1/lamda3*period, 1/lamda1*period, 0.002 do
        S:SetFrequency(freq)
        S:SetLayerPatternPolygon('slab', 'Silicon', {0, 0}, 0, shape)
        S:SetExcitationPlanewave({0, 0}, {1, 0}, {0, 0})

        forw, back = S:GetAmplitudes('top', 0)
        forw, h = S:GetAmplitudes('bottom', 0)

        print(freq, str_from_complex(forw[1]))
    end
    --]]
--end
