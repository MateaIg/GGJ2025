-----------------------------------------------------------------------------------------
--
-- main_gameMode.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local math = require("math")
local physics = require("physics")

local helper = require "helper"
-- local gameMode1 = require "game_mode_1"

math.randomseed(os.time())
-- display.setDefault( "background", 1,1,1)

local scene = composer.newScene()
local sceneGroup = {}
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local playableGameArea = { 
    startX =  0,
    startY = 0,
    endX = 0,
    endY = 0
}

local bubbleMaxSize = screenW / 3
local bubbleMinSize = screenW / 6
local bubbleGenerationBeginY = screenH + bubbleMaxSize
local bubbleFinishY = -50

local bubbleVersions = {"v1", "v2", "v3"}
local bubbleColors = nil

local finishedBubblesScore = nil
local poppedBubblesScore = nil
local gameModeTarget = nil

local scorePlaceholder = nil
local goalPlaceholder = nil
local finishDetector = nil -- zid u na kojem se baloni unistavaju i predstavlja finalno

local bubbles = {}

local bubbleCreationTimer = nil

--------------------------------------------------------------------------------------------------------------
-- populate values
--------------------------------------------------------------------------------------------------------------

local function populateBubbleScore(_gameMode)
    for i, color in pairs(bubbleColors) do
        finishedBubblesScore[color] = 0
        poppedBubblesScore[color] = 0
    end
end

local function populateInitValues(_gameMode)
    if _gameMode == 1 then
        bubbleColors = {"red", "blue", "orange", "green", "purple"}
    end

    populateBubbleScore(_gameMode)
end

--------------------------------------------------------------------------------------------------------------
-- bubble events
--------------------------------------------------------------------------------------------------------------

local function popBubble(_bubble)
    if poppedBubblesScore[_bubble.bubbleInfo.color] then
        poppedBubblesScore[_bubble.bubbleInfo.color] = poppedBubblesScore[_bubble.bubbleInfo.color] + 1
        print ("Popped " .. _bubble.bubbleInfo.color .. " bubbles: " ..  poppedBubblesScore[_bubble.bubbleInfo.color])
    end
end

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
        if finishedBubblesScore[event.other.bubbleInfo.color] ~= nil then
            finishedBubblesScore[event.other.bubbleInfo.color] = finishedBubblesScore[event.other.bubbleInfo.color] + 1
            print ("Color ".. event.other.bubbleInfo.color .. ", count: " .. finishedBubblesScore[event.other.bubbleInfo.color] )
        end

        event.other:removeSelf()
    end
end

--------------------------------------------------------------------------------------------------------------
-- functions
--------------------------------------------------------------------------------------------------------------

local function createNextBubbleInfo()
    -- todo: ovo ovisi o trenutnom statusu igre, dodaju se osnovni podaci za kreiranje bubble-a - tip, boja, size
    local bubbleInfo = {}

    bubbleInfo.imgVersion = bubbleVersions[math.random(1, 3)]
    bubbleInfo.color =  bubbleColors[math.random(1, 5)]
    bubbleInfo.size = math.random(bubbleMinSize, bubbleMaxSize)
    bubbleInfo.evil = false

    return bubbleInfo
end

local function getBubbleImagePath(_bubbleInfo)
    if _bubbleInfo.evil then
        return "res/img/bubble_evil_".. _bubbleInfo.imgVersion .. "_" .. _bubbleInfo.color .. ".png"
    else
        return "res/img/bubble_".. _bubbleInfo.imgVersion .. "_" .. _bubbleInfo.color .. ".png"
    end
end

local function setBubbleImageSize(_bubble)
    local size = math.random(bubbleMinSize, bubbleMaxSize)
    _bubble.width = size
    _bubble.height = size
end

local function setBubbleStartPosition(_bubble)
    _bubble.x = math.random(0, screenW)
    _bubble.y = bubbleGenerationBeginY
end

local function createBubble()
    bubbleInfo = createNextBubbleInfo()
    
    bubble = display.newImageRect(getBubbleImagePath(bubbleInfo), 1, 1)
    bubble.bubbleInfo = bubbleInfo

    setBubbleImageSize(bubble);
    setBubbleStartPosition(bubble)

    physics.addBody( bubble , "dynamic", { radius=bubble.width/2, density=1.0, friction=0.3, bounce=0.2 })
 
    sceneGroup:insert(bubble)

    bubble:addEventListener( "touch", onBubbleTap)

    -- table.insert(bubble, bubbles)
end

--------------------------------------------------------------------------------------------------------------
-- end game
--------------------------------------------------------------------------------------------------------------

local function endGameModeScene()
    -- composer.removeScene( "main_menu", false )
    composer.gotoScene( "menu" )
