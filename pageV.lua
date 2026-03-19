-- module(..., package.seeall);
local composer = require("composer");
local scene = composer.newScene();
scene.orientation = "v";
-- -----------------------------------------------------------------------------------
local gameGroup;
local UIs = {};
local itxt;

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
	
	local btn = display.newText(gameGroup, "V", W/2, 100, nil, 48);
	function btn:updateXY()
		self.x, self.y = W/2, 100;
	end
	btn:updateXY();
	table.insert(UIs, btn);
	
	local dtxt1 = display.newText(gameGroup, "always portrait / vertical", W/2, 140, nil, 24);
	function dtxt1:updateXY()
		self.x, self.y = W/2, 140;
	end
	dtxt1:updateXY();
	table.insert(UIs, dtxt1);
	
	local btn = createBtn(gameGroup, "menu", display.returnMiddleXY, function(e)
		composer.gotoScene("pageMenu");
	end);
	table.insert(UIs, btn);
	
	local mc = newGroup(gameGroup);
	-- mc.x, mc.y = 160, H-200;
	local r = display.newRect(mc, 0, 0, 160, 60);
	r.alpha = 1/3;
	local dtxt0 = display.newText(mc, '"width X height" vs "contentWidth X contentHight"', 0, -46, nil, 22);
	local dtxt1 = display.newText(mc, "WxH", 0, -18, nil, 18);
	local dtxt2 = display.newText(mc, "WxH", 0, 18, nil, 18);
	function mc:updateXY()
		mc.x, mc.y = W/2, H-200;
		dtxt1.text = r.width .. "x" .. r.height;
		dtxt2.text = r.contentWidth .. "x" .. r.contentHeight;
	end
	mc:updateXY();
	table.insert(UIs, mc);
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
	
	-- print("ORIENTATION: ", system.orientation);
	-- portrait, portraitUpsideDown 
	-- landscapeLeft, landscapeRight
	-- gameGroup.rotation = 90;
	if scene.orientation == "v" then
		if system.orientation=="landscapeLeft" or system.orientation=="landscapeRight" then
			gameGroup.rotation = 90;
			gameGroup.x = H;
			if itxt then
				itxt.rotation = 90;
			end
		else
			gameGroup.rotation = 0;
			gameGroup.x = 0;
			if itxt then
				itxt.rotation = 0;
			end
		end
	end
	
	-- object:localToContent( x, y )
	-- itxt._bg 
	if itxt then
		itxt.x, itxt.y = itxt._bg:localToContent(0, 0);
	end
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
		
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
		-- scene:resize({});
		checkResize();
		
		itxt = native.newTextField(0, 0, 200, 30);
		function itxt:updateXY()
			self.x, self.y = W/2, H*0.19;
		end
		itxt:updateXY();
		table.insert(UIs, itxt);
		
		local itxtBG = display.newRect(gameGroup, itxt.x, itxt.y, itxt.width+10, itxt.height+10);
		itxtBG:setFillColor(0, 1, 1, 0.3);
		itxt._bg = itxtBG;
		
		-- if itxt and itxt._bg then
			-- itxt.x, itxt.y = itxt._bg:localToContent(0, 0);
		-- end
		
		scene:resize({});
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
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene