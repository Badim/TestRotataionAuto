--[[
  Scroll view that works when placed inside a rotated/scaled parent.
  Uses display.newContainer for clipping and contentToLocal() for touch deltas
  (widget.newScrollView assumes un-transformed coordinates and breaks under rotation).

  API subset compatible with widget.newScrollView for common options:
    parent, left, top, width, height, scrollWidth, scrollHeight,
    verticalScrollDisabled, horizontalScrollDisabled, friction, hideBackground, listener,
    captureTouchesOnOverlay (default true): full-viewport hit layer on top so dragging works.
    Set false if you need taps on row items — then set those objects isHitTestable = false so
    the scroll view (below) receives drags, or handle scroll differently.
]]

local M = {}

function M.newScrollView(options)
	options = options or {}
	local viewW = options.width or 300
	local viewH = options.height or 200
	local scrollW = options.scrollWidth or viewW
	local scrollH = options.scrollHeight or viewH
	local verticalDisabled = options.verticalScrollDisabled == true
	local horizontalDisabled = options.horizontalScrollDisabled == true
	local friction = (options.friction ~= nil) and options.friction or 0.96
	local hideBackground = options.hideBackground == true
	local listener = options.listener
	-- Topmost hit layer so drags work (otherwise icons/text receive touches first).
	local useTouchOverlay = options.captureTouchesOnOverlay ~= false

	local minX = math.min(0, viewW - scrollW)
	local maxX = 0
	local minY = math.min(0, viewH - scrollH)
	local maxY = 0

	local container = display.newContainer(viewW, viewH)
	container.anchorX = 0
	container.anchorY = 0

	if not hideBackground then
		local bg = display.newRect(0, 0, viewW, viewH)
		bg.anchorX = 0
		bg.anchorY = 0
		bg:setFillColor(0.25, 0.25, 0.25, 0.35)
		container:insert(bg)
	end

	local content = display.newGroup()
	container:insert(content)

	local touchRect
	if useTouchOverlay then
		touchRect = display.newRect(0, 0, viewW, viewH)
		touchRect.anchorX = 0
		touchRect.anchorY = 0
		touchRect:setFillColor(1, 1, 1, 0.01)
		container:insert(touchRect)
		container._touchRect = touchRect
	end

	local prevLX, prevLY
	local velX, velY = 0, 0
	local lastMoveTime = 0
	local enterFrameAdded = false
	local lastFrameTime = system.getTimer()

	local function clampPos()
		content.x = math.max(minX, math.min(maxX, content.x))
		content.y = math.max(minY, math.min(maxY, content.y))
	end

	local function onEnterFrame()
		local now = system.getTimer()
		local dtFrames = math.max(0.25, (now - lastFrameTime) / (1000 / 60))
		lastFrameTime = now

		if math.abs(velX) < 0.2 then
			velX = 0
		end
		if math.abs(velY) < 0.2 then
			velY = 0
		end
		if velX == 0 and velY == 0 then
			Runtime:removeEventListener("enterFrame", onEnterFrame)
			enterFrameAdded = false
			return
		end

		local prevX, prevY = content.x, content.y
		content.x = content.x + velX * dtFrames
		content.y = content.y + velY * dtFrames
		clampPos()

		if content.x <= minX + 0.5 or content.x >= maxX - 0.5 then
			velX = 0
		end
		if content.y <= minY + 0.5 or content.y >= maxY - 0.5 then
			velY = 0
		end

		velX = velX * friction
		velY = velY * friction

		if listener and (content.x ~= prevX or content.y ~= prevY) then
			listener({ phase = "moved", target = container, x = content.x, y = content.y })
		end
	end

	local function startMomentum()
		if enterFrameAdded then
			return
		end
		if math.abs(velX) < 1.5 and math.abs(velY) < 1.5 then
			return
		end
		lastFrameTime = system.getTimer()
		enterFrameAdded = true
		Runtime:addEventListener("enterFrame", onEnterFrame)
	end

	local function onTouch(event)
		-- Viewport-local deltas; correct under parent rotation/scale (not event.target).
		local lx, ly = container:contentToLocal(event.x, event.y)
		local target = event.target

		if event.phase == "began" then
			if enterFrameAdded then
				Runtime:removeEventListener("enterFrame", onEnterFrame)
				enterFrameAdded = false
			end
			velX, velY = 0, 0
			prevLX, prevLY = lx, ly
			lastMoveTime = system.getTimer()
			display.getCurrentStage():setFocus(target, event.id)
			target.isFocus = true
			if listener then
				listener({ phase = "began", target = container, x = content.x, y = content.y })
			end
			return true
		end

		if not target.isFocus then
			return false
		end

		if event.phase == "moved" then
			local now = system.getTimer()
			local dt = math.max(1, now - lastMoveTime)
			lastMoveTime = now

			local dx = lx - prevLX
			local dy = ly - prevLY
			prevLX, prevLY = lx, ly

			if not horizontalDisabled then
				content.x = content.x + dx
			end
			if not verticalDisabled then
				content.y = content.y + dy
			end

			clampPos()

			if not horizontalDisabled then
				velX = (dx / dt) * 18
			end
			if not verticalDisabled then
				velY = (dy / dt) * 18
			end

			if listener then
				listener({ phase = "moved", target = container, x = content.x, y = content.y })
			end
			return true
		end

		if event.phase == "ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(target, nil)
			target.isFocus = false
			clampPos()
			if listener then
				listener({ phase = event.phase, target = container, x = content.x, y = content.y })
			end
			startMomentum()
			return true
		end

		return true
	end

	if useTouchOverlay and touchRect then
		function touchRect:touch(event)
			return onTouch(event)
		end
		touchRect:addEventListener("touch", touchRect)
	else
		function container:touch(event)
			return onTouch(event)
		end
		container:addEventListener("touch", container)
	end

	-- User content: same as widget — insert into scroll content (not container shell).
	function container:insert(obj)
		return content:insert(obj)
	end

	container._content = content

	function container:getContentPosition()
		return content.x, content.y
	end

	function container:scrollToPosition(x, y, time)
		transition.to(content, {
			x = x or content.x,
			y = y or content.y,
			time = time or 400,
		})
	end

	if options.left then
		container.x = options.left
	end
	if options.top then
		container.y = options.top
	end
	if options.parent then
		options.parent:insert(container)
	end

	return container
end

return M
