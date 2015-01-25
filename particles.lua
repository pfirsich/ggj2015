particles = {}

function initParticles()
	maxParticles = 600
	for i = 1, maxParticles do
		particles[i] = {alive = false}
	end
	nextParticleIndex = 1
end

function spawnParticles(number, position, direction, properties)
	-- spread, image, lifetime, friction, angularVel, orientationSpread, startSize, endSize, startColor, endColor
	for i = 1, number do
		local particle = particles[nextParticleIndex]
		nextParticleIndex = nextParticleIndex + 1
		if nextParticleIndex > maxParticles then nextParticleIndex = 1 end
		
		particle.position = vret(position)
		properties.spread = properties.spread
		local speed = randf(-properties.speedVariance, properties.speedVariance) + properties.speed
		particle.velocity = vmul(vrotate(direction, randf(-properties.spread/2, properties.spread/2)), speed)
		particle.image = properties.image
		particle.lifetime = properties.lifetime
		particle.age = 0
		particle.friction = properties.friction
		particle.angle = vangle(particle.velocity) +  randf(-properties.orientationSpread/2, properties.orientationSpread/2)
		particle.angularVelocity = properties.angularVelocity
		particle.alive = true
		particle.startSizeX, particle.endSizeX = properties.startSizeX, properties.endSizeX
		particle.startSizeY, particle.endSizeY = properties.startSizeY, properties.endSizeY
		particle.startColor = properties.startColor
		particle.endColor = properties.endColor
		particle.gravity = properties.gravity
	end
end

function updateParticles()
	for i = 1, maxParticles do
		local particle = particles[i]
		if particle.alive then 
			particle.velocity = vsub(particle.velocity, vmul({0, 1}, particle.gravity * simulationDt))
			particle.velocity = vsub(particle.velocity, vmul(particle.velocity, particle.friction * simulationDt))
			particle.position = vadd(particle.position, vmul(particle.velocity, simulationDt))
			particle.angle = vangle(particle.velocity)
			particle.age = particle.age + simulationDt
			if particle.age > particle.lifetime then
				particle.alive = false
			end
		end
	end
end

function drawParticles()
	for i = 1, maxParticles do
		local particle = particles[i]
		if particle.alive then 
			local scaleX = lerp(particle.startSizeX, particle.endSizeX, particle.age / particle.lifetime)
			local scaleY = lerp(particle.startSizeY, particle.endSizeY, particle.age / particle.lifetime)
			local color = lerpArray(particle.startColor, particle.endColor, particle.age / particle.lifetime)
			love.graphics.setColor(unpack(color))
			love.graphics.draw(particle.image, particle.position[1], particle.position[2], particle.angle, scaleX, scaleY)
		end
	end
end