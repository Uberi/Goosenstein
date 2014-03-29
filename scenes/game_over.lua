scenes = scenes or {}

require "utilities/buttons"

scenes.game_over = {
  initialize = function(self)
   self.pixel_large = love.graphics.newFont("fonts/Victor Pixel.ttf", 86)
   self.pixel_medium = love.graphics.newFont("fonts/Victor Pixel.ttf", 56)
   self.pixel_small = love.graphics.newFont("fonts/Victor Pixel.ttf", 30)
   self.credit_font = love.graphics.newFont("fonts/Victor Pixel.ttf", 14)
   
   self.restart_button = button:create("restart", 130, 400, 400, 90, self.pixel_large)
   self.exit_button = button:create("exit", 600, 400, 400, 90, self.pixel_large)
     
   self.buttons_enabled = true
   end,
   
	enter = function(self, old_scene)   
		self.restart_button = button:create("restart", 130, 400, 400, 90, self.pixel_large)
		self.exit_button = button:create("exit", 600, 400, 400, 90, self.pixel_large)
     
		self.old_scene = old_scene 
		self.buttons_enabled = true
	end,
   
   mousereleased = function(self, x, y, button)
    self.restart_button:mousereleased(x, y, button)
    self.exit_button:mousereleased(x, y, button)
  end,
  
  update = function(self, dt, elapsed)
    if self.buttons_enabled then
      self.restart_button:update(dt)
      self.exit_button:update(dt)
      if self.restart_button.was_clicked then
        self.buttons_enabled = false
        set_scene(self.old_scene)
        return
      end
      
      if self.exit_button.was_clicked then
        self.buttons_enabled = false
        set_scene(scenes.title)
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
    love.graphics.setFont(self.pixel_medium)
    love.graphics.printf("The geese overran you. You have perished.", 100, 100, 500, "center")
    love.graphics.setFont(self.credit_font)
    love.graphics.printf("Credits\n\n Anthony Zhang\t- Lead Developer\n \
                          Nerman Nicholas\t- Level Design/Developer\n \
                          Matas Empakeris\t- Developer/Research/Level Design\n\
                          Ankit Whateverurlastnameis\t- #GraphicDesigner\n\
                          Elvin Yung - Master Race Troll\n\n \
                          Special Thanks to Dan Wolczuk for narration"
                          , 450, 100, 700, "center")
                          
    
    self.restart_button:draw()
    self.exit_button:draw()
    
    love.graphics.setColor(0, 0, 0, self.darkening)
    love.graphics.rectangle("fill", 0, 0, width, height)
  end,
  }
   