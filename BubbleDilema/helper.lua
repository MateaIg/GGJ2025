function createGoalPlaceholder(_display, _screenH, _screenW)
    local placeholder = {}

    placeholder = _display.newRect(_screenW, 0, _screenW / 3, 100)
    placeholder.anchorX = 1
    placeholder.anchorY = 0
    placeholder:setFillColor(0.3, 0.1, 0.1, 1)

    return placeholder
end

function createScorePlaceholder(_display, _screenH, _screenW)
    local placeholder = {}

    placeholder = _display.newRect(0, 0, _screenW / 3, 100)
    placeholder.anchorX = 0
    placeholder.anchorY = 0
    placeholder:setFillColor(0.3, 0.3, 0.9, 1)

    return placeholder
end

-- bubbleColorScore {"color" = count}
function updateColorScore(_display, _bubbleColorScore, _colorTargets) 
end

return {createGoalPlaceholder = createGoalPlaceholder, createScorePlaceholder = createScorePlaceholder }