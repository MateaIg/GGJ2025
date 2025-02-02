function createGoalPlaceholder(_display, _screenH, _screenW)
    local placeholder = {}

    placeholder = _display.newRect(_screenW, 0, _screenW / 3, 100)
    placeholder.anchorX = 1
    placeholder.anchorY = 0
    placeholder:setFillColor(0.5, 0.3, 0.3, 1)

    return placeholder
end

function createPlayer1Status(_display, _screenH, _screenW, _gameModeTarget)
    local placeholder = {}

    placeholder = _display.newRect(0, 0, _screenW / 3, 100)
    placeholder.anchorX = 0
    placeholder.anchorY = 0
    placeholder:setFillColor(0.5,0.5,0.5, 1)

    local playerNameText = display.newText({
        text = _gameModeTarget.player1.name,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 40,
        align = "center"
    })
    playerNameText.x = 50;
    playerNameText.y = 40;

    local goalColor1 = _display.newImageRect("res/img/bubble_v2_" .. _gameModeTarget.player1.colors[1] .. ".png", 40, 40)
    goalColor1.x = 30;
    goalColor1.y = 80;

    local goalColor2 = _display.newImageRect("res/img/bubble_v3_" .. _gameModeTarget.player1.colors[2] .. ".png", 40, 40)
    goalColor2.x = 30;
    goalColor2.y = 135;

    local scoreText = _display.newText({
        text = _gameModeTarget.player1.poppedGoal - _gameModeTarget.player1.poppedTotal,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 60,
        align = "center"
    })
    scoreText.x = 88;
    scoreText.y = 110;

    local player1StatusGroup = _display.newGroup()
    player1StatusGroup:insert( placeholder )
    player1StatusGroup:insert( playerNameText )
    player1StatusGroup:insert( goalColor1 )
    player1StatusGroup:insert( goalColor2 )
    player1StatusGroup:insert( scoreText )

    return player1StatusGroup, scoreText
end

function createPlayer2Status(_display, _screenH, _screenW, _gameModeTarget)
    local placeholder = {}

    placeholder = _display.newRect(0, 0, _screenW / 3, 100)
    placeholder.anchorX = 0
    placeholder.anchorY = 0
    placeholder:setFillColor(0.5,0.5,0.5, 1)

    local playerNameText = display.newText({
        text = _gameModeTarget.player1.name,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 40,
        align = "center"
    })
    playerNameText.x = 50;
    playerNameText.y = 40;

    local goalColor1 = _display.newImageRect("res/img/bubble_v3_" .. _gameModeTarget.player2.colors[1] .. ".png", 40, 40)
    goalColor1.x = 30;
    goalColor1.y = 80;

    local goalColor2 = _display.newImageRect("res/img/bubble_v1_" .. _gameModeTarget.player2.colors[2] .. ".png", 40, 40)
    goalColor2.x = 30;
    goalColor2.y = 135;

    local scoreText = _display.newText({
        text = _gameModeTarget.player2.poppedGoal - _gameModeTarget.player2.poppedTotal,
        font = "res/fonts/lifeIsGoofy.ttf",
        fontSize = 60,
        align = "center"
    })
    scoreText.x = 88;
    scoreText.y = 110;

    local player2StatusGroup = _display.newGroup()
    player2StatusGroup:insert( placeholder )
    player2StatusGroup:insert( playerNameText )
    player2StatusGroup:insert( goalColor1 )
    player2StatusGroup:insert( goalColor2 )
    player2StatusGroup:insert( scoreText )

    return player2StatusGroup, scoreText
end

function createScorePlaceholder(_display, _screenH, _screenW)
    local placeholder = {}

    placeholder = _display.newRect(0, 0, _screenW / 3, 100)
    placeholder.anchorX = 0
    placeholder.anchorY = 0
    placeholder:setFillColor(0.9,0.9,0.9, 1)

    return placeholder
end

-- bubbleColorScore {"color" = count}; colorTargets 
function updateColorScore(_display, _bubbleColorScore, _levelTarget)
    
end

function createCharacterBurstAnimation(_character)
    -- local placeholder = {}

    -- placeholder = _display.newRect(0, 0, _screenW / 3, 100)
    -- placeholder.anchorX = 0
    -- placeholder.anchorY = 0
    -- placeholder:setFillColor(0.9,0.9,0.9, 1)

    -- return placeholder
end


return {createGoalPlaceholder = createGoalPlaceholder, createScorePlaceholder = createScorePlaceholder, createPlayer1Status = createPlayer1Status }