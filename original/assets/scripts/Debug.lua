Log("Debug Lua script started v1.0.02")

---
-- Debug class
--  Members turn different logging on and off.
---
Debug =
{
	General = true,
	States = false,
	Particles = false,
	HudShakes = false,
	Sounds = false
}

---
-- Enum ErrorLevel
---
ErrorLevel =
{
	Log = 0,
	Warn = 1,
	Error = 2
}

---
-- Handy for selectively Logging.
---
function Debug.Log(isEnabled, output)
	if (isEnabled == true) then
		Log(ErrorLevel.Log, output)
	end
end

---
-- Warn Log
---
function Debug.Warn(output)
	Log(ErrorLevel.Warn, output);
end

---
-- Error Log
---
function Debug.Error(output)
	Log(ErrorLevel.Error, output);
end