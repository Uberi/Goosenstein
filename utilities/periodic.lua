--produces an oscillating value between 0 and 1 inclusive as a function of `elapsed`
--the period of the value is `period`
--assuming `offset` is 0, the function is 0 when `elapsed` is 0, goes up to 1 when `elapsed` is half of `period`, then goes back to 0 when `elapsed` is `period`
--function is offset by `offset` percent of the period, so an offset of 0.5 makes the function start halfway through, so at 1 when `elapsed` is 0
function periodic(period, elapsed, offset)
	period = period or 1
	offset = offset or 0
	elapsed = elapsed or love.timer.getTime()
	return (math.sin((elapsed * 2 * math.pi) / period + offset * 2 * math.pi - math.pi / 2) + 1) / 2
end

function once(length, elapsed, start)
	length = length or 1
	start = start or 0
	local extent = (elapsed or love.timer.getTime()) - start
	if extent > length then return 1 end
	return (math.sin(extent * math.pi / length - math.pi / 2) + 1) / 2
end

transition = {}

function transition:create(length, from, to, complete_callback)
	self = {from=from, to=to, length=length, complete_callback=complete_callback}
	setmetatable(self, {__index = transition})
	self:reset(true)
	return self
end

function transition:on_complete(callback)
	self.complete_callback = callback
end

--resets the transition, but does nothing while the transition is running, unless `even_if_incomplete` is true
function transition:reset(even_if_incomplete)
	if self.complete or even_if_incomplete then
		self.complete = false
		self.elapsed = 0
	end
end

function transition:update(dt)
	if self.complete then return self.to end
	self.elapsed = self.elapsed + dt
	local value = once(self.length, self.elapsed) * (self.to - self.from) + self.from
	if math.abs(value - self.to) < 0.00001 and self.complete_callback then
		self.complete_callback(self.elapsed)
		self.complete = true
	end
	return value
end