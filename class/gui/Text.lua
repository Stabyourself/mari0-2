local Text = class("GUI.Text", GUI.Element)

function Text:initialize(s, x, y)
    self.s = s
    
    GUI.Element.initialize(self, x, y, #self.s*8, 8)
end

function Text:setString(s)
    self.s = s
    self.w = #self.s*8
end

function Text:draw(level)
    GUI.Element.translate(self)
    GUI.Element.stencil(self, level)
    
    GUI.Element.draw(self, level)
    
    marioPrint(self.s, 0, 0)

    GUI.Element.unStencil(self, level)
    GUI.Element.unTranslate(self)
end

return Text
