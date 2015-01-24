escapes = {}

function addEscape(x, y, text, drawCallback, activateCallback) 
	local escape = {
		position = {x,y},
		width = 100,
		height = 40,
		text = text,
		activateRadius = 100,
		activateCallback = activateCallback,
		drawCallback = drawCallback, 
		relativeMessagePosition = {0,0},
		messageShowing = false,
		activated = false
	}
	table.insert(escapes, escape)
	return escape
end

function drawEscapes()
	for i = 1, #escapes do
		local escape = escapes[i]
		--love.graphics.setColor(0, 255, 0)
		--love.graphics.circle("line", escape.position[1], escape.position[2], escape.activateRadius)
		
		love.graphics.setColor(255,255,255,255)
		if escape.drawCallback ~= nil then 
			escape.drawCallback(escape) 
		end
		
		if escape.messageShowing then
			local x = escape.position[1] + escape.relativeMessagePosition[1]
			local y = escape.position[2] + escape.relativeMessagePosition[2]
			
			love.graphics.setColor(0,0,0,100)
			love.graphics.rectangle("fill", x, y, escape.width, escape.height)
			love.graphics.setColor(0,0,0,225)	
			love.graphics.rectangle("line", x, y, escape.width, escape.height)
			
			love.graphics.setFont(smallFont)
			love.graphics.setColor(255,255,255,255)	
			love.graphics.printf(escape.text, x, y+2, escape.width, "center")
		end
	end
end

function updateEscapes()
	for i = 1, #escapes do
		local escape = escapes[i]
		for j = 1, #players do
			local player = players[j]
			local r = vnorm(vsub(escape.position, player.position))
			if r < escape.activateRadius and player.controller.interact().pressed then
				if not escape.messageShowing then
					escape.messageShowing = true
				else
					if escape.activateCallback ~= nil then 
						escape.activateCallback(escape, player) 
					end
					escape.activated = true
				end
			end
		end
	end
end