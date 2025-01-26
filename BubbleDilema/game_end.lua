------------------------------------------------------------------------------
-- "game_end.lua" OVERLAY
------------------------------------------------------------------------------
 
local composer = require( "composer" )
 
local scene = composer.newScene()
 
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local customButton = require "custom_button"


function scene:create( event )
    local parent = event.parent
	sceneGroup = self.view

    local modalGroup = display.newGroup()

    local backgroundColor = "blue";
    local winnerName = "Player";
	
    local params = event.params
    if params and params.winner then
        if params.winner.id then
            print("winnerID:", params.winner.id)
            winnerName = params.winner.id;
        end
        if params.winner.color then
            print("winnerID:", params.winner.color)
            backgroundColor = params.winner.color;
        end
    end

    local resultsBackground = display.newImageRect("res/img/bubble_v1_" .. backgroundColor .. "_splash.png", 0, 0 )
    resultsBackground.x = screenW / 2 ;
    resultsBackground.y = screenH / 2;
    resultsBackground.alpha = 1;

    transition.to(
        resultsBackground, {
            time=500, 
            delay=0,
            alpha=1,
            width=screenW,
            height=screenW,
            transition=easing.inSine,
        }
    )

    local winnerText = display.newText( winnerName, 0, 0, "res/fonts/lifeIsGoofy.ttf", 60 )
    winnerText.x = resultsBackground.x;
    winnerText.y = resultsBackground.y - winnerText.height; 
    winnerText:setFillColor( 1, 1, 1 )

    local wonText = display.newText( "WON", 0, 0, "res/fonts/lifeIsGoofy.ttf", 60 )
    wonText.x = resultsBackground.x;
    wonText.y = resultsBackground.y + wonText.height / 2; 
    wonText:setFillColor( 1, 1, 1 )

    local menuButton = customButton.createCustomButton({
        label = "Menu",
        font = "res/fonts/lifeIsGoofy.ttf", 
        fontSize = 40,
        width = 200,
        height = 60,
        labelColor = {1, 1, 1},
        fillColor = {115/255, 144/255, 198/255},
        cornerRadius = 12,
        x = display.contentCenterX,
        y = screenH * 0.8,
        onTap = function()
            composer.gotoScene( "menu" )
        end
    })
        
    sceneGroup:insert(resultsBackground)
    sceneGroup:insert(winnerText)
    sceneGroup:insert(wonText)
    sceneGroup:insert(menuButton) 

end


function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
 
    if ( phase == "will" ) then
        -- Call the "resumeGame()" function in the parent scene
        -- parent:resumeGame()
    end
end
 
-- By some method such as a "resume" button, hide the overlay
composer.hideOverlay( "fade", 400 )


scene:addEventListener("create", scene)
scene:addEventListener( "hide", scene )
return scene