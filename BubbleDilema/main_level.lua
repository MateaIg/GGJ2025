-----------------------------------------------------------------------------------------
--
-- main_level.lua
--
-----------------------------------------------------------------------------------------

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

local bubbleColors = {"red", "blue", "orange", "green", "purple"}
local bubbleColorScore = {}
local colorTargets = {}

local scorePlaceholder = nil
local goalPlaceholder = nil

local bubbles = {}

--------------------------------------------------------------------------------------------------------------
-- populate values
--------------------------------------------------------------------------------------------------------------

local function populateColorScore()
    for i, color in pairs(bubbleColors) do
        bubbleColorScore[color] = 0
    end
end

local function populateInitValues()
    populateColorScore()
end

--------------------------------------------------------------------------------------------------------------
-- graphics and animations
--------------------------------------------------------------------------------------------------------------

local function burstBubble(_bubble)
    transition.to(
        _bubble, {
            time=50, 
            delay=0,
            alpha=0,
            width=_bubble.width * 1.1,
            height=_bubble.height * 1.1,
            onComplete = function()
                _bubble:removeSelf()
            end
        }
    )
end

--------------------------------------------------------------------------------------------------------------
-- event listeners
--------------------------------------------------------------------------------------------------------------

local function onBubbleTap( event )
    print( "Tap bubble x:" .. event.target.width .. "y: " .. event.target.height)
    burstBubble(event.target)

    return true
end

local function onBubbleFinishCollision( self, event )
    if event.other ~= nil then
        if bubbleColorScore[event.other.colorTag] ~= nil then
            print ("Color ".. event.other.colorTag .. ", count: " .. bubbleColorScore[event.other.colorTag] )
            bubbleColorScore[event.other.colorTag] = bubbleColorScore[event.other.colorTag] + 1
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

    bubble.imgVersion = "v1"
    bubble.color = "blue"
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
 
    bubble.image:addEventListener( "tap", onBubbleTap)

    -- table.insert(bubble, bubbles)
end

--------------------------------------------------------------------------------------------------------------
-- scene setup
--------------------------------------------------------------------------------------------------------------

local function showBubbleColorScore()
    if #bubbleColorScore > 0 then
        for color, score in pairs(bubbleColorScore) do
            display.newText( options )
        end
    end
end

local function scaleScorePlaceholder()
    if scorePlaceholder ~= nil then 
        -- scorePlaceholder 
    end
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
    leftSideWall:setFillColor(1, 0, 0, 0)
    rightSideWall:setFillColor(1, 1, 0, 0)

    physics.addBody( leftSideWall, "static")
    physics.addBody( rightSideWall, "static")

    -- collision top wall
    topWall = display.newRect(0, 0, screenW, bubbleMinSize / 2)
    topWall.anchorX = 0
    topWall.anchorY = 0

    topWall:setFillColor(0, 0, 1, 1)

    physics.addBody( topWall, "static", { density=1.0, friction=1, bounce=0.01 , isSensor = true})

    topWall.collision = onBubbleFinishCollision
    topWall:addEventListener( "collision" )
end

local function createTopBar()

end

local function createScorePlaceholder()
    scorePlaceholder = display.newRect(0, 0, screenW / 3, 100)
    scorePlaceholder.anchorX = 0
    scorePlaceholder.anchorY = 0
    scorePlaceholder:setFillColor(0.9, 0.9, 0.9, 1)
end

local function createGoalPlaceholder()

    goalPlaceHolder = display.newRect(0, 0, screenW / 3, 100)
    goalPlaceHolder.anchorX = 1
    goalPlaceHolder.anchorY = 0
    goalPlaceHolder:setFillColor(1, 0.1, 0, 1)
end

local function setupLevel()
    physics.start()
    physics.setGravity( 0, -5)

    populateInitValues()

    createSceneInvisibleWalls()

    createTopBar()

    createScorePlaceholder()
    createGoalPlaceholder()
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