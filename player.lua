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

function cloneAnimations(animations)
	ret = {}
	for k, v in pairs(animations.frameSets) do
		ret[k] = v:clone()
	end
	ret.image = animations.image
	return ret
end

function addPlayer(color, hairColor, jacketColor, pantsColor, female, controller)
	--local shape = collider:addRectangle(0, 0, playerW / 4.0, playerH * 0.8)
	local shape = playerCollisonShape()
	shape.g_type = "player"
	shape.g_mtvSum = {0,0}
	shape.g_collisionCount = 0
	table.insert(players, {color = color, hairColor = hairColor, jacketColor = jacketColor, pantsColor = pantsColor, 
						female = female, controller = controller, position = {2000+200*#players,2500}, velocity = {0,0}, collisionShape = shape, 
						animations = cloneAnimations(playerAnimation), hairAnimations = cloneAnimations(playerHairAnimation),
						jacketAnimations = cloneAnimations(playerJacketAnimation), pantsAnimations = cloneAnimations(playerPantsAnimation),
						direction = "r", lastDirection = "r", animState = "stand", downCollision = false})
end

function updatePlayers()
	local updateAnimations = function(anims)
		for name, animation in pairs(anims) do
			if name ~= "image" then animation:update(simulationDt) end
		end
	end
	
	for i = 1, #players do
		local player = players[i]
		
		local move = player.controller.move()
		move = math.abs(move) > 0.2 and move * 900.0 or 0.0
		player.velocity[1] = player.velocity[1] + move * simulationDt

		-- gravity
		if not player.downCollision or player.velocity[2] > 90.0 then
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
		
		updateAnimations(player.animations)
		updateAnimations(player.hairAnimations)
		updateAnimations(player.pantsAnimations)
		updateAnimations(player.jacketAnimations)
		
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
	local flipAnims = function(anims) 
		for name, animation in pairs(anims) do
			if name ~= "image" then animation:flipH() end
		end
	end
	
	for i = 1, #players do
		local player = players[i]
		
		--player.collisionShape:draw()
		
		if player.direction ~= player.lastDirection then
			flipAnims(player.animations)
			flipAnims(player.hairAnimations)
			flipAnims(player.jacketAnimations)
			flipAnims(player.pantsAnimations)
		end
		
		local anim = player.animations[player.animState]
		local hairAnim = player.hairAnimations[player.animState]
		local pantsAnim = player.pantsAnimations[player.animState]
		local jacketAnim = player.jacketAnimations[player.animState]
		
		love.graphics.setColor(255, 255, 255)
		player.lastDirection = player.direction
		local yOffset = 10
		anim:draw(player.animations.image, player.position[1] - playerW/2, player.position[2] - playerH/2 + yOffset)
		local hairOffset = player.direction == "r" and 53 or 24
		love.graphics.setColor(unpack(player.hairColor))
		hairAnim:draw(player.hairAnimations.image, player.position[1] - playerW/2 + hairOffset, player.position[2] - playerH/2 + 10 + yOffset)
		
		love.graphics.setColor(unpack(player.pantsColor))
		pantsAnim:draw(player.pantsAnimations.image, player.position[1] - playerW/2, player.position[2] - playerH/2 + yOffset - 6)
		
		love.graphics.setColor(unpack(player.jacketColor))
		jacketAnim:draw(player.jacketAnimations.image, player.position[1] - playerW/2, player.position[2] - playerH/2 + yOffset - 10)
	end
end