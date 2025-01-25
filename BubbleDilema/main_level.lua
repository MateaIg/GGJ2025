-----------------------------------------------------------------------------------------
--
-- main_level.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require( "composer" )
local math = require("math")


math.randomseed(os.time())

local scene = composer.newScene()
local sceneGroup = {}
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local object = display.newImage( "sprites/bubble_transparent_placeholder.png")
object.name = "ball object"

object.width = 200
object.height = 200
object.x = halfW
object.y = screenH

local function onObjectTap( event )
    print( "Tap bubble x:" .. event.target.x .. "y: " .. event.target.y)
    
    local popImage = display.newImage( "sprites/splatter_pop.png")

    popImage.width = 200
    popImage.height = 200
    popImage.x = event.target.x;
    popImage.y = event.target.y;

    transition.to(
        popImage, {
            time=500, 
            delay=2000,
            alpha=0,
            onComplete = function()
                popImage = nil
            end
        }
    )

    event.target.x = math.random(0, screenW)
    event.target.y = screenH
end


local function gameLoop()
    if object.y ~= nil then
        object.y = object.y - 2;
        if object.y < 0 then 
            object.y = screenH;
        end
    end
end

--- scene interface funcitons

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
	end
end

function scene:hide( event )
	sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end
    
function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	sceneGroup = self.view
end


Runtime:addEventListener("enterFrame", gameLoop)
object:addEventListener( "tap", onObjectTap )

return scene