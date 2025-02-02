local function shuffleTable(t)
    local rand = math.random 
    local shuffled = {}
    for i = #t, 1, -1 do
        local index = rand(i)
        shuffled[#shuffled + 1] = t[index]
        table.remove(t, index)
    end
    return shuffled
end

function getGameModeTarget_1()
    local bubbleColors = {"red", "blue", "orange", "green", "purple"}
    
    local shuffledColors = shuffleTable({unpack(bubbleColors)})

    return {
        bubbleGenerationTimer = 600,
        player1 = {
            name = "Player 1",
            colors = {shuffledColors[1], shuffledColors[2]},
            poppedGoal = 100,
            poppedTotal = 0,
            -- passGoal = 5,
            -- passTotal = 0
        },
        player2 = {
            name = "Player 2",
            colors = {shuffledColors[3], shuffledColors[4]},
            poppedGoal = 100,
            poppedTotal = 0,
            -- passGoal = 5,
            -- passTotal = 0
        },
        time = 60,
        modifiers = {
            burst = {
                startDelay = 15000,
                prepareInhale = 3100,
                burstDuration = 3800,
                burstCreationTimer = 80,
            },
        },
        penalize = true,
        allowPop = true,
        allowPass = true,
    }
end


return {getGameModeTarget_1 = getGameModeTarget_1}
