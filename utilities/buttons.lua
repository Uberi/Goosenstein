button = button or {}

require "utilities/periodic"

function button:create(text, x, y, w, h, font, text_offset_y)
	self = {
		text = text or "Button",
		font = font or love.graphics.getFont(),
		fill_alpha = 0,
		border_width = 4,
		text_offset_y = text_offset_y or 0,
		angle = 5 * math.pi / 180,
		was_clicked = false,
		enabled = true,
		elapsed = 0,
	}
	setmetatable(self, {__index = button})
	self:move(x, y, w, h)
	return self
end

function button:move(x, y, w, h)
	self.x, self.y = x or self.x, y or self.y
	local width, height = self.font:getWidth(self.text), self.font:getHeight()
	self.w, self.h = w or width + height * 1.5, h or height * 1.2
end

function button:mousereleased(x, y, button)
	if self.enabled and button == "l" and self:test(x, y) then
		self.was_clicked = true
	end
end

function button:test(x, y)
	return x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h
end

function button:update(dt)
	local x, y = love.mouse.getPosition()
	local max_alpha = 40
	if self.enabled and self:test(x, y) then
		self.elapsed = self.elapsed + dt
		self.fill_alpha = math.min(self.fill_alpha + max_alpha * dt / 0.2, max_alpha)
		self.angle = (periodic(0.5, self.elapsed, 1 / 4) * 2 - 1) * 4 * math.pi / 180
	else
		self.elapsed = 0 --reset periodic function
		self.fill_alpha = math.max(self.fill_alpha - max_alpha * dt / 0.8, 0)
		self.angle = self.angle * 0.8
	end
end

function button:draw()
	local r, g, b, a = love.graphics.getColor()
	local font = love.graphics.getFont()
	love.graphics.setFont(self.font)
	love.graphics.push()

	love.graphics.translate(self.x + self.w / 2, self.y + self.h / 2)
	love.graphics.rotate(self.angle)
	love.graphics.setColor(r, g, b, self.fill_alpha)
	love.graphics.rectangle("fill", -self.w / 2, -self.h / 2, self.w, self.h, self.border_radius)
	love.graphics.setColor(r, g, b, 255)
	love.graphics.setLineWidth(self.border_width)
	love.graphics.rectangle("line", -self.w / 2, -self.h / 2, self.w, self.h, self.border_radius)
	love.graphics.printf(self.text, -self.w / 2, self.text_offset_y - self.h / 2, self.w, "center")

	love.graphics.pop()
	love.graphics.setFont(font)
	love.graphics.setColor(r, g, b, a)
end