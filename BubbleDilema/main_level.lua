-----------------------------------------------------------------------------------------
--
-- main_level.lua
--
-----------------------------------------------------------------------------------------
local helper = require "helper"
local composer = require( "composer" )
local math = require("math")
local physics = require("physics")

math.randomseed(os.time())
display.setDefault( "background", 1,1,1)

local scene = composer.newScene()
local sceneGroup = {}
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local bubbleMaxSize = screenW / 3
local bubbleMinSize = screenW / 6
local bubbleGenerationBeginY = screenH + bubbleMaxSize
local bubbleFinishY = -50

local bubbleVersions = {"v1", "v2", "v3"}
local bubbleColors = {"red", "blue", "orange", "green", "purple"}

local finishedBubblesScore = {}
local poppedBubblesScore = {}
local levelTarget = {}

local scorePlaceholder = nil
local goalPlaceholder = nil
local finishDetector = nil

local bubbles = {}

--------------------------------------------------------------------------------------------------------------
-- populate values
--------------------------------------------------------------------------------------------------------------

local function populateBubbleScore(_level)
    for i, color in pairs(bubbleColors) do
        finishedBubblesScore[color] = 0
        poppedBubblesScore[color] = 0
    end
end

local function populateInitValues(_level)
    populateBubbleScore(_level)
end

--------------------------------------------------------------------------------------------------------------
-- bubble mechanics
--------------------------------------------------------------------------------------------------------------

local function popBubble(_bubbleImage)
    if poppedBubblesScore[_bubbleImage.colorTag] then
        poppedBubblesScore[_bubbleImage.colorTag] = poppedBubblesScore[_bubbleImage.colorTag] + 1
        print ("Popped " .. _bubbleImage.colorTag .. " bubbles: " ..  poppedBubblesScore[_bubbleImage.colorTag])
    end
end

--------------------------------------------------------------------------------------------------------------
-- event listeners
--------------------------------------------------------------------------------------------------------------

local function onBubbleTap( event )
    if ( event.phase == "began" ) then
        popBubble(event.target)

        transition.to(
            event.target, {
                time=50, 
                delay=0,
                alpha=0,
                width=event.target.width * 1.1,
                height=event.target.height * 1.1,
                onComplete = function()
                    if event.target then
                        event.target:removeSelf()
                    end
                end
            }
        )
    end

    return true
end

local function onBubbleFinishCollision( self, event )
    if event.other ~= nil then
        if finishedBubblesScore[event.other.colorTag] ~= nil then
            print ("Color ".. event.other.colorTag .. ", count: " .. finishedBubblesScore[event.other.colorTag] )
            finishedBubblesScore[event.other.colorTag] = finishedBubblesScore[event.other.colorTag] + 1
        end

        event.other:removeSelf()
    end
end

--------------------------------------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------------------------------------

local function createNextBubble()
    -- todo: ovo ovisi o trenutnom statusu igre, dodaju se osnovni podaci za kreiranje bubble-a - tip, boja, size
    local bubble = {}

    bubble.imgVersion = bubbleVersions[math.random(1, 3)]
    bubble.color =  bubbleColors[math.random(1, 5)]
    bubble.size = math.random(bubbleMinSize, bubbleMaxSize)
    bubble.evil = false

    return bubble
end

local function getBubbleImagePath(_bubble)
    if _bubble.evil then
        return "res/img/bubble_".. bubble.imgVersion .. "_" .. _bubble.color .. ".png"
    else
        return "res/img/bubble_".. bubble.imgVersion .. "_" .. _bubble.color .. ".png"
    end
end

local function setBubbleImageSize(_bubble)
    local size = math.random(bubbleMinSize, bubbleMaxSize)
    _bubble.image.width = size
    _bubble.image.height = size
end

local function setBubbleStartPosition(_bubble)
    _bubble.image.x = math.random(0, screenW)
    _bubble.image.y = bubbleGenerationBeginY
end

local function createBubble()

    bubble = createNextBubble()
    
    bubble.image = display.newImageRect( getBubbleImagePath(bubble), 1, 1)
    bubble.image.colorTag = bubble.color

    setBubbleImageSize(bubble);
    setBubbleStartPosition(bubble)

    physics.addBody( bubble.image , "dynamic", { radius=bubble.image.width/2, density=1.0, friction=0.3, bounce=0.2 })
 
    bubble.image:addEventListener( "touch", onBubbleTap)

    -- table.insert(bubble, bubbles)
end

--------------------------------------------------------------------------------------------------------------
-- scene setup
--------------------------------------------------------------------------------------------------------------

local function showfinishedBubblesScore()
    if #finishedBubblesScore > 0 then
        for color, score in pairs(finishedBubblesScore) do
            display.newText( options )
        end
    end
end

local function createSceneWalls(_level)
    if _level == 1 then
        leftSideWall = display.newRect(-bubbleMinSize/2, 0, bubbleMinSize, screenH )
        rightSideWall = display.newRect(screenW + bubbleMinSize/2, 0, bubbleMinSize, screenH)
    
        leftSideWall.anchorX = 1
        leftSideWall.anchorY = 0
        rightSideWall.anchorX = 0
        rightSideWall.anchorY = 0
        leftSideWall:setFillColor(1, 0, 0, 0)
        rightSideWall:setFillColor(1, 1, 0, 0)
    
        physics.addBody( leftSideWall, "static")
        physics.addBody( rightSideWall, "static")
    end
end

local function createFinishDetector(_level)
    -- collision top wall
    finishDetector = display.newRect(0, 0, screenW, bubbleMinSize / 2)
    finishDetector.anchorX = 0
    finishDetector.anchorY = 0

    finishDetector:setFillColor(0, 0, 1, 1)

    physics.addBody( finishDetector, "static", { density=1.0, friction=1, bounce=0.01 , isSensor = true})

    finishDetector.collision = onBubbleFinishCollision
    finishDetector:addEventListener( "collision" )
end

local function setLevelTarget(_level)
    if _level == 1 then 
        levelTarget["blue"] = 20
    end
end

local function setupLevel(_level)
    setLevelTarget(_level)

    populateInitValues(_level)

    createSceneWalls(_level)
    createFinishDetector(_level)

    scorePlaceholder = helper.createScorePlaceholder(display, screenH, screenW)
    goalPlaceHolder = helper.createGoalPlaceholder(display, screenH, screenW)
end

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

        physics.start()
        physics.setGravity( 0, -5)

        setupLevel(1)

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

-- Listen for the "key" event to handle back button presses
local function onKeyEvent(event)
    if event.keyName == "back" then
        if event.phase == "down" then
            composer.gotoScene("menu")
            return true
        end
    end
end

--------------------------------------------------------------------------------------------------------------
-- registered listeners
--------------------------------------------------------------------------------------------------------------

-- Add the event listener for the key event
Runtime:addEventListener("key", onKeyEvent)
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- Runtime:addEventListener("enterFrame", gameLoop)

return scene