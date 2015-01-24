function transformPoint(point)
	return {(point[1] - camera.position[1]) * camera.scale + xRes/2,
				(point[2] - camera.position[2]) * camera.scale + yRes/2}
end

function applyCameraTransforms(position, scale, parallax)
	parallax = parallax or 1.0
	love.graphics.translate(xRes/2, yRes/2)
	love.graphics.scale(parallax, parallax)
	love.graphics.translate(-position[1] * scale, -position[2] * scale)
	love.graphics.scale(scale, scale)
end

function drawGame()
	drawRockets()
	
	for layer = bgLayerCount, 1, -1 do
		love.graphics.push()
		local img = bgLayers[layer].image
		applyCameraTransforms(camera.position, camera.scale, bgLayers[layer].parallax)
		love.graphics.draw(img, bgLayers[layer].cropData.left, bgLayers[layer].cropData.top, 0, 1.0, 1.0)
		
		if layer == bgLayerCount then
			-- HACK (PRESENTATION)
			love.graphics.setColor(108, 83, 36)
			love.graphics.rectangle("fill", -10000, 4000, 100000, 100000)
			love.graphics.setColor(255, 255, 255)
		end
		
		love.graphics.translate(bgLayers[layer].cropData.originalWidth/2, bgLayers[layer].cropData.originalHeight/2)
		love.graphics.scale(-1.0, 1.0)
		love.graphics.translate(-bgLayers[layer].cropData.originalWidth/2, -bgLayers[layer].cropData.originalHeight/2)
		
		love.graphics.draw(img, bgLayers[layer].cropData.left - bgLayers[layer].cropData.originalWidth + 5, bgLayers[layer].cropData.top, 0, 1.0, 1.0)
		love.graphics.draw(img, bgLayers[layer].cropData.left + bgLayers[layer].cropData.originalWidth - 5, bgLayers[layer].cropData.top, 0, 1.0, 1.0)
		
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
	
	drawEscapes()
	drawPlayers()
	
	love.graphics.pop()
	
	-- HUD
	drawBubbles()
	drawTimer()
end

function drawTimer()
	local time = getStateVar(globalState, "time")
	local remaining = round(math.max(mapTime - time, 0), 0)

	local w,h = love.graphics.getDimensions()
	local margin = 10
	local countdownWidth = 200
	
	local x = (w-countdownWidth-margin)
	local y = margin
	
	love.graphics.setFont(hugeFont)
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.printf(tostring(remaining), x, y, countdownWidth, "right")
end

function drawPaused()
	drawGame()
	love.graphics.setColor({150, 150, 150, 0})
	love.graphics.rectangle("fill", 0, 0, xRes, yRes)
	love.graphics.setColor({255,255,255,255})
	love.graphics.setFont(mediumFont)
	love.graphics.printf("PAUSE", 0, yRes/2, xRes, "center")
end

function drawError()
	love.graphics.setColor(255,255,255)
	love.graphics.printf(getStateVar(globalState, "message"), 5, 5, 500)
end

function love.draw()
	stateCall(globalState, "draw")
end

