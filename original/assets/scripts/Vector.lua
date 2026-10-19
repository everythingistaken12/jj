Log("Vector Lua Script Loaded v1.0.01")

Vector = {}

mt = {}
mt.__unm = function(v) return Vector.New(-v[1], -v[2], -v[3]) end
mt.__add = function(v1, v2) return Vector.New(v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3]) end
mt.__sub = function(v1, v2) return Vector.New(v1[1] - v2[1], v1[2] - v2[2], v1[3] - v2[3]) end
mt.__mul = function(v1, v2)
  local s = tonumber(v2)
  if s then
    return Vector.New(v1[1] * s, v1[2] * s, v1[3] * s)
  else
    return Vector.New(v1[1] * v2[1], v1[2] * v2[2], v1[3] * v2[3])
  end
end

function Vector.New(x, y, z)
  local v = { x or 0, y or 0, z or 0}
  setmetatable(v, mt)
  return v
end

function Vector.Clone(v)
	return Vector.New(v[1], v[2], v[3])
end

function Vector.Normalise(v)
  local d = math.sqrt(v[1]*v[1] + v[2]*v[2] + v[3]*v[3])
  local s = 1.0 / d
  return Vector.New(v[1]*s, v[2]*s, v[3]*s), d
end

function Vector.Dot(v1, v2)
  return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]
end

function Vector.Cross(v1, v2)
  return Vector.New(v1[2] * v2[3] - v1[3] * v2[2], v1[3] * v2[1] - v1[1] * v2[3], v1[1] * v2[2] - v1[2] * v2[1])
end


