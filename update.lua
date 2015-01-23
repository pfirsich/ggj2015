function updateGame()
	-- check for pause key
	if pauseKeyInput().pressed then
		transitionState(globalState, "paused")
	end
end

function updatePaused()
	if pauseKeyInput().pressed then
		transitionState(globalState, "gameloop")
	end
end

function tickSimulation()
	updateWatchedInputs()
	local name, state = getState(globalState)
	state.time = state.time + simulationDt
	stateCall(globalState, "update")
end