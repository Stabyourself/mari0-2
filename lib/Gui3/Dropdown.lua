local Gui3 = ...
Gui3.Dropdown = class("Gui3.Dropdown", Gui3.Element)

function Gui3.Dropdown:initialize(x, y, s)
    self.button = Gui3.Button:new(0, 0, s, false, 3, function() self:toggle() end)
    self.button.color.normal = {1, 1, 1, 0}

    self.box = Gui3.Box:new(0, 14, 50, 100)
    self.box.background = {255, 255, 255}
    self.box.visible = false

    Gui3.Element.initialize(self, x, y, #s*8, 8)

    self:addChild(self.button)
    self:addChild(self.box)
end

function Gui3.Dropdown:onAssign()
    self.button.gui = self.gui
    self.box.gui = self.gui
end

function Gui3.Dropdown:draw(level)
    Gui3.Element.translate(self)

    Gui3.Element.draw(self, level)

    Gui3.Element.unTranslate(self)
end

function Gui3.Dropdown:toggle(status)
    self.box.visible = status or not self.box.visible
end

function Gui3.Dropdown:mousepressed(x, y, button)
    local toReturn = Gui3.Element.mousepressed(self, x, y, button)
    if not toReturn then
        self.box.visible = false
    end

    return toReturn
end

function Gui3.Dropdown:autoSize()
    self.box:autoSize()

    for _, child in ipairs(self.box.children) do
        child.w = self.box.childBox[3]
    end
end
