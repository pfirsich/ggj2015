do
	local mapTime = 3600
	
	local function explosion()
		lush.play("explosion.wav") 
	end

	return {
		name = "Finale",
		geometryFile = "media/geo_level3.lua",
		layers = {
			{ file="media/images/lvl3.png", parallax=1.0, mirror=false},
		},
		groundColor = {108, 83, 36},
		backgroundColor = {33, 7, 0},
		spawn = {950, 645},
		time = 60,
		hasTimer = false,
		finishCallback = explosion
	}	
end
