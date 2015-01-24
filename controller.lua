
function dummyController()
	return {
		move = getFloatInputFromTwoBinaryInputs(dummyButtonCallback(false), dummyButtonCallback(false)),
		jump = watchBinaryInput(dummyButtonCallback(false)),
		interact = watchBinaryInput(dummyButtonCallback(false)),
		shove = watchBinaryInput(dummyButtonCallback(false)),
		pause = watchBinaryInput(dummyButtonCallback(false))
	}
end

function keyboardController(left, right, jump, interact, shove)
	return {
		move = getFloatInputFromTwoBinaryInputs(keyboardCallback(right), keyboardCallback(left)),
		jump = watchBinaryInput(keyboardCallback(jump)),
		interact = watchBinaryInput(keyboardCallback(interact)),
		shove = watchBinaryInput(keyboardCallback(shove)),
		pause = watchBinaryInput(keyboardCallback("escape")),
		setFeedback = function(v) end,
		getFeedback = function() return 0.0 end,
	}
end

function joystickController(joystick)
	joystick = love.joystick.getJoysticks()[joystick]
	assert(joystick ~= nil)
	return {
		move = getJoystickAxisCallback(joystick, "leftx"),
		jump = watchBinaryInput(joystickButtonCallback(joystick, "a")),
		interact = watchBinaryInput(joystickButtonCallback(joystick, "x")),
		shove = watchBinaryInput(joystickButtonCallback(joystick, "b")),
		pause = watchBinaryInput(joystickButtonCallback(joystick, "start")),
		setFeedback = function(rumble) joystick:setVibration(rumble, rumble) end,
		getFeedback = function() return joystick:getVibration() end
	}
end

