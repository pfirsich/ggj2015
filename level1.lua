-- HACK (PRESENTATION)

local imageAngle = -0.655
local imageInvSlope = -math.tan(imageAngle)

function setupLevel()
	mapTime = 3000.0
	roquetteAuspuffAnimation = makeAnimations("media/images/rocketburst.png", 160, {burst = {frames = {1,2,3}, interval = 0.1}})
	
	rockets = {}
	rocketCount = 100
	rocketImage = love.graphics.newImage("media/images/rocket.png")
	for i = 1, rocketCount do
		local rocket = {position = {(love.math.random() - 1/10)*mapSize[1], (love.math.random() - 1/2)*mapSize[2]*0.3}, parallax = love.math.random() * 0.3 + 0.3}
		rocket.speed = (0.72*mapSize[2] - rocket.position[2]) / mapTime
		table.insert(rockets, rocket)
	end
	
	setupEscapeRocket(4400, 890)
--	setupMobileToilet(2294, 3836)
	setupMobileToilet(2890, 1380)
	setupMobileToilet(3050, 1380)
end

function setupMobileToilet(x,y)
	local image = love.graphics.newImage("media/images/toytoy.png")
	
	local delta = {0,0}
	local drawCallback = function (escape) -- draw callback
		love.graphics.draw(image, escape.position[1], escape.position[2]-290)
	end
	local activateCallback = function (escape, player) -- activate callback
		removePlayer(player)
	end
	
	local escape = addEscape(x, y, "It's just a mobile toilet,\nbut better than nothing!\nPress (X) to enter.", drawCallback, activateCallback)
	
	escape.relativeMessagePosition = {100, 0}
	escape.height = 100
	escape.width = 150
	escape.activateRadius = 150
end


function setupEscapeRocket(x,y)
	local rocket = love.graphics.newImage("media/images/escaperocket.png")
	local pad = love.graphics.newImage("media/images/emptyescaperocket.png")
	
	local delta = {0,0}
	local drawCallback = function (escape) -- draw callback
		love.graphics.draw(rocket, escape.position[1]-250+delta[1], escape.position[2]-370+delta[2])
		love.graphics.draw(pad, escape.position[1]-250, escape.position[2]-370)
	end
	local activateCallback = function (escape, player) -- activate callback
		addCallback(function ()
			local v = {232, -255}
			local f = 1.5
			delta[1] = delta[1] + v[1]*simulationDt*f
			delta[2] = delta[2] + v[2]*simulationDt*f
			return true
		end)
	
		removePlayer(player)
	end
		
	local escape = addEscape(x, y, "An old, rusty rocket.\n Press (X) to use.", drawCallback, activateCallback)
	
	escape.relativeMessagePosition = {100, -100}
	escape.height = 90
	escape.width = 200
	escape.activateRadius = 150
end

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
