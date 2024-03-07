Utils = class("Utils")

function Utils:getTextHeight(text, width)
    local font = love.graphics.getFont()
    local _, wrappedText = font:getWrap(text, width)
    local totalTextHeight = #wrappedText * font:getHeight()*font:getLineHeight()
    local spacing = 5
    return totalTextHeight + spacing
end

function Utils:printCtrTxtWScl(text, y, scale)
    scale = scale or 1
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text) * scale
    local centerX = math.ceil((widthWindow - textWidth)/2)

    love.graphics.print(text, centerX, y, 0, scale)
end

function Utils:weightedRandom(table) --Must have a proba key
    local poolsize = 0
    for _, v in pairs(table) do
        poolsize = poolsize + v.proba
    end
    local selection = math.random(1, poolsize)
    for _, v in pairs(table) do
        selection = selection - v.proba
        if (selection <= 0) then
            return v
        end
    end
end

function Utils:round(val)
    return math.ceil(val-0.5)
end