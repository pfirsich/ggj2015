function clamp(v, a, b)
	return math.max(math.min(v, b), a)
end

function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename)))()
end