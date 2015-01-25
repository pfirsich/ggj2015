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
	drawLevelBackground()
	
	love.graphics.push()
	applyCameraTransforms(camera.position, camera.scale)
	drawLevelObjects()
	drawEscapes()
	drawPlayers()
	love.graphics.pop()
	
	-- HUD
	drawBubbles()
	drawTimer()
end

function drawTimer()
	local time = globalState["gameloop"]["time"]
	local remaining = round(currentLevel.time - time, 0)
	
	if remaining <= 0 then  -- HACK
		transitionState(globalState, "levelEnd")
		finishLevel()
	else
		local margin = 10
		local countdownWidth = 200
		
		local x = (xRes-countdownWidth-margin)
		local y = margin
		
		love.graphics.setFont(hugeMonospaceFont)
		love.graphics.setColor(255, 255, 0, 255)
		love.graphics.printf(tostring(remaining), x, y, countdownWidth, "right")
	end
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

function drawLevelEnd()
	love.graphics.setColor(255,255,255,255)
	love.graphics.rectangle("fill", 0, 0, xRes, yRes)
	local time = getStateVar(globalState, "time")
	if time > 2 then
		local value = math.min(255, (time-2)*50)
		love.graphics.setColor(30,30,30,value)
		love.graphics.setFont(hugeFont)
		love.graphics.printf("BOOM.", 0, (yRes-hugeFont:getHeight())/2, xRes, "center")
	end
end

function love.draw()
	stateCall(globalState, "draw")
end

