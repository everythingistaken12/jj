Log("SpeedEvent Lua script started v1.0.01")

---
-- SpeedEvent class
---
SpeedEvent = {}

function SpeedEvent.New(eventName, triggerValue)
	local newSpeedEvent = {}
	newSpeedEvent.eventName = eventName
	newSpeedEvent.triggerValue = triggerValue

	---
	-- Check
	--  Returns TRUE if this Event should trigger for the supplied value
	---
	function newSpeedEvent:Check(previousValue, currentValue)
		local shouldTrigger = (previousValue < self.triggerValue and currentValue >= self.triggerValue)
		return shouldTrigger
	end

	return newSpeedEvent
end
