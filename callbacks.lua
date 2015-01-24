callbacks = {}

function addCallback(callback)
	table.insert(callback)
end

function updateCallbacks()
	for i=#callbacks,1,-1 do
		local callback = callbacks[i]
		local result = callback()
		if not results then
			table.remove(callbacks, i)
		end
	end
end