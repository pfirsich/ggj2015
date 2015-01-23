function drawGame()
	-- debug draw
	love.graphics.setColor(255, 255, 255)
	local shapes = currentMap.shapes
	for i = 1, #shapes do
		love.graphics.polygon("fill", unpack(shapes[i]))
	end
	
	drawPlayers()
end

function drawPaused()
	drawGame()
	love.graphics.setColor({150, 150, 150, 0})
	love.graphics.rectangle("fill", 0, 0, xRes, yRes)
	love.graphics.setColor({255,255,255,255})
	love.graphics.printf("PAUSE", 0, yRes/2, xRes, "center")
end

function drawError()
	love.graphics.setColor(255,255,255)
	love.graphics.printf(getStateVar(globalState, "message"), 5, 5, 500)
end

function love.draw()
	stateCall(globalState, "draw")
end