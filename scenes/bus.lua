scenes = scenes or {}

require "utilities/bloom"
require "utilities/buttons"
local HC = require "hardoncollider"
local tilemap = require "levels/level1_part1"
require "levels"

scenes.bus = {
	initialize = function(self)
		self.bloom_effect = bloom:create()
		self.bloom_effect.radius = 4
		self.bloom_effect.samples = 4

		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 36)
		self.background = love.graphics.newImage("images/Background Morning.png")
		self.goose_flying = love.graphics.newImage("images/Goose Flying.png")
		self.goose_flapping = love.graphics.newImage("images/Goose Flapping.png")
		self.goosoraptor = love.graphics.newImage("images/Goosoraptor.png")
		self.bus = love.graphics.newImage("images/Bus.png")

		self.pause_play_button = button:create("ii", 10, 10, 40, 40, self.pixel_small)
		
		self.rain = init_rain()
		
		self.camera_x, self.camera_y = 0, 0
		
		self.collider = HC(100)
		self.character = init_character(self.collider, 500, 250)
		self.geese = {init_goose(self.collider, 700, 0, "images/Goose Flying.png"), init_goose(self.collider, 0, 0, "images/Goose Flapping.png")}
		
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
		local bus_scene_initiate = false; --if true then player can not move, if false then player can move!
		
		if self.character.x >= 1700 and self.character.x <= 1725 and self.character.y == 750 then
			bus_scene_initiate = true
		end
		
		if  not bus_scene_initiate then
			if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
				self.character.x = self.character.x - move_speed * dt
				self.character.flipped = true
				actuated = true
				--print("CHARACTER X: ", self.character.x)
				--print("CHARACTER Y: ", self.character.y)
			end
			if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
				self.character.x = self.character.x + move_speed * dt
				self.character.flipped = false
				actuated = true
				--print("CHARACTER X: ", self.character.x)
				--print("CHARACTER Y: ", self.character.y)
			end
		else
			--nothing shall go here!!
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
				if not bus_scene_initiate then
					if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
						self.character.velocity_y = -600
					end
				else
					--nothing will happen here because yeah
				end
			else
				self.character.velocity_x = 0
			end
		end
		
		for i, goose in ipairs(self.geese) do
			if goose.x > self.character.x then goose.x = goose.x - 10 * dt
			else goose.x = goose.x + 10 * dt end
			goose.x = goose.x - 150 * dt
			goose.y = goose.y + 200 * dt
			if goose.y > 1000 then
				goose.x = self.character.x + i * 600
				goose.y = -200
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