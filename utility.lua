function clamp(v, a, b)
	return math.max(math.min(v, b), a)
end

function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename), filename))()
end

function round(num, idp) -- http://lua-users.org/wiki/SimpleRound
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function keys(t)
	local list = {}
	for k,v in pairs(t) do
		table.insert(list, k)
	end
	return list
end

function extendTable(source, destination, k)
	k = k or keys(source)
	for i=1,#k do
		local key = k[i]
		destination[key] = source[key]
	end
	return destination
end