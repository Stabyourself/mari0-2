local Canvas = class("GUI.Canvas", GUI.Element)

function Canvas:initialize(gui, x, y, w, h)
    self.gui = gui
    
    GUI.Element.initialize(self, x, y, w, h)
    
    self.children = {}
    self.backgroundColor = {0, 0, 0, 0}
end

function Canvas:draw(level)
    GUI.Element.translate(self)
    GUI.Element.stencil(self, level, true)
    
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.w, self.h)
    
    GUI.Element.draw(self, level)
    
    GUI.Element.unStencil(self, level)
    GUI.Element.unTranslate(self)
end
    
return Canvas
