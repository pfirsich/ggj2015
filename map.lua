function setupMap(shapeList) 
	local map = {}
	map.shapes = {}
	for i = 1, #shapeList do
		local shape = collider:addPolygon(unpack(shapeList[i]))
		collider:setPassive(shape)
		shape.g_type = "level"
		table.insert(map.shapes, shapeList[i])
	end
	
	return map
end