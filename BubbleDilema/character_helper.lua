
function character1Create(_display, _screenW, _screenH)
    local character1 = display.newImageRect(_display, "res/img/character1_back.png", _screenW * 0.28, (_screenW * 0.28) * 1.5)
    character1.x = _screenW * 0.18
    character1.y = _screenH * 1.05
    character1.anchorY = 1
    character1.id = 1;
    character1:rotate(-20)

    -- characterAnimate(character1)

    return character1
end

function character2Create(_display, _screenW, _screenH)
    local character2 = display.newImageRect(_display, "res/img/character2_back.png", _screenW * 0.28, (_screenW * 0.28) * 1.5)
    character2.x = _screenW * 0.8
    character2.y = _screenH * 1.05
    character2.anchorY = 1
    character2.id = 2;
    character2:rotate(20)

    -- characterAnimate(character2)

    return character2
end

function characterAnimate(_character)
    local finalRotation = 0

    if (_character.id == 1) then
        finalRotation = -20
    else
        finalRotation = 20
    end
    -- Animation parameters
    local originalXScale = _character.xScale
    local originalYScale = _character.yScale
    local enlargedScale = originalXScale * 1.5 -- Increase size by 50%
    local growTime = 3000                      -- Time to grow (ms)
    local shrinkTime = 4000                    -- Time to shrink and tilt (ms)
    local rotations = 40                       -- Number of rotations during shrink phase
    local singleRotationTime = shrinkTime / (rotations * 2) -- Time per tilt (up and back)

    -- Step 1: Enlarge the character
    transition.to(_character, {
        time = growTime,
        xScale = enlargedScale,
        yScale = enlargedScale,
        onComplete = function()
            -- Step 2: Shrink and tilt during the shrink phase
            transition.to(_character, {
                time = shrinkTime,
                xScale = originalXScale,
                yScale = originalYScale,
                rotation = finalRotation, -- Use the finalRotation argument here
            })

            -- Start the tilting effect
            local function tiltCharacter(rotationAngle)
                transition.to(_character, {
                    time = singleRotationTime,
                    rotation = rotationAngle,
                    onComplete = function()
                        -- Return to the provided final rotation during tilting
                        transition.to(_character, {
                            time = singleRotationTime,
                            rotation = finalRotation, -- Reset to finalRotation
                            onComplete = function()
                                rotations = rotations - 1
                                if rotations > 0 then
                                    tiltCharacter(rotationAngle * -1) -- Alternate direction
                                end
                            end
                        })
                    end
                })
            end

            tiltCharacter(5) -- Initial tilt angle during the shrink phase
        end
    })
end

return {
    character1Create = character1Create, 
    character2Create = character2Create, 
    characterAnimate = characterAnimate,
 }