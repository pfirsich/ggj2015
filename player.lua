players = {}

function playerCollisonShape()
	local points = {}
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
	
	local polygon = collider:addPolygon(unpack(points))
	
	polygon.g_type = "player"
	polygon.g_mtvSum = {0,0}
	polygon.g_collisionCount = 0
	
	return polygon
end

function cloneAnimations(animations)
	local ret = {}
	for k, v in pairs(animations.frameSets) do
		ret[k] = v:clone()
	end
	ret.image = animations.image
	return ret
end

function resetPlayerCollisionShapes()
	for i=1,#players do
		local player = players[i]
		player.collisionShape = playerCollisonShape()
	end
end

function addPlayer(controller)
	--local shape = collider:addRectangle(0, 0, playerW / 4.0, playerH * 0.8)
	local shape = playerCollisonShape()
	local hairColors = {{221, 223, 17}, {139, 49, 49}, {96, 96, 96}, {197, 32, 32}}
	
	local r = love.math.random()
	local index = 4
	if r < 0.3 then 
		index = 1
	elseif r < 0.6 then
		index = 2
	elseif r < 0.9 then
		index = 3
	end
	
	local hairColor = hairColors[index]
	local jacketColor = {love.math.random(255),love.math.random(255),love.math.random(255)}
	local pantsColor = love.math.random() < 0.5 and {20,20,200} or {150,75,0}

	table.insert(players, {
			color = color, 
			hairColor = hairColor, 
			jacketColor = jacketColor, 
			pantsColor = pantsColor, 
			female = female, 
			controller = controller, 
			position = {1000+200*#players,100}, 
			velocity = {0,0}, 
			collisionShape = shape, 
			animations = cloneAnimations(playerAnimation), 
			hairAnimations = cloneAnimations(playerHairAnimation),
			jacketAnimations = cloneAnimations(playerJacketAnimation), 
			pantsAnimations = cloneAnimations(playerPantsAnimation),
			direction = "r", 
			lastDirection = "r", 
			animState = "stand", 
			downCollision = false, 
			stunStart = -math.huge,
			stunned = false,
			nextAnimUpdate = -math.huge,
			alive = true
		})
end

function removePlayer(player)
	player.alive = false
end

function updatePlayers()
	local updateAnimations = function(anims)
		for name, animation in pairs(anims) do
			if name ~= "image" then animation:update(simulationDt) end
		end
	end
	
	for i = 1, #players do
		local player = players[i]
		
		if player.alive then
		
			local stunTime = 0.7
			player.stunned = false -- not (getStateVar(globalState, "time") - player.stunStart > stunTime)
			
			-- move
			local move = player.controller.move()
			move = math.abs(move) > 0.2 and move * 1800.0 or 0.0
			if not player.stunned then
				player.velocity[1] = player.velocity[1] + move * simulationDt
			end

			-- gravity
			if not player.downCollision or player.velocity[2] > 450.0 then
				player.velocity[2] = player.velocity[2] + 3000.0 * simulationDt
			end
			
			-- jumping
			if player.controller.jump().pressed and player.downCollision and not player.stunned then
				player.velocity[2] = -2400.0
				lush.play("jump.wav", {tags={"ingame"}})
			end
			
			-- shoving
			if player.controller.shove().pressed and not player.stunned then
				for i, other in ipairs(players) do
					if other ~= player then
						local rel = vsub(other.position, player.position)
						local relLen = vnorm(rel)
						local dirVec = player.direction == "l" and {-1, 0} or {1, 0}
						if relLen < 80.0 and rel[1] * dirVec[1] / relLen > math.cos(35) and not other.stunned then
							other.stunStart = getStateVar(globalState, "time")
							other.velocity = vadd(other.velocity, vmul(dirVec, 1500.0))
							lush.play("hurt.wav", {tags={"ingame"}})
							spawnParticles(5, other.position, dirVec, bloodParticles)
							spawnParticles(5, other.position, dirVec, bloodSprayParticles)
							
							other.animState = "stun"
							other.nextAnimUpdate = getStateVar(globalState, "time") + stunTime
						end
					end
				end
				player.animState = "shove"
				player.nextAnimUpdate = getStateVar(globalState, "time") + 0.1
			end
			
			-- kicking
			if player.controller.kick().pressed and not player.stunned then
				for i, other in ipairs(players) do
					if other ~= player then
						local rel = vsub(other.position, player.position)
						local relLen = vnorm(rel)
						local dirVec = player.direction == "l" and {-1, 0} or {1, 0}
						if relLen < 80.0 and rel[1] * dirVec[1] / relLen > math.cos(35) and not other.stunned then
							other.stunStart = getStateVar(globalState, "time")
							local kickAngle = -60.0 / 180.0 * math.pi
							dirVec = {math.cos(kickAngle) * dirVec[1], math.sin(kickAngle)}
							other.velocity = vadd(other.velocity, vmul(dirVec, 2000.0))
							lush.play("hurt.wav", {tags={"ingame"}})
							spawnParticles(5, other.position, dirVec, bloodParticles)
							spawnParticles(5, other.position, dirVec, bloodSprayParticles)
							
							other.animState = "stun"
							other.nextAnimUpdate = getStateVar(globalState, "time") + stunTime
						end
					end
				end
				player.animState = "kick" -- TODO KICK
				player.nextAnimUpdate = getStateVar(globalState, "time") + 0.1
			end
			
			-- friction and integration
			player.velocity = vsub(player.velocity, vmul(player.velocity, 3.0 * simulationDt))
			
			-- intergration
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
			
			if player.nextAnimUpdate < getStateVar(globalState, "time") then
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
		
		if player.alive then
			-- player.collisionShape:draw()
			
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
			local yOffset = player.stunned and 30 or 10
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
end