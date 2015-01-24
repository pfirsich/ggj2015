function applyCameraTransforms(position, scale, parallax)
	parallax = parallax or 1.0
	love.graphics.translate(xRes/2, yRes/2)
	love.graphics.scale(parallax, parallax)
	love.graphics.translate(-position[1] * scale, -position[2] * scale)
	love.graphics.scale(scale, scale)
end

function drawGame()
	love.graphics.setColor(255, 255, 255)
	for layer = bgLayerCount, 1, -1 do
		love.graphics.push()
		local img = bgLayers[layer].image
		applyCameraTransforms(camera.position, camera.scale, bgLayers[layer].parallax)
		love.graphics.draw(img, bgLayers[layer].cropData.left, bgLayers[layer].cropData.top, 0, 1.0, 1.0)
		
		if layer == bgLayerCount then
			-- HACK for presentation
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
	love.graphics.setColor(255, 255, 255)
	local shapes = currentMap.shapes
	for i = 1, #shapes do
		--love.graphics.polygon("fill", unpack(shapes[i]))
	end
	
	drawPlayers()
	
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