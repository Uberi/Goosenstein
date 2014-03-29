scenes = scenes or {}

require "utilities/bloom"
require "utilities/buttons"
HC = require "hardoncollider"

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

scenes.intro = {
	initialize = function(self)
		self.bloom_effect = bloom:create()
		self.bloom_effect.radius = 4
		self.bloom_effect.samples = 4

		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 36)
		self.background = love.graphics.newImage("images/Background Morning.png")

		self.pause_play_button = button:create("ii", 10, 10, 40, 40, self.pixel_small)
		
		self.rain = init_rain()
		
		self.camera_x, self.camera_y = 0, 0
		
		love.physics.setMeter(10) --80 pixels to the meter
		self.world = love.physics.newWorld(0, 9.81 * 10, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
		self.collider = HC(100)
		
		self.character = {
			x = 500, y = 0,
			w = 80, h = 100,
			image = love.graphics.newImage("images/Character.png"),
			scale = 0.4,
			velocity_x = 0, velocity_y = 0,
			mtv_x = nil, mtv_y = nil,
			flipped = false,
		}
		self.character.shape = self.collider:addRectangle(self.character.x, self.character.y, self.character.w, self.character.h)
		self.character.idle_quads = {}
		for i = 1, 4 do
			table.insert(self.character.idle_quads, love.graphics.newQuad(0, (i - 1) * 250, 200, 250, self.character.image:getWidth(), self.character.image:getHeight()))
		end
		
		self.collider:setCallbacks(function(dt, shape_s, shape_t, dx, dy)
			if shape_s == self.character.shape or shape_t == self.character.shape then --keep it out of collision
				self.character.mtv_x, self.character.mtv_y = dx, dy
			end
		end)
		
		self.map = {
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 3, 2, 0, 0, 0, 0, 0, 0, 0, 0},
			{0, 0, 0, 0, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0},
			{4, 5, 6, 0, 0, 1, 1, 2, 0, 4, 5, 6, 0, 0},
			{1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1},
			{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1},
			{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
			{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		}
		
		self.tile_size = 50
		for i, row in ipairs(self.map) do
			for j, value in ipairs(row) do
				if value ~= 0 then
					local shape = self.collider:addRectangle((j - 1) * self.tile_size, (i - 1) * self.tile_size, self.tile_size, self.tile_size)
					self.collider:addToGroup("tiles", shape)
					self.collider:setPassive(shape)
				end
			end
		end
		self.tiles = love.graphics.newImage("images/Tiles.png")
		self.tile_quads = {}
		for i = 1, 6 do
			local rect = love.graphics.newQuad(0, (i - 1) * 128, 128, 128, self.tiles:getWidth(), self.tiles:getHeight())
			table.insert(self.tile_quads, rect)
		end
	end,
	mousereleased = function(self, x, y, button)
		self.pause_play_button:mousereleased(x, y, button)
	end,
	update = function(self, dt, elapsed)
		self.rain:update(dt)
		
		self.pause_play_button:update(dt)
		if self.pause_play_button.was_clicked then
			self.pause_play_button.was_clicked = false
			if self.pause_play_button.text == ">" then
				self.pause_play_button.text = "ii"
			else
				self.pause_play_button.text = ">"
			end
		end
		
		--update tracking camera
		local movement = 1.5 * dt
		self.camera_x = self.camera_x * (1 - movement) + (self.character.x - width / 2) * movement
		self.camera_y = self.camera_y * (1 - movement) + (self.character.y - height / 2) * movement
		
		--everything before this still runs while paused
		if self.pause_play_button.text == ">" then
			return --make sure the game is paused
		end
		
		local move_speed = 300
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			self.character.x = self.character.x - move_speed * dt
			self.character.flipped = true
			speedx = -move_speed
		end
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
			self.character.x = self.character.x + move_speed * dt
			self.character.flipped = false
		end
		self.character.velocity_y = self.character.velocity_y + 600 * dt
		self.character.x = self.character.x + self.character.velocity_x * dt
		self.character.y = self.character.y + self.character.velocity_y * dt
		
		self.character.shape:moveTo(self.character.x + self.character.w / 2, self.character.y + self.character.h / 2)
		self.character.mtv_x, self.character.mtv_y = nil, nil
		self.collider:update(dt)
		if self.character.mtv_x then --currently colliding
			self.character.x = self.character.x + self.character.mtv_x
			self.character.y = self.character.y + self.character.mtv_y
			self.character.velocity_y = 0
			if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
				self.character.velocity_y = -400
			end
		end
		
		--fade in rectangle alpha
		if elapsed <= 0.5 then
			self.darkening = 255
		elseif elapsed <= 1 then
			self.darkening = math.max(0, 255 - (elapsed - 0.5) * 255 / 0.5)
		else
			self.darkening = 0
		end
	end,
	draw = function(self, dt, elapsed)
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.setColor(255, 255, 255)
		
		self.bloom_effect:before_draw()
		
		love.graphics.push()
		love.graphics.translate((-self.camera_x * 0.5) % self.background:getWidth(), 0)
		love.graphics.draw(self.background, -self.background:getWidth(), 0, 0, height / self.background:getHeight())
		love.graphics.draw(self.background, 0, 0, 0, height / self.background:getHeight())
		love.graphics.draw(self.background, self.background:getWidth(), 0, 0, height / self.background:getHeight())
		love.graphics.pop()
		
		--draw the character
		love.graphics.push()
		love.graphics.translate(-self.camera_x, -self.camera_y)
		local index = (math.floor(elapsed / 0.3) % 4) + 1
		if self.character.flipped then
			love.graphics.draw(self.character.image, self.character.idle_quads[index], self.character.x + self.character.w, self.character.y + 7, 0, -self.character.scale, self.character.scale)
		else
			love.graphics.draw(self.character.image, self.character.idle_quads[index], self.character.x, self.character.y + 7, 0, self.character.scale)
		end
		love.graphics.pop()
		
		love.graphics.draw(self.rain, 0, 0)
		
		--draw map
		love.graphics.push()
		love.graphics.translate(-self.camera_x, -self.camera_y)
		local count_x, count_y = math.ceil(width / self.tile_size), math.ceil(height / self.tile_size)
		local index_x, index_y = math.floor(self.camera_x / self.tile_size), math.floor(self.camera_y / self.tile_size)
		for i, row in ipairs(self.map) do
			for j, value in ipairs(row) do
				if value ~= 0 then
					love.graphics.draw(self.tiles, self.tile_quads[value], (j - 1) * self.tile_size, (i - 1) * self.tile_size, 0, self.tile_size / 128)
				end
			end
		end
		love.graphics.pop()
		
		self.pause_play_button:draw()
		
		self.bloom_effect:after_draw()
		
		love.graphics.setColor(0, 0, 0, self.darkening)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
}