state = TimedUnlocksManager.GetState("starter_pack")

-- we shouldn't get here, the check for notification schedule should fail before this
if state == nil  then
    return -1
end

return state.timeRemainingSeconds - 60*60

