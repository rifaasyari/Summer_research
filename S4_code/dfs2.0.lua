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

function dfs(points, cur_line, pre, end_line, sub, res, activate)
    if cur_line > end_line then
        table.insert(res, table.clone(sub))
        return
    end
    if activate[cur_line] == 0 then
        table.insert(sub, 0)
        dfs(points, cur_line + 1, pre, end_line, sub, res, activate)
        table.remove(sub)
        return
    end

    for i = -1, 1, 1 do
        next = pre + i
        if next > 0 and next <= #points[cur_line] then
            table.insert(sub, next)
            dfs(points, cur_line + 1, next, end_line, sub, res, activate)
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



sub, res = {}, {}
activate = {0, 1, 0, 1, 0, 1}
for i = 1, 6, 1 do
    if activate[i] == 0 then
        table.insert(sub, 0)
    end
    table.insert(sub, i)
    dfs(points, 2, i, 6, sub, res, activate)
    table.remove(sub)
end


for i = 1, #res, 1 do
    print(res[i][1], res[i][2], res[i][3], res[i][4], res[i][5], res[i][6])
end
