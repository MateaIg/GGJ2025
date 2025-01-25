-----------------------------------------------------------------------------------------
--
-- main.lua
---
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

math.randomseed(os.time())

introSound = audio.loadStream( "res/audio/map-background-music-v1.wav" )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "main_level_playground" )