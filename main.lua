require "lush"
require "states"
require "input"
require "controller"
require "math_vec"
require "update"
require "draw"
require "player"
require "escape"
require "callbacks"
require "collision"
require "utility"
require "speechbubble"
require "particles"
require "levels"
HC = require "hardoncollider"
anim8 = require "anim8"

function loadConfig(filename)
	local Config = {}
	local f, err = loadstring(love.filesystem.read(filename))
	if f == nil then
		transitionState(globalState, "error")
		setStateVar(globalState, "message", filename .. " could not be interpreted. Error message: " .. err)
	else
		Config = f()
		if Config == nil then
			transitionState("error")
			setStateVar(globalState, "message", filename .. " corrupted.")
		end
	end
	
	xRes, yRes = Config.width, Config.height
	if xRes == nil then xRes = 1024 end
	if yRes == nil then yRes = 768 end
	
	local flags = {}
	local toExtract = {fullscreen = 1, fullscreentype = 1, vsync = 1, fsaa = 1, 
								borderless = 1, centered = 1, display = 1, highdpi = 1, srgb = 1, x = 1, y = 1}
	for k, v in pairs(toExtract) do
		if Config[k] then flags[k] = Config[k] end
	end
	
	love.window.setMode(xRes, yRes, flags)
	
	return Config
end

