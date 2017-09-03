local ui = {
  elements = { }
}
local _NAME = (...)
local hc = require(_NAME .. '.HC')
ui.mouse = hc.circle(0, 0, 1)
ui.mouse:moveTo(love.mouse.getPosition())
ui.obj = hc.rectangle(100, 100, 200, 200)
ui.draw = function(elements)
  if elements == nil then
    elements = { }
  end
  local args = ui.__pipeArray(elements)
  for name, element in pairs(args) do
    element:draw()
  end
end
ui.mousepressed = function(elements, x, y, button)
  if elements == nil then
    elements = { }
  end
  local args = ui.__pipeArray(elements)
  for name, element in pairs(args) do
    element:mousepressed(x, y, button)
  end
end
ui.mousereleased = function(elements, x, y, button)
  if elements == nil then
    elements = { }
  end
  local args = ui.__pipeArray(elements)
  for name, element in pairs(args) do
    element:mousereleased(x, y, button)
  end
end
ui.update = function(elements, x, y, dt)
  if elements == nil then
    elements = { }
  end
  ui.mouse:moveTo(love.mouse.getPosition())
  local args = ui.__pipeArray(elements)
  for name, element in pairs(args) do
    element:update(x, y)
  end
end
ui.destroy = function(elements)
  if elements == nil then
    elements = { }
  end
  local args = ui.__pipeArray(elements)
  for _, element in pairs(args) do
    for name, destroy in pairs(ui.elements) do
      if destroy == element then
        destroy = nil
        table.remove(ui.elements, name)
      end
    end
  end
end
ui.__pipeArray = function(elements)
  if elements.__type == "Filter" then
    return elements.elements
  else
    return elements
  end
end
ui.__filter = function(patterns)
  local res = { }
  local exists
  exists = function(element1)
    for _, element2 in pairs(res) do
      if element1 == element2 then
        return true
      end
    end
    return false
  end
  for _, pattern in pairs(patterns) do
    for _, element in pairs(ui.elements) do
      for _, tag in pairs(element.tags) do
        if (not exists(element)) then
          if type(pattern == "string") then
            if string.match(tag, pattern) then
              table.insert(res, element)
            end
          end
        end
      end
    end
  end
  return res
end
ui.__checkMouse = function(elem)
  for shape, delta in pairs(hc.collisions(ui.mouse)) do
    if shape == elem.shape then
      return true
    end
  end
  return false
end
do
  local _class_0
  local _base_0 = {
    update = function(self)
      self.elements = nil
      self.elements = ui.__filter(self.patterns)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, patterns)
      self.patterns = patterns
      self.elements = ui.__filter(self.patterns)
      self.__type = "Filter"
    end,
    __base = _base_0,
    __name = "Filter"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ui.Filter = _class_0
