module(..., package.seeall);
local composer = require("composer");
local scene = composer.newScene();
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
scene.orientation = nil;

-- local logo;
-- local btn1, btn2;

local gameGroup;
local UIs = {};
local itxt;

function scene:create( event )
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
	
	gameGroup = newGroup(sceneGroup);
	local logo = display.newImage(gameGroup, "logo.png");
	function logo:updateXY()
		logo.x, logo.y = W/2, 100;
	end
	logo:updateXY();
	table.insert(UIs, logo);
	
	local btn1 = createBtn(gameGroup, "goto: pageV", display.returnMiddleXY, function(e)
		composer.gotoScene("pageV");
	end);
	table.insert(UIs, btn1);
	
	local btn2 = createBtn(gameGroup, "goto: pageH", function()
		return W/2, H/2 + 60;
	end, function(e)
		composer.gotoScene("pageH");
	end);
	table.insert(UIs, btn2);
	
	local mc = newGroup(gameGroup);
	mc.x, mc.y = 200, 200;
	local r = display.newRect(mc, 0, 0, 160, 40);
	r.alpha = 1/3;
	local dtxt = display.newText(mc, "WxH", 0, 0, nil, 20);
	function mc:updateXY()
		mc.x, mc.y = 200, 200;
		dtxt.text = r.contentWidth .. "x" .. r.contentHeight;
	end
	mc:updateXY();
	table.insert(UIs, mc);
end

function scene:resize( event )
	print('scene: resize');
    -- Use display.contentCenterX and display.contentCenterY for centering
	for i=1,#UIs do -- clean up nil pointers!
		local mc = UIs[i];
		if mc and mc.updateXY then
			mc:updateXY();
		end
		if mc and mc.updateWH then
			mc:updateWH();
		end
	end
	
	-- display.remove(itxt);
	
	-- timer.performWithDelay(100, function()
		-- itxt = native.newTextField(W/2, H*0.28, 200, 30);
	-- end)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		checkResize();
		
		itxt = native.newTextField(W/2, H*0.28, 200, 30);
		function itxt:updateXY()
			self.x, self.y = W/2, H*0.28;
		end
		table.insert(UIs, itxt);
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
		display.remove(itxt);
		itxt = nil;
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
scene:addEventListener( "resize", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene