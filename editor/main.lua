require "helpers"

function love.load(arg)
	local filename = "Level1.png" -- arg[2]
	
	love.filesystem.setIdentity("PolygonEditor")
	love.keyboard.setKeyRepeat(true)
	
	image = love.graphics.newImage(filename)
	polygons = {}
	currentPolygon = {}
	
	scale = 1
	translateX = 0
	translateY = 0
end

function love.draw()
	love.graphics.push()
	
	local w,h = love.graphics.getDimensions()
	love.graphics.translate(w/2, h/2)
	love.graphics.scale(scale, scale)
	love.graphics.translate(-translateX, -translateY)
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(image, 0, 0)
	for i=1,#polygons do
		love.graphics.setColor(255, 0, 0, 150)
		love.graphics.polygon("fill", unpack(polygons[i]))
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.polygon("line", unpack(polygons[i]))
		love.graphics.setColor(0, 255, 0, 255)
		for j=1,#polygons[i],2 do
			love.graphics.circle("fill", polygons[i][j], polygons[i][j+1], 2)
		end
	end
	love.graphics.setColor(0, 255, 0, 255)
	if #currentPolygon > 2 then
		love.graphics.line(unpack(currentPolygon))
	end
	love.graphics.pop()
end

function love.mousepressed(x,y, button)
	local w,h = love.graphics.getDimensions()
	x = (x-w/2) / scale + translateX
	y = (y-h/2) / scale + translateY
	if button == "l" then
		table.insert(currentPolygon, x)
		table.insert(currentPolygon, y)
	elseif button == "r" then
		finishPolygon()
		for i=#polygons,1,-1 do
			if pointInPolygon(x,y, polygons[i]) then
				table.remove(polygons, i)
				break
			end
		end
	elseif button == "m" then
		finishPolygon()
		for i=#polygons,1,-1 do
			if pointInPolygon(x,y, polygons[i]) then
				local polygon = simplifyPolygon(polygons[i], 10)
				local new = earClippingTriangulation(polygon)
				for j=1,#new do
					table.insert(polygons, new[j])
				end
				table.remove(polygons, i)
				break
			end
		end
	elseif button == "wu" then
		scale = scale * 1.5
	elseif button == "wd" then
		scale = scale /1.5
	end
end

function love.keypressed(key, isrepeat)
	if key == " " then
		finishPolygon()
	elseif key == "s" then
		savePolygons("output.lua")
	elseif key == "l" then
		loadPolygons("output.lua")
	elseif key == "right" then
		translateX = translateX + 50
	elseif key == "left" then
		translateX = translateX - 50
	elseif key == "up" then
		translateY = translateY - 50
	elseif key == "down" then
		translateY = translateY + 50
	elseif key == "delete" then
		finishPolygon()
		polygons = {}
	end
end

function finishPolygon()
	if #currentPolygon > 2 then
		table.insert(polygons, currentPolygon)
	end
	currentPolygon = {}
end

function savePolygons(filename) 
	local file = love.filesystem.newFile(filename, "w")
	file:write("return {\n")
	for i=1,#polygons do
		file:write("{")
		for j=1,#polygons[i] do
			file:write(tostring(polygons[i][j]) .. ", ")
		end
		file:write("}, \n")
	end
	file:write("}")
	file:close()
	print("Saved to file", filename)
end

function loadPolygons(filename)
	local content = love.filesystem.read(filename)
	local data = loadstring(content)
	assert(data)
	polygons = data()
	currentPolygon = {}
end


