-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

_G.W = display.contentWidth;
_G.H = display.contentHeight;
_G.O = nil;

function _G.newGroup(p) -- Now we can use newGroup(p) in one line, instead of doing it in two.
	local mc=display.newGroup();
	if p and p.insert then
		p:insert(mc)
	end
	return mc;
end
function _G.cleanGroup(p) -- simple method to clean up the Group
	if(p.numChildren)then
		while(p.numChildren>0) do
			p[1]:removeSelf();
		end
	end
end
_G.rnd = math.random; -- shortcut

display.returnMiddleXY = function()
	return W/2, H/2;
end

function _G.createBtn(parent, label, loc, act)
	local mc = newGroup(parent);
	function mc:updateXY()
		mc.x, mc.y = loc();
	end
	mc:updateXY();
	
	local r = display.newRect(mc, 0, 0, 160, 36);
	r.alpha = 0.2;
	
	local btn = display.newText(mc, label, 0, 0, nil, 18);
	
	mc:addEventListener('tap', act);
	
	return mc;
end

local composer = require("composer");
composer.gotoScene("pageMenu");

local rotationIcon = display.newImage("rotation.png");
-- composer.setVariable("rotationIcon", rotationIcon);

-- Called when the app's view has been resized
local function onResize( event )
    -- print('main: resize');
	W = display.contentWidth;
	H = display.contentHeight;
	
	local currentSceneName = composer.getSceneName("current");
	local currentScene = composer.getScene(currentSceneName);
	print('main, scene orientation:', currentScene.orientation);
	
	_G.O = currentScene.orientation;
	if _G.O=="v" then
		_G.W = math.min(display.contentWidth, display.contentHeight);
		_G.H = math.max(display.contentWidth, display.contentHeight);
	elseif _G.O=="h" then
		_G.W = math.max(display.contentWidth, display.contentHeight);
		_G.H = math.min(display.contentWidth, display.contentHeight);
	end
	
	if currentScene.resize then
		currentScene:resize(event);
	end
	
	rotationIcon.x, rotationIcon.y = rotationIcon.width/2, rotationIcon.height/2;
	rotationIcon:setFillColor(1, 1, 1);
	
	if _G.O then
		if system.orientation=="landscapeLeft" or system.orientation=="landscapeRight" then
			if _G.O=="h" then
				rotationIcon:setFillColor(0, 1, 0);
			else
				rotationIcon:setFillColor(1, 0, 0);
			end
		else
			if _G.O=="v" then
				rotationIcon:setFillColor(0, 1, 0);
			else
				rotationIcon:setFillColor(1, 0, 0);
			end
		end
	end
end

_G.checkResize = function()
	onResize({});
end
 
-- Add the "resize" event listener
Runtime:addEventListener( "resize", onResize )