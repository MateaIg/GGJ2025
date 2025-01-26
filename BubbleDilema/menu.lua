-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

--------------------------------------------
local widget = require "widget"
local customButton = require "custom_button"

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

function scene:create(event)
    local sceneGroup = self.view

    -- Add a background image
    local background = display.newImageRect(sceneGroup, "res/img/pastel_background.jpg", screenW, screenH)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    sceneGroup:insert(background)

    local character1 = display.newImageRect(sceneGroup, "res/img/lik.png", screenH * 0.43, screenH * 0.43 * 1.1)
    character1.x = display.contentCenterX / 2
    character1.y = display.contentCenterY

    sceneGroup:insert(character1)

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
            composer.gotoScene( "main_level" )
        end
    })

    sceneGroup:insert(playButton)

    local soundOnIcon = "res/img/sound_on.png"
    local soundOffIcon = "res/img/sound_off.png"

    local soundButton
    local function toggleSound()
        if soundIsOn then
            audio.pause(introSound)
            soundButton:removeSelf()
            soundButton = widget.newButton({
                defaultFile = soundOffIcon,
                width = 50,
                height = 50,
                onRelease = toggleSound,
            })
            soundButton.x = display.contentWidth - 40
            soundButton.y = 40
            sceneGroup:insert(soundButton)
        else
            audio.resume(introSound)
            soundButton:removeSelf()
            soundButton = widget.newButton({
                defaultFile = soundOnIcon,
                width = 50,
                height = 50,
                onRelease = toggleSound,
            })
            soundButton.x = display.contentWidth - 40
            soundButton.y = 40
            sceneGroup:insert(soundButton)
        end
        soundIsOn = not soundIsOn
    end

    soundButton = widget.newButton({
        defaultFile = soundOnIcon,
        width = 50,
        height = 50,
        onRelease = toggleSound,
    })
    soundButton.x = display.contentWidth - 40
    soundButton.y = 40
    sceneGroup:insert(soundButton)

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
        audio.play(introSound, {
            channel = 1,
            loops = -1
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

    -- Remove and dispose of the audio when the scene is destroyed
    if introSound then
        audio.dispose(introSound)
        introSound = nil
    end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-----------------------------------------------------------------------------------------

return scene
