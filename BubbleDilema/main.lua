-----------------------------------------------------------------------------------------
--
-- main.lua
---
-----------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility" , "immersiveSticky" )

math.randomseed(os.time())

system.activate( "multitouch" )

gamePlaySoundIntro = audio.loadStream( "res/audio/PoppinAround-gameplay-intro.wav" )
gamePlaySoundLoop = audio.loadStream( "res/audio/PoppinAround-gameplay-loop.wav" )

popSound = {}
popSound[1] = audio.loadSound( "res/audio/bubble_pop_1.wav" )
popSound[2] = audio.loadSound( "res/audio/bubble_pop_2.wav" )
popSound[3] = audio.loadSound( "res/audio/bubble_pop_3.wav" )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )