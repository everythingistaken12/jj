state = TimedUnlocksManager.GetState("christmas_2021_1_nutcracker_bundle")

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

return EventSystem.GetActiveEventName() == "christmas" and
	EventSystem.GetCurrentEventUserDay() == 3