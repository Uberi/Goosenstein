function init_rain()
	local rain = love.graphics.newParticleSystem(love.graphics.newImage("images/rain.png"), 2000)
		rain:setEmissionRate(80) --emitted particles per second
		rain:setEmitterLifetime(-1) --continuously emit particles
		rain:setParticleLifetime(16, 20) --each particle lives for 5 seconds
		rain:setPosition(width / 2, 0) --emit particles from center of left edge
		rain:setDirection(80 * math.pi / 180) --emit downwards
		rain:setRotation(-10 * math.pi / 180) --slant the raindrops
		rain:setSpeed(460, 500)
		rain:setSizes(1.2, 0.8, 0)
		rain:setSizeVariation(0.8)
		rain:setAreaSpread("uniform", width / 2, 0)
		rain:start()

		for i = 1, 200 do rain:update(0.05) end --ensure the particle system is in a good initial state
		return rain
end

function init_character(collider, x, y)
	local character = {
		x = x, y = y,
		w = 80, h = 100,
		image = love.graphics.newImage("images/main_character.png"),
		scale = 0.4,
		velocity_x = 0, velocity_y = 0,
		mtv_x = nil, mtv_y = nil,
		flipped = false,
	}
	character.shape = collider:addRectangle(character.x, character.y, character.w, character.h)
	character.quads = {}
	for i = 1, 8 do
		table.insert(character.quads, love.graphics.newQuad(0, (i - 1) * 250, 200, 250, character.image:getWidth(), character.image:getHeight()))
	end
	
	collider:setCallbacks(function(dt, shape_s, shape_t, dx, dy)
		if shape_s == character.shape or shape_t == character.shape then --keep it out of collision
			character.mtv_x, character.mtv_y = dx, dy
		end
		if shape_s == character.shape or shape_t == character.shape then --keep it out of collision
			character.mtv_x, character.mtv_y = dx, dy
		end
	end)
	return character
end

function init_goose(collider, x, y, image)
	local character = {
		x = x, y = y,
		image = love.graphics.newImage(image),
		scale = 0.6,
		velocity_x = 0, velocity_y = 0,
		mtv_x = nil, mtv_y = nil,
		flipped = false,
	}
	character.w, character.h = character.image:getWidth() * character.scale, character.image:getHeight() * character.scale
	character.shape = collider:addRectangle(character.x, character.y, character.w, character.h)
	character.state = love.graphics.newQuad(0, 0, character.image:getWidth(), character.image:getHeight(), character.image:getWidth(), character.image:getHeight())
	
	local original = collider.on_collide
	collider:setCallbacks(function(dt, shape_s, shape_t, dx, dy)
		if shape_s == character.shape or shape_t == character.shape then --keep it out of collision
			character.mtv_x, character.mtv_y = dx, dy
		else
			return original(dt, shape_s, shape_t, dx, dy)
		end
	end)
	return character
end

function init_map(map, collider, tile_size)
	for i, row in ipairs(map) do
		for j, value in ipairs(row) do
			if value ~= 0 then
				local shape = collider:addRectangle((j - 1) * tile_size, (i - 1) * tile_size, tile_size, tile_size)
				collider:addToGroup("tiles", shape)
				collider:setPassive(shape)
			end
		end
	end
	local tiles = love.graphics.newImage("images/Tiles.png")
	local tile_quads = {}
	for i = 1, 8 do
		local rect = love.graphics.newQuad(0, (i - 1) * 128, 128, 128, tiles:getWidth(), tiles:getHeight())
		table.insert(tile_quads, rect)
	end
	return tiles, tile_quads
end

function draw_map(map, tiles, tile_quads, tile_size, camera_x, camera_y)
	--draw map
	love.graphics.push()
	love.graphics.translate(-camera_x, -camera_y)
	for i, row in ipairs(map) do
		for j, value in ipairs(row) do
			if value ~= 0 then
				love.graphics.draw(tiles, tile_quads[value], (j - 1) * tile_size, (i - 1) * tile_size, 0, tile_size / 128)
			end
		end
	end
	love.graphics.pop()
end

function draw_character(character, camera_x, camera_y)
	--draw the character
	love.graphics.push()
	love.graphics.translate(-camera_x, -camera_y)
	if character.flipped then
		love.graphics.draw(character.image, character.state, character.x + character.w, character.y + 7, 0, -character.scale, character.scale)
	else
		love.graphics.draw(character.image, character.state, character.x, character.y + 7, 0, character.scale)
	end
	love.graphics.pop()
end

function draw_background(background, camera_x, camera_y)
	love.graphics.push()
	love.graphics.translate((-camera_x * 0.5) % background:getWidth(), 0)
	love.graphics.draw(background, -background:getWidth(), 0, 0, height / background:getHeight())
	love.graphics.draw(background, 0, 0, 0, height / background:getHeight())
	love.graphics.draw(background, background:getWidth(), 0, 0, height / background:getHeight())
	love.graphics.pop()
end
