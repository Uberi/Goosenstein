scenes = scenes or {}

require "utilities/bloom"
require "utilities/buttons"
HC = require "hardoncollider"
require "levels"

scenes.intro = {
	initialize = function(self)
		self.bloom_effect = bloom:create()
		self.bloom_effect.radius = 4
		self.bloom_effect.samples = 4

		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 36)
		self.background = love.graphics.newImage("images/Background Morning.png")
		self.goose_flying = love.graphics.newImage("images/Goose Flying.png")

		self.pause_play_button = button:create("ii", 10, 10, 40, 40, self.pixel_small)
		
		self.rain = init_rain()
		
		self.camera_x, self.camera_y = 0, 0
		
		love.physics.setMeter(10) --80 pixels to the meter
		self.world = love.physics.newWorld(0, 9.81 * 10, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
		self.collider = HC(100)
		
		self.character = init_character(self.collider)
		
		
		self.tile_size = 50
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
		self.tiles, self.tile_quads = init_map(self.map, self.collider, self.tile_size)
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
		local actuated = false
		if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
			self.character.x = self.character.x - move_speed * dt
			self.character.flipped = true
			actuated = true
		end
		if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
			self.character.x = self.character.x + move_speed * dt
			self.character.flipped = false
			actuated = true
		end
		if actuated then
			self.character.state = self.character.quads[(math.floor(elapsed / 0.1) % 4) + 5]
		else
			self.character.state = self.character.quads[(math.floor(elapsed / 0.3) % 4) + 1]
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
		
		draw_character(self.character, self.camera_x, self.camera_y)
		love.graphics.draw(self.rain, 0, 0)
		draw_map(self.map, self.tiles, self.tile_quads, self.tile_size, self.camera_x, self.camera_y)
		self.pause_play_button:draw()
		
		self.bloom_effect:after_draw()
		
		love.graphics.setColor(0, 0, 0, self.darkening)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
}