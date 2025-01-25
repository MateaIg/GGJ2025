-----------------------------------------------------------------------------------------
--
-- main_level.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require( "composer" )
local math = require("math")
local physics = require("physics")

local scene = composer.newScene()
local sceneGroup = {}
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local bubbleMaxSize = screenW / 3
local bubbleMinSize = screenW / 10 
local bubbleGenerationBeginY = screenH + bubbleMaxSize
local bubbleFinishY = -50

math.randomseed(os.time())
display.setDefault( "background", 1,1,1)

bubbles = {}

--------------------------------------------------------------------------------------------------------------
-- graphics and animations
--------------------------------------------------------------------------------------------------------------

local function showBubbleBurst(_bubble)
    local popImage = display.newImageRect( "sprites/splatter_pop.png", _bubble.width, _bubble.height)
    popImage.alpha= 0.6
    popImage.x = _bubble.x;
    popImage.y = _bubble.y;

    transition.to(
        popImage, {
            time=400, 
            delay=100,
            alpha=0,
            onComplete = function()
                display.remove(popImage)
            end
        }
    )
end

--------------------------------------------------------------------------------------------------------------
-- event listeners
--------------------------------------------------------------------------------------------------------------

local function onBubbleTap( event )
    print( "Tap bubble x:" .. event.target.width .. "y: " .. event.target.height)
    showBubbleBurst(event.target)

    event.target:removeSelf()

    return true
end

--------------------------------------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------------------------------------

local function generateNextBubbleType()

end

local function setBubbleSize(_bubble)
    local size = math.random(bubbleMinSize, bubbleMaxSize)
    _bubble.image.width = size
    _bubble.image.height = size
end

local function setBubbleStartPosition(_bubble)
    _bubble.image.x = math.random(0, screenW)
    _bubble.image.y = bubbleGenerationBeginY
end
„
local function createBubble()
    local bubble = {}
    bubble.name = "bubble"
    bubble.colorTag = "blue"
    
    bubble.image = display.newImageRect( "sprites/bubble_transparent_placeholder.png", 200, 200)

    bubble.image.x = math.random(0, screenW)
    bubble.image.y = bubbleGenerationBeginY
    -- setBubbleSize(bubble);
    -- setBubbleStartPosition(bubble)

    physics.addBody( bubble.image , "dynamic", { radius=bubble.image.width/2, density=1.0, friction=0.3, bounce=0.2 })
 
    bubble.image:addEventListener( "tap", onBubbleTap)

    -- table.insert(bubble, bubbles)
end

local function createSceneInvisibleWalls()
    -- leftSideWall = display.newRect(- bubbleMaxSize * 2, bubbleGenerationBeginY, bubbleMaxSize, bubbleGenerationBeginY - bubbleFinishY)
    -- rightSideWall = display.newRect(screenW + bubbleMaxSize, bubbleGenerationBeginY, bubbleMaxSize, bubbleGenerationBeginY - bubbleFinishY)
    leftSideWall = display.newRect(-bubbleMinSize/2, 0, bubbleMinSize, screenH )
    rightSideWall = display.newRect(screenW - bubbleMinSize/2, 0, bubbleMinSize, screenH)

    leftSideWall.anchorX = 0
    leftSideWall.anchorY = 0
    rightSideWall.anchorX = 0
    rightSideWall.anchorY = 0
    leftSideWall:setFillColor(1, 0, 0, 1) -- Invisible (red with 0 alpha)
    rightSideWall:setFillColor(1, 1, 0, 1) -- Invisible (red with 0 alpha)

    -- collision top wall
    topWall = display.newRect(0, 0, screenW, bubbleMinSize)
    topWall.anchorX = 0
    topWall.anchorY = 0

    topWall:setFillColor(0, 0, 1, 1) -- Invisible (red with 0 alpha)
end

local function setupLevel()
    physics.start()
    physics.setGravity( 0, -10)

    createSceneInvisibleWalls()
end

--------------------------------------------------------------------------------------------------------------
-- game loop
--------------------------------------------------------------------------------------------------------------

-- local function gameLoop()
--     if object.y ~= nil then
--         object.y = object.y - 2;
--         if object.y < 0 then 
--             object.y = screenH;
--         end
--     end
-- end

--------------------------------------------------------------------------------------------------------------
-- scene interface funcitons
--------------------------------------------------------------------------------------------------------------

function scene:create( event )
	sceneGroup = self.view
end

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
        setupLevel()

        timer.performWithDelay(500, createBubble ,0)
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

--------------------------------------------------------------------------------------------------------------
-- registered listeners
--------------------------------------------------------------------------------------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- Runtime:addEventListener("enterFrame", gameLoop)

return scene