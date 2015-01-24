players = {}

function playerCollisonShape()
	points = {}
	local segments = 5
	local width = playerW * 0.3
	local height = playerH * 0.85
	local radius = width / 2
	for i = 0, segments do
		points[#points + 1] = math.cos(i/segments * math.pi) * radius
		points[#points + 1] = math.sin(i/segments * math.pi) * radius
	end
	points[#points + 1] = -width / 2
	points[#points + 1] = -height
	
	points[#points + 1] = width / 2
	points[#points + 1] = -height
	
	return collider:addPolygon(unpack(points))
end

function addPlayer(color, female, controller)
	--local shape = collider:addRectangle(0, 0, playerW / 4.0, playerH * 0.8)
	local shape = playerCollisonShape()
	shape.g_type = "player"
	table.insert(players, {color = color, female = female, controller = controller, 
						position = {2000+100*#players,2500}, velocity = {0,0}, collisionShape = shape, 
						animations = {	walk = playerWalkAnimation:clone(), stand = playerStandAnimation:clone(), 
											jump = playerJumpAnimation:clone(), fall = playerFallAnimation:clone()}, 
						direction = "r", lastDirection = "r", animState = "stand", downCollision = false})
end

function updatePlayers()
	for i = 1, #players do
		local player = players[i]
		
		local move = player.controller.move()
		move = math.abs(move) > 0.2 and move * 600.0 or 0.0
		player.velocity[1] = player.velocity[1] + move * simulationDt

		-- gravity
		print(player.downCollision, player.velocity[2])
		if not player.downCollision or player.velocity[2] > 50.0 then
			player.velocity[2] = player.velocity[2] + 1800.0 * simulationDt
		end
		
		-- jumping
		if player.controller.jump().pressed and player.downCollision then
			player.velocity[2] = -1400.0
		end
		
		-- friction and integration
		player.velocity = vsub(player.velocity, vmul(player.velocity, 3.0 * simulationDt))
		player.position = vadd(player.position, vmul(player.velocity, simulationDt))
		
		-- collision resolution
		player.collisionShape:moveTo(unpack(player.position))
		player.collisionShape.g_mtvSum = {0,0}
		player.collisionShape.g_collisionCount = 0
		collider:update(0)
		
		if player.collisionShape.g_collisionCount > 0 then
			player.collisionShape.g_mtvSum = vmul(player.collisionShape.g_mtvSum, 1/player.collisionShape.g_collisionCount)
			player.position = vadd(player.position, vmul(player.collisionShape.g_mtvSum, 1.0 - 1.0 / vnorm(player.collisionShape.g_mtvSum)))
		end
		player.collidingX = math.abs(player.collisionShape.g_mtvSum[1]) > 0.1
		player.collidingY = math.abs(player.collisionShape.g_mtvSum[2]) > 0.1
		player.downCollision = player.collisionShape.g_mtvSum[2] < -0.1
		
		-- adjust velocity according to collision e.g. project velocity on vector orthogonal to mtv
		-- so the part of the velocity which is along the mtv is removed
		if player.collidingX or player.collidingY then
			local orthoMTV = {player.collisionShape.g_mtvSum[2], -player.collisionShape.g_mtvSum[1]}
			orthoMTV = vnormed(orthoMTV)
			player.velocity = vmul(orthoMTV, vdot(orthoMTV, player.velocity))
		end
		
		for name, animation in pairs(player.animations) do
			animation:update(simulationDt)
		end
		
		-- horizontal animation
		local walkThresh = 30
		if player.velocity[1] > walkThresh then
			player.animState = "walk"
			player.direction = "r" 
		elseif player.velocity[1] < -walkThresh then
			player.animState = "walk"
			player.direction = "l" 
		else
			if player.animState ~= "stand" then player.animState = "stand" end
		end
		
		-- vertical animation
		local jumpThresh = 20
		local fallThresh = 20
		if player.velocity[2] > jumpThresh and not player.downCollision then
			player.animState = "jump"
		elseif player.velocity[2] < -fallThresh and not player.downCollision then
			player.animState = "fall"
		end
	end
end

function drawPlayers()
	for i = 1, #players do
		local player = players[i]
		
		player.collisionShape:draw()
		
		love.graphics.push()
		local anim = player.animations[player.animState]
		if player.direction ~= player.lastDirection then
			for name, animation in pairs(player.animations) do
				animation:flipH()
			end
		end
		player.lastDirection = player.direction
		anim:draw(playerAnimationStrip, player.position[1] - playerW/2, player.position[2] - playerH/2 + 10)
		love.graphics.pop()
	end
end