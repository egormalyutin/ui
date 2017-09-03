ui = {
	elements: {}
}

_NAME = (...)

hc     = require _NAME .. '.HC'

ui.mouse = hc.circle 0,0,1
ui.mouse\moveTo(love.mouse.getPosition())

ui.obj = hc.rectangle 100, 100, 200, 200

-----------------------
-- EVENTS
-----------------------

ui.draw = (elements = {}) ->
	args = ui.__pipeArray elements
	for name, element in pairs args
		element\draw!

ui.mousepressed = (elements = {}, x, y, button) ->
	args = ui.__pipeArray elements
	for name, element in pairs args
		element\mousepressed x, y, button

ui.mousereleased = (elements = {}, x, y, button) ->
	args = ui.__pipeArray elements
	for name, element in pairs args
		element\mousereleased x, y, button

ui.update = (elements = {}, x, y, dt) ->
	ui.mouse\moveTo(love.mouse.getPosition())
	args = ui.__pipeArray elements
	for name, element in pairs args
		element\update x, y

ui.destroy = (elements = {}) ->
	args = ui.__pipeArray elements
	for _, element in pairs args
		for name, destroy in pairs ui.elements
			if destroy == element
				destroy = nil
				table.remove ui.elements, name 


-----------------------
-- HELPERS
-----------------------

ui.__pipeArray = (elements) ->
	if elements.__type == "Filter"
		return elements.elements
	else
		return elements

ui.__filter = (patterns) ->
	res = {}

	exists = (element1) ->
		for _, element2 in pairs res
			if element1 == element2
				return true
		return false

	for _, pattern in pairs patterns
		for _, element in pairs ui.elements
			for _, tag in pairs element.tags
				if (not exists element)
					if type pattern == "string"
						if string.match tag, pattern
							table.insert res, element

	res

ui.__checkMouse = (elem) ->
	for shape, delta in pairs hc.collisions ui.mouse
		if shape == elem.shape
			return true

	false


-----------------------
-- CLASSES
-----------------------

ui.Filter = class
	new: (patterns) =>
		@patterns = patterns
		@elements = ui.__filter @patterns
		@__type = "Filter"

	update: =>
		@elements = nil	
		@elements = ui.__filter @patterns

ui.Element = class
	new: (s) =>
		@drawFunction   = s.draw   or () ->
		@updateFunction = s.update or () ->
		@drawf   =   @drawFunction
		@updatef = @updateFunction
		@canvas = love.graphics.newCanvas!

		@x  = s.x  or 0
		@y  = s.y  or 0
		@r  = s.r  or 0
		@sx = s.sx or 1
		@sy = s.sy or 1
		@ox = s.ox or 0
		@oy = s.oy or 0
		@kx = s.kx or 0
		@ky = s.ky or 0

		if not @x then @x = 0
		if not @y then @y = 0

		@data = s.data or {}

		@width  = s.width  or 1
		@height = s.height or 1

		@tags   = s.tags or {}

		table.insert ui.elements, @

		@\reshape!

		@on = {}

		@_focused = false
		@_pressed = false

		if type(s.mousepressedbare) == "function"
			@on.mousepressedbare = { s.mousepressedbare }
		else
			@on.mousepressedbare = s.mousepressedbare

		if type(s.mousepressed) == "function"
			@on.mousepressed = { s.mousepressed }
		else
			@on.mousepressed = s.mousepressed

		-----------

		if type(s.mousereleasedbare) == "function"
			@on.mousereleasedbare = { s.mousereleasedbare }
		else
			@on.mousereleasedbare = s.mousereleasedbare

		if type(s.mousereleased) == "function"
			@on.mousereleased = { s.mousereleased }
		else
			@on.mousereleased = s.mousereleased

		-----------

		if type(s.mousefocusbare) == "function"
			@on.mousefocusbare = { s.mousefocusbare }
		else
			@on.mousefocusbare = s.mousefocusbare

		if type(s.mousefocus) == "function"
			@on.mousefocus = { s.mousefocus }
		else
			@on.mousefocus = s.mousefocus

		-----------

		if type(s.mouseblurbare) == "function"
			@on.mouseblurbare = { s.mouseblurbare }
		else
			@on.mouseblurbare = s.mouseblurbare

		if type(s.mouseblur) == "function"
			@on.mouseblur = { s.mouseblur }
		else
			@on.mouseblur = s.mouseblur

	draw: =>
		------------------- NOW USING "REDRAW"
		-- -- Draw on canvas
		-- love.graphics.setCanvas @canvas	
  		-- love.graphics.clear!
		-- @drawFunction!

		-- -- Set default canvas
		-- love.graphics.setCanvas!

		-- Draw canvas
		love.graphics.push 'all'

		love.graphics.translate @x, @y
		love.graphics.rotate @r
		love.graphics.scale @sx, @sy
		love.graphics.translate (-@ox), (-@oy)
		love.graphics.shear @kx, @ky
		@drawf @

		love.graphics.pop!

	reshape: =>
		@shape = hc.rectangle(
			((@x - @ox) * @sx),
			((@y - @oy) * @sy),
			@width, @height
		)
		@shape\setRotation @r, @x, @y


	mousepressed: (x, y, button) =>
		x = x or love.mouse.getX!
		y = y or love.mouse.getY!

		if ui.__checkMouse @
			if @on.mousepressedbare ~= nil
				for _, listener in pairs @on.mousepressedbare
						listener @, x, y, button

			if (@on.mousepressed ~= nil) and (not @_pressed)
				for _, listener in pairs @on.mousepressed
						listener @, x, y, button	
			@\__setPressed true

	mousereleased: (x, y, button) =>
		x = x or love.mouse.getX!
		y = y or love.mouse.getY!

		if ui.__checkMouse @
			if @on.mousereleasedbare ~= nil
				for _, listener in pairs @on.mousereleasedbare
						listener @, x, y, button

			if (@on.mousereleased ~= nil) and (@_pressed)
				for _, listener in pairs @on.mousereleased
						listener @, x, y, button	

			@\__setPressed false

	update: (x, y) =>
		x = x or love.mouse.getX!
		y = y or love.mouse.getY!

		if ui.__checkMouse @
			if @on.mousefocusbare ~= nil
				for _, listener in pairs @on.mousefocusbare
						listener @, x, y, button

			if (@on.mouserfocus ~= nil) and (@_focused)
				for _, listener in pairs @on.mousefocus
						listener @, x, y, button	

			@\__setFocused true
		else
			if @on.mouseblurbare ~= nil
				for _, listener in pairs @on.mouseblurbare
					listener @, x, y, button

			if (@on.mouserblur ~= nil) and (not @_focused)
				for _, listener in pairs @on.mouseblur
						listener @, x, y, button
			@\__setFocused false 
		@updateFunction @, x, y

	__setPressed: (value) =>
		@_pressed  = value
		@pressed   = value
		@press     = value
		@release  = not value
		@released = not value

	__setFocused: (value) =>
		@_focused = value
		@focused  = value
		@focus    = value
		@hover    = value
		@hovered  = value
		@blured   = not value
		@blur     = not value
		if not value
			@\__setPressed false

return ui