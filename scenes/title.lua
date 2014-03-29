scenes = scenes or {}

require "utilities/buttons"

scenes.title = {
	initialize = function(self)
		self.pixel_large = love.graphics.newFont("fonts/Victor Pixel.ttf", 86)
		self.pixel_medium = love.graphics.newFont("fonts/Victor Pixel.ttf", 56)
		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 30)
		self.logo = love.graphics.newImage("images/Goosenstein.png")
	end,
	enter = function(self)
		self.resume_button = button:create("resume", 130, 400, 400, 90, self.pixel_large)
		self.start_button = button:create("start", 570, 400, 250, 60, self.pixel_medium)
		self.levels_button = button:create("levels", 870, 400, 260, 60, self.pixel_medium)
		self.exit_button = button:create("exit", 1030, 500, 100, 40, self.pixel_small)
		
		self.buttons_enabled = true
	end,
	mousereleased = function(self, x, y, button)
		self.resume_button:mousereleased(x, y, button)
		self.start_button:mousereleased(x, y, button)
		self.levels_button:mousereleased(x, y, button)
		self.exit_button:mousereleased(x, y, button)
	end,
	update = function(self, dt, elapsed)
		if self.buttons_enabled then
			self.resume_button:update(dt)
			if self.resume_button.was_clicked then
				self.buttons_enabled = false
				set_scene(scenes.intro)
				return
			end
			self.start_button:update(dt)
			if self.start_button.was_clicked then
				self.buttons_enabled = false
				set_scene(scenes.intro)
				return
			end
			self.levels_button:update(dt)
			if self.levels_button.was_clicked then
				self.buttons_enabled = false
				return
			end
			self.exit_button:update(dt)
			if self.exit_button.was_clicked then
				love.event.quit()
				return
			end
		end

		if elapsed <= 0.5 then
			self.darkening = 255
		elseif elapsed <= 1 then
			self.darkening = 255 - (elapsed - 0.5) * 255 / 0.5
		else
			self.darkening = 0
		end
	end,
	draw = function(self, dt, elapsed)
		love.graphics.setBackgroundColor(0, 0, 0)
		love.graphics.setColor(255, 255, 255)
		
		love.graphics.draw(self.logo, (width - self.logo:getWidth() * 0.8) / 2, -100, 0, 0.8)
		
		self.resume_button:draw()
		self.start_button:draw()
		self.levels_button:draw()
		self.exit_button:draw()
		
		love.graphics.setColor(0, 0, 0, self.darkening)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
}