function updateGame()
		-- Move and scale camera so that all players are in view
	local targetTransformPos = {0,0}
	for playerId = 1, #players do
		targetTransformPos = vadd(targetTransformPos, vmul(players[playerId].position, 1/#players))
	end
	local camPosRel = vsub(targetTransformPos, camera.position)
	local targetTransformScale = 1.0
	camera.position = vadd(camera.position, vmul(camPosRel, 3.0 * simulationDt))
	camera.scale = camera.scale + (targetTransformScale - camera.scale) * 3.0 * simulationDt
	
	-- check for pause key
	if false then
		transitionState(globalState, "paused")
	end
	
	updatePlayers()
end

function updatePaused()
	if false then
		transitionState(globalState, "gameloop")
	end
end

function tickSimulation()
	updateWatchedInputs()
	local name, state = getState(globalState)
	state.time = state.time + simulationDt
	stateCall(globalState, "update")
end