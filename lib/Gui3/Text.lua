local Text = class("Gui3.Text", Gui3.Element)

function Text:initialize(s, x, y)
    self.s = s
    
    Gui3.Element.initialize(self, x, y, #self.s*8, 8)
end

function Text:setString(s)
    self.s = s
end

function Text:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)
    
    fontOutlined:print(self.s, 0, 0)

    Gui3.Element.unTranslate(self)
end

return Text
