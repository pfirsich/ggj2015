
function keyboardController(left, right, jump, interact, shove, kick)
	return {
		move = getFloatInputFromTwoBinaryInputs(keyboardCallback(right), keyboardCallback(left)),
		jump = watchBinaryInput(keyboardCallback(jump)),
		interact = watchBinaryInput(keyboardCallback(interact)),
		shove = watchBinaryInput(keyboardCallback(shove)),
		kick = watchBinaryInput(keyboardCallback(kick)),
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
		kick = watchBinaryInput(joystickButtonCallback(joystick, "y")),
		pause = watchBinaryInput(joystickButtonCallback(joystick, "start")),
		setFeedback = function(rumble) joystick:setVibration(rumble, rumble) end,
		getFeedback = function() return joystick:getVibration() end
	}
end

