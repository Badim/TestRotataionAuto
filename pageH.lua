-- module(..., package.seeall);
local composer = require("composer");
local scene = composer.newScene();
scene.orientation = "h";
--------------------------------------------------------------------------------------
local rotatableScrollView = require("rotatableScrollView");
-- -----------------------------------------------------------------------------------
local gameGroup;
local UIs = {};

function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
	gameGroup = newGroup(sceneGroup);
	
	local r = display.newRect(gameGroup, W/2, H/2, W*0.9, H*0.9);
	r:setFillColor(0, 0, 1, 0.3);
	function r:updateXY()
		self.x, self.y = W/2, H/2;
	end
	function r:updateWH()
		self.width, self.height = W*0.9, H*0.9;
	end
	r:updateWH();
	table.insert(UIs, r);
	
	local img = display.newImage(gameGroup, "btn.png");
	img.x, img.y = W/2, H*0.31;
	function img:updateXY()
		self.x, self.y = W/2, H*0.31;
	end
	img:updateXY();
	table.insert(UIs, img);
	
	local btn = display.newText(gameGroup, "H", W/2, 100, nil, 48);
	function btn:updateXY()
		self.x, self.y = W/2, 100;
	end
	btn:updateXY();
	table.insert(UIs, btn);
	
	local dtxt1 = display.newText(gameGroup, "always landscape / horizontal", W/2, 140, nil, 24);
	function dtxt1:updateXY()
		self.x, self.y = W/2, 140;
	end
	dtxt1:updateXY();
	table.insert(UIs, dtxt1);
	
	local btn = createBtn(gameGroup, "menu", display.returnMiddleXY, function(e)
		composer.gotoScene("pageMenu");
	end);
	table.insert(UIs, btn);
	
	local scrollW, scrollH = W-120, 160;
	-- scrollWidth must cover laid-out content (widget scrollWidth was same as viewport; that yields no scroll room).
	local itemPitch = 90
	local numItems = 41
	local scrollView = rotatableScrollView.newScrollView({
		width = scrollW,
		height = scrollH,
		scrollWidth = (numItems) * itemPitch,
		scrollHeight = scrollH,
		verticalScrollDisabled = true,
		friction = 0.96,
		debugDraw = true, -- green = viewport clip; yellow/red = full scroll content bounds; cyan = HUD
		listener = function(event)
			-- print("phase:", event.phase, event.x, event.y)
		end,
	})
	scrollView.x, scrollView.y = W/2, H - 280;
	gameGroup:insert(scrollView);
	
	for i=0,40 do
		local itemmc=newGroup(scrollView);
		itemmc.x, itemmc.y = i*90, scrollH/2;
		
		local itemBody = display.newImage(itemmc, "Icon.png");
		itemBody.rotation = math.random(1, 360);
		
		local itemTxt = display.newText(itemmc, i, 0, 0, nil, 24);
		itemTxt:setFillColor(0);
	end
end

function scene:resize( event )
	print('scene: resize', scene.orientation);
    -- Use display.contentCenterX and display.contentCenterY for centering
	for i=1,#UIs do
		local mc = UIs[i];
		if mc and mc.updateXY then
			mc:updateXY();
		end
		if mc and mc.updateWH then
			mc:updateWH();
		end
	end
	
	print("ORIENTATION: ", system.orientation);
	-- portrait, portraitUpsideDown 
	-- landscapeLeft, landscapeRight
	-- gameGroup.rotation = 90;
	if scene.orientation == "h" then
		if system.orientation=="landscapeLeft" or system.orientation=="landscapeRight" then
			gameGroup.rotation = 0;
			gameGroup.x = 0;
		else
			gameGroup.rotation = 90;
			gameGroup.x = H;
		end
	end
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		checkResize();
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
    end
end
 
function scene:destroy( event )
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene