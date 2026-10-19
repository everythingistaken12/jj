
state = TimedUnlocksManager.GetState("chinese_new_year_bundle_2019")

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

return EventSystem.GetActiveEventName() == "chinese_new_year" and
	EventSystem.GetCurrentEventUserDay() == 1