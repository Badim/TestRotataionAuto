--[[
  Scroll view that works when placed inside a rotated/scaled parent.
  Uses display.newContainer for clipping and contentToLocal() for touch deltas.

  Solar2D containers clip around their origin with default anchor 0.5/0.5: child (0,0)
  is the viewport center, not the top-left. This module aligns bg/touch/content to that
  system and clamps scroll in the same local space.

  Options (subset of widget.newScrollView):
    width, height, scrollWidth, scrollHeight,
    verticalScrollDisabled, horizontalScrollDisabled, friction, hideBackground, listener,
    parent, left, top,
    captureTouchesOnOverlay (default true),
    debugDraw (default false): viewport stroke, content-bounds fill+stroke, optional HUD text,
    anchorX, anchorY (default 0.5): container placement; x/y are the viewport center.
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
	local useTouchOverlay = options.captureTouchesOnOverlay ~= false
	local debugDraw = options.debugDraw == true

	-- Container local space: origin at viewport CENTER (default newContainer behavior).
	local maxX = -viewW * 0.5
	local minX = viewW * 0.5 - scrollW
	if minX > maxX then
		minX = maxX
	end
	local maxY = -viewH * 0.5
	local minY = viewH * 0.5 - scrollH
	if minY > maxY then
		minY = maxY
	end

	local container = display.newContainer(viewW, viewH)
	container.anchorX = (options.anchorX ~= nil) and options.anchorX or 0.5
	container.anchorY = (options.anchorY ~= nil) and options.anchorY or 0.5

	if not hideBackground then
		local bg = display.newRect(0, 0, viewW, viewH)
		bg:setFillColor(0.25, 0.25, 0.25, 0.35)
		container:insert(bg)
	end

	local content = display.newGroup()
	container:insert(content)

	-- Start with left/top of scroll content aligned to viewport left/top (center-origin space).
	content.x = maxX
	content.y = maxY

	local debugViewportRect, debugContentRect, debugHud

	if debugDraw then
		debugViewportRect = display.newRect(0, 0, viewW, viewH)
		debugViewportRect:setFillColor(0, 0, 0, 0)
		debugViewportRect:setStrokeColor(0, 1, 0)
		debugViewportRect.strokeWidth = 2
		debugViewportRect.isHitTestable = false
		container:insert(debugViewportRect)

		debugContentRect = display.newRect(scrollW * 0.5, scrollH * 0.5, scrollW, scrollH)
		debugContentRect:setFillColor(1, 1, 0, 0.12)
		debugContentRect:setStrokeColor(1, 0, 0)
		debugContentRect.strokeWidth = 2
		debugContentRect.isHitTestable = false
		content:insert(1, debugContentRect)

		debugHud = display.newText(container, "", 0, -viewH * 0.5 - 14, native.systemFont, 11)
		debugHud:setFillColor(0, 1, 1)
		debugHud.anchorY = 1
		debugHud.isHitTestable = false
	end

	local touchRect
	if useTouchOverlay then
		touchRect = display.newRect(0, 0, viewW, viewH)
		touchRect:setFillColor(1, 1, 1, 0.01)
		container:insert(touchRect)
		container._touchRect = touchRect
	end

	local function updateDebugHud()
		if debugHud then
			debugHud.text = string.format(
				"content: %.0f, %.0f  |  clamp X [%.0f..%.0f]  Y [%.0f..%.0f]",
				content.x,
				content.y,
				minX,
				maxX,
				minY,
				maxY
			)
		end
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
		if debugDraw then
			updateDebugHud()
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
			if debugDraw then
				updateDebugHud()
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
			if debugDraw then
				updateDebugHud()
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
			if debugDraw then
				updateDebugHud()
			end
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
			onComplete = function()
				clampPos()
			end,
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

	if debugDraw then
		updateDebugHud()
	end

	return container
end

return M
