local Gui3 = ...
Gui3.SubDraw = class("Gui3.SubDraw", Gui3.Element)

function Gui3.SubDraw:initialize(func, x, y, w, h)
    self.func = func
    self.w = w
    self.h = h

    Gui3.Element.initialize(self, x, y, self.w, self.h)
end

function Gui3.SubDraw:draw()
    self.func()

    Gui3.Element.draw(self)
end
