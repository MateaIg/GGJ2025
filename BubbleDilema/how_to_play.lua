-----------------------------------------------------------------------------------------
--
-- how_to_play.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

--------------------------------------------
local widget = require "widget"
local customButton = require "custom_button"

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local mainLevelParams = {
    gameMode = 1,
}

function scene:create(event)
    local sceneGroup = self.view

    -- Add a background image
    local background = display.newImageRect(sceneGroup, "res/img/pastel_background.jpg", screenW, screenH)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert(background)

    local instructions = [[
        How to Play
    
        1. Each player gets two colors - your mission is to pop only the bubbles in your colors.
        2. The first player to pop the target number of bubbles wins!
        3. Oops! If you pop a bubble in an unassigned color, both players get +1 added to their target score (uh-oh, extra challenge!).
        ]]
    
    local instructionText = display.newText({
        text = instructions,
        x = display.contentCenterX,
        y = display.contentCenterY,
        width = display.contentWidth - 40,  -- Adjust width for wrapping
        height = 0,  -- Auto calculate height
        font = "res/fonts/lifeIsGoofy.ttf", 
        fontSize = 50
    })
    
    instructionText.anchorX = 0.5
    instructionText.anchorY = 0.5
    instructionText:setFillColor(146/255, 102/255, 138/255)
    
    sceneGroup:insert(instructionText)


    local playButton = customButton.createCustomButton({
        label = "Play",
        font = "res/fonts/lifeIsGoofy.ttf", 
        fontSize = 40,
        width = 200,
        height = 60,
        labelColor = {1, 1, 1},
        fillColor = {115/255, 144/255, 198/255},
        cornerRadius = 12,
        x = display.contentCenterX,
        y = screenH - 100,
        onTap = function()
            composer.gotoScene( "main_level", {
                params=mainLevelParams
            })
        end
    })

    sceneGroup:insert(playButton)

  
end

function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        composer.removeHidden()
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- Play background music
        audio.play(gamePlaySoundIntro, {
            channel = audio.findFreeChannel(),
            loops = 0,
            onComplete = {
                audio.play(gamePlaySoundLoop, {
                    channel = audio.findFreeChannel(),
                    loops = -1,
                }) 
            }
        }) -- Infinite loop for background music
    end
end

function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        -- Stop audio when leaving the scene
        audio.fadeOut( 1, 200 )
    elseif phase == "did" then
        -- Called when the scene is now off screen
    end
end

function scene:destroy(event)
    local sceneGroup = self.view

    -- audio.dispose()
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

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

Runtime:addEventListener("key", onKeyEvent)

-----------------------------------------------------------------------------------------

return scene
