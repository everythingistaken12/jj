
state = TimedUnlocksManager.GetState("starter_pack_best_buddy_bundle")

if state == nil then
    return false
end

if state.isRunning == false then
    return false
end

-- if less than an hour is left
if state.timeRemainingSeconds < (60*60) then
    return false
end

return true