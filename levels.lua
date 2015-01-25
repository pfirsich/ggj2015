levels = {}

currentLevel = nil

function registerLevel(filename) 
	local level = {
		name = "LEVELNAME",
		geometryFile = "GEOMETRYPATH",
		layers = {
			-- { file="media/images/Lvl11.png", parallax=1.0, mirror=false },
		},
		groundColor = {0,0,0},
		backgroundColor = {0, 0, 0},
		spawn = {0, 0},
		time = 30.0,
		setupCallback = nil,
		updateCallback = nil,
		drawBackgroundCallback = nil,
		finishCallback = nil
	}
	
	extendTable(loveDoFile(filename), level)
	assert(level.name, "Level not named")
	levels[#levels + 1] = level
end

function loadLevel(name)
	for i, level in ipairs(levels) do
		if level.name == name then
			currentLevel = level
			return
		end
	end
	error("Level '" .. name .. "' has not been registered.")
end

function setupLevel()
	if currentLevel == nil then
		error("Level has not been loaded.")
	end
	
	love.graphics.setBackgroundColor(unpack(currentLevel.backgroundColor))
	
	-- layers
	for i = 1,#currentLevel.layers do
		local layer = currentLevel.layers[i]
		
		if love.filesystem.isFile(layer.file .. ".cropped.png") then
			layer.image = love.graphics.newImage(layer.file .. ".cropped.png")
			layer.cropData = loveDoFile(layer.file .. ".cropped.lua")
		else
			layer.image = love.graphics.newImage(layer.file)
			layer.cropData = {top = 0, left = 0}
			layer.cropData.originalWidth = layer.image:getWidth()
			layer.cropData.originalHeight = layer.image:getHeight()
			layer.cropData.bottom = layer.cropData.originalHeight
			layer.cropData.right = layer.cropData.originalWidth
		end
	end
	mapSize = {currentLevel.layers[1].cropData.originalWidth, currentLevel.layers[1].cropData.originalHeight} -- HACK (put into level!)

	-- collision geometry
	collider:clear()
	currentLevel.shapes = {}
	
	local polygons = loveDoFile(currentLevel.geometryFile)
	
	local wallThickness = 10000
	table.insert(polygons, {0,mapSize[2],  0,0,  -wallThickness,0,  -wallThickness,mapSize[2]})
	table.insert(polygons, {mapSize[1],mapSize[2],  mapSize[1]+wallThickness,mapSize[2],  mapSize[1]+wallThickness,0,  mapSize[1],0})
	
	for i = 1, #polygons do
		local shape = collider:addPolygon(unpack(polygons[i]))
		collider:setPassive(shape)
		shape.g_type = "level"
		table.insert(currentLevel.shapes, polygons[i])
	end
	
	resetPlayerCollisionShapes()
	
	for i=1,#players do
		players[i].position = {currentLevel.spawn[1]+100*i, currentLevel.spawn[2]}
	end
	
	if currentLevel.setupCallback then
		currentLevel.setupCallback()
	end
end


function updateLevel()
	if currentLevel.updateCallback then
		currentLevel.updateCallback()
	end
end


function drawLevelBackground()
	if currentLevel.drawBackgroundCallback then
		currentLevel.drawBackgroundCallback()
	end
		
	for i=#currentLevel.layers, 1, -1 do
		local layer = currentLevel.layers[i]
		local yOffset = mapSize[2] - layer.cropData.originalHeight
		
		love.graphics.push()
		
		love.graphics.setColor(255,255,255,255)
		applyCameraTransforms(camera.position, camera.scale, layer.parallax)
		
		love.graphics.translate(0, yOffset)
		
		love.graphics.draw(layer.image, layer.cropData.left, layer.cropData.top)

		if layer.ground then
			love.graphics.setColor(unpack(layer.ground))
			love.graphics.rectangle("fill", -10000, layer.cropData.originalHeight-1, 100000, 100000)
			love.graphics.setColor(255, 255, 255)
		end
		
		love.graphics.translate(layer.cropData.originalWidth/2, layer.cropData.originalHeight/2)
		love.graphics.scale(-1.0, 1.0)
		love.graphics.translate(-layer.cropData.originalWidth/2, -layer.cropData.originalHeight/2)
		
		if layer.mirror then
			love.graphics.draw(layer.image, layer.cropData.left - layer.cropData.originalWidth + 5, layer.cropData.top)
			love.graphics.draw(layer.image, layer.cropData.left + layer.cropData.originalWidth - 5, layer.cropData.top)
		end
		
		love.graphics.pop()
	end
	

	if currentLevel.drawCallback then
		currentLevel.drawCallback()
	end
end

function drawLevelObjects()
	if false then
		love.graphics.setColor(255, 255, 255, 100)
		for i = 1, #currentLevel.shapes do
			love.graphics.polygon("fill", unpack(currentLevel.shapes[i]))
		end
	end
end


function finishLevel()
	if currentLevel.finishCallback then
		currentLevel.finishCallback()
	end
end