callbacks = {}

function addCallback(callback)
	table.insert(callbacks, callback)
end

function updateCallbacks()
	for i=#callbacks,1,-1 do
		local callback = callbacks[i]
		local result = callback()
		if not result then
			table.remove(callback, i)
		end
	end
end