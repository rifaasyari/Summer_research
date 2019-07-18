

function permutation(cur, sub, res)
    if cur > 6 then
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

sub, res = {}, {}
permutation(1, sub, res)
