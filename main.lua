--global resource tables
images = {}
fonts = {}
scenes = {}

require "scenes/title"
require "scenes/intro"

--give local aliases for globals to improve performance
local love, math = love, math
local images, fonts, scenes = images, fonts, scenes

--[[
Scene Table
-----------

Scenes are often stored in their own files, with the same general format:

    scenes.some_scene = {
		initialize = function(self) print("This is called at the start of the game.") end,
		enter = function(self) print("This is called when the scene starts") end,
		exit = function(self) print("This is called when the scene ends") end,
		update = function(self, dt, elapsed) print("This is called on every frame to perform game logic") end,
		draw = function(self, dt, elapsed) print("This is called on every frame to perform drawing") end,
		mousereleased = function(self, x, y, button) print("This is called when the mouse is released") end,
	}
]]

function love.load()
	width, height = love.graphics.getDimensions()

	for k, scene in pairs(scenes) do
		scene:initialize()
	end

	--set_scene(scenes.title) --wip: debug
	set_scene(scenes.intro)
end

current_scene = {}
function set_scene(scene)
	if not scene then
		error("No scene specified")
	end
	if current_scene.exit then
		current_scene:exit()
	end
	current_scene = scene
	if current_scene.enter then
		scene:enter()
	end
	current_start_time = love.timer.getTime()
end

function love.mousereleased(x, y, button)
	if current_scene.mousereleased then
		return current_scene:mousereleased(x, y, button)
	end
end

function love.update(dt)
	if dt > 0.05 then dt = 0.05 end --delta limit to avoid lag issues
	if current_scene.update then
		local elapsed = love.timer.getTime() - current_start_time
		return current_scene:update(dt, elapsed)
	end
end

function love.draw()
	local elapsed = love.timer.getTime() - current_start_time
	return current_scene:draw(love.timer.getDelta(), elapsed)
end