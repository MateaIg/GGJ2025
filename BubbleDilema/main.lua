-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

local composer = require( "composer" )

local scene = composer.newScene()

local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX

local object = display.newImage( "sprites/bubble_transparent_placeholder.png")
object.name = "ball object"

object.width = 200
object.height = 200
object.x = halfW
object.y = screenH/2

local function onObjectTap( event )
    print( "Tap bubble x:" .. event.target.x .. "y: " .. event.target.y)
    return true
end

object:addEventListener( "tap", onObjectTap )