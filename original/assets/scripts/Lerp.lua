Log("Lerp Lua script started v1.0.01")

---
-- Lerp Class
---
Lerp = {}

Lerp.Linear = {}
function Lerp.Linear.Tween(from, to, delta)
	return to * delta + from * (1.0 - delta)
end

Lerp.Sin = {}
function Lerp.Sin.Tween(from, to, delta)
	local deltaMod = (math.sin(3.14159 * (delta + 1.5)) + 1.0) / 2.0
	return Lerp.Linear.Tween(from, to, deltaMod)
end

Lerp.EaseOutSin = {}
function Lerp.EaseOutSin.Tween(from, to, delta)
	local deltaMod = math.sin(delta * (3.14159 / 2.0))
	return Lerp.Linear.Tween(from, to, deltaMod)
end
