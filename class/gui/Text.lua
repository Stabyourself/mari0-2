local Text = class("GUI.Text")

function Text:initialize(s, x, y)
    self.s = s
    self.x = x
    self.y = y
end

function Text:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    marioPrint(self.s, 0, 0)

    love.graphics.pop()
end

return Text
