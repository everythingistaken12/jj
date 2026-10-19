local utils = {}

function utils.get_formatted_number(num)
    local str = tostring(num)
    repeat
        str, k = string.gsub(str, "^(-?%d+)(%d%d%d)", "%1,%2")
    until k == 0
    return str
end

return utils