inputs = {}

function dummyButtonCallback(state)
	return function() return state end
end

function keyboardCallback(key)
	return function() return love.keyboard.isDown(key) end
end

function joystickButtonCallback(joystick, button)
	return function() return joystick:isGamepadDown(button) end
end

function mouseButtonCallback(button)
	return function() return love.mouse.isDown(button) end
end

function combineCallbacks(A, B)
	return function() return A() and B() end
end

function combineCallbacksOR(A, B)
	return function() return A() or B() end
end

function getBinaryInputFromAxis(joystick, axisID, threshold) 
	threshold = threshold or 0.5
	return function() return math.abs(joystick:getGamepadAxis(axisID)) > threshold end
end

function getFloatInputFromTwoBinaryInputs(funA_plus, funB_minus, factor)
	if factor == nil then factor = 1.0 end
	return function() return ((funA_plus() and 1.0 or 0.0) - (funB_minus() and 1.0 or 0.0)) * factor end
end

function getJoystickAxisCallback(joystick, axisID, factor)
	if factor == nil then factor = 1.0 end
	return function() return joystick:getGamepadAxis(axisID) * factor end
end

function watchBinaryInput(fun) 
	table.insert(inputs, {func = fun, pressed = false, down = false, released = false, lastdown = false})
	local index = #inputs
	return function() return inputs[index] end
end

function updateWatchedInputs()
	for i = 1, #inputs do
		inputs[i].lastdown = inputs[i].down
		inputs[i].down = inputs[i].func()
		
		inputs[i].pressed = false
		inputs[i].released = false
		if inputs[i].down then
			if not inputs[i].lastdown then inputs[i].pressed = true end
		else
			if inputs[i].lastdown then inputs[i].released = true end
		end
	end
end

