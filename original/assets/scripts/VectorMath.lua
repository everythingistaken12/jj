Log("VectorMath Lua Script Loaded v1.0.01")

---
-- VectorMath Class
---
VectorMath = {}

function VectorMath.RotateVector(vec, deg)
	local rot = deg / 180.0 * 3.14159
	x = math.cos(rot) * vec[1] - math.sin(rot) * vec[2];
	y = math.sin(rot) * vec[1] + math.cos(rot) * vec[2];
	retVec = Vector.New(x, y)
	return retVec
end
