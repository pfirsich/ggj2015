function clamp(v, a, b)
	return math.max(math.min(v, b), a)
end

function loveDoFile(filename)
	return assert(loadstring(love.filesystem.read(filename)))()
end

local imageAngle = -0.655
local imageInvSlope = -math.tan(imageAngle)

function updateRockets()
	
	for i = 1, rocketCount do
		rockets[i].position = vadd(rockets[i].position, vmul({imageInvSlope, 1.0}, rockets[i].speed * simulationDt))
	end
	roquetteAuspuffAnimation.frameSets.burst:update(simulationDt)
end

function drawRockets()
	love.graphics.setColor(255, 255, 255)
	for i = 1, rocketCount do
		love.graphics.push()
		applyCameraTransforms(camera.position, camera.scale, rockets[i].parallax)
		love.graphics.draw(rocketImage, rockets[i].position[1], rockets[i].position[2])
		roquetteAuspuffAnimation.frameSets.burst:draw(roquetteAuspuffAnimation.image, rockets[i].position[1] - 150, rockets[i].position[2] - 70, imageAngle)
		love.graphics.pop()
	end
end
