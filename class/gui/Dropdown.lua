local Dropdown = class("GUI.Dropdown", GUI.Element)

Dropdown.noClip = true

function Dropdown:initialize(x, y, s)
    self.button = GUI.Button:new(0, 0, s, false, 3, function() self:toggle() end)
    self.button.color.normal = {1, 1, 1, 0}
    
    self.box = GUI.Box:new(0, 14, 50, 100)
    self.box.background = {255, 255, 255}
    self.box.visible = false
    
    GUI.Element.initialize(self, x, y, #s*8, 8)
    
    self:addChild(self.button)
    self:addChild(self.box)
end

function Dropdown:onAssign()
    self.button.gui = self.gui
    self.box.gui = self.gui
end

function Dropdown:draw(level)
    GUI.Element.translate(self)
    
    GUI.Element.draw(self, level)

    GUI.Element.unTranslate(self)
end

function Dropdown:toggle(status)
    self.box.visible = status or not self.box.visible
end

function Dropdown:mousepressed(x, y, button)
    if not GUI.Element.mousepressed(self, x, y, button) then
        self.box.visible = false
    end
end

function Dropdown:autoSize()
    self.box:autoSize()
    
    for _, v in ipairs(self.box.children) do
        v.w = self.box.childBox[3]
    end
end

return Dropdown
