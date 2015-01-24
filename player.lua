players = {}

function addPlayer(color, female, controller)
	local shape = collider:addRectangle(0, 0, playerW, playerH)
	shape.g_type = "player"
	table.insert(players, {color = color, female = female, controller = controller, position = {0,0}, velocity = {0,0}, collisionShape = shape, animations = {walk = playerWalkAnimation:clone(), stand = playerStandAnimation:clone(), jump = playerJumpAnimation:clone(), fall = playerFallAnimation:clone()}, direction = "r", lastDirection = "r", animState = "stand", downCollision = false})
end

function updatePlayers()
	for i = 1, #players do
		local player = players[i]
		local move = player.controller.move()
		
		move = math.abs(move) > 0.2 and move * 600.0 or 0.0
		player.velocity = vadd(player.velocity, {move * simulationDt, 50.0})
		
		print(player.controller.jump().pressed, player.downCollision)
		if player.controller.jump().pressed and player.downCollision then
			player.velocity[2] = -600.0
		end
		
		player.velocity = vsub(player.velocity, vmul(player.velocity, 0.1))
		player.position = vadd(player.position, vmul(player.velocity, simulationDt))
		
		player.collisionShape:moveTo(unpack(player.position))
		player.collisionShape.g_mtvSum = {0,0}
		player.collisionShape.g_collisionCount = 0
		collider:update(0)
		
		if player.collisionShape.g_collisionCount > 0 then
			player.collisionShape.g_mtvSum = vmul(player.collisionShape.g_mtvSum, 1/player.collisionShape.g_collisionCount)
			player.position = vadd(player.position, player.collisionShape.g_mtvSum)
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
		if player.velocity[2] > jumpThresh then
			player.animState = "jump"
		elseif player.velocity[2] < -fallThresh then
			player.animState = "fall"
		end
	end
end

function drawPlayers()
	for i = 1, #players do
		local player = players[i]
		--love.graphics.setColor(unpack(player.color))
		--love.graphics.rectangle("fill", player.position[1] - playerW/2, player.position[2] - playerH/2, playerW, playerH)
		love.graphics.push()
		local anim = player.animations[player.animState]
		if player.direction ~= player.lastDirection then
			for name, animation in pairs(player.animations) do
				animation:flipH()
			end
		end
		player.lastDirection = player.direction
		anim:draw(playerAnimationStrip, player.position[1] - playerW/2, player.position[2] - playerH/2)
		love.graphics.pop()
	end
end