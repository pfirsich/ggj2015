function applyCameraTransforms(position, scale, parallax)
	parallax = parallax or 1.0
	love.graphics.translate(xRes/2, yRes/2)
	--love.graphics.scale(parallax)
	local tx = -math.floor(position[1] * scale)
	local ty = -math.floor(position[2] * scale)
	love.graphics.translate(tx, ty)
	love.graphics.scale(scale, scale)
end

function drawGame()
	love.graphics.setColor(255, 255, 255)
	for layer = bgLayerCount, 1, -1 do
		love.graphics.push()
		applyCameraTransforms(camera.position, camera.scale, bgLayers[layer].parallax)
		love.graphics.draw(bgLayers[layer].image, bgLayers[layer].cropData.left, bgLayers[layer].cropData.top, 0, 1.0, 1.0)
		love.graphics.pop()
	end
	
	love.graphics.push()
	applyCameraTransforms(camera.position, camera.scale)
	
	-- debug draw
	if false then
		love.graphics.setColor(255, 255, 255, 100)
		local shapes = currentMap.shapes
		for i = 1, #shapes do
			love.graphics.polygon("fill", unpack(shapes[i]))
		end
	end
	
	drawPlayers()
	drawEscapes()
	
	love.graphics.pop()
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