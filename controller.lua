
function dummyController()
	return {
		pause = watchBinaryInput(dummyButtonCallback(false)), 
		shootA = watchBinaryInput(dummyButtonCallback(false)),
		shootB = watchBinaryInput(dummyButtonCallback(false)),
		dash = watchBinaryInput(dummyButtonCallback(false)),
		moveX = function() return 0.0 end,
		moveY = function() return 0.0 end,
		aimX = function() return 0.0 end,
		aimY = function() return 0.0 end
	}
end

function getKeyboardController()
	return {
		pause = watchBinaryInput(keyboardCallback("escape")), 
		shootA = watchBinaryInput(mouseButtonCallback("l")),
		shootB = watchBinaryInput(mouseButtonCallback("r")),
		dash = watchBinaryInput(keyboardCallback("lshift")),
		moveX = getFloatInputFromTwoBinaryInputs(keyboardCallback("d"), keyboardCallback("a")),
		moveY = getFloatInputFromTwoBinaryInputs(keyboardCallback("s"), keyboardCallback("w")),
		aimX = function() return screenToWorld({love.mouse.getX(), 0})[1] end,
		aimY = function() return screenToWorld({0, love.mouse.getY()})[2] end,
		setFeedback = function(v) end,
		getFeedback = function() return 0.0 end,
		relativeAim = true
	}
end

function getJoystickController(joystick)
	return {
		pause = watchBinaryInput(joystickButtonCallback(joystick, "start")),
		shootA = watchBinaryInput(combineCallbacksOR(getBinaryInputFromAxis(joystick, "rightx", 0.4), getBinaryInputFromAxis(joystick, "righty", 0.4))),
		shootB = watchBinaryInput(joystickButtonCallback(joystick, "rightshoulder")),
		dash = watchBinaryInput(joystickButtonCallback(joystick, "leftshoulder")),
		moveX = getJoystickAxisCallback(joystick, "leftx"),
		moveY = getJoystickAxisCallback(joystick, "lefty"),
		aimX = getJoystickAxisCallback(joystick, "rightx"),
		aimY = getJoystickAxisCallback(joystick, "righty"),
		setFeedback = function(rumble) joystick:setVibration(rumble, rumble) end,
		getFeedback = function() return joystick:getVibration() end,
		relativeAim = false
	}
end

