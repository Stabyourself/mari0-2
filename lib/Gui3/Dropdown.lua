local Gui3 = ...
Gui3.Dropdown = class("Gui3.Dropdown", Gui3.Element)

function Gui3.Dropdown:initialize(x, y, s, boxCanvas)
    self.button = Gui3.TextButton:new(0, 0, s, false, 3, function() self:toggle() end)
    self.button.color.normal = {1, 1, 1, 0}

    self.box = Gui3.Box:new(x, y+14, 50, 100)
    self.box.background = {255, 255, 255}
    self.box.visible = false

    Gui3.Element.initialize(self, x, y, self.button.w, self.button.h)

    self:addChild(self.button)
    boxCanvas:addChild(self.box)
end

function Gui3.Dropdown:onAssign()
    self.button.gui = self.gui
    self.box.gui = self.gui
end

function Gui3.Dropdown:toggle(status)
    self.box.visible = status or not self.box.visible

    if self.box.visible then
        self.box:moveToFront()
    end
    self.box:updateRender()

    self.box:mouseRegionChanged()
end

function Gui3.Dropdown:mousepressed(x, y, button)
    Gui3.Element.mousepressed(self, x, y, button)

    return toReturn
end

function Gui3.Dropdown:autoSize()
    self.box:autoSize()

    for _, child in ipairs(self.box.children) do
        child.w = self.box.childBox[3]
        child:sizeChanged()
    end
end
