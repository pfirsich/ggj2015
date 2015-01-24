-- HACK (PRESENTATION)

function setupLevel()
	setupEscapeRocket(4400, 890)
end


function setupEscapeRocket(x,y)
	local rocket = love.graphics.newImage("media/images/escaperocket.png")
	local pad = love.graphics.newImage("media/images/emptyescaperocket.png")
	
	local delta = {0,0}
	local drawCallback = function (escape) -- draw callback
		love.graphics.draw(rocket, escape.position[1]-250+delta[1], escape.position[2]-370+delta[2])
		love.graphics.draw(pad, escape.position[1]-250, escape.position[2]-370)
	end
	local activateCallback = function (escape, player) -- activate callback
		addCallback(function ()
			local v = {232, -255}
			local f = 1.5
			delta[1] = delta[1] + v[1]*simulationDt*f
			delta[2] = delta[2] + v[2]*simulationDt*f
			return true
		end)
	
		removePlayer(player)
	end
		
	local escape = addEscape(x, y, "escape rocket", drawCallback, activateCallback)
	
	escape.relativeMessagePosition = {100, -100}
	escape.height = 55
	escape.activateRadius = 150
end