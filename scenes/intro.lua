scenes = scenes or {}

require "levels"

scenes.intro = {
	initialize = function(self)
		self.bloom_effect = bloom:create()

		self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 36)
		self.logo = love.graphics.newImage("images/Goosenstein.png")

		self.pause_play_button = button:create("ii", 10, 10, 40, 40, self.pixel_small)
		
		local rain = love.graphics.newParticleSystem(love.graphics.newImage("images/rain.png"), 2000)
		rain:setEmissionRate(80) --emitted particles per second
		rain:setEmitterLifetime(-1) --continuously emit particles
		rain:setParticleLifetime(16, 20) --each particle lives for 5 seconds
		rain:setPosition(width / 2, 0) --emit particles from center of left edge
		rain:setDirection(80 * math.pi / 180) --emit downwards
		rain:setSpread(5 * math.pi / 180)
		rain:setSpeed(460, 500)
		rain:setSizes(0.8, 0.6, 0)
		rain:setSizeVariation(0.8)
		rain:setAreaSpread("uniform", width / 2, 0)
		rain:start()
		self.rain = rain

		for i = 1, 200 do self.rain:update(0.05) end --ensure the particle system is in a good initial state
	end,
	mousereleased = function(self, x, y, button)
		self.pause_play_button:mousereleased(x, y, button)
	end,
	update = function(self, dt, elapsed)
		--everything before this still runs while paused
		self.rain:update(dt)
		
		self.pause_play_button:update(dt)
		if self.pause_play_button.was_clicked then
			self.pause_play_button.was_clicked = false
			if self.pause_play_button.text == ">" then
				self.pause_play_button.text = "ii"
			else
				self.pause_play_button.text = ">"
				return --make sure the game is paused
				--wip: parallax background
				--wip: rain effect
			end
		end
		
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
		
		love.graphics.draw(self.rain, 0, 0)
		
		self.pause_play_button:draw()
		
		self.bloom_effect:after_draw()
		
		love.graphics.setColor(0, 0, 0, self.darkening)
		love.graphics.rectangle("fill", 0, 0, width, height)
	end,
}