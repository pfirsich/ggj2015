function clamp(v, a, b)
	return math.max(math.min(v, b), a)
end

function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename)))()
end

function round(num, idp) -- http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end