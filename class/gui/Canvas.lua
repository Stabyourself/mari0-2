local Canvas = class("GUI.Canvas", GUI.Element)

function Canvas:initialize(x, y, w, h)
    GUI.Element.initialize(self, x, y, w, h)
    
    self.children = {}
    self.background = {0, 0, 0, 0}
end

function Canvas:draw(level)
    GUI.Element.translate(self)
    
    love.graphics.setColor(self.background)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unTranslate(self)
end
    
return Canvas
