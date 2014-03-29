level = level or {}

love.physics.setMeter(80) --80 pixels to the meter

function level:create()
	self = {}
	self.world = love.physics.newWorld(0, 9.81 * 80, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	self.physical_objects = {}
	return self
end
