function transitionState(state, toState)
	local fromState = state._currentState
	if fromState and state[fromState].onExit then state[fromState].onExit(toState) end
	state._currentState = toState
	if state[toState].onEnter then state[toState].onEnter(fromState) end
end
	
function stateCall(state, func)
	if state._currentState and state[state._currentState][func] then
		state[state._currentState][func]()
	end
end

function getState(state)
	if state._currentState then
		return state._currentState, state[state._currentState]
	else
		return "", nil
	end
end

function setStateVar(state, key, val)
	if state._currentState then
		state[state._currentState][key] = val
	end
end

function getStateVar(state, key)
	if state._currentState then
		return state[state._currentState][key]
	else
		return nil
	end
end
