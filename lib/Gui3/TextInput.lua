local Gui3 = ...
Gui3.TextInput = class("Gui3.TextInput", Gui3.Element)

Gui3.TextInput.padding = 0

function Gui3.TextInput:initialize(x, y, w, lines)
    x = x or 0
    y = y or 0
    self.charW = w
    self.lines = lines or 1

    self.text = love.graphics.newText(fontOutlined, "")

    self.scroll = {0, 0}
    self.cursorPos = 0
    self.focus = false

    Gui3.Element.initialize(self, x, y, self.charW*8+2+Gui3.TextInput.padding*2, self.lines*8+2+Gui3.TextInput.padding*2)
end

function Gui3.TextInput:draw()
    Gui3.Element.draw(self)

    love.graphics.rectangle("line", 0.5, 0.5, self.charW*8+1+Gui3.TextInput.padding*2, self.lines*8+1+Gui3.TextInput.padding*2)

    love.graphics.push()
    love.graphics.translate(Gui3.TextInput.padding, Gui3.TextInput.padding)
    love.graphics.draw(self.text, 1, 1)
    love.graphics.pop()
end

function Gui3.TextInput:mousepressed(x, y, button)
    self.focus = true
end

return Gui3.TextInput
