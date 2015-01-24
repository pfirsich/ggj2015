function updateGame()
	-- Move and scale camera so that all players are in view
	local xMin, xMax, yMin, yMax = math.huge, -math.huge, math.huge, -math.huge
	for playerId = 1, #players do
		local player = players[playerId]
		xMin, yMin = math.min(player.position[1], xMin), math.min(player.position[2], yMin)
		xMax, yMax = math.max(player.position[1], xMax), math.max(player.position[2], yMax)
	end
	local defaultZoom = 0.4
	local xScale = xRes / (xMax - xMin + xRes * defaultZoom)
	local yScale = yRes / (yMax - yMin + yRes * defaultZoom)
	
	local targetTransformPos = {(xMin + xMax)/ 2.0, (yMin + yMax)/2.0}
	local marginX, marginY = xRes/2.0/camera.scale, yRes/2.0/camera.scale
	targetTransformPos[1] = clamp(targetTransformPos[1], marginX, mapSize[1] - marginX)
	targetTransformPos[2] = clamp(targetTransformPos[2], marginY, 4000 - marginY)
	local camPosRel = vsub(targetTransformPos, camera.position)
	local targetTransformScale = math.min(1.0, xScale, yScale)
	camera.position = vadd(camera.position, vmul(camPosRel, 3.0 * simulationDt))
	camera.scale = camera.scale + (targetTransformScale - camera.scale) * 3.0 * simulationDt
	
	-- check for pause key
	for playerId = 1, #players do
		if players[playerId].controller.pause().pressed then
			transitionState(globalState, "paused")
		end
	end
	
	updatePlayers()
end

function updatePaused()
		for playerId = 1, #players do
		if players[playerId].controller.pause().pressed then
			transitionState(globalState, "gameloop")
		end
	end
end

function tickSimulation()
	updateWatchedInputs()
	local name, state = getState(globalState)
	state.time = state.time + simulationDt
	stateCall(globalState, "update")
end