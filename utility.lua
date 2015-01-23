function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename)))()
end