bubbles = {}

function spawnBubble(text, position, width, height, lifetime, colors)
	local bubble = {text = text, position = position, width = width, height = height, lifetime = lifetime, colors = colors, age = -1.0}
	table.insert(bubbles, bubble)
end

function updateBubbles()
	for i = #bubbles, 1, -1 do
		local bubble = bubbles[i]
		if bubble.age < 0.0 then
			bubble.age = getStateVar(globalState, "time")
		end
		bubble.age = bubble.age + simulationDt
		if bubble.age > bubble.lifetime then
			table.remove(bubbles, i)
		end
	end
end

function drawBubbles()
	for i = 1, #bubbles do
		local bubble = bubbles[i]
		pos = transformPoint(bubble.position)
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle("fill", pos[1], pos[2], bubble.width, bubble.height)
		love.graphics.setColor(0,0,0,225)	
		love.graphics.rectangle("line", pos[1], pos[2], bubble.width, bubble.height)
		
		love.graphics.setFont(smallFont)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(bubble.text, pos[1], pos[2]+2, bubble.width, "center")
	end
end