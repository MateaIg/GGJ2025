-----------------------------------------------------------------------------------------
--
-- main_gameMode.lua
--
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local math = require("math")
local physics = require("physics")

local helper = require "helper"
local characterHelper = require "character_helper"

local gameModeTargetUtility = require "game_mode_targets"

math.randomseed(os.time())
-- display.setDefault( "background", 1,1,1)

local g_GameMode = 1

local scene = composer.newScene()
local sceneGroup = {}
local gameGroup = display.newGroup()

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local playableGameArea = { 
    startX =  0,
    startY = 0,
    endX = screenW,
    endY = 0
}
local pointZones = {
    -- begin y, end y, modifier
    {beginY = 0, endY =  0, points = 3},
    {beginY = 0, endY =  0, points = 3},
    {beginY = 0, endY =  0, points = 3}
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

local currentBubbleCreationTimerDuration = nil
local bubbleCreationTimer = nil

local isFirstBurst = true
local isFirstClouds = true

local latestPoppedBubble = nil -- {color, position x, position y, time}
local latestPassedBubble = nil -- {color, time}

local character1 = nil
local character2 = nil

local player1Score = nil
local player2Score = nil

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
-- end game and gameplay bubble events
--------------------------------------------------------------------------------------------------------------
local function endGame(_gameStatus)

    if g_GameMode == 1 then
        if _gameStatus.win then
            local options = {
                isModal = true,
                effect = "fade",
                time = 400,
                params = {
                    winner = {
                        id = _gameStatus.playerName,
                        color = _gameStatus.color,
                    }
                }
            }
            composer.showOverlay( "game_end", options )
        end
    end
end

local function updateResults()
    if g_GameMode == 1 then
        player1Score.text = gameModeTarget.player1.poppedGoal - gameModeTarget.player1.poppedTotal
        player2Score.text = gameModeTarget.player2.poppedGoal - gameModeTarget.player2.poppedTotal

        -- todo: popped results are written into score bar
        print(gameModeTarget.player1.name .. " popped: " .. gameModeTarget.player1.poppedTotal .. "needs: " .. gameModeTarget.player1.poppedGoal)
        print(gameModeTarget.player2.name .. " popped: " .. gameModeTarget.player2.poppedTotal .. "needs: " .. gameModeTarget.player2.poppedGoal)
    end
end

local function getPopPoints (_bubble)
    local zone1 = (screenH - playableGameArea.startY) / 3
    local zone2 = zone1 * 2
    local zone3 = playableGameArea.endY

    zone1 = zone1 + playableGameArea.startY
    zone2 = zone2 + playableGameArea.startY

    local bubblePositionY = _bubble.y - _bubble.height * 0.5 -- hack modify size a bit

    if bubblePositionY < zone1 then
        points = 3
    elseif bubblePositionY < zone2 then
        points =  2
    else
        points = 1
    end

    print("Points: " .. points)

    return points
end

local function popBubble(_bubble)
    audio.play(popSound[math.random(1, 3)], {
    channel = audio.findFreeChannel(),
    loops = 0,
    });

    local points = 0

    if poppedBubblesScore[_bubble.bubbleInfo.color] then
        poppedBubblesScore[_bubble.bubbleInfo.color] = poppedBubblesScore[_bubble.bubbleInfo.color] + getPopPoints(_bubble)
        print ("Popped " .. _bubble.bubbleInfo.color .. " bubbles: " ..  poppedBubblesScore[_bubble.bubbleInfo.color])

        if g_GameMode == 1 then
            local gameStatus = nil
            points = getPopPoints(_bubble)

            if table.indexOf(gameModeTarget.player1.colors, _bubble.bubbleInfo.color) ~= nil then
                gameModeTarget.player1.poppedTotal = gameModeTarget.player1.poppedTotal + points
                if gameModeTarget.player1.poppedTotal >= gameModeTarget.player1.poppedGoal then
                    gameStatus = {
                        win = true,
                        playerName = gameModeTarget.player1.name,
                        color = _bubble.bubbleInfo.color
                    }
                end
            elseif table.indexOf(gameModeTarget.player2.colors, _bubble.bubbleInfo.color) ~= nil then
                gameModeTarget.player2.poppedTotal =  gameModeTarget.player2.poppedTotal + points
                if gameModeTarget.player2.poppedTotal >=  gameModeTarget.player2.poppedGoal then
                    gameStatus = {
                        win = true,
                        playerName = gameModeTarget.player2.name,
                        color = _bubble.bubbleInfo.color
                    }
                end
            elseif gameModeTarget.penlize == true then
                points = -1
                gameModeTarget.player1.poppedTotal = gameModeTarget.player1.poppedTotal + 1
                gameModeTarget.player2.poppedTotal = gameModeTarget.player2.poppedTotal + 1
            end

            if gameStatus then
                endGame(gameStatus)
            else
                updateResults()
            end
        end
    end

    return points
end

local function onBubbleTap( event )
    if ( event.phase == "began" ) then
        local points = popBubble(event.target)

        -- point modifier text
        local pointPopupText = ""
        if points > 0 then
            pointPopupText = "+" .. points
        else
            pointPopupText = "-" .. points
        end
        
        pointPopup = display.newText({
            text = pointPopupText,
            x = event.target.x + event.target.width / 2,
            y = event.target.y - event.target.height / 2,
            width = event.target.width,  -- Adjust width for wrapping
            height = 0,  -- Auto calculate height
            font = "res/fonts/lifeIsGoofy.ttf", 
            fontSize = 100
        })

        transition.to(
            pointPopup, {
                time = 400, 
                delay = 0,
                alpha = 0,
                width = pointPopup.width ,
                height = pointPopup.height,
                onComplete = function()
                    if pointPopup ~= nil then
                        pointPopup:removeSelf()
                    end
                end
            })

        transition.to(
            event.target, {
                time=75, 
                delay=0,
                alpha=0,
                width=event.target.width * 1.1,
                height=event.target.height * 1.1,
                onComplete = function()
                    if event.target ~= nil then
                        event.target:removeSelf()
                    end
                end
            })
    end

    return true
end

local function onBubbleFinishCollision( self, event )
    if event.other ~= nil then
        if finishedBubblesScore[event.other.bubbleInfo.color] ~= nil then
            finishedBubblesScore[event.other.bubbleInfo.color] = finishedBubblesScore[event.other.bubbleInfo.color] + 1
            -- print ("Color ".. event.other.bubbleInfo.color .. ", count: " .. finishedBubblesScore[event.other.bubbleInfo.color] )
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
 
    gameGroup:insert(bubble)

    bubble:toBack()

    bubble:addEventListener( "touch", onBubbleTap)
end


local function setBubbleCreationTimer()
    if bubbleCreationTimer then
        timer.cancel(bubbleCreationTimer)
    end

    bubbleCreationTimer = timer.performWithDelay(currentBubbleCreationTimerDuration, createBubble ,0)
end

local function stopBurstEvent()
    print("Burst ended")
    currentBubbleCreationTimerDuration = gameModeTarget.bubbleGenerationTimer

    setBubbleCreationTimer()
end

local function startBurstEvent()
    print ("Start bursting!!")
    currentBubbleCreationTimerDuration = gameModeTarget.modifiers.burst.burstCreationTimer

    setBubbleCreationTimer()

    timer.performWithDelay( gameModeTarget.modifiers.burst.burstDuration, stopBurstEvent, 1)
end

local function  startBubbleBurstSequence()
    if isFirstBurst then
        -- pause and show event info!
        isFirstBurst = false
    end

    -- todo: play sound

    -- start animation

    -- start timer till burst
    timer.performWithDelay( gameModeTarget.modifiers.burst.prepareInhale, startBurstEvent, 1)
end

--------------------------------------------------------------------------------------------------------------
-- end game
--------------------------------------------------------------------------------------------------------------

local function endGameModeScene()
    -- composer.removeScene( "main_menu", false )
    audio.stop()
    composer.gotoScene( "menu" )
end


--------------------------------------------------------------------------------------------------------------
-- scene setup
--------------------------------------------------------------------------------------------------------------

local function addScoreLabels(_gameModeTarget)
    local playerNameText = display.newText({
        text = _gameModeTarget.player1.name,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 40,
        align = "center"
    })
    playerNameText.x = 60;
    playerNameText.y = 30;
    playerNameText:setFillColor(146/255, 102/255, 138/255)

    local goalColor1 = display.newImageRect("res/img/bubble_v2_" .. _gameModeTarget.player1.colors[1] .. ".png", 40, 40)
    goalColor1.x = 30;
    goalColor1.y = 80;

    local goalColor2 = display.newImageRect("res/img/bubble_v3_" .. _gameModeTarget.player1.colors[2] .. ".png", 40, 40)
    goalColor2.x = 30;
    goalColor2.y = 135;

    player1Score = display.newText({
        text = _gameModeTarget.player1.poppedGoal - _gameModeTarget.player1.poppedTotal,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 60,
        align = "center"
    })
   player1Score.x = 88;
   player1Score.y = 110;
   player1Score:setFillColor(146/255, 102/255, 138/255)

    
   local playerNameText2 = display.newText({
    text = _gameModeTarget.player2.name,
    font = "res/fonts/lifeIsGoofy.ttf",
    fontSize = 40,
    align = "center"
    })
    playerNameText2.x = screenW - 60;
    playerNameText2.y = 30;
    playerNameText2:setFillColor(146/255, 102/255, 138/255)

    local goalColor12 = display.newImageRect("res/img/bubble_v2_" .. _gameModeTarget.player2.colors[1] .. ".png", 40, 40)
    goalColor12.x = screenW - 30;
    goalColor12.y = 80;

    local goalColor22 = display.newImageRect("res/img/bubble_v3_" .. _gameModeTarget.player2.colors[2] .. ".png", 40, 40)
    goalColor22.x = screenW - 30;
    goalColor22.y = 135;

    player2Score = display.newText({
        text = _gameModeTarget.player2.poppedGoal - _gameModeTarget.player2.poppedTotal,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 60,
        align = "center"
    })
    player2Score.x = screenW - 88;
    player2Score.y = 110;
    player2Score:setFillColor(146/255, 102/255, 138/255)

    gameGroup:insert(playerNameText)
    gameGroup:insert(goalColor1)
    gameGroup:insert(goalColor2)
    gameGroup:insert(player1Score)

    gameGroup:insert(playerNameText2)
    gameGroup:insert(goalColor12)
    gameGroup:insert(goalColor22)
    gameGroup:insert(player2Score)


end



local function showFinishedBubblesScore()
    if #finishedBubblesScore > 0 then
        for color, score in pairs(finishedBubblesScore) do

        end
    end
end

local function createTopFunnel(_gameMode)
    local triangleW = screenW / 3
    local triangleH = screenH / 6

    local leftTriangleShape = { 0, 0, triangleW, 0, 0, triangleH }
    local rightTriangleShape = {0, 0, 0, -triangleH, -triangleW, -triangleH}

    local leftTopWall = display.newMesh( { 
        x = playableGameArea.startX,
        -- x = 0,
        y = playableGameArea.startY,
        -- y = 0,
        mode = "indexed", 
        vertices = leftTriangleShape,
        indices = {1, 2, 3}
    })
    leftTopWall:setFillColor(1, 0.5, 0.5, 1)
    leftTopWall:translate( leftTopWall.path:getVertexOffset() )

    local leftCollisionShape = {}
    for i, value in pairs(leftTriangleShape) do 
        if i % 2 == 1 then
            leftCollisionShape[i] = value - triangleW / 2
        else
            leftCollisionShape[i] = value - triangleH / 2
        end
    end

    physics.addBody( leftTopWall , "static", {shape = leftCollisionShape})

    local rightTopWall = display.newMesh( {
        x = playableGameArea.endX,
        -- x = screenW,
        y = playableGameArea.startY,
        -- y = 0,
        mode = "indexed",
        vertices = rightTriangleShape, 
        indices = {1, 2, 3}
    })

    rightTopWall:setFillColor(0.5, 0.5, 1, 1)
    rightTopWall:translate( -triangleW/2, triangleH/2)

    local rightCollisionShape = {}
    for i, value in pairs(rightTriangleShape) do 
        if i % 2 == 1 then
            rightCollisionShape[i] = value + triangleW / 2
        else
            rightCollisionShape[i] = value + triangleH / 2
        end
    end

    physics.addBody( rightTopWall , "static" , {shape = rightCollisionShape})

    gameGroup:insert( leftTopWall )
    gameGroup:insert( rightTopWall )
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

        gameGroup:insert( leftSideWall )
        gameGroup:insert( rightSideWall )
    end
end

local function createFinishDetector(_gameMode)
    -- collision top wall
    finishDetector = display.newRect(playableGameArea.startX, playableGameArea.startY, playableGameArea.endX - playableGameArea.startX, playableGameArea.startY)
    finishDetector.anchorX = 0
    finishDetector.anchorY = 1

    finishDetector:setFillColor(0, 0, 1, 0)

    physics.addBody( finishDetector, "static", { density=1.0, friction=1, bounce=0.01 , isSensor = true})

    finishDetector.collision = onBubbleFinishCollision
    finishDetector:addEventListener( "collision" )

    gameGroup:insert(finishDetector)
end

local function createZoneDividers()
    -- local zone1 = (screenH - playableGameArea.startY) / 3
    -- local zone2 = zone1 * 2
    -- local zone3 = playableGameArea.endY

    local zone1 = (screenH - playableGameArea.startY) / 3
    local zone2 = zone1 * 2
    local zone3 = playableGameArea.endY

    zone1 = zone1 + playableGameArea.startY
    zone2 = zone2 + playableGameArea.startY


    local zoneRect1 = display.newRect( playableGameArea.startX, zone1, playableGameArea.endX - playableGameArea.startX, 5 )
    zoneRect1.anchorX = 0
    zoneRect1.anchorY = 0
    
    zoneRect1:setFillColor(0.2, 0.2, 1, 0.5)

    local zoneRect2 = display.newRect( playableGameArea.startX, zone2,  playableGameArea.endX - playableGameArea.startX, 5 )
    zoneRect2.anchorX = 0
    zoneRect2.anchorY = 0

    zoneRect2:setFillColor(0.2, 1, 0.1, 0.5)

    -- todo: add to backgroud scene group
end

local function createCloudObstacle()
    local cloudW = screenW * 2
    local cloudH = screenH / 2
    local cloudX = screenW / 2
    local cloudY = screenH / 2

    local cloud = display.newImageRect( "res/img/cloud_obstacle.png", cloudW, cloudH )
    cloud.alpha = 0
    cloud.x = cloudX
    cloud.y = cloudY
    cloud:toFront()

    transition.to(
        cloud, {
            time=2000, 
            delay=0,
            alpha=1,
            onComplete = function()
            end
        }
    )

    gameGroup:insert(cloud)
end


local function setPlayableArea(_gameMode)

    if _gameMode == 1 then
        playableGameArea.startX = - bubbleMinSize 
        playableGameArea.endX =  screenW + bubbleMinSize

        playableGameArea.startY = screenH / 11
        playableGameArea.endY = bubbleGenerationBeginY
    end
end

local function setGameModeTarget(_gameMode)
    if _gameMode == 1 then -- multiplayer game where Player 1 and Player 2 each needs to pop their own bubble color type with special modifiers: cloud obfuscate, bubble craze!
        gameModeTarget = {}
        finishedBubblesScore = {}
        poppedBubblesScore = {}

        gameModeTarget = gameModeTargetUtility.getGameModeTarget_1(bubbleColors)

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
        
        currentBubbleCreationTimerDuration = gameModeTarget.bubbleGenerationTimer
        
        setBubbleCreationTimer()

        timer.performWithDelay(gameModeTarget.modifiers.burst.startDelay, startBubbleBurstSequence, 0)
    end
end

local function createTopBar()
    topBar = display.newImageRect( "res/img/oblaci.png", screenW, screenH)
    topBar.x = display.contentCenterX
    topBar.y = display.contentCenterY

    gameGroup:insert(topBar)
end

local function setupGameMode(_gameMode)
    setGameModeTarget(_gameMode)

    populateInitValues(_gameMode)

    setPlayableArea(_gameMode)

    createSceneWalls(_gameMode)
    createFinishDetector(_gameMode)
    createTopFunnel(_gameMode)
    createZoneDividers()
    createTopBar()
    addScoreLabels(gameModeTarget)

    -- scorePlaceholder = helper.createScorePlaceholder(display, screenH, screenW)
    -- gameGroup:insert(scorePlaceholder)
    -- goalPlaceHolder = helper.createGoalPlaceholder(display, screenH, screenW)
    -- gameGroup:insert(goalPlaceHolder)

    setGameModeSpecificModifiers(_gameMode)
end

local function gameLoop()
    if bubblePopped then
    
        bubblePopped = false
    end

    if bubblePassed then
    
        bubblePassed = false
    end
end

--------------------------------------------------------------------------------------------------------------
-- scene interface functions
--------------------------------------------------------------------------------------------------------------

-- Listen for the "key" event to handle back button presses
local function onKeyEvent(event)
    if event.keyName == "back" then
        if event.phase == "down" then
            audio.stop()
            composer.gotoScene("menu")
            return true
        end
    end
end

function scene:create( event )
	sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "res/img/pastel_background.jpg", screenW, screenH)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert(background)
    
    character1 = characterHelper.character1Create(sceneGroup, screenW, screenH)
    character2 = characterHelper.character2Create(sceneGroup, screenW, screenH)
    
    sceneGroup:insert(character1)
    sceneGroup:insert(character2)

    sceneGroup:insert(gameGroup)
    background:toBack()

    -- print("-------------------------");
    -- print(event.params.gameMode);
end

function scene:show( event )
	sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
        Runtime:addEventListener("key", onKeyEvent)
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen

        audio.play(gamePlaySoundIntro, {
            channel = audio.findFreeChannel(),
            loops = 0,
            onComplete = function()
                audio.play(gamePlaySoundLoop, {
                    channel = audio.findFreeChannel(),
                    loops = -1,
                })
            end
        })

        physics.start()
        physics.setGravity( 0, -5)
        -- physics.setDrawMode("hybrid")

        setupGameMode(g_GameMode)
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
Runtime:addEventListener("enterFrame", gameLoop)


return scene