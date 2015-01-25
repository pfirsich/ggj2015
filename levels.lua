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
	levels[level.name] = level
end

function loadLevel(name)
	if levels[name] ~= nil then
		currentLevel = levels[name]
	else
		error("Level '" .. name .. "' has not been registered.")
	end
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
			layer.cropData.originalWidth = bgLayers[i].image:getWidth()
			layer.cropData.originalHeight = bgLayers[i].image:getHeight()
			layer.cropData.bottom = bgLayers[i].cropData.originalHeight
			layer.cropData.right = bgLayers[i].cropData.originalWidth
		end
	end
	mapSize = {currentLevel.layers[1].cropData.originalWidth, currentLevel.layers[1].cropData.originalHeight} -- HACK (put into level!)

	-- collision geometry
	collider:clear()
	currentLevel.shapes = {}
	
	local polygons = loveDoFile(currentLevel.geometryFile)
	
	local wallThickness = 50
	table.insert(polygons, {0,mapSize[2],  0,0,  -wallThickness,0,  -wallThickness,mapSize[2]})
	table.insert(polygons, {mapSize[1],mapSize[2],  mapSize[1]+wallThickness,mapSize[2],  mapSize[1]+wallThickness,0,  mapSize[1],0})
	
	for i = 1, #polygons do
		local shape = collider:addPolygon(unpack(polygons[i]))
		collider:setPassive(shape)
		shape.g_type = "level"
		table.insert(currentLevel.shapes, polygons[i])
	end
	
	resetPlayerCollisionShapes()
	
	if currentLevel.setupCallback then
		currentLevel.setupCallback()
	end
end


function updateLevel()
	if currentLevel.updateCallback then
		currentLevel.updateCallback()
	end
end


function drawLevel()
	if currentLevel.drawBackgroundCallback then
		currentLevel.drawBackgroundCallback()
	end
	
	for i=#currentLevel.layers, 1, -1 do
		local layer = currentLevel.layers[i]
		
		love.graphics.push()
		
		love.graphics.setColor(255,255,255,255)
		applyCameraTransforms(camera.position, camera.scale, layer.parallax)
		love.graphics.draw(layer.image, layer.cropData.left, layer.cropData.top)

		love.graphics.setColor(unpack(currentLevel.groundColor))
		love.graphics.rectangle("fill", -10000, 4000, 100000, 100000)
		love.graphics.setColor(255, 255, 255)
		
		love.graphics.translate(layer.cropData.originalWidth/2, layer.cropData.originalHeight/2)
		love.graphics.scale(-1.0, 1.0)
		love.graphics.translate(-layer.cropData.originalWidth/2, -layer.cropData.originalHeight/2)
		
		if layer.mirror then
			love.graphics.draw(layer.image, layer.cropData.left - layer.cropData.originalWidth + 5, layer.cropData.top, 0, 1.0, 1.0)
			love.graphics.draw(layer.image, layer.cropData.left + layer.cropData.originalWidth - 5, layer.cropData.top, 0, 1.0, 1.0)
		end
		
		love.graphics.pop()
	end
	
	if true then
		love.graphics.setColor(255, 255, 255, 100)
		for i = 1, #currentLevel.shapes do
			love.graphics.polygon("fill", unpack(currentLevel.shapes[i]))
		end
	end
	
	if currentLevel.drawCallback then
		currentLevel.drawCallback()
	end
end

function finishLevel()
	if currentLevel.finishCallback then
		currentLevel.finishCallback()
	end
end