bubbles = {}

function spawnBubble(text, position, lifetime, colors)
	lifetime = lifetime or math.huge
	colors = colors or {}
	
	local font = smallFont
	local proposedWidth = math.sqrt(font:getWidth(text))*10
	local actualWidth, lineCount = font:getWrap(text, proposedWidth)
	local actualHeight = font:getHeight()*lineCount
	local bubble = {text = text, position = position, width = actualWidth, height = actualHeight, lifetime = lifetime, colors = colors, age = -1.0, font=font}
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
	local fadeTime = 0.5 --seconds
	for i = 1, #bubbles do
		local bubble = bubbles[i]
		local alpha = clamp(((bubble.lifetime - bubble.age)-fadeTime)/fadeTime, 0, 1)
		local pos = transformPoint(bubble.position)
		love.graphics.setColor(0,0,0,100*alpha)
		love.graphics.rectangle("fill", pos[1], pos[2], bubble.width, bubble.height)
		love.graphics.setColor(0,0,0,225*alpha)	
		love.graphics.rectangle("line", pos[1], pos[2], bubble.width, bubble.height)
		
		love.graphics.setFont(bubble.font)
		love.graphics.setColor(255,255,255,255*alpha)
		love.graphics.printf(bubble.text, pos[1], pos[2]+2, bubble.width, "center")
	end
end