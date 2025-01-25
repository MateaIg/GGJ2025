-----------------------------------------------------------------------------------------
--
-- main.lua
---
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility" , "immersiveSticky" )

math.randomseed(os.time())

system.activate( "multitouch" )

introSound = audio.loadStream( "res/audio/map-background-music-v1.wav" )

popSound = {}
popSound[1] = audio.loadSound( "res/audio/bubble_pop_1.wav" )
popSound[2] = audio.loadSound( "res/audio/bubble_pop_2.wav" )
popSound[3] = audio.loadSound( "res/audio/bubble_pop_3.wav" )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )