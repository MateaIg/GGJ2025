local M = {}

function M.createCustomButton(params)

    local buttonParams = {
        label = "Button",
        font = native.systemFontBold,
        fontSize = 18,
        width = 150,
        height = 50,
        labelColor = {0, 0, 0},
        fillColor = {0.8, 0.8, 0.8},
        cornerRadius = 10,
        x = 0,
        y = 0,
        onTap = function() print("Button tapped!") end
    }

    for k, v in pairs(params) do
        buttonParams[k] = v
    end

    local buttonGroup = display.newGroup()

    local background = display.newRoundedRect(0, 0, buttonParams.width, buttonParams.height, buttonParams.cornerRadius)
    background:setFillColor(unpack(buttonParams.fillColor))
    buttonGroup:insert(background)

    local label = display.newText({
        text = buttonParams.label,
        font = buttonParams.font,
        fontSize = buttonParams.fontSize,
        align = "center"
    })
    label:setFillColor(unpack(buttonParams.labelColor))
    label.x, label.y = 0, 0
    buttonGroup:insert(label)

    buttonGroup.x, buttonGroup.y = buttonParams.x, buttonParams.y

    local function onTapHandler()
        transition.to(buttonGroup, {
            time = 100,
            xScale = 0.9,
            yScale = 0.9,
            onComplete = function()
                transition.to(buttonGroup, {
                    time = 100,
                    xScale = 1,
                    yScale = 1,
                    onComplete = function()
                        buttonParams.onTap() 
                    end
                })
            end
        })
        return true
    end

    background:addEventListener("tap", onTapHandler)

    return buttonGroup
end

return M