end
do
  local _class_0
  local _base_0 = {
    draw = function(self)
      love.graphics.push('all')
      love.graphics.translate(self.x, self.y)
      love.graphics.rotate(self.r)
      love.graphics.scale(self.sx, self.sy)
      love.graphics.translate((-self.ox), (-self.oy))
      love.graphics.shear(self.kx, self.ky)
      self:drawf(self)
      return love.graphics.pop()
    end,
    reshape = function(self)
      self.shape = hc.rectangle(((self.x - self.ox) * self.sx), ((self.y - self.oy) * self.sy), self.width, self.height)
      return self.shape:setRotation(self.r, self.x, self.y)
    end,
    mousepressed = function(self, x, y, button)
      x = x or love.mouse.getX()
      y = y or love.mouse.getY()
      if ui.__checkMouse(self) then
        if self.on.mousepressedbare ~= nil then
          for _, listener in pairs(self.on.mousepressedbare) do
            listener(self, x, y, button)
          end
        end
        if (self.on.mousepressed ~= nil) and (not self._pressed) then
          for _, listener in pairs(self.on.mousepressed) do
            listener(self, x, y, button)
          end
        end
        return self:__setPressed(true)
      end
    end,
    mousereleased = function(self, x, y, button)
      x = x or love.mouse.getX()
      y = y or love.mouse.getY()
      if ui.__checkMouse(self) then
        if self.on.mousereleasedbare ~= nil then
          for _, listener in pairs(self.on.mousereleasedbare) do
            listener(self, x, y, button)
          end
        end
        if (self.on.mousereleased ~= nil) and (self._pressed) then
          for _, listener in pairs(self.on.mousereleased) do
            listener(self, x, y, button)
          end
        end
        return self:__setPressed(false)
      end
    end,
    update = function(self, x, y)
      x = x or love.mouse.getX()
      y = y or love.mouse.getY()
      if ui.__checkMouse(self) then
        if self.on.mousefocusbare ~= nil then
          for _, listener in pairs(self.on.mousefocusbare) do
            listener(self, x, y, button)
          end
        end
        if (self.on.mouserfocus ~= nil) and (self._focused) then
          for _, listener in pairs(self.on.mousefocus) do
            listener(self, x, y, button)
          end
        end
        self:__setFocused(true)
      else
        if self.on.mouseblurbare ~= nil then
          for _, listener in pairs(self.on.mouseblurbare) do
            listener(self, x, y, button)
          end
        end
        if (self.on.mouserblur ~= nil) and (not self._focused) then
          for _, listener in pairs(self.on.mouseblur) do
            listener(self, x, y, button)
          end
        end
        self:__setFocused(false)
      end
      return self:updateFunction(self, x, y)
    end,
    __setPressed = function(self, value)
      self._pressed = value
      self.pressed = value
      self.press = value
      self.release = not value
      self.released = not value
    end,
    __setFocused = function(self, value)
      self._focused = value
      self.focused = value
      self.focus = value
      self.hover = value
      self.hovered = value
      self.blured = not value
      self.blur = not value
      if not value then
        return self:__setPressed(false)
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, s)
      self.drawFunction = s.draw or function() end
      self.updateFunction = s.update or function() end
      self.drawf = self.drawFunction
      self.updatef = self.updateFunction
      self.canvas = love.graphics.newCanvas()
      self.x = s.x or 0
      self.y = s.y or 0
      self.r = s.r or 0
      self.sx = s.sx or 1
      self.sy = s.sy or 1
      self.ox = s.ox or 0
      self.oy = s.oy or 0
      self.kx = s.kx or 0
      self.ky = s.ky or 0
      if not self.x then
        self.x = 0
      end
      if not self.y then
        self.y = 0
      end
      self.data = s.data or { }
      self.width = s.width or 1
      self.height = s.height or 1
      self.tags = s.tags or { }
      table.insert(ui.elements, self)
      self:reshape()
      self.on = { }
      self._focused = false
      self._pressed = false
      if type(s.mousepressedbare) == "function" then
        self.on.mousepressedbare = {
          s.mousepressedbare
        }
      else
        self.on.mousepressedbare = s.mousepressedbare
      end
      if type(s.mousepressed) == "function" then
        self.on.mousepressed = {
          s.mousepressed
        }
      else
        self.on.mousepressed = s.mousepressed
      end
      if type(s.mousereleasedbare) == "function" then
        self.on.mousereleasedbare = {
          s.mousereleasedbare
        }
      else
        self.on.mousereleasedbare = s.mousereleasedbare
      end
      if type(s.mousereleased) == "function" then
        self.on.mousereleased = {
          s.mousereleased
        }
      else
        self.on.mousereleased = s.mousereleased
      end
      if type(s.mousefocusbare) == "function" then
        self.on.mousefocusbare = {
          s.mousefocusbare
        }
      else
        self.on.mousefocusbare = s.mousefocusbare
      end
      if type(s.mousefocus) == "function" then
        self.on.mousefocus = {
          s.mousefocus
        }
      else
        self.on.mousefocus = s.mousefocus
      end
      if type(s.mouseblurbare) == "function" then
        self.on.mouseblurbare = {
          s.mouseblurbare
        }
      else
        self.on.mouseblurbare = s.mouseblurbare
      end
      if type(s.mouseblur) == "function" then
        self.on.mouseblur = {
          s.mouseblur
        }
      else
        self.on.mouseblur = s.mouseblur
      end
    end,
    __base = _base_0,
    __name = "Element"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ui.Element = _class_0
end
return ui
