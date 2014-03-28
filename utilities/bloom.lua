bloom = bloom or {}

function bloom:create()
	self = {}
	setmetatable(self, {__index = bloom})

	self.shader = love.graphics.newShader("shaders/bloom.fs")
	local width, height = love.graphics.getDimensions()
	self.frame_target = love.graphics.newCanvas(width, height)

	self.radius = 8
	self.samples = 4
	self.glow = 0.3
	return self
end

--runs before each frame
function bloom:before_draw()
	self.frame_target:clear()
	self.previous_target = love.graphics.getCanvas()
	love.graphics.setCanvas(self.frame_target)
end

--runs after each frame
function bloom:after_draw()
	love.graphics.setCanvas(self.previous_target) --set drawing target to previous target
	local previous_shader = love.graphics.getShader()
    love.graphics.setShader(self.shader)
	self.shader:send("IMAGE_SIZE", {love.graphics.getDimensions()})
	self.shader:sendInt("RADIUS", self.radius)
	self.shader:sendInt("SAMPLES", self.samples)
	self.shader:send("GLOW", self.glow)

	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(self.frame_target)
	love.graphics.setColor(r, g, b, a)
	
    love.graphics.setShader(previous_shader)
end