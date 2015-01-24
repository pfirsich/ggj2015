function love.load(arg)
	love.filesystem.setIdentity("ImageCrop")
	
	autoCrop("Lvl11.png")
	autoCrop("Lvl12.png")
	autoCrop("Lvl13.png")
	autoCrop("Lvl14.png")
	autoCrop("Lvl15.png")
	
	love.event.quit()
end

function autoCrop(filename)
	print("Cropping file", filename)
	local image = love.image.newImageData(filename)
	
	local top = getBoundTop(image)
	local left = getBoundLeft(image)
	local bottom = getBoundBottom(image)
	local right = getBoundRight(image)
	
	local newWidth = (right - left)
	local newHeight = (bottom - top)
	
	print("Target", tostring(newWidth) .. " x " .. tostring(newHeight))
	
	local saved = 1 - (newWidth*newHeight) / (image:getWidth()*image:getHeight())
	print("Saved " .. tostring(math.floor(saved*100)) .. "%")
	
	local newImage = love.image.newImageData(newWidth, newHeight)
	newImage:paste(image, 0, 0, left, top, newWidth, newHeight)
	newImage:encode(filename .. ".cropped.png")
	
	local file = love.filesystem.newFile(filename .. ".cropped.lua", "w")
	file:write("return {\n")
	file:write("\ttop=" .. tostring(top) .. " , \n")
	file:write("\tbottom=" .. tostring(bottom) .. " , \n")
	file:write("\tleft=" .. tostring(left) .. " , \n")
	file:write("\tright=" .. tostring(right) .. " , \n")
	file:write("}\n")
	file:close()
	print("Saved to file", filename)
end

function getBoundTop(data)
	local y = 0
	while y <= data:getHeight()-1 do
		for x=0,data:getWidth()-1 do
			local r, g, b, a = data:getPixel(x,y)
			if a > 0 then return y end
		end
		y = y + 1
	end
	return y
end

function getBoundLeft(data)
	local x = 0
	while x <= data:getWidth()-1 do
		for y=0,data:getHeight()-1 do
			local r, g, b, a = data:getPixel(x,y)
			if a > 0 then return x end
		end
		x = x + 1
	end
	return x
end

function getBoundBottom(data)
	local y = data:getHeight()-1
	while y >= 0 do
		for x=0,data:getWidth()-1 do
			local r, g, b, a = data:getPixel(x,y)
			if a > 0 then return y end
		end
		y = y - 1
	end
	return y
end

function getBoundRight(data)
	local x = data:getWidth()-1
	while x >= 0 do
		for y=0,data:getHeight()-1 do
			local r, g, b, a = data:getPixel(x,y)
			if a > 0 then return x end
		end
		x = x - 1
	end
	return x
end