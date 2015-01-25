do
	local mapTime = 120
	
	local imageAngle = -0.655
	local imageInvSlope = -math.tan(imageAngle)
	
	local function setupEscapeRocket(x,y)
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
	
	
	local function setupLevel()
		engineAnimation = makeAnimations("media/images/rocketburst.png", 160, {burst = {frames = {1,2,3}, interval = 0.1}})
		
		rockets = {}
		rocketCount = 100
		rocketImage = love.graphics.newImage("media/images/rocket.png")
		for i = 1, rocketCount do
			local rocket = {position = {(love.math.random() - 1/10)*mapSize[1], (love.math.random() - 1/2)*mapSize[2]*0.3}, parallax = love.math.random() * 0.3 + 0.3}
			rocket.speed = (0.95*mapSize[2] - rocket.position[2]) / mapTime
			table.insert(rockets, rocket)
		end
		
		
		setupEscapeRocket(1685, 470)
	end

	local function updateRockets()
		for i = 1, rocketCount do
			rockets[i].position = vadd(rockets[i].position, vmul({imageInvSlope, 1.0}, rockets[i].speed * simulationDt))
		end
		engineAnimation.frameSets.burst:update(simulationDt)
	end

	local function drawRockets()
		love.graphics.setColor(255, 255, 255)
		for i = 1, rocketCount do
			love.graphics.push()
			applyCameraTransforms(camera.position, camera.scale, rockets[i].parallax)
			love.graphics.draw(rocketImage, rockets[i].position[1], rockets[i].position[2])
			engineAnimation.frameSets.burst:draw(engineAnimation.image, rockets[i].position[1] - 150, rockets[i].position[2] - 70, imageAngle)
			love.graphics.pop()
		end
	end
	
	local function explosion()
		lush.play("explosion.wav") 
	end

	return {
		name = "Plant Level",
		geometryFile = "media/geo_level2.lua",
		layers = {
			{ file="media/images/Lvl21.png", parallax=1.0, mirror=false, ground={215,164,69} },
			{ file="media/images/Lvl22.png", parallax=0.99, mirror=false },
			{ file="media/images/Lvl23.png", parallax=0.98, mirror=false },
			{ file="media/images/Lvl24.png", parallax=0.98, mirror=false, ground={82,63,27} },
			{ file="media/images/Lvl25.png", parallax=0.98, mirror=false, ground={82,63,27} },
			{ file="media/images/Lvl14.png", parallax=0.4, mirror=true, ground={108,83,36} },
			{ file="media/images/Lvl15.png", parallax=0.3, mirror=true, ground={82,63,27} },
		},
		groundColor = {108, 83, 36},
		backgroundColor = {33, 7, 0},
		spawn = {100, 4700},
		time = mapTime,
		setupCallback = setupLevel,
		updateCallback = updateRockets,
		drawBackgroundCallback = drawRockets,
		finishCallback = explosion
	}	
end
