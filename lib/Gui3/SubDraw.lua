local Gui3 = ...
Gui3.SubDraw = class("Gui3.SubDraw", Gui3.Element)

function Gui3.SubDraw:initialize(func, x, y, w, h)
    self.func = func
    self.w = w or 0
    self.h = h or 0

    Gui3.Element.initialize(self, x, y, self.w, self.h)
end

function Gui3.SubDraw:draw(level)
    Gui3.Element.translate(self)
    
    Gui3.Element.draw(self, level)
    
    self.func()

    Gui3.Element.unTranslate(self)
end
