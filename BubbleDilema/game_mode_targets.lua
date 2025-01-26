
function getGameModeTarget_1()
    return {
        player1 = {
            name = "Player 1",
            colors = {"red", "blue"}, -- "orange"
            poppedGoal = 5,
            poppedTotal = 0,
            -- passGoal = 5,
            -- passTotal = 0
        },
        player2 = {
            name = "Player 2",
            colors = {"green", "purple"},
            poppedGoal = 5,
            poppedTotal = 0,
            -- passGoal = 5,
            -- passTotal = 0
        },
        time = 60,
        modifiers = {
        },
        penalize = true,
        allowPop = true,
        allowPass = true,
    }
end


return {getGameModeTarget_1 = getGameModeTarget_1}
