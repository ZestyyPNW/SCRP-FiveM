
function ps.sorter(tab, key)
    table.sort(tab, function(a, b)
        return a[key] < b[key]
    end)
end

function ps.concat(tab, str)
    return table.concat(tab, str)
end

function ps.string(str, ...)
    return string.format(str, ...)
end

function ps.decimalRound(num, decimalPlaces)
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function ps.random(min, max)
    if not min then min = 0 end
    if not max then max = 1 end
    return math.random(min, max)
end

function ps.tableContains(tab, value)
    for _, v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false
end
