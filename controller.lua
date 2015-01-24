
function keyboardController(left, right, jump, interact, shove)
	return {
		move = getFloatInputFromTwoBinaryInputs(keyboardCallback(right), keyboardCallback(left)),
		jump = watchBinaryInput(keyboardCallback(jump)),
		interact = watchBinaryInput(keyboardCallback(interact)),
		shove = watchBinaryInput(keyboardCallback(shove)),
		pause = watchBinaryInput(keyboardCallback("escape")),
		salto = watchBinaryInput(keyboardCallback("rctrl")),
		setFeedback = function(v) end,
		getFeedback = function() return 0.0 end,
	}
end

function joystickController(joystick)
	joystick = love.joystick.getJoysticks()[joystick]
	return {
		move = getJoystickAxisCallback(joystick, "leftx"),
		jump = watchBinaryInput(joystickButtonCallback(joystick, "a")),
		interact = watchBinaryInput(joystickButtonCallback(joystick, "x")),
		shove = watchBinaryInput(joystickButtonCallback(joystick, "b")),
		pause = watchBinaryInput(joystickButtonCallback(joystick, "start")),
		salto = watchBinaryInput(joystickButtonCallback(joystick, "leftshoulder")),
		setFeedback = function(rumble) joystick:setVibration(rumble, rumble) end,
		getFeedback = function() return joystick:getVibration() end
	}
end

