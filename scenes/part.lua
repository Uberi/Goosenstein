scenes = scenes or {}

require "utilities/bloom"
require "utilities/buttons"
local HC = require "hardoncollider"
local tilemap = require "levels/level1_part2"
require "levels"

local total_elapsed

scenes.part = {
	initialize = function(self)
		self.bloom_effect = bloom:create()
		self.bloom_effect.radius = 4
		self.bloom_effect.samples = 4

		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 36)
		self.background = love.graphics.newImage("images/Background Morning.png")
		self.goose_flying = love.graphics.newImage("images/Goose Flying.png")
		self.goose_flapping = love.graphics.newImage("images/Goose Flapping.png")
		self.goosoraptor = love.graphics.newImage("images/Goosoraptor.png")

		self.pause_play_button = button:create("ii", 10, 10, 40, 40, self.pixel_small)
		
		self.rain = init_rain()
		
		self.camera_x, self.camera_y = 0, 0
		
		self.collider = HC(100)
		self.character = init_character(self.collider, 151, 250)
		
		self.goose_collider = HC(100, function(dt, shape_s, shape_t, dx, dy)
			if total_elapsed > 2 then --small period of invulnerability
				love.event.quit() --wip: game over screen
			end
		end)
		self.geese = {init_goose(self.collider, 700, 0, "images/Goose Flying.png"), init_goose(self.collider, 0, 0, "images/Goose Flapping.png")}
		for i, goose in ipairs(self.geese) do
			goose.shape = self.goose_collider:addRectangle(goose.x, goose.y, goose.w, goose.h)
			self.goose_collider:addToGroup("geese", goose.shape)
			self.goose_collider:setPassive(goose.shape)
		end
		self.goose_shape = self.goose_collider:addRectangle(self.character.x + 20, self.character.y + 20, self.character.w - 40, self.character.h - 40)
		
		self.tile_size = 50
		self.map = {}
		for i = 1, tilemap.height do self.map[i] = {} end
		for i, value in ipairs(tilemap.layers[1].data) do
			table.insert(self.map[math.floor((i - 1) / tilemap.width) + 1], value)
		end
		self.tiles, self.tile_quads = init_map(self.map, self.collider, self.tile_size)
	end,
	mousereleased = function(self, x, y, button)
		self.pause_play_button:mousereleased(x, y, button)
	end,
	update = function(self, dt, elapsed)
		total_elapsed = elapsed
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

		self.character.velocity_y = self.character.velocity_y + 900 * dt
		self.character.x = self.character.x + self.character.velocity_x * dt
		self.character.y = self.character.y + self.character.velocity_y * dt
		
		self.character.shape:moveTo(self.character.x + self.character.w / 2, self.character.y + self.character.h / 2)
		self.character.mtv_x, self.character.mtv_y = nil, nil
		for i, goose in ipairs(self.geese) do
			goose.mtv_x, goose.mtv_y = nil, nil
		end
		
		self.collider:update(dt)
		
		if self.character.mtv_x then --currently colliding
			self.character.x = self.character.x + self.character.mtv_x
			self.character.y = self.character.y + self.character.mtv_y
			if self.character.mtv_y < self.character.mtv_x then --colliding on top or bottom
				self.character.velocity_y = 0
				if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
					self.character.velocity_y = -600
				end
			else
				self.character.velocity_x = 0
			end
		end
		
		self.goose_shape:moveTo(self.character.x + self.character.w / 2, self.character.y + self.character.h / 2)
		for i, goose in ipairs(self.geese) do
			goose.shape:moveTo(goose.x + goose.w / 2, goose.y + goose.h / 2)
		end
		
		self.goose_collider:update(dt)
		for i, goose in ipairs(self.geese) do
			goose.x = goose.x - 300 * dt
			if goose.x < self.character.x - 1500 then
				goose.x = self.character.x + 1500
				goose.target_x, goose.target_y = self.character.x, self.character.y
			end
			goose.y = -0.001 * (goose.x - goose.target_x)^2 + goose.target_y
		end
		
		--fade in rectangle alpha
		if elapsed <= 0.5 then
			self.darkening = 255
		elseif elapsed <= 1 then
			self.darkening = math.max(0, 255 - (elapsed - 0.5) * 255 / 0.5)
		else
			self.darkening = 0
		end
		
		if self.character.x > 2400 then --end condition reached
			set_scene(scenes.bus)
			return
		end
	end,
	draw = function(self, dt, elapsed)
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.setColor(255, 255, 255)
		
		self.bloom_effect:before_draw()
		
		draw_background(self.background, self.camera_x, self.camera_y)
		
		draw_character(self.character, self.camera_x, self.camera_y)
		for i, goose in ipairs(self.geese) do
			
			draw_character(goose, self.camera_x, self.camera_y)
		end
		love.graphics.draw(self.rain, 0, 0)
		draw_map(self.map, self.tiles, self.tile_quads, self.tile_size, self.camera_x, self.camera_y)
		self.pause_play_button:draw()
		
		self.bloom_effect:after_draw()
		
		love.graphics.setColor(0, 0, 0, self.darkening)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
}