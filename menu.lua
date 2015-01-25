menuType = "player"
local selectedLevel = nil

function updateMenu()
	logoScale = 0.8 * xRes/1920
	titleScale = 0.4 * yRes/1080
	
	local topMargin = 0 + gameTitle:getHeight() * titleScale - 100
	local playerX = xRes - 300
	if menuType == "player" then
		if menuInputs.space().pressed then 
			local there = false
			for i, player in ipairs(players) do
				if player.name == "Keyboard" then there = true end
			end
			if not there then
				addPlayer(keyboardController("left", "right", "up", " ", "lalt", "rctrl"))
				players[#players].name = "Keyboard"
			else
				spawnBubble("Only one keyboard player allowed", {xRes/2, yRes/2}, 2.0)
			end
		end
		for joystick, input in pairs(joystickAMap) do
			if input().pressed then
				local there = false
				for i, player in ipairs(players) do
					if player.name == "Joystick " .. tostring(joystick) then there = true end
				end
				if not there then
					addPlayer(joystickController(joystick))
					players[#players].name = "Joystick " .. tostring(joystick)
				end
			end
		end
		
		if menuInputs.enter().pressed then
			menuType = "level"
			selectedLevel = 1
		end
	else
		if menuInputs.enter().pressed then
			loadLevel(levels[selectedLevel].name)
			setupLevel()
			transitionState(globalState, "gameloop")
		end
		
		if menuInputs.up().pressed then
			selectedLevel = selectedLevel - 1
		end
		
		if menuInputs.down().pressed then
			selectedLevel = selectedLevel + 1
		end
		
		if selectedLevel < 1 then selectedLevel = 1 end
		if selectedLevel > #levels then selectedLevel = #levels end
	end
end

function drawMenu()
	love.graphics.setBackgroundColor(50, 50, 50, 255)
	if menuType == "player" then
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.draw(gameLogo, 0, yRes/2 - gameLogo:getHeight()/2 * logoScale, 0, logoScale, logoScale)
		love.graphics.draw(gameTitle, xRes - gameTitle:getWidth() * titleScale, 0, 0, titleScale, titleScale)
		love.graphics.setFont(smallFont)
		love.graphics.setColor(200, 200, 200, 255)
		local width = xRes - gameLogo:getWidth()*logoScale - gameTitle:getWidth()*titleScale
		love.graphics.printf("Press the (A) key on your controller to join the game or the space key to add a keyboard controlled player.\nPress the enter key to choose a map.", xRes/2-width/2, 35 * xRes/1920, width, "center")
		
		for i, player in ipairs(players) do
			local x = xRes / 2 + (i % 2 == 1 and -200 or 50) + 100
			player.position = {x, math.floor((i-1) / 2) * 200 + 250}
			love.graphics.setColor(200, 200, 200, 255)
			love.graphics.printf(player.name, player.position[1] + 50, player.position[2], 400, "left")
		end
		drawPlayers()
	else
		love.graphics.setFont(mediumFont)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.printf("Use the arrow keys to choose a level and the enter key to start it.", 20, 20, xRes - 40, "center")
		for i, level in ipairs(levels) do
			love.graphics.setColor(255, 255, 255, 255)
			local y = 200 + 80 * i
			love.graphics.printf(level.name, 150, y, 1000, "left")
			if selectedLevel == i then
				love.graphics.setColor(255, 0, 0, 255)
				love.graphics.rectangle("fill", 100, y + 5, 25, 25)
			end
		end
	end
	camera.scale = 1.0
	camera.position = {0,0}
	drawBubbles()
end