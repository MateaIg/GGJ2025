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

local bubbleMaxSize = screenW / 4
local bubbleMinSize = screenW / 6
local bubbleGenerationBeginY = screenH + bubbleMaxSize
local bubbleFinishY = -50

math.randomseed(os.time())
display.setDefault( "background", 1,1,1)

bubbles = {}

--------------------------------------------------------------------------------------------------------------
-- graphics and animations
--------------------------------------------------------------------------------------------------------------

local function showBubbleBurst(_bubble)
    transition.to(
        _bubble, {
            time=50, 
            delay=0,
            alpha=0,
            width=_bubble.width * 1.1,
            height=_bubble.height * 1.1,
            onComplete = function()
                display.remove(popImage)
            end
        }
    )


    -- local popImage = display.newImageRect("res/img/bubble_v1_blue_splash.png", _bubble.width * 1.3, _bubble.height * 1.3)
    -- popImage.alpha = 1
    -- popImage.x = _bubble.x;
    -- popImage.y = _bubble.y;

    -- transition.to(
    --     popImage, {
    --         time=500, 
    --         delay=100,
    --         alpha=0,
    --         width=_bubble.width * 0.5,
    --         height=_bubble.height * 0.5,
    --         onComplete = function()
    --             display.remove(popImage)
    --         end
    --     }
    -- )
end

--------------------------------------------------------------------------------------------------------------
-- event listeners
--------------------------------------------------------------------------------------------------------------

local function onBubbleTap( event )

    if ( event.phase == "began" ) then
        print( "Tap bubble x:" .. event.target.width .. "y: " .. event.target.height)
        
        local availableChannel = audio.findFreeChannel(3)
        
        audio.play(popSound[math.random(1, 3)], {
            channel = availableChannel
        }) 
        -- Code executed when the button is touched
        print( "object touched = " .. tostring(event.target) )  -- "event.target" is the touched object
    elseif ( event.phase == "moved" ) then
        -- Code executed when the touch is moved over the object
        print( "touch location in content coordinates = " .. event.x .. "," .. event.y )
    elseif ( event.phase == "ended" ) then
        showBubbleBurst(event.target)
        -- Code executed when the touch lifts off the object
        print( "touch ended on object " .. tostring(event.target) )
    end

    return true
end

      
local function onBubbleFinishCollision( self, event )
    if event.other ~= nil then 
        event.other:removeSelf()
    end
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

local colors = { 'blue', 'red', 'green', 'orange', 'purple' }

local function createBubble()
    local bubble = {}
    bubble.name = "bubble"
    bubble.colorTag = colors[math.random(1, 5)]
    
    bubble.version = math.random(1, 3)

    bubble.image = display.newImageRect( "res/img/bubble_v" .. bubble.version .. "_" .. bubble.colorTag .. ".png", 200, 200)

    setBubbleSize(bubble);
    setBubbleStartPosition(bubble)

    physics.addBody( bubble.image , "dynamic", { radius=bubble.image.width/2, density=1.0, friction=0.3, bounce=1 })
 
    bubble.image:addEventListener( "touch", onBubbleTap)

    -- table.insert(bubble, bubbles)
end

local function createSceneInvisibleWalls()
    -- leftSideWall = display.newRect(- bubbleMaxSize * 2, bubbleGenerationBeginY, bubbleMaxSize, bubbleGenerationBeginY - bubbleFinishY)
    -- rightSideWall = display.newRect(screenW + bubbleMaxSize, bubbleGenerationBeginY, bubbleMaxSize, bubbleGenerationBeginY - bubbleFinishY)
    leftSideWall = display.newRect(-bubbleMinSize/2, 0, bubbleMinSize, screenH )
    rightSideWall = display.newRect(screenW + bubbleMinSize/2, 0, bubbleMinSize, screenH)

    leftSideWall.anchorX = 1
    leftSideWall.anchorY = 0
    rightSideWall.anchorX = 0
    rightSideWall.anchorY = 0
    leftSideWall:setFillColor(1, 0, 0, 1) -- Invisible (red with 0 alpha)
    rightSideWall:setFillColor(1, 1, 0, 1) -- Invisible (red with 0 alpha)

    physics.addBody( leftSideWall, "static")
    physics.addBody( rightSideWall, "static")
    
    -- collision top wall
    topWall = display.newRect(0, 0, screenW, bubbleMinSize / 2)
    topWall.anchorX = 0
    topWall.anchorY = 0

    topWall:setFillColor(0, 0, 1, 1) -- Invisible (red with 0 alpha)

    physics.addBody( topWall, "static", { density=1.0, friction=0, bounce=0 , isSensor = true})

    topWall.collision = onBubbleFinishCollision
    topWall:addEventListener( "collision" )
end

local function setupLevel()
    physics.start()
    physics.setGravity( 0, -2)

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

    local background = display.newImageRect(sceneGroup, "res/img/pastel_background.jpg", screenW, screenH)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert(background)
end

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
        setupLevel()

        timer.performWithDelay(300, createBubble ,0)
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

-- Listen for the "key" event to handle back button presses
local function onKeyEvent(event)
    if event.keyName == "back" then
        if event.phase == "down" then
            composer.gotoScene("menu")
            return true
        end
    end
end

-- Add the event listener for the key event
Runtime:addEventListener("key", onKeyEvent)

--------------------------------------------------------------------------------------------------------------
-- registered listeners
--------------------------------------------------------------------------------------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- Runtime:addEventListener("enterFrame", gameLoop)

return scene