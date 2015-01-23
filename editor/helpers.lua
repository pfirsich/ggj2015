function getFromWrappedArray(i, table)
	return table[(i-1)%#table+1]
end

function pointInTriangle(x, y, p1x, p1y, p2x, p2y, p3x, p3y) 
	return pointInPolygon(x, y, {p1x, p1y, p2x, p2y, p3x, p3y})
end

function pointInPolygon(x, y, polygon)
	for i=1,#polygon,2 do
		local x1 = getFromWrappedArray(i, polygon)
		local y1 = getFromWrappedArray(i+1, polygon)
		local x2 = getFromWrappedArray(i+2, polygon)
		local y2 = getFromWrappedArray(i+3, polygon)
		
		local normalX = -(y2 - y1)
		local normalY = (x2 - x1)
		
		local minProjection = math.huge
		local maxProjection = -math.huge
		
		for j=1,#polygon,2 do
			local projection = normalX*polygon[j]+normalY*polygon[j+1]
			minProjection = math.min(minProjection, projection)
			maxProjection = math.max(maxProjection, projection)
		end
		
		local projection = normalX*x+normalY*y
		if (projection < minProjection) or (projection > maxProjection) then return false end
	end
	return true
end

function normedDot(x1, y1, x, y, x2, y2) 
	local dx1 = (x1-x)
	local dx2 = (x2-x)
	local dy1 = (y1-y)
	local dy2 = (y2-y)
	local dot = dx1*dx2+dy1*dy2
	local N = math.sqrt( (dx1*dx1+dy1*dy1) * (dx2*dx2+dy2*dy2) ) 
	return dot/N
end

function earClippingTriangulation(polygon)
	local triangles = {}
	local fails = -1
	local i = 1
	local maxCos = math.acos(5 / 180 * math.pi) -- 5 deg
	while #polygon > 6 do -- more than 3 points remaining
		fails = fails + 1
		if fails > 100 then 
			error("Could not triangulate polygon.")
		end
		local x1 = getFromWrappedArray(i-2, polygon)
		local y1 = getFromWrappedArray(i-1, polygon)
		local x = getFromWrappedArray(i, polygon)
		local y = getFromWrappedArray(i+1, polygon)
		local x2 = getFromWrappedArray(i+2, polygon)
		local y2 = getFromWrappedArray(i+3, polygon)
		
		local cos = math.max(
			math.abs(normedDot(x1, y1, x, y, x2, y2)),
			math.abs(normedDot(x, y, x1, y1, x2, y2)),
			math.abs(normedDot(x1, y1, x2, y2, x, y))
		)
		if cos < maxCos then
			local orientation = (x1-x)*(y2-y)-(y1-y)*(x2-x)
			if orientation < 0 then
				local inPolygon = false
				for j=1,#polygon,2 do
					local px = polygon[j]
					local py = polygon[j+1]
					if ((px~=x1) or (py~=y1)) and ((px~=x) or (py~=y)) and ((px~=x2) or (py~=y2)) then -- = point polygon[j] is NOT in (p1, p2, p)
						if pointInTriangle(px, py, x1, y1, x, y, x2, y2) then
							inPolygon = true
							break
						end
					end
				end
				if not inPolygon then
					table.insert(triangles, {x1, y1, x, y, x2, y2})
					table.remove(polygon, i)
					table.remove(polygon, i)
					fails = 0
					i = i - 2
				end
			end
		end
		i = (i+1) % #polygon + 1 -- increase by one point (2 elements)
	end
	table.insert(triangles, polygon)
	return triangles
end

function simplifyPolygon(polygon, minAngle)
	local minCos = math.cos(minAngle*math.pi/180)
	local i = 1
	while i<#polygon do
		local x1 = getFromWrappedArray(i-2, polygon)
		local y1 = getFromWrappedArray(i-1, polygon)
		local x = getFromWrappedArray(i, polygon)
		local y = getFromWrappedArray(i+1, polygon)
		local x2 = getFromWrappedArray(i+2, polygon)
		local y2 = getFromWrappedArray(i+3, polygon)
		
		local dot = normedDot(x1, y1, x, y, x2, y2)
		if dot < -minCos then
			table.remove(polygon, i)
			table.remove(polygon, i)
			-- i = i - 2
		end
		i = i + 2
	end
	return polygon
end