end


--------------------------------------------------------------------------------------------------------------
-- scene setup
--------------------------------------------------------------------------------------------------------------


local function showFinishedBubblesScore()
    if #finishedBubblesScore > 0 then
        for color, score in pairs(finishedBubblesScore) do

        end
    end
end

local function createSceneWalls(_gameMode)
    if _gameMode == 1 then
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

        sceneGroup:insert( leftSideWall )
        sceneGroup:insert( rightSideWall )
    end
end

local function createFinishDetector(_gameMode)
    -- collision top wall
    finishDetector = display.newRect(0, 0, screenW, bubbleMinSize / 2)
    finishDetector.anchorX = 0
    finishDetector.anchorY = 0

    finishDetector:setFillColor(0, 0, 1, 1)

    physics.addBody( finishDetector, "static", { density=1.0, friction=1, bounce=0.01 , isSensor = true})

    finishDetector.collision = onBubbleFinishCollision
    finishDetector:addEventListener( "collision" )

    sceneGroup:insert(finishDetector)
end

local function createCloudObstacle(_sector)
    local cloudW = 0
    local cloudH = 0
    local cloudX = 0
    local cloudY = 0

    if _sector == 1 then -- first lower sector
        cloudX = 0
        cloudY = 0
        cloudW = 0
        cloudH = 0
    elseif _sector == 2 then -- second middle sector
        cloudX = 0
        cloudY = 0
        cloudW = 0
        cloudH = 0
    end

    local cloud = display.newImageRect( "res/img/cloud_obstacle", width, height )

    transition.to(
        event.target, {
            time=2000, 
            delay=0,
            alpha=1,
            width=event.target.width * 1.1,
            height=event.target.height * 1.1,
            onComplete = function()
                if event.target then
                    event.target:removeSelf()
                end
            end
        }
    )

    sceneGroup:insert(cloud)
end

local function setPlayableArea()
    playableGameArea.startX = - bubbleMinSize 
    playableGameArea.endX =  screenW + bubbleMinSize

    playableGameArea.startY = finishDetector.y
    playableGameArea.endY = bubbleGenerationBeginY
end

local function setGameModeTarget(_gameMode)
    if _gameMode == 1 then 
        gameModeTarget = {}
        finishedBubblesScore = {}
        poppedBubblesScore = {}
        gameModeTarget["blue"] = 20
    end
end

-- local function drawLevelSectors()
--     s1 = display.newRect( x, y, width, height )
--     s1.setFillColor(1, 0, 0, 1)
--     s2 = display.newRect( x, y, width, height )
--     s1.setFillColor(1, 0, 0, 1)
--     s3 = display.newRect( x, y, width, height )
--     s1.setFillColor(1, 0, 0, 1)
-- end

local function setGameModeSpecificModifiers(_gameMode)
    if _gameMode == 1 then
        -- drawLevelSectors()

        timer.performWithDelay(500, createBubble ,0)
        timer.performWithDelay(5000, endGameModeScene, 1)
    end
end

local function setupGameMode(_gameMode)
    setGameModeTarget(_gameMode)
    setGameModeSpecificModifiers(_gameMode)
    populateInitValues(_gameMode)

    createSceneWalls(_gameMode)
    createFinishDetector(_gameMode)

    setPlayableArea()

    scorePlaceholder = helper.createScorePlaceholder(display, screenH, screenW)
    sceneGroup:insert(scorePlaceholder)
    goalPlaceHolder = helper.createGoalPlaceholder(display, screenH, screenW)
    sceneGroup:insert(goalPlaceHolder)

    setGameModeSpecificModifiers(_gameMode)
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
-- scene interface functions
--------------------------------------------------------------------------------------------------------------

-- Listen for the "key" event to handle back button presses
local function onKeyEvent(event)
    if event.keyName == "back" then
        if event.phase == "down" then
            composer.gotoScene("menu")
            return true
        end
    end
end

function scene:create( event )
	sceneGroup = self.view
end

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
        Runtime:addEventListener("key", onKeyEvent)
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen

        physics.start()
        physics.setGravity( 0, -5)

        setupGameMode(1)
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
        physics.stop()

        Runtime:removeEventListener("key", onKeyEvent)
        timer.cancelAll()
        print("evo radit cu hide!")

	elseif phase == "did" then
	end	
	
end
    
function scene:destroy( event )
    print("evo unistavam sve!")
	
    -- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	sceneGroup = self.view
end


--------------------------------------------------------------------------------------------------------------
-- registered listeners
--------------------------------------------------------------------------------------------------------------

-- Add the event listener for the key event
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- Runtime:addEventListener("enterFrame", gameLoop)


return scene