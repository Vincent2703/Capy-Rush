Notif = class("Notif")

function Notif:init(title, subtitle, colorText, colorBorder, size)
    self.title = title
    self.subtitle = subtitle
    self.text = self.title
    if subtitle ~= nil then
        self.text = self.text.."\n\n"..subtitle
    end

    self.colorText = colorText or {1, 0, 0}
    self.colorBorder = colorBorder or {1, 1, 1}
    self.size = size or 1

    self.textObject = love.graphics.newText(love.graphics.getFont(), text)
    self.borderSize = 3
    self.opacity = 1

    self.visible = false

    self.ig = gameState.states["InGame"]
end