function makeAnimations(filename, frameWidth, frames)
	local anims = {}
	anims.image = love.graphics.newImage(filename)
	anims.frameWidth = frameWidth
	anims.grid = anim8.newGrid(frameWidth, anims.image:getHeight(), anims.image:getWidth(), anims.image:getHeight())
	anims.frameSets = {}
	for name, frame in pairs(frames) do
		local realFrames = {}
		for i, f in ipairs(frame.frames) do
			realFrames[#realFrames + 1] = f
			realFrames[#realFrames + 1] = 1
		end
		anims.frameSets[name] = anim8.newAnimation(anims.grid:getFrames(unpack(realFrames)), frame.interval)
	end
	return anims
end

function love.load()
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	
	love.mouse.setVisible(false)
	
	smallFont = love.graphics.newFont("media/Anke.ttf", 24)
	mediumFont = love.graphics.newFont("media/Anke.ttf", 48)
	hugeFont = love.graphics.newFont("media/Anke.ttf", 200)
	hugeMonospaceFont = love.graphics.newFont("media/DroidSansMono.ttf", 200)
	
	-- dirty, dirty, dirty to support my crappy old controllers
	local gpMap = function(...) love.joystick.setGamepadMapping("6d0418c2000000000000504944564944", ...) end
	gpMap("start", "button", 10)
	gpMap("a", "button", 2)
	gpMap("x", "button", 1)
	gpMap("y", "button", 4)
	gpMap("b", "button", 3)
	gpMap("leftx", "axis", 1)
	gpMap("lefty", "axis", 2)
	
	Config = loadConfig("config.cfg")
	lush.setDefaultVolume(Config.defaultVolume or 1.0)
	lush.setPath("media/sounds/")
	
	camera = {position = {0,0}, scale = 1.0}
	
	collider = HC(100, collisionStart, nil)
	
		-- backgrounds
	love.graphics.setBackgroundColor(0,0,0)
	
	-- particles
	initParticles()
	bloodParticles = {spread = 20 / 180 * math.pi, image = love.graphics.newImage("media/images/blood.png"), lifetime = 0.4, 
							friction = 0.01, angularVelocity = 0.8, gravity = -1000,
							orientationSpread = math.pi, startSizeX = 0.09, endSizeX = 0.25, startSizeY = 0.09, endSizeY = 0.25,
							startColor = {100, 50, 50, 255}, endColor = {100, 50, 50, 0}, speed = 400, speedVariance = 50}
	bloodSprayParticles = {spread = 90 / 180 * math.pi, image = love.graphics.newImage("media/images/blood.png"), lifetime = 0.4, 
							friction = 0.00, angularVelocity = 0.0, gravity = -3000.0,
							orientationSpread = 0, startSizeX = 0.06, endSizeX = 0.06, startSizeY = 0.02, endSizeY = 0.02, 
							startColor = {255, 255, 255, 255}, endColor = {255, 255, 255, 100}, speed = 800, speedVariance = 300}
	
	-- animations
	local walkAnimPeriod = 0.07
	
	playerW = 160
	playerH = 216
	
	local playerFrames = {walk = {frames = {6, 5, 2, 3, 4}, interval = walkAnimPeriod}, stand = {frames = {1}, interval = 1.0}, 
										fall = {frames = {7, 8}, interval = 0.05}, jump = {frames = {9,10}, interval = 0.05}, shove = {frames = {11}, interval = 1.0}, 
										stun = {frames = {7}, interval = 1.0}, kick = {frames = {4}, interval = 1.0}}
									
	playerAnimation = makeAnimations("media/images/character.png", playerW, playerFrames)
	playerJacketAnimation = makeAnimations("media/images/jackets.png", playerW, playerFrames)
	playerPantsAnimation = makeAnimations("media/images/pants.png", playerW, playerFrames)
	
	playerHairAnimation = makeAnimations("media/images/hair.png", 83, {
			walk = {frames = {'1-2',3,'2-1'}, interval = walkAnimPeriod}, stand = {frames = {3}, interval = 1.0},
			fall = {frames = {'4-5'}, interval = 0.08}, jump = {frames = {'6-7'}, interval = 0.15}, shove = {frames = {3}, interval = 1.0}, 
			stun = {frames = {4}, interval = 1.0}, kick = {frames = {1}, interval = 1.0}})
	
	-- blonde, black, brown, red
	local hairColors = {{221, 223, 17}, {139, 49, 49}, {96, 96, 96}, {197, 32, 32}}
	for i, playerController in ipairs(Config.playerControllers) do
		-- hair color
		local r = love.math.random()
		local index = 4
		if r < 0.3 then 
			index = 1
		elseif r < 0.6 then
			index = 2
		elseif r < 0.9 then
			index = 3
		end
		
		local jacketColor = {love.math.random(255),love.math.random(255),love.math.random(255)}
		local pantsColor = love.math.random() < 0.5 and {20,20,200} or {150,75,0}
		
		addPlayer(hairColors[index], jacketColor, pantsColor, playerController)
	end
	
	-- sounds
	lush.play("theme3.xm", {tags={"background"}, looping = true})
	
	registerLevel("level1.lua")
	
	loadLevel("Dev Level") -- hack (hardgecoded)
	
	setupLevel()
	
	globalState = {
		["gameloop"] = {update = updateGame, draw = drawGame, onEnter = nil, onExit = nil, time = 0},
		["paused"] = {update = updatePaused, draw = drawPaused, onEnter = nil, time = 0},
		["error"] = {update = nil, draw = drawError, onEnter = nil, time = 0},
		["levelEnd"] = {update = nil, draw = drawLevelEnd, onEnter = nil, time = 0},
		["menu"] = {update = 
	}
	transitionState(globalState, "gameloop")
end

function love.quit()
	local dontClose = false
	return dontClose
end

function love.run()
	if love.math then
		love.math.setRandomSeed(os.time())
		for i=1,3 do love.math.random() end
	end

	if love.event then
		love.event.pump()
	end

	simulationTime = love.timer.getTime()
	simulationDt = 1.0/30.0
	timeStepDt = simulationDt

	if love.load then love.load(arg) end
	
	local nextSimFPS = love.timer.getTime()
	local simFPSCount = 0
	simFPS = 0

   -- Main loop time.
	while true do
		if nextSimFPS < love.timer.getTime() then
			nextSimFPS = love.timer.getTime() + 1.0
			simFPS = simFPSCount
			simFPSCount = 0
		end
		
		while simulationTime < love.timer.getTime() do
			local start = love.timer.getTime()
			
			simFPSCount = simFPSCount + 1
			simulationTime = simulationTime + timeStepDt
			
			-- Process events.
			if love.event then
				love.event.pump()
				for e,a,b,c,d in love.event.poll() do
					if e == "quit" then
						if not love.quit or not love.quit() then
							if love.audio then
								love.audio.stop()
							end
							return
						end
					end
					love.handlers[e](a,b,c,d)
				end
			end

			tickSimulation()
			
			tickFreq = 1.0 / (love.timer.getTime() - start)
			print(tickFreq)
		end
		
		lush.update()

		if love.window and love.graphics and love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end