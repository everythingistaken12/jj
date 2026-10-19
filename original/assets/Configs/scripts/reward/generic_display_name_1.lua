local itemType, itemId, qty, icon, displayName, displayDescription, additionalParams = ...

local function comma_value(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

return comma_value(qty) .. " " .. StringTable.GetString(displayName)