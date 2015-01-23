function updateGame()
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