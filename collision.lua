function collisionStart(dt, shapeA, shapeB, mtvX, mtvY)
	if shapeA.g_type == "level" and shapeB.g_type == "player" then
		shapeA, shapeB = shapeB, shapeA
	end
	
	if shapeA.g_type == "player" and shapeB.g_type == "level" then
		shapeA.g_mtvSum = vadd(shapeA.g_mtvSum, {mtvX, mtvY})
		shapeA.g_collisionCount = shapeA.g_collisionCount + 1
	end
end