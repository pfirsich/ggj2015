function getFromWrappedArray(i, table)
	return table[(i-1)%#table+1]
end

function clamp(v, a, b)
	return math.max(math.min(v, b), a)
end

function randf(min, max)
	return min + love.math.random() * (max - min)
end

function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename)))()
end

function round(num, idp) -- http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function lerpArray(a, b, t, transform)
	assert(#a == #b)
	if transform then t = transform(t) end
	local ret = {}
	for i, v in ipairs(a) do
		ret[i] = lerp(v, b[i], t)
	end
	return ret
end

function lerp(a, b, t)
	return (1-t)*a + t*b
